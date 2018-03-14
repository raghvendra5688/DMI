function Conn = calculate_overall_connectivity(connectivity_clusters_per_level,cluster_size_per_level,noh)

if (noh>1)
    Conn = zeros(noh,2);
    for i=1:noh
        Conn(i,1) = max(cluster_size_per_level{i}(:,1));
        Conn(i,2) = sum(cluster_size_per_level{i}(:,2).*connectivity_clusters_per_level{i}(:,2))/sum(cluster_size_per_level{i}(:,2));
        %Conn(i,2) = mean(connectivity_clusters_per_level{i}(:,2));
    end
else
    Conn = sum(cluster_size_per_level{1}(:,2).*connectivity_clusters_per_level{1}(:,2))/sum(cluster_size_per_level{1}(:,2));
end
