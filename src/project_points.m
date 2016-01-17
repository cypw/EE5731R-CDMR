function [cands_idx, projexy, cands_out] = project_points(pidxmap,coorsxy,lbmap,cam,opt)
% Author: cypw
%

%% load parameters
d_ = opt.d;
im_h_ = opt.im_h;
im_w_ = opt.im_w;
levels_ = opt.levels;

%% find candidat points 
% comput x`
% projexy = arrayfun(@(id)( ...
%     cam.K{2}*cam.R{2}'*(cam.R{1}/(cam.K{1})*coorsxy ...
%     + repmat(d_(id)*((cam.T{1}-cam.T{2})), ...
%     [1,size(coorsxy,2)]))), 1:length(d_), 'Uni', 0);
% projexy = cellfun(@(mtx)(mtx ./ repmat(mtx(3,:),[3,1])), projexy, 'Uni', 0);
% projexy = permute(cat(3, projexy{:}),[1,3,2]); % [xy1,levels,numel]

projexy = zeros(size(coorsxy));
K2_R2t = cam.K{2} * cam.R{2}';
R1_iK1 = cam.R{1} / (cam.K{1});
T1_T2  = cam.T{1} - cam.T{2};
parfor i_p = 1:size(coorsxy,3)
    for i_level = 1:levels_
        txy = K2_R2t * ( R1_iK1 * coorsxy(:,i_level,i_p) ...
                         + d_(lbmap(pidxmap(i_p,i_level))) * T1_T2 );
        projexy(:,i_level,i_p) = txy ./ txy(3);
    end
end

% check if out of boundary
cands_out = squeeze( (projexy(1,:,:) < 0.5) | (projexy(1,:,:) >= (im_w_-0.5)) ...
    | (projexy(2,:,:) < 0.5) | (projexy(2,:,:) >= (im_h_-0.5)) );

% re-idx
cands_idx = arrayfun(@(ic)( sub2ind([im_h_, im_w_], ...
    max(min(round(projexy(2,ic,:)), im_h_),1), ...
    max(min(round(projexy(1,ic,:)), im_w_),1)) ), 1:levels_,'Uni',0);
cands_idx = squeeze(cat(2, cands_idx{:}))'; % [numel,levels]

end