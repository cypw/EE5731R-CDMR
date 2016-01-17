function data = binread(filepath)
%

fid = fopen(filepath, 'rb');
data = fread(fid, 'float32');
fclose(fid);

end