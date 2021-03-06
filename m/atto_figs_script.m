%---------------------------------
%---------------------------------
%-----  Input parameters  --------

Nt = 2^14;    % t-grid size
tmin = -50;   % min value of time (fs)
tmax = 100;    % max value of time (fs)

cep = pi*[-0.5 : 0.01 : 0.49];   % Carrier-envelope phase (CEP) grid 
Ncep = length(cep);       % Number of points of the CEP grid 

nu12 = 10.03;             % Transition frequency (eV)
d12  = 5;                 % Transition dipole moment (a.u.)

I1    = 5e13;              % Field intensity  (W/cm^2)
I2    = 1e14;
linear_I = I1/1e4;        % Intensity at which dipole response can be considered as linear

Q    = 1e6;               % Transition finesse factor. If larger than ~100, does not affect the results

numin = 6;                %minimum frequency for spectral figures
numax = 11;               %maximum frequency for spectral figures
nusplit = 8.5;            %frequency, at which spectrum normalization changes
splitfactor = 1e2;        %extra normalization factor for frequencies above nusplit 

linecut_lf = [6 8];       %frequency range that is used to plot low-frequency line cut (fig. 4, panel 4, bottom)
linecut_hf = [9.5 10.5];  %frequency range that is used to plot high-frequency line cut (fig. 4, panel 4, top)





fig_fontsize = 20; 
fig_panelname_fontsize = 25;
fig_mainlinewidth = 2; 
fig_auxlinewidth = 0.5;
fig_auxlinecolor = [0.5 0.5 0.5];

fig4_filename_eps = 'atto_fig4.eps';

apanel_pos  = [0.1    0.1100 0.1  0.8150];   % Panel postions in the format [x, y, w, h]. Coordinates go from (0,0) -> left bottom corner
bpanel_pos  = [0.25   0.1100 0.2  0.8150];   % to (1,1) -> right top corner 
cpanel_pos  = [0.5    0.1100 0.2  0.8150];
dpanel_pos  = [0.75   0.1100 0.15 0.8150];


%----------------------------------
%----------------------------------
%----  Dipole calculation part  ---

disp('Calculating dipole moment ... '); 

tic; disp(sprintf('For I = %e W/cm^2', I1));
d1 = atto_qs(cep, I1*1e4, nu12, d12, Q, 1, @(a,b)atto_E_exp(a,b,Nt, tmin, tmax)); 
disp('Done.'); toc; 

tic; disp(sprintf('For I = %e W/cm^2', I2));
d2 = atto_qs(cep, I2*1e4, nu12, d12, Q, 1, @(a,b)atto_E_exp(a,b,Nt, tmin, tmax)); 
disp('Done.'); toc; 

tic; disp(sprintf('Linear (for I = %e W/cm^2)', linear_I));
dl = atto_qs(cep, I1    , nu12, d12, Q, 1, @(a,b)atto_E_exp(a,b,Nt, tmin, tmax)); 
disp('Done.'); toc; 

disp('Running Fourier transform...'); 
f = (exp(-(2*(-Nt/2:(Nt/2-1)).'/Nt/0.8).^20)*ones(size(cep))); %anti-aliasing super-gaussian temporal filter

fd1 = fftshift(fft(d1.*f),1);  %Fourier-transforming the dipole moment
fd2 = fftshift(fft(d2.*f),1);  %Fourier-transforming the dipole moment

disp('Done');

const_SI; 
t = tmin + (tmax-tmin)*(1:Nt)/Nt; t=reshape(t,length(t),1);  
w = cfreq(t); 
nu = w*1e15*SI.h_./SI.e;      %nu contains frequency grid that corresponds to the Fourier transform on the given t grid

nuindex = (numin < nu) & (nu < numax);

fd1_ = fd1; 
fd2_ = fd2; 
fd1_(nu > nusplit,:) = fd1_(nu > nusplit,:)/splitfactor; %Make the splitted spectrum normalization
fd2_(nu > nusplit,:) = fd2_(nu > nusplit,:)/splitfactor;  
cep__ = cat(2, cep-pi, cep, cep+pi); 
fd1__ = cat(2, fd1_, fd1_, fd1_);    %Sampling -pi/2 ... pi/2 values of CEP to -1.5pi ... 1.5 
fd2__ = cat(2, fd2_, fd2_, fd2_); 


%----------------------------------
%----------------------------------
%-------  Graphics part  ----------

%----------------------------------
%----- Plot analog of Fig. 4 ------

fig4 = figure; 
% Draw panel (a) -- plot spectrum of the dipole moment, generated by cosine
% (blue) and sine (red) waveforms
apanel = subplot(1,4,1);
plot(abs(fd1_(nuindex,Ncep/2)).^2/max(max(abs(fd1_(nuindex,:)).^2)), nu(nuindex), 'b-', ... 
     abs(fd1_(nuindex,Ncep)).^2  /max(max(abs(fd1_(nuindex,:)).^2)), nu(nuindex), 'r-', ...
     'LineWidth', fig_mainlinewidth);
hold on; 
plot([0 1], nusplit*[1 1], '--', 'LineWidth', fig_auxlinewidth, ...
'Color', [0.5 0.5 0.5]);

set(apanel, 'XDir', 'reverse', 'FontSize', fig_fontsize, 'Position', apanel_pos); 
xlabel('Intesity (arb. u.)'); ylabel('Energy (eV)');
set(apanel, 'Position', apanel_pos);

% Draw color maps
bpanel = subplot(1,4,2);
imagesc_(cep__/pi, nu(nuindex), abs(fd1__(nuindex, :)).^2); 
set(bpanel, 'FontSize', fig_fontsize, 'Position', bpanel_pos); xlabel('\phi_G(\pi)'); 
cpanel = subplot(1,4,3);
imagesc_(cep__/pi, nu(nuindex), abs(fd2__(nuindex, :)).^2); 
set(cpanel, 'FontSize', fig_fontsize, 'Position', cpanel_pos); xlabel('\phi_G(\pi)'); 


%Draw line cuts through the maps

dpanel = subplot(1,4,4);
nuindex_cut_lf = linecut_lf(1) < nu & nu < linecut_lf(2);
nuindex_cut_hf = linecut_hf(1) < nu & nu < linecut_hf(2);
lc_lf1 = sum(abs(fd1__(nuindex_cut_lf,:)).^2, 1); 
lc_hf1 = sum(abs(fd1__(nuindex_cut_hf,:)).^2, 1); 
lc_lf2 = sum(abs(fd2__(nuindex_cut_lf,:)).^2, 1); 
lc_hf2 = sum(abs(fd2__(nuindex_cut_hf,:)).^2, 1); 

%Plot normalized line cuts, shifted by +- 1 against zero. 
%blue line stands for intensity 1, red curve stands for intensity 2
plot(cep__/pi, lc_lf1./max(lc_lf1)-1, 'b-', cep__/pi, lc_lf2./max(lc_lf2)-1, 'r-', ...  
     cep__/pi, lc_hf1./max(lc_hf1)+1, 'b-', cep__/pi, lc_hf2./max(lc_hf2)+1, 'r-', ...
     'LineWidth', fig_mainlinewidth); 
set(dpanel, 'YAxisLocation', 'right', 'FontSize', fig_fontsize, ...
    'XLim', [min(cep__), max(cep__)]/pi, 'Position', dpanel_pos);
xlabel('\phi_G(\pi)'); ylabel('Intensity (arb. u.)');


% Display auxiliary information
 % Draw rectangles to embrace frequency regions for line cuts
r_lf = [cpanel_pos(1)+cpanel_pos(3), cpanel_pos(2) + cpanel_pos(4)*(linecut_lf(1)-numin)/(numax-numin), ...
        0.01, cpanel_pos(4)*(linecut_lf(2)-linecut_lf(1))/(numax-numin)];
    
r_hf = [cpanel_pos(1)+cpanel_pos(3), cpanel_pos(2) + cpanel_pos(4)*(linecut_hf(1)-numin)/(numax-numin), ...
        0.01, cpanel_pos(4)*(linecut_hf(2)-linecut_hf(1))/(numax-numin)];

annotation('rectangle', r_lf, 'LineWidth', fig_auxlinewidth, 'Color', fig_auxlinecolor);
annotation('rectangle', r_hf, 'LineWidth', fig_auxlinewidth, 'Color', fig_auxlinecolor);

 %Draw arrows between panel (d) and panel (c)

arrow_x = [dpanel_pos(1), cpanel_pos(1)+cpanel_pos(3)+0.01];
arrow_lf_y = [dpanel_pos(2) + dpanel_pos(4)*0.1, r_lf(2) + r_lf(4)/2];
arrow_hf_y = [dpanel_pos(2) + dpanel_pos(4)*0.8, r_hf(2) + r_hf(4)/2];

annotation('arrow', arrow_x, arrow_lf_y, 'LineWidth', fig_auxlinewidth, 'Color', fig_auxlinecolor);
annotation('arrow', arrow_x, arrow_hf_y, 'LineWidth', fig_auxlinewidth, 'Color', fig_auxlinecolor);

 %Print panel names

annotation('textbox', [apanel_pos(1)-0.03, apanel_pos(2)+apanel_pos(4)-0.03, 0.03, 0.03], ...
           'String', '(A)', 'LineStyle', 'none', 'FontSize', fig_panelname_fontsize); 

annotation('textbox', [bpanel_pos(1)-0.03, bpanel_pos(2)+bpanel_pos(4)-0.03, 0.03, 0.03], ...
           'String', '(B)', 'LineStyle', 'none', 'FontSize', fig_panelname_fontsize); 

annotation('textbox', [cpanel_pos(1)-0.03, cpanel_pos(2)+cpanel_pos(4)-0.03, 0.03, 0.03], ...
           'String', '(C)', 'LineStyle', 'none', 'FontSize', fig_panelname_fontsize); 

annotation('textbox', [dpanel_pos(1)-0.03, dpanel_pos(2)+dpanel_pos(4)-0.03, 0.03, 0.03], ...
           'String', '(D)', 'LineStyle', 'none', 'FontSize', fig_panelname_fontsize); 

% Print fig. 4

set(fig4, 'Position', [1 1 1920 1080], 'PaperPositionMode', 'auto');
print(fig4, fig4_filename_eps, '-depsc');


% Exhale, drink some tea - let's print fig. 5
%First, we calculate 'linear' dipole moment - at low intensity;

d1nl = d1 - dl*sqrt(I1/linear_I);
d2nl = d2 - dl*sqrt(I1/linear_I);

fig5 = figure; 

plot(t, d1nl(:,[Ncep/2, Ncep]), t, d2nl(:,[Ncep/2, Ncep]));


       

