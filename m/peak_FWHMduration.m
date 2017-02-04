function [d, pp]=peak_FWHMduration(t,I, withwaitbar)
I_ = I(:,:);
d = zeros(size(I_,2),1);

if (nargin == 2); withwaitbar = 0; end;
if (withwaitbar == 1); h=waitbar(0,'Calculating, please wait...'); end;
for i=1:size(I_,2);
    [M,pM]=max(I_(:,i)); 
    for lpM=pM:-1:1; if (I_(lpM,i)<M/2); break; end; end;
    for rpM=pM:1:size(I_,1); if (I_(rpM,i)<M/2); break; end; end;
    
    tl = (t(lpM) - t(lpM+1))*(M/2 - I_(lpM+1,i))/(I_(lpM,i) - I_(lpM+1,i)) + t(lpM+1);
    tr = (t(rpM) - t(rpM-1))*(M/2 - I_(rpM-1,i))/(I_(rpM,i) - I_(rpM-1,i)) + t(rpM-1);
    d(i)=tr-tl;
    
    pp(i)=t(pM);
    if (withwaitbar==1); waitbar(i/size(I_,2), h); end;
end;
S = size(I); if (length(S)==2) S = [S 1]; end;
d = reshape(d, S(2:end));
pp = reshape(pp, S(2:end));
if (withwaitbar==1); close(h); end;