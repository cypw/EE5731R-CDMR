function [PathList,NameList] = GetFileList(path,type,varargin)
%GetImagePath()
%
%disp('- Get file List...');

if length(varargin) > 2
    if strcmp(varargin{1}, 'skipstr')
        skipnum = varargin{2};
    end
else
    skipnum = 0;
end

%%
if strcmp(type,'')
    fileList = dir(fullfile(path,'*'));
    s_offset = 0;
else
    fileList = dir(fullfile(path,['*.',type]));
    s_offset = 1+length(type);
end
PathList = {};
NameList = {};
kk = 0;

%%
for rr=1:length(fileList)
    if(~fileList(rr).isdir&&~strcmp(fileList(rr).name,'.')&&~strcmp(fileList(rr).name,'..'))
        kk = kk+1;
        NameList{kk,1} = fileList(rr).name(1:(end-s_offset));
        PathList{kk,1} = fullfile(path((skipnum+1):end),fileList(rr).name);
    end
end

%disp('- Finished.');
