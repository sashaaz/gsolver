function [S,wl] = loadOOIspectra_new_comma(path, beginsgn);
%function [S,wl] = loadOOIspectra(files, beginsgn);
%
% This function loads series of spectra saved with Ocean Optics
% spectrometer. File names should be given as a mask with possible path
% before, e.g 
%  \spectra\*.scope 
% takes all the *.scope files from directory \spectra;
%  \spectra 
% treates all the files in \spectra\ directory as OOI-spectra inspite their
% extensions.
% default value is '*.scope'
% 
% beginsgn - signature of the beginning of spectral information (end of
% header). 
% Default value for beginsgn is '>>>>>Begin Spectral Data<<<<<'
% if beginsgn is empty file is treated as a file without header,
% and spectrum is read from the first line.

if nargin == 0
    path = '*.Scope';
end;

files = dir(path);

while (size(path,2) >= 1) && (path(1,end)~=filesep)
        path = path(1:end-1);
end


if nargin < 2
    beginsgn = '>>>>>Begin Processed Spectral Data<<<<<';
end;    

S = [];
t = [];
for n = 1 : length(files)
    fname = [path files(n).name];
    fid   = fopen(fname, 'rt');
    if fid < 0
        error(sprintf('Error opening file %s',fname));
    end
    if ~isempty(beginsgn)
      sbuf = [];
      while strcmp(sbuf, beginsgn) == 0 
         sbuf = fgetl(fid); 
         if feof(fid)
            warning(sprintf('File %s does not contain the beginnning signature and ignored', [path files(n).name]));
            break;
         end;
      end;      
    end;
 %   s = fgets(fid);
    t = fscanf(fid, '%d,%d %d,%d');
    t = [t(1:4:end)+t(2:4:end)/100, t(3:4:end)+t(4:4:end)/100];
    fclose(fid);
    S = [S t(:,2)];
end;
wl = t(:,1);


