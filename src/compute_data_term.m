function data_term  = compute_data_term(coorsxy, im, cam, opt)
% Author: cypw
%

%% load parameters
sigma_c_ = opt.sigma_c;
levels_ = opt.levels;

%% init parameters
im_h = opt.im_h;
im_w = opt.im_w;
vec_len = opt.vec_len;
pair_num = length(im) - 1;
posidx_1 = sub2ind([im_h, im_w], coorsxy(2,:), coorsxy(1,:))';

%%  coding image to boost accuracy
feamap_1 = ext_feas(im{1});
intens_1 = reshape(feamap_1,[vec_len,size(feamap_1,3)]).*256;

%% comput pc(.*pv) for each neighborhood frame
pc = zeros(levels_,vec_len);
cands_out = false(levels_,vec_len);
for i_p = 1:pair_num
    
    % pair info
    pair_cam = cam([1,i_p+1],:);
    feamap_2 = ext_feas(im{i_p+1});
    
    % find candidat points for each p`
    [posidx_2, ~, tcands_out] = find_candidats(coorsxy,pair_cam,opt);  
    
    %%  coding image to boost accuracy
    intens_2 = reshape(feamap_2,[vec_len,size(feamap_2,3)]).*256;
    
    %% compute data term
    tpc = zeros(levels_,vec_len);
    parfor i = 1:vec_len
        tpc(:,i) = sigma_c_ ./ (sigma_c_ + sqrt(sum(( ...
            repmat(intens_1(posidx_1(i),:), [levels_,1]) ...
            - intens_2(posidx_2(i,:),:) ).^2,2)));
    end
    mtpc = repmat(min(tpc,[],1),[size(tpc,1),1]);
    tpc(tcands_out) = mtpc(tcands_out);
        
    %% save
    if i_p == 1
        cands_out = tcands_out;
    else
        cands_out = cands_out & tcands_out;
    end
    pc = pc + tpc;    
        
    fprintf('.');
end

%% integrate pc
u_x = 1 ./ max(pc,[],1);
data_term = 1 - repmat(u_x,[levels_,1]) .* pc;
data_term(cands_out) = 1.0;

end







