function pairwise_term = compute_pairwise_term(coorsxy, im, opt)
% Author: cypw
%

%% load parameters
w_s_ = opt.w_s;
epsilon_ = opt.epsilon;

%% init parameters
im_h = opt.im_h;
im_w = opt.im_w;
vec_len = opt.vec_len;
posidx_1 = sub2ind([im_h, im_w], coorsxy(2,:), coorsxy(1,:))';
intens = {reshape(im{1},[vec_len,size(im{1},3)])'.*256, get_8nb_intens(im{1},1).*256};
N_x = size(intens{2}, 2);

%% compute prior term
% compute u_lambda
fu_lambda = @(ix)(N_x / sum(1./( sqrt( ...
            sum((repmat(intens{1}(:,posidx_1(ix)),[1,N_x]) ...
            - intens{2}(:,:,posidx_1(ix))).^2, 1) ...
            ) + epsilon_)));
u_lambda = arrayfun(fu_lambda, 1:vec_len);

% find 8 nearest neighborhood
E = get_8nb_edge_idx(size(im{1},1), size(im{1},2));

% compute lambda
flambda = @(ix,iy)(w_s_ * u_lambda(ix) / ( ...
      norm(intens{1}(:,posidx_1(ix)) - intens{1}(:,posidx_1(iy))) + epsilon_));
lambda  = arrayfun(flambda, E(:,1), E(:,2));

pairwise_term = sparse(E(:,1), E(:,2), lambda);

end

function intens = get_8nb_intens(im, isEnhance)
% 8 neighborhood

if nargin > 1 && isEnhance    
    im = imfilter(im, fspecial('gaussian',[5 5],0.8));
    im(:,:,1) = 0.774 .* im(:,:,1);
    im(:,:,2) = 1.552 .* im(:,:,2);
    im(:,:,3) = 0.284 .* im(:,:,3);
    f = 2;
else
    f = 1;
end
vec_len = size(im,1) * size(im,2);

nb = { imtranslate(im,[ 0,-f],'FillValues',0), ...
       imtranslate(im,[-f, 0],'FillValues',0), ...
       imtranslate(im,[ 0, f],'FillValues',0), ...
       imtranslate(im,[ f, 0],'FillValues',0), ...
       imtranslate(im,[-f,-f],'FillValues',0), ...
       imtranslate(im,[-f, f],'FillValues',0), ...
       imtranslate(im,[ f, f],'FillValues',0), ... 
       imtranslate(im,[ f,-f],'FillValues',0)  }; 
   
intens = cellfun(@(I)(reshape(I, [vec_len,size(I,3)])), nb, 'Uni', 0);
intens = permute(cat(3, intens{:}),[2,3,1]); % [color,nb,ix]

end

function E = get_8nb_edge_idx(h, w)
%

% speedup
cache_file = sprintf('./tmp/8nb_%dx%d.mat',h,w);
if exist(cache_file, 'file')
    load(cache_file, 'E');
    return;
end

[Y, X] = meshgrid(1:w, 1:h);
nb_sub = permute(get_8nb_intens(cat(3,X,Y)), [3,2,1]); % [ix,nb,xy]
or_sub = repmat(permute(reshape(cat(3,X,Y),[w*h,2]), [1,3,2]), [1,8,1]);

nb_idx = reshape(nb_sub, [numel(nb_sub(:,:,1)),2]);
or_idx = reshape(or_sub, [numel(or_sub(:,:,1)),2]);
idx = (nb_idx(:,1) > 0);

nb_idx = sub2ind([h,w], nb_idx(idx,1), nb_idx(idx,2));
or_idx = sub2ind([h,w], or_idx(idx,1), or_idx(idx,2));
E = [or_idx, nb_idx];

% speedup
if exist('./tmp','dir')
    save(cache_file, 'E');
end

end


