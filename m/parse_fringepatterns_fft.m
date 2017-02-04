function [S,Q] = parse_fringepatterns_fft(mask,Ns)
 N = length(Ns);
 S = zeros(size(Ns));
 Q = zeros(size(Ns));
 w = waitbar(0,sprintf('Processing image files, 0 of %d done',N));
  for n=1:N
    nname = sprintf(mask,Ns(n));
    dirout = dir(nname);
    if size(dirout,1) > 1
        error('Multiple files match pattern %s',nname);
    end
    M = load(dirout(1).name,'-ascii');
    M = M(300:550, 300:550);
    [S(n),Q(n)]=fringe_visibility_fft(M);
    waitbar(n/N,w,sprintf('Processing image files, %d of %d done',n,N));
 end;
 close(w);
end
