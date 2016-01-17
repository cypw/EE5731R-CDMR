function fea = ext_feas(im)
% 1, R - Color
% 2, G - Color
% 3, B - Color
% 4, H - Color
% 5, LBP_V_3x3 - Structure
% 6, LBP_V_7x7 - Structure
%

imsharpenf = @(I)(imsharpen(I, 'Radius',2,'Amount',1));
imblurf = @(I,sigma)(imfilter(I, fspecial('gaussian',[3 3],sigma)));

% --------------
R = 0.774 .* im(:,:,1);
G = 1.552 .* im(:,:,2);
B = 0.284 .* im(:,:,3);

% --------------
[H,~,V] = rgb2hsv(im);
Hb_ = imblurf(H, 0.8);

% --------------
Hb = imblurf(H, 0.5);
Vb = imblurf(V, 0.5);
nFiltSize = 8; nFiltRadius = 1;
filtR = generateRadialFilterLBP(nFiltSize, nFiltRadius);
LBP_V_3x3 = double(efficientLBP(Vb, 'filtR', filtR, 'isRotInv', false, 'isChanWiseRot', false)) ./ 2^nFiltSize;

Ho = imsharpenf(imblurf(Hb, 0.8));
nFiltSize = 16; nFiltRadius = 3;
filtR = generateRadialFilterLBP(nFiltSize, nFiltRadius);
LBP_H_7x7 = double(efficientLBP(Ho, 'filtR', filtR, 'isRotInv', false, 'isChanWiseRot', false)) ./ 2^nFiltSize;

% --------------
fea = cat(3, R, G, B, Hb_, LBP_V_3x3, LBP_H_7x7);
fea = fea .* (255/sqrt(2));
end