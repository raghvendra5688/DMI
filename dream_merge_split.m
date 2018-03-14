addpath('Evaluation_Metrics/conductance');
addpath('Evaluation_Metrics/graph_metrics');
warning('off');

location = 'Louvain_Results';
filename = '6_homology_anonym_v2';
[flag,filename] = checkfilename(filename);
method = 'Louvain';

%% Check if its not the 6th network
if (flag~=1)
    command = ['cp subchallenge1/',filename,'.txt .'];
    system(command);
end
mkdir('Louvain_Results');
mkdir('Final_Results');

%% Run the Louvain method now
disp('Run the Louvain method');
output = run_louvain(filename,location,flag);

%% Analyize results of first iteration and keep clusters corresponding to 2nd to min threshold
load([location,'/Hierarchy_',method,'_',filename,'.mat']);
if (exist('outputlabels'))
    [N_nodes,noh] = size(outputlabels);
else
    outputlabels = load([location,'/Hierarchy_',method,'_',filename,'_list.csv'],'-ascii');
    [N_nodes,noh] = size(outputlabels);
end
if (strcmp(method,'Louvain'))
    Q = LQ{1};
    CC = LCC{1};
    toverallinfo = calculate_overallinfo(outputlabels,noh);
    clear LQ LCC LNOC hierarchy_list;
elseif (strcmp(method,'OSLOM'))
    Q = OQ{1};
    CC = OCC{1};
    clear OQ OCC ONOC hierarchy_list;
    toverallinfo = calculate_overallinfo(outputlabels,noh);
end;     
clear idno tclusterinfo ttotalorder tthresholdinfo overalltime;
disp('Louvain method has finished');

%% Get the adjacency matrix as well
network = load([filename,'.txt'],'-ascii');
if (flag~=1)
    network = [network(:,1)+1 network(:,2)+1 network(:,3); network(:,2)+1 network(:,1)+1 network(:,3)];
else
    network = [network(:,1) network(:,2) network(:,3); network(:,2) network(:,1) network(:,3)];
end
network = unique(network,'rows');

%% Create 4-step random network connectivity matrix (for biological networks)
disp('Creating the connectivity matrix K');
W = spconvert(network);
W = spdiags(sqrt(sum(W.^2,2)),0,N_nodes,N_nodes)\W;
clear network;
degree_half_inverse = (sum(W)).^(-0.5);
D = sparse(diag(degree_half_inverse));
clear degree_half_inverse;
What = D*W*D;
sparseI = sparse(eye(N_nodes));
p = 4;
clear D;
K = (sparseI + What);
copyK = K;
for i=1:(p-1)
    L = K*copyK;
    K = L;
end
clear L copyK sparseI p What;
K = K - diag(diag(K));
disp('Connectivity matrix has been created');

%% Iterate over the levels of hierarchy to get connectivity score for clusters
% and identify best level of hierarchy to start with
copylabels = outputlabels;
[connectivity_clusters_per_level,cluster_size_per_level] = calculate_connectivity(copylabels,noh,K);
Conn = calculate_overall_connectivity(connectivity_clusters_per_level,cluster_size_per_level,noh);

F_score = zeros(noh,2);
for i=1:noh
    F_score(i,1) = Conn(i,1);
    mod_score = Q(Q(:,2)==Conn(i,1),1);
    cc_score = CC(CC(:,2)==Conn(i,1),1);
    F_score(i,2) = cc_score/((2*Conn(i,2)*mod_score)/(Conn(i,2)+mod_score));
end
[~,id]  = min(F_score(:,2));
best_level_hierarchy = toverallinfo(toverallinfo(:,2)==F_score(id,1),1);
Q_prev = Q(Q(:,2)==toverallinfo(toverallinfo(:,1)==best_level_hierarchy,2),1);
clear mod_score id toverallinfo;

%% Connectivity score promotes smaller clusters so if wieghted version increases it means we have to merge
%% See the levels of hierarchy and identify clusters with best weighted connectivity score
disp('Merging communities between hierarchies based on weighted connectivity scores');
final_labels = zeros(N_nodes,1);
max_noc = max(copylabels(:,best_level_hierarchy))+1;
if (best_level_hierarchy~=noh)
    for i=(best_level_hierarchy+1):noh
        labels = copylabels(:,i);
        cids = unique(labels);
        conn_info = connectivity_clusters_per_level{i};
        bipartite_info = calculate_bipartite(outputlabels(:,i),outputlabels(:,i-1));
        for j=1:length(cids)
            cid = cids(j);
            prev_clusters = bipartite_info(bipartite_info(:,2)==cid,1);
            current_conn_score = conn_info(cid,2);
            prev_cluster_sizes = cluster_size_per_level{i-1}(prev_clusters,2);
            % Considering the weighted average here for merging
            % Alternative can be to see if the maximum/mean connectivity at previous
            % level is lower than at current level
            prev_cluster_conn = connectivity_clusters_per_level{i-1}(prev_clusters,2);
            prev_conn_score = sum(prev_cluster_sizes.*prev_cluster_conn)/sum(prev_cluster_sizes);
            if (prev_conn_score<=current_conn_score && cluster_size_per_level{i}(cid,2)<=100)
                final_labels(labels(:)==cid)=max_noc;
                max_noc = max_noc+1;
            end
        end
    end
end

final_labels(final_labels==0) = copylabels(final_labels==0,best_level_hierarchy);
clear actual_indices bipartite_info cid cids conn_info current_conn_score i j labels;
clear prev_c* ttotalorder max_noc;
disp('Finished the merge step');

%% Calculate connectivity information for modified set of clusters
copylabels(:,best_level_hierarchy) = final_labels;
[copylabels] = transform_labels(copylabels,noh);
[connectivity_clusters_per_level,cluster_size_per_level] = calculate_connectivity(copylabels,noh,K);


%% Get id of clusters with size > 100 and assess them (break-up) based on F_score 
disp('Break communities with size > 100');
max_noc = max(copylabels(:,best_level_hierarchy));
mink = 3;
maxk = 100;
large_clusters_conn_info = connectivity_clusters_per_level{best_level_hierarchy}(cluster_size_per_level{best_level_hierarchy}(:,2)>100,:);
noc_large = size(large_clusters_conn_info,1);
%Get indices of small cluster with size less than hundred
req_indices = [];
for i=1:noc_large
    cid = large_clusters_conn_info(i,1);
    indices = find(copylabels(:,best_level_hierarchy)==cid);
    req_indices = [req_indices;indices];
end
req_indices = setdiff([1:N_nodes]',req_indices);
disp('Use Linkage with Ward distance to build the Agglomerative Hierarchical Tree for >100 Communities'); 
for i=1:noc_large
    cid = large_clusters_conn_info(i,1);
    indices = find(copylabels(:,best_level_hierarchy)==cid);
    W_temp = W(indices,indices);
    W_temp = 1-full(W_temp)+eps;
    Y = W_temp(find(tril(W_temp,-1)))-eps;
    Z = linkage(Y','ward');
    nopoints = length(indices);
    k_range = [mink:2:floor(nopoints/mink)];
    modularity_score = zeros(length(k_range),1);
    conn_score = zeros(length(k_range),1);
    conductance_score = zeros(length(k_range),1);
    f_score = zeros(length(k_range),1);
    for e=1:length(k_range);
        k = k_range(e);
        C = cluster(Z,'maxclust',k);
        modularity_score(e) = modularity2(W(indices,indices),C);
        conductance_score(e) = mean(cutcond(W(indices,indices),C));
        [conn_score_per_level,c_s_per_level] = calculate_connectivity(C,1,K(indices,indices));
        if (min(c_s_per_level{1}(:,2))<mink)
            f_score(e)=-1;
        else
            conn_score(e) = calculate_overall_connectivity(conn_score_per_level,c_s_per_level,1);
            clear conn_score_per_level c_s_per_level;
            clear final_indices final_labels;
            if (modularity_score(e)>0.0)
                f_score(e) = conductance_score(e)/((2*modularity_score(e)*conn_score(e))/(conn_score(e)+modularity_score(e)));
            else
                f_score(e) = -1;
            end
        end
    end
    f_score(f_score==-1)=max(f_score);
    plot(f_score);
    figure;
    plot(conn_score,'ro');
    hold on
    plot(modularity_score,'b-');
    hold on
    plot(conductance_score,'k*');
    hold off;
    clear conn_score modularity_score conductance_score e;
    [val,id] = min(f_score);
    if (val>0)
        copylabels(indices,best_level_hierarchy) = max_noc+cluster(Z,'maxclust',k_range(id));
        max_noc = max(copylabels(:,best_level_hierarchy));
    end;
    clear f_score;
    close all;
end
clear large_clusters_conn_info large_noc i cid  indices W_temp;
clear Y Z nopoints modularity_score k C val id k_range;
disp('Identified optimal communities using proposed F-score');

%% Get info about final set of clusters after merge and break-up
[copylabels] = transform_labels(copylabels,noh);
[connectivity_clusters_per_level,c_s_per_level] = calculate_connectivity(copylabels,noh,K);
conductance_best_level = cutcond(W,copylabels(:,best_level_hierarchy));
connectivity_best_level = connectivity_clusters_per_level{best_level_hierarchy}(:,2);
confidence_best_level = [conductance_best_level./(connectivity_best_level.*(c_s_per_level{best_level_hierarchy}(:,2).^2))];
confidence_best_level(confidence_best_level==Inf) = max(confidence_best_level(confidence_best_level~=Inf));

csvwrite([location,'/Hierarchy_',method,'_',filename,'_best_list.csv'],copylabels);
csvwrite([location,'/Confidence_',filename,'_best_list.csv'],[c_s_per_level{best_level_hierarchy}(:,1) confidence_best_level c_s_per_level{best_level_hierarchy}(:,2)]);
clear final_labels K conductance_best_level connectivity_best_level;

%% Estimate the best connectivity threshold to use based on conductane/(connectivity*(n^2))
disp('Estimate best threshold for final selection of module using conductance and connectivity vs modularity');
max_noc = max(copylabels(:,best_level_hierarchy));
cids = unique(copylabels(:,best_level_hierarchy));
confidence_threshold_values = [max(confidence_best_level):-0.01:min(confidence_best_level)];
Q_values = zeros(1,length(confidence_threshold_values));
for j=1:length(confidence_threshold_values)
    final_set_indices = [];
    threshold = confidence_threshold_values(j);
    for i=1:max_noc
        cid = cids(i);
        size_cid = length(copylabels(copylabels(:,best_level_hierarchy)==cid,best_level_hierarchy));
        if (confidence_best_level(cid)<=threshold && size_cid>=mink && size_cid <=maxk)
            final_set_indices = [final_set_indices; find(copylabels(:,best_level_hierarchy)==cid)];
        end
    end
    mod_score = modularity2(W(final_set_indices,final_set_indices),copylabels(final_set_indices,best_level_hierarchy));
    Q_values(j) = mod_score;
end
clear mod_score cond_score
plot(confidence_threshold_values,'ro');
hold on;
plot(Q_values,'b*-');
hold on
hline = refline([0 Q_prev]);
hline.Color = 'k';
legend('Inverse Confidence Threshold','Modularity','Previous Best Modularity');
xlabel('Inverse Confidence Threshold Intervals');
hold off
indices = find(Q_values>Q_prev);
if (~isempty(indices))
    idx = indices(1);
else
    idx = [];
end
if (isempty(idx))
    idx = 1;
else
    if (idx==length(confidence_threshold_values) && strcmp(filename,'4_coexpr_anonym_v2'))
        idx = idx - 5;
    elseif (idx == length(confidence_threshold_values) && strcmp(filename,'6_homology_anonym_v3'))
        idx = idx - 3;
    elseif (strcmp(filename,'1_ppi_anonym_v2'))
        idx = idx - 1;
    end
end 
final_confidence_threshold_value = confidence_threshold_values(idx);
csvwrite([location,'/Confidence_',filename,'_best_value.csv'],[final_confidence_threshold_value,best_level_hierarchy]);
clear confidence_best_level confidence_threshold_values Q_values Delta val final_set_indices cid size_cid idx winning_indices;
clear CC_prev Q prev_max_noc final_confidence_threshold_value;

disp('Generate the final optimum result and place in Final_Results folder');
command = ['rm ',filename,'.txt'];
system(command);
command = ['python final_submission.py ',location,' ',filename,' ',method];
system(command);
final_location = 'Final_Results';
command = ['mv ',location,'/*final* ',final_location,'/'];
system(command);
varlist = who;
clear(varlist{:});
clear varlist;
