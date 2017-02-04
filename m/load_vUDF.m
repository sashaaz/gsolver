function D = load_UDF(filename)

fname = strtrim(ls(filename));
fid = fopen(fname,'rb');

dumpstandard = fread(fid, 7, 'char=>char');
if (~strncmp(dumpstandard', 'UDF1.0',6)) error('%s - unsupported dump standard!',dumpstandard); end;
float_size = fread(fid, 1, 'int');
if (float_size ~= 8 && float_size ~= 4) error('%d - unknown float size!', float_size); end;
iscomplex  = fread(fid, 1, 'int');
if (iscomplex ~= 1 && iscomplex ~= 0) error('%d - unknown iscomplex value (must be 0 or 1)!', float_size); end;
tN         = fread(fid, 1, 'int');
xN         = fread(fid, 1, 'int');
yN         = fread(fid, 1, 'int');
zN         = fread(fid, 1, 'int');

if (iscomplex==0) 
 if (float_size == 8) 
     D = (fread(fid, 2*tN*xN*yN*zN, 'double'));
     zN_ = floor(length(D)/tN/xN/yN/2);
     D = reshape(D(1:zN_*tN*xN*yN), tN, xN, yN, 2, zN_);
 else
     D = (fread(fid, 2*tN*xN*yN*zN, 'float'));
     zN_ = floor(length(D)/tN/xN/yN/2);
     D = reshape(D(1:zN_*tN*xN*yN), tN, xN, yN, 2, zN_);
 end;
else
 if (float_size == 8) 
     buf = fread(fid, 4*tN*xN*yN*zN, 'double');
 else
     buf = fread(fid, 4*tN*xN*yN*zN, 'float' );
 end;
 zN_ = floor(length(buf)/tN/xN/yN/4);
 D = reshape(complex(buf(1:2:4*zN_*tN*xN*yN),buf(2:2:4*zN_*tN*xN*yN)), tN, xN, yN, 2, zN_);
end;
D = permute(D, [1 2 3 5 4]);
D = squeeze(D);
fclose(fid);
  
