function cam = decode_cameras_txt(filepath)
%

%% Open file
fid = fopen(filepath);

%% [1] Frame Number 
frame_num = fscanf(fid, '%d', 1);

%% [2] Camera Parameters of each frame:
% K   R   T ------  X_{world} = R * X_{camera} + T
% K (intrinsic matrix): the first 3*3 matrix 
% R (camera rotation): the second 3*3 matrix 
% T (camera position):  the final line 
cam_K = cell(frame_num, 1);
cam_R = cell(frame_num, 1);
cam_T = cell(frame_num, 1);
for i_frame = 1:frame_num    
    cam_K{i_frame} = fscanf(fid, '%f', [3,3])';
    cam_R{i_frame} = fscanf(fid, '%f', [3,3])';
    cam_T{i_frame} = fscanf(fid, '%f', [1,3])';
end
fclose(fid);

%% [3] Compute C, P
% compute camera center
%  C_{world} = R0 + T  ->  C_{world} = T
cam_C = cellfun(@(T)([T;1]), cam_T, 'Uni', 0);

% compute camera parameter
%  X_{world} = R * X_{camera} + T
%  X_{camera}= R'* X_{world} - R'T
cam_P = cellfun(@(K,R,T)(K*[R',-R'*T]), cam_K, cam_R, cam_T, 'Uni', 0);

%% Finish
cam.K = cam_K;
cam.R = cam_R;
cam.T = cam_T;
cam.C = cam_C;
cam.P = cam_P;
cam = struct2table(cam);

end




