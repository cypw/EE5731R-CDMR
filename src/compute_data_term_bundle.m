function data_term  = compute_data_term_bundle(coorsxy, im, initlab, cam, opt)
% Author: cypw
%

%% load parameters
sigma_c_ = opt.sigma_c;
levels_ = opt.levels;
sigma_d_ = opt.sigma_d;

%% init parameters
im_h = opt.im_h;
im_w = opt.im_w;
vec_len = opt.vec_len;
pair_num = length(im) - 1;
posidx_1  = sub2ind([im_h, im_w], coorsxy(2,:), coorsxy(1,:))';

%%  coding image to boost accuracy
feamap_1 = ext_feas(im{1});
intens_1 = reshape(feamap_1,[vec_len,size(feamap_1,3)]).*256;
clear feamap_1;

%% comput pc(.*pv) for each neighborhood frame
pc = zeros(levels_,vec_len);
cands_out = false(levels_,vec_len);
for i_p = 1:pair_num
    
    % pair info
    feamap_2 = ext_feas(im{i_p+1});
    initlab_2 = initlab{i_p+1};
    
    % find candidat points for each p`
    [posidx_2, candsxy_tp, tcands_out_ttp] = find_candidats(coorsxy,cam([1,i_p+1],:),opt); 
    [     ~, candsxy_ttpt, tcands_out_tpt] = project_points(posidx_2,candsxy_tp,initlab_2,...
                                                            cam([i_p+1,1],:), opt);
    tcands_out = tcands_out_ttp | tcands_out_tpt;
    clear candsxy_tp tcands_out_ttp tcands_out_tpt initlab_2;
    
    %%  coding image to boost accuracy
    intens_2 = reshape(feamap_2,[vec_len,size(feamap_2,3)]).*256;
    clear feamap_2;
    
    %% compute pc
    tpc = zeros(levels_,vec_len);
    parfor i = 1:vec_len
        tpc(:,i) = sigma_c_ ./ (sigma_c_ + sqrt(sum(( ...
            repmat(intens_1(posidx_1(i),:), [levels_,1]) ...
            - intens_2(posidx_2(i,:),:) ).^2,2)));
    end
    mtpc = repmat(min(tpc,[],1),[size(tpc,1),1]);
    tpc(tcands_out) = mtpc(tcands_out);
    clear mtpc;
    
    %% bundle optimization    
    tdist = zeros(size(tpc));
    for i=1:size(coorsxy,2)
        % fast eu distance
        A = squeeze(candsxy_ttpt(1:2,:,i)); B = coorsxy(1:2,i);
        tdist(:,i) = bsxfun(@plus,full(dot(B,B,1)),full(dot(A,A,1))')-full(2*(A'*B));
    end
    tpc = tpc .* exp( - tdist ./ (2*sigma_d_^2) );
    clear tdist
    
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







