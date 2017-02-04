function [gamma,v] = fringe_visibility(A)
 %filtering
 A = tyukee2d(A,1000);
 A = iron_gauss(A,1,1); 
 [M,s1,s2] = max2d(A);
 A = A-0.5*(A(10,s2)+A(500,s2));
 %search for minima
 s1m1=s1; while A(s1m1-1,s2)<A(s1m1,s2); s1m1 = s1m1-1; end;
 s1m2=s1; while A(s1m2+1,s2)<A(s1m2,s2); s1m2 = s1m2+1; end;
 
 m1 = A(s1m1,s2); m2 = A(s1m2,s2);
 m = 0.5*(m1+m2);
 gamma = (M-m)/(M+m);
 v = 1;
 %check for fringe periodicity
 if (M > 15500) warning('M = %d, CCD nonlinearity may affect fringe visibility measure',M); v=0; end;
 if (abs(s1m1+s1m2-2*s1) > 5) gamma=0; end;
  
%  As = A(s1-64:s1+63,s2-64:s2+63);
%  perim_mean = (mean(As(1,1:end))+mean(As(end,1:end))+mean(As(1:end,1))+mean(As(1:end,end)))/4;
%  As = As - perim_mean;
%  fAs = abs(fftshift(fft2(As)));
%  fAsup =   fAs(1:60,:);
%  fAsdown = fAs(70:end,:);
%  gamma = (max(fAsup(:))+max(fAsdown(:)))/max(fAs(:));
end

function [M,s1,s2] = max2d(A)
[P,Q] = max(A);
[M,s2] = max(P);
s1 = Q(s2);
end


function [B] = tyukee2d(A,tol)
 S = size(A);
 B = A;
 for j=2:S(2)-1;
 for i=2:S(1)-1;
    if (abs(B(i,j)-B(i-1,j))>tol && abs(B(i,j)-B(i+1,j))>tol && abs(B(i,j)-B(i,j-1))>tol && abs(B(i,j+1))>tol)
        B(i,j)=0.25*(B(i-1,j)+B(i+1,j)+B(i,j-1)+B(i,j+1));
    end;
 end;
 end;
end
