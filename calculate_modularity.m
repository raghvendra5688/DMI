function Q = calculate_modularity(filename,weighted,outputlabel)

network = load([filename,'.txt'],'-ascii');
if (weighted~=1)
    network = [network(:,1) network(:,2); network(:,2) network(:,1)];
else
    network = [network(:,1) network(:,2) network(:,3); network(:,2) network(:,1) network(:,3)];
end
%% Construct network
network = unique(network,'rows');
N_rows = length(network);

%% For unweighted or weighted network 
if (weighted ~= 1)
    adj_matrix = [network ones(N_rows,1)];
    A = spconvert(adj_matrix);
else
    A = spconvert(network);
end;

Q = modularity2(A,outputlabel);
