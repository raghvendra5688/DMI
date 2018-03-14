function [connectivity_clusters_per_level,cluster_size_per_level] = calculate_connectivity(copylabels,noh,W)

connectivity_clusters_per_level = {};
cluster_size_per_level = {};
for i=1:noh
    labels = copylabels(:,i);
    cids = unique(labels);
    conn_info = [];
    cluster_info = [];
    for j=1:length(cids)
        cid = cids(j);
        indices = find(labels==cid);
        n = length(indices);
        if (n>1)
            connectivity_value = full(sum(sum(W(indices,indices))))/(n*(n-1));
        else
            connectivity_value = 0.0;
        end
        conn_info = [conn_info; cid connectivity_value];
        cluster_info = [cluster_info; cid n];
    end
    connectivity_clusters_per_level{i} = conn_info;
    cluster_size_per_level{i} = cluster_info;
end