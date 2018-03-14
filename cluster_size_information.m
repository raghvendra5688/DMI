function [c_s_info] = cluster_size_information(outputlabels)

%% Estimate size of each cluster in final outputlabels (For internal use only)
total_cids = unique(outputlabels(:,1));
c_s_info = zeros(length(total_cids),2);
for i=1:length(total_cids)
    cid = total_cids(i);
    siz = length(find(outputlabels(:,1)==cid));
    c_s_info(i,:) = [cid siz];
end