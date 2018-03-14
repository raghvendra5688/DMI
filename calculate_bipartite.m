function bipartite_info = calculate_bipartite(outlabels_curr,outlabels_prev)

max_curr = max(outlabels_curr);
max_prev = max(outlabels_prev);
bipartite_info = zeros(max_prev,2);
for i=1:max_prev
    indices = outlabels_prev==i;
    curr_cid = unique(outlabels_curr(indices));
    bipartite_info(i,:) = [i curr_cid];
end