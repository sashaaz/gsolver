%load Acssh
%Acs = Acssh;
function I = coherence_examin(Acs); 
fA = fftshift(fft(Acs),1); fA(1:350,:,:,:) = 0; Acs = ifft(ifftshift(fA,1));
p = [1 2; 1 3; 1 4; 1 5; 1 6; 2 3; 2 4; 2 5; 2 6; 3 4; 3 5; 3 6; 4 5; 4 6; 5 6];
%p = [1 1; 2 2; 3 3; 4 4; 5 5; 6 6];
n = 2; 
x = 1:size(Acs,2); 
dk = 1/10;
M = ones(size(Acs,1),1)*exp(i*x*dk); 
I = zeros(size(Acs,1), size(Acs,2));
for i=1:size(p,1); 
    A1 = Acs(:,:,n,p(i,1)).*M;
    A2 = Acs(:,:,n,p(i,2)).*conj(M);
    I = I+abs(A1+A2).^2;
end;


    