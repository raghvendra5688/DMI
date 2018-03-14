function [copylabels] = transform_labels(copylabels,noh)
for i=1:noh
    cids = unique(copylabels(:,i));
    counter = 1;
    for j=1:length(cids)
        cid = cids(j);
        copylabels(copylabels(:,i)==cid,i)=counter;
        counter=counter+1;
    end
end;