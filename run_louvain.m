function output = run_louvain(filename,result_dir,flag)

%% Obtain the network and run the experiments
network = load([filename,'.txt'],'-ascii');
if (flag~=1)
    network = [network(:,1)+1 network(:,2)+1 network(:,3); network(:,2)+1 network(:,1)+1 network(:,3)];
else
    network = [network(:,1) network(:,2) network(:,3); network(:,2) network(:,1) network(:,3)];
end
network = unique(network,'rows');
N_rows = length(network);

%% Print an unweighted network into a file
ftemp = fopen([filename,'.csv'],'W');
for i=1:N_rows
    fprintf(ftemp,'%d %d %f\n',network(i,1),network(i,2),network(i,3));
end
system(['mv ',filename,'.csv ',filename,'_mod.txt']);

%% Weighted undirected graphs
%adj_matrix = [network ones(N_rows,1)];
adj_matrix = network;
clear network;
A = spconvert(adj_matrix);
clear adj_matrix;

%% Quality metrics for Real world networks
LQ = cell(1,1);
LCC = cell(1,1);
LNOC = cell(1,1);

%% Perform OSLOM method
weighted=1;
[hierarchy_list] = louvain_hierarchy(filename,weighted);

[N,noh] = size(hierarchy_list);
for i=1:noh    
    %% In case of real world networks
    LQ{1} = [LQ{1}; [modularity2(A,hierarchy_list(:,i)) length(unique(hierarchy_list(:,i)))]];
    LCC{1} = [LCC{1}; [mean(cutcond(A,hierarchy_list(:,i))) length(unique(hierarchy_list(:,i)))]];
    LNOC{1} = [LNOC{1}; length(unique(hierarchy_list(:,i)))];
end;

%% Evaluation for real world networks
tempLQ = LQ{1};
tempLQ = sortrows(tempLQ,-1);
LQ{1} = tempLQ;
tempLCC = LCC{1};
tempLCC = sortrows(tempLCC,1);
LCC{1} = tempLCC;
save([result_dir,'/Hierarchy_Louvain_',filename,'.mat'],'hierarchy_list','LQ','LCC','LNOC');
csvwrite([result_dir,'/Hierarchy_Louvain_',filename,'_list.csv'],hierarchy_list);
clear
output=1;

