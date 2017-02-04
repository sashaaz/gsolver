function [W,L,E, t] = ion_aniso_(gamma, T, delta)

const_SI; 
lambda = 800e-9; 

Nt = 2048; 
t = -40 + (0:(Nt-1))*80/Nt;  t=t(:);
t = t*1e-15/SI.atomic_time;
T = T*1e-15/SI.atomic_time;

dt = t(2)-t(1); 


w = 2*pi*SI.c/lambda/SI.atomic_frequency; 


mx = 0.9;
my = 0.6; 

delta = delta*w; 


A0 = sqrt(mx*delta)./gamma;

E = real(exp(1i*w*t - (t/T).^2));  %electric field
fE = fft(E);  fE(abs(fE)<1e-3*max(abs(fE)))=0; 
E = ifft(fE);

A = cumsum(E)*dt; %vector potential

E = E.*A0./max(A); E0 = max(E); 
A = A./max(A).*A0; 

Ai = cumsum(A)*dt;
A2i= cumsum(A.^2)*dt; 
% Xi = t*ones(1,Nt); Xi=-Xi+Xi.';
% 
% E1E2 = E*E.';
% %AI = Ai*ones(1,Nt); AI=-AI+AI.';
% %A2I = A2i*ones(1,Nt); A2I=-A2I+A2I.'; 
% 
% xi_ = 0:dt:max(t);
% Nxi = length(xi_); 
% E1E2_ = zeros(Nt, Nt);
% AI = zeros(Nt); A2I = zeros(Nt);
% A1 = zeros(Nt); A2 = zeros(Nt);
% Xi = zeros(Nt);
% for nt2 = 1:Nt; 
%     for nxi = 1:nt2;
%         E2 = E(nt2); 
%         E1 = E(nt2-nxi+1); 
%         
%         A2(nt2,nxi) = A(nt2);
%         A1(nt2,nxi) = A(nt2-nxi+1); 
%         Ai_  = Ai(nt2) - Ai(nt2-nxi+1); 
%         A2i_ = A2i(nt2) - A2i(nt2-nxi+1); 
%         E1E2_(nt2, nxi)=E1*E2;
%         AI(nt2, nxi)=Ai_; 
%         A2I(nt2, nxi)=A2i_; 
%         Xi(nt2, nxi) = dt*(nxi-1);
%     end;
% end;
%         
% 
%         
% Ain = (abs(Xi.*delta));
% %Bin1 = sqXi.*(ones(Nt,1)*A(:).') - AI./sqXi;
% %Bin2 = sqXi.*(A(:)*ones(1,Nt))   - AI./sqXi;
% Bin1 =  - AI./Xi;
% Bin2 =  - AI./Xi;
% Bin1(Xi==0) = 0; 
% Bin2(Xi==0) = 0; 
% 
% %S = S_integral_1d(Ain, Bin1, Bin2);
% %load S1d;
% 
% %S = interp2(B_, A_, S_, Bin1, Xi.*delta, 'linear', 0);
% %S = exp(-1i*Ain-2*0.042722116i*pi);
% S = exp(-1i*Ain-1i*delta*dt*0.4855);
% %S(isnan(S)) = exp(-1i.*Ain(isnan(S))).*(pi./1i./Ain(isnan(S))).^(1/2);
% 
% % S = exp(-1i.*Ain)./(1+Bin1.^2./Ain)./(1+Bin2.^2./Ain); 
% % S(Xi==0) = 1;
% 
% expA2I = exp(-1i.*(A2I-(AI).^2./abs(Xi))); expA2I(Xi==0)=1; 
% % hb = waitbar(0, 'Calculating S integral...'); 
% % for nt2 = 1:Nt; 
% %     parfor nt1 = 1:(nt2-1); 
% %         xi = Xi(nt1, nt2); 
% %         S(nt1, nt2) = S_integral(delta*xi, sqrt(xi).*A(nt2) - (Ai(nt2)-Ai(nt1)/xi));
% %         expA2I(nt1, nt2) = exp(-1i*(A2I(nt1, nt2)-AI(nt1, nt2)./xi)-i*xi*delta); 
% %     end;
% %     waitbar(nt2/Nt, hb); 
% % end;
% %close(hb); 
% % S = S_intergral(delta*Xi, sqrt(Xi).*(A.*ones(1,Nt) - AI
% % 
% % tA = exp(-sqrt(delta)./abs(A*ones(size(A)).')); tA(~(Xi==0))=0;
% % 
% % S = pi^2/2*exp(1i*delta*Xi)+tA;
% 
% 
% %expA2I = exp(-1i*(A2I-AI.^2./Xi)); expA2I(Xi==0)=1;  
% 
% I = E1E2_.*expA2I.*S; 
% 
% % W = zeros(size(t)); W(1)=I(1,1); 
% % 
% % for nt=2:Nt; 
% %     W(nt) = W(nt-1)+real(sum(I(nt,1:nt)))+real(sum(I(1:(nt-1),nt)));
% % end; 
% % 
% W = cumsum(sum(I,2));
% 
% W = W*dt;
% 
% 
% return; 

% pmaxx = 0.5.*sqrt(mx*delta); 
% px = -pmaxx + 2*pmaxx*(0:511)./512;
% 
% L = zeros(Nt, length(px));

Xi = t*ones(1,Nt); Xi=-Xi+Xi.';

E1E2 = E*E.';

AI = Ai*ones(1,Nt); AI=-AI+AI.';
A2I = A2i*ones(1,Nt); A2I=-A2I+A2I.'; 

% t_ = t-min(t)+dt; 
% parfor nx = 1:length(px);
%     %en = delta + (px(nx)+A).^2;
%     ien = delta.*t_ + A2i + (px(nx)).^2.*t_ ;
%     %dA = A-Ai./t_; dA(t==0)=0;
%     K = exp(-1i*ien)./(1+(px(nx)+A).^2); 
%     L(:, nx) = dt*cumsum(K(:).*E(:))./delta; 
% end;
% W = sum(abs(L).^2, 2)*dt; 
% 
% return; 
% 
W = zeros(Nt, 1); 

A1 = A(:)*ones(1,Nt);
A2 = ones(Nt,1)*A(:).';

B1 = A1-AI./Xi; B1(Xi==0)=0; 
B2 = A2-AI./Xi; B2(Xi==0)=0;


pmaxx = 2; 
px = -pmaxx + 2*pmaxx*(0:511)./512;


S = S_integral_3d(Xi.*delta, B1./sqrt(delta), B2./sqrt(delta))./delta.^0.5;
%

exp2AI = exp(-1i.*delta.*Xi-1i.*(A2I-AI.^2./Xi)); exp2AI(Xi==0)=1;
I = S.*exp2AI.*E1E2;
    W_ = zeros(Nt,1); 
    W_(1)=I(1,1); 
    for nt=2:Nt; 
      W_(nt) = W_(nt-1)+real(sum(I(nt,1:nt)))+real(sum(I(1:(nt-1),nt)));
    end;
    W=W_.*(dt.^2);
return; 
      


