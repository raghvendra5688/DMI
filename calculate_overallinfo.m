function overallinfo = calculate_overallinfo(outputlabels,noh)

overallinfo = zeros(noh,2);
for i=1:noh
    overallinfo(i,1)=i;
    overallinfo(i,2) = max(outputlabels(:,i));
end

