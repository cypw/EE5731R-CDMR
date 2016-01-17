function [cands_idx, candsxy, cands_out] = find_candidats(coorsxy,cam,opt)
% Author: cypw
%

%% load parameters
d_ = opt.d;
im_h_ = opt.im_h;
im_w_ = opt.im_w;
levels_ = opt.levels;

%% find candidat points 
% comput x`
candsxy = arrayfun(@(id)( ...
    cam.K{2}*cam.R{2}'*(cam.R{1}/(cam.K{1})*coorsxy ...
    + repmat(d_(id)*((cam.T{1}-cam.T{2})), ...
    [1,size(coorsxy,2)]))), 1:length(d_), 'Uni', 0);
candsxy = cellfun(@(mtx)(mtx ./ repmat(mtx(3,:),[3,1])), candsxy, 'Uni', 0);
candsxy = permute(cat(3, candsxy{:}),[1,3,2]); % [xy1,levels,numel]

% check if out of boundary
cands_out = squeeze( (candsxy(1,:,:) < 0.5) | (candsxy(1,:,:) >= (im_w_-0.5)) ...
    | (candsxy(2,:,:) < 0.5) | (candsxy(2,:,:) >= (im_h_-0.5)) );

% re-idx
cands_idx = arrayfun(@(ic)( sub2ind([im_h_, im_w_], ...
    max(min(round(candsxy(2,ic,:)), im_h_),1), ...
    max(min(round(candsxy(1,ic,:)), im_w_),1)) ), 1:levels_,'Uni',0);
cands_idx = squeeze(cat(2, cands_idx{:}))'; % [numel,levels]

end