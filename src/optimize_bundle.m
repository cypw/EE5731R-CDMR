function optimize_bundle(imPath, lbPath, cam, opt)
% need GCMex toolbox
% Author: cypw
%

%% load parameters
levels_ = opt.levels;
result_root_ = opt.result_root;
nbframes_ = opt.nbframes;

%% init parameters
plsave = @(f)(save(f,'dmap','labmap','opt'));
plimwrite = @(f,im_path)(imwrite(f,im_path));

%% init each frame
for i_im = 1:length(imPath)      
    t = tic;        
    
    im_path = fullfile(result_root_, sprintf('test%04d.png', i_im-1));
    mt_path = fullfile(result_root_, sprintf('test%04d.mat', i_im-1));
    idx_tp = [i_im-nbframes_,i_im+nbframes_];
    
    if exist(mt_path,'file') 
        continue;  
    end
    
    fprintf('\n-------- frame: %03d, pairnum: %03d.\n', i_im, numel(idx_tp));
    
    % prepare and load pairs
    idx_tp(idx_tp<1|idx_tp>length(imPath)) = [];    
    curr_imPath  = [ imPath(i_im);  imPath(idx_tp)  ];
    curr_lbPath  = [ lbPath(i_im);  lbPath(idx_tp)  ];
    curr_cam     = [  cam(i_im,:);   cam(idx_tp,:)  ];
    
    tic; fprintf('- loading frames.');
    im = cellfun(@(f)(im2double(imread(f))),curr_imPath,'uni',0);
    lb = cellfun(@(f)(getfield(load(f,'labmap'),'labmap')),curr_lbPath,'uni',0);
    fprintf(' (%.1fs)\n', toc);
    
    % process each pair [current frame + neighborhood]
    [dmap, labmap] = bundle_disparity(im, lb, curr_cam, opt);
    
    % save rendered disparity map
    rdmap = imrender(labmap, levels_, 'jet');
    plimwrite(rdmap, im_path);
    
    % save full init disparity results
    plsave(mt_path);
    
    fprintf('- finished. [%.1fmin]\n', toc(t)/60); 
end

end



