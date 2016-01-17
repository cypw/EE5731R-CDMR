clc; clear; close all; 
addpath('./src');
addpath(genpath('./toolbox'));

%% set parameters
opt = DefParam('init');
dataset = {'Road', 'Lawn', 'Flower'}; id = 1;
video_root  = sprintf('./video/%s', dataset{id});
result_root = sprintf('./result/init/%s', dataset{id});

%% init parameters
cameras_txt_path = fullfile(video_root, 'cameras.txt');
[imPath, ~] = GetFileList(fullfile(video_root, 'src'), 'jpg');
makedir(result_root);

%% load parameters
fprintf('- loading frames\n');
im = cellfun(@(f)(im2double(imread(f))),imPath,'uni',0);

fprintf('- decoding camera parameters ...\n');
cam = decode_cameras_txt(cameras_txt_path);

%% solve disparity initialization
fprintf('- doing disparity initialization ...\n');
opt.result_root = result_root;
init_disparity(im, cam, opt);

fprintf('- finished.\n');
