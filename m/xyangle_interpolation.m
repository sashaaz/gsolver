function [E, w, phix, phiy] = xyangle_interpolation(A, omega, wavenum, xmin, xmax, ymin, ymax, phix, phiy)
%function [E, w, phix, phiy] = xyangle_intepolation(A,omega,wavenum,xmin,xmax)
%
%This function takes field amplitude A(t,x), performs Fourier transform to
%A(w,kx) and interpolates it to eqidistant angle net A(w,phi)
%phi = arcsin(kx/k(w))
%
% omega is field circular frequency. May be fftshift'ed or not. 
% wavenum - field wavenumber in the same format with omega
% xmin - minimum value of x coordinate
% xmax - maximum value of x coordinate

if (length(omega)~=size(A,1))
    error('length(omega) should be equal to size(A,1)');
end;
if (length(wavenum)~=size(A,1))
    error('length(wavenum) should be equal to size(A,1)');
end;
if (xmin >= xmax)
    error('xmin should be less than xmax');
end;
if (ymin >= ymax)
    error('xmin should be less than xmax');
end;



xspan = xmax-xmin;
yspan = ymax-ymin;
Nt = size(A,1);
Nx = size(A,2);
Ny = size(A,3);
if (omega(1) > omega(Nt-1))
    w = fftshift(omega);
    k = real(fftshift(wavenum));
else
    w = omega;
    k = real(wavenum);
end;

kx = (-pi*Nx/xspan+2*pi/xspan) : 2*pi/xspan : pi*Nx/xspan;
ky = (-pi*Ny/yspan+2*pi/yspan) : 2*pi/yspan : pi*Ny/yspan;
if (nargin < 7)
	phix = -0.5 : 0.005 : 0.5;
end;
if (nargin < 8)
	phiy = -0.2 : 0.002 : 0.2;
end;

%A_ = zeros(size(A)); A_(:, 2869:3407) = A(:,2869:3407);
fA = abs(fftshift(fftn(A))).^2;
E = zeros(Nt, length(phix), length(phiy));
for nt=1:Nt;
 
    if (w(nt)) <= 0
        continue;
    end;
    sphix = kx./k(nt);
    sphiy = ky./k(nt);
    cx = abs(sphix) < 1;
    cy = abs(sphiy) < 1;
    sphix1 = sphix(cx);
    sphiy1 = sphiy(cy);
    [My, Mx] = meshgrid(asin(sphiy1), asin(sphix1));
    pE = reshape(fA(nt,cx,cy), length(sphix1), length(sphiy1));
    iE = interp2(My,Mx, pE, phiy,phix', 'linear')*(k(nt).^2).*(cos(phix)'*cos(phiy));
    %imagesc(iE); title(sprintf('nt=%d', nt)); drawnow; 
    E(nt,:,:) = reshape(iE, 1, length(phix), length(phiy)); 
end;



