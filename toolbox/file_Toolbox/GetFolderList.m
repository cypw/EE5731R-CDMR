function [fldPathList,fldNameList] = GetFolderList(path)
%GetImagePath()
%
%disp('- Get folder List...');

%% 
fileList = dir(path);
fldPathList = {};
fldNameList = {};
kk = 0;

for rr=1:length(fileList)
    if(fileList(rr).isdir&&~strcmp(fileList(rr).name,'.')&&~strcmp(fileList(rr).name,'..'))
        kk = kk+1;
        fldNameList{1,kk} = fileList(rr).name;
        fldPathList{1,kk} = fullfile(path,fileList(rr).name);
    end
end

%disp('- Finished.');
