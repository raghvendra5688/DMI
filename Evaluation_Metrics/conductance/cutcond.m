function cond = cutcond(A,s)
% CUTCOND Return the conductance of a cut
%
% cond = cutcond(A,s) returns the sum of degrees of vertices in A
%

%d = sum(A,2);
%Gvol = full(sum(d));
%setvol = cutvol(A,s);
%cut = cutsize(A,s);
%cond = cut./min(abs(Gvol-setvol),setvol);
%cond = mean(cond);

cids = unique(s);
conductance = ones(length(cids),1);
for i=1:length(cids)
    cid = cids(i);
    indices = find(s(:)==cid);
    m_s = full(sum(sum(A(indices,indices))));
    c_s = full(sum(sum(A(indices,:))))+full(sum(sum(A(:,indices))))-2*m_s;
    conductance(cid) = (c_s/(2*m_s+c_s));
end
cond = conductance;
%%cond = mean(conductance);