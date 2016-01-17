function [dmap, labmap] = bundle_disparity(im, initlab, cam, opt)
% need GCMex toolbox
% Author: cypw
%

%% load parameters
d_ = opt.d;
ita_ = opt.ita;

%% init parameters
im_h = size(im{1},1);
im_w = size(im{1},2);
vec_len = im_h * im_w;

opt.im_h = im_h;
opt.im_w = im_w;
opt.vec_len = vec_len;

%% build index table
tic; fprintf('  - building index table.');
[X, Y] = meshgrid(1:im_w, 1:im_h);
coorsxy = [X(:)'; Y(:)'; ones(1,vec_len)];
fprintf(' (%.1fs)\n', toc);

%% compute data term
tic; fprintf('  - computing data term.');
data_term = compute_data_term_bundle(coorsxy, im, initlab, cam, opt);
fprintf(' (%.1fmin)\n', toc/60);

%% compute pairwise term
tic; fprintf('  - computing pairwise term.');
pairwise_term = compute_pairwise_term(coorsxy, im, opt); % sparse matrix
fprintf(' (%.1fmin)\n', toc/60);

%% optimize by graph-cut using GCMex tool
tic; fprintf('  - optimizing by graph-cut.');
[~, initcls] = min(data_term,[],1); initcls = initcls' - 1;
labelcost = min(ita_, pdist2(d_',d_',@(x,y)(abs(x-y))));
labels = GCMex(initcls, single(data_term), pairwise_term, single(labelcost),0) + 1;
fprintf(' (%.1fmin)\n', toc/60);

%% compute disparity
tic; fprintf('  - computing disparity.');
labmap = reshape(labels,  [im_h, im_w]);
dmap   = reshape(d_(labels), [im_h, im_w]);
fprintf(' (%.1fs)\n', toc);

end


