function opt = DefParam(method)
% Author: cypw
%

switch lower(method)
    case 'init'
        opt.d_min = 0;
        opt.d_max = 0.01;
        opt.m = 100;
        opt.levels = opt.m + 1;
        opt.d = linspace(opt.d_min, opt.d_max, opt.levels);
        opt.w_s = 2 / (opt.d_max - opt.d_min);
        opt.ita = 0.05 * (opt.d_max - opt.d_min);
        opt.epsilon = 50;
        opt.sigma_c = 10;
        opt.sigma_d = 2.5;
        opt.alpha = 2;
        opt.beta = 100;
        opt.nbframes = 1:10; % [-nbframe,nbframe]

    case 'bundle'
        opt.d_min = 0;      %　should be the same as 'init'
        opt.d_max = 0.01;   %　should be the same as 'init'
        opt.m = 100;        %　should be the same as 'init'
        opt.levels = opt.m + 1;
        opt.d = linspace(opt.d_min, opt.d_max, opt.levels);
        opt.w_s = 2 / (opt.d_max - opt.d_min);
        opt.ita = 0.05 * (opt.d_max - opt.d_min);
        opt.epsilon = 50;
        opt.sigma_c = 10;
        opt.sigma_d = 2.5;
        opt.alpha = 2;
        opt.beta = 100;
        opt.nbframes = 1:10; % [-nbframe,nbframe]
        
    otherwise
        error('- Illegal method name!');
end


end