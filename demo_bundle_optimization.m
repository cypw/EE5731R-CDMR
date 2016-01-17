clc; clear; close all; 
addpath('./src');
addpath(genpath('./toolbox'));

%% set parameters
opt = DefParam('bundle');
dataset = {'Road', 'Lawn', 'Flower'}; id = 2;
video_root  = sprintf('./video/%s', dataset{id});
initmt_root = sprintf('./result/init/%s', dataset{id});
result_root = sprintf('./result/bundle_p1/%s', dataset{id});
% % uncomment to run the second pass
% initmt_root = sprintf('./result/bundle_p%d/%s', dataset{id}, 1);
% result_root = sprintf('./result/bundle_p%d/%s', dataset{id}, 2);

%% init parameters
cameras_txt_path = fullfile(video_root, 'cameras.txt');
[imPath, ~] = GetFileList(fullfile(video_root, 'src'), 'jpg');
[lbPath, ~] = GetFileList(initmt_root, 'mat');
makedir(result_root);

%% decode camera parameters
fprintf('- decoding camera parameters ...\n');
cam = decode_cameras_txt(cameras_txt_path);

%% solve disparity initialization
fprintf('- doing disparity initialization ...\n');
opt.result_root = result_root;
optimize_bundle(imPath, lbPath, cam, opt);

fprintf('- finished.\n');
