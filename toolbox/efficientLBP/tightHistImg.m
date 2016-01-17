function [outImg, varargout]=tightHistImg(inImg, varargin) % isTight, minQuant, isChanWise, inMap, outMap
%% tightHistImg
% Improve contrast by making matrix/image histogram tight or uniformly distributed.
%
%% Syntax
% outImg=tightHistImg(inImg, isTight, minQuant, isChanWise);
%
%% Description
% The goal of this function is modifiy the input matrix (usually image) contrast, by
%   replaicing its values in a manner that will achive eihter tight histogram (no empty
%   bins), or uniformly distributed hitogram. Both cases will result in a visually
%   appealing contarst. The user can apply this function to the whole matrix at once, or
%   by applying it individually to each 2D slice of the input matrix (color chanel in case
%   of color image).
%
%% Input arguments (defaults exist):
% inImg- a N (0<N<4) dimentional array of numericals.
% isTight- a logical flag. When enables (default) results in tight
%   histogram (no empty bins), otherwise, matrix eleemnst are uniformly
%   distributed among minimal and maximal values of inImg matrix.
% minQuant- a numerical array, specifying the minimal quant defined by the
%   user. Values with resolution below minQuant, will be rounded towards
%   nearest multiply of minQuant. Empty by deafault.
% isChanWise- a logical flag, specifying wether the contrats operation will
%   be common ot all inImg elements, or will be applied individualy to each
%   2D slice of it.
%
%% Output arguments
% outImg- the rusulting matrix, of same class and dimentions as inImg
%
%% Issues & Comments
% Consider adding upper and lower limit inputs.
% Consider using intlut fuction to improve run time in cases of long
%   inMap vetros
%
%% Example I- transfering variables via structure and "name value" pairs
% img = imread('pout.tif'); 
% histeqImg = histeq(img);
% tightImg=tightHistImg(img, true);
% figure;
% subplot(1, 3, 1); imshow(img, []);
% subplot(1, 3, 2); imshow(histeqImg, []);
% subplot(1, 3, 3); imshow(tightImg, []);
% figure;
% subplot(1, 3, 1); imhist(img);
% subplot(1, 3, 2); imhist(histeqImg);
% subplot(1, 3, 3); imhist(tightImg);
%
%% See also
% - intlut              % Matlab function
% - imadjust            % Matlab function
% - intlut              % Matlab function
%
%% Revision history
% First version: Nikolay S. 2014-01-05.
% Last update:   Nikolay S. 2014-01-05.
% 
% *List of Changes:*

%% Deafult params
outMap={};
inMap={};
isChanWise=false;
minQuant=[];
isTight=true;

%% Get user inputs overriding default values
funcParamsNames={'isTight', 'minQuant', 'isChanWise', 'inMap', 'outMap'}; 
assignUserInputs(funcParamsNames, varargin{:});


if isChanWise
    nChans=size(inImg, 3);
    if length(minQuant)~=nChans
        minQuant=repmat( minQuant(1), 1,  nChans );
    end
    
    outImg=zeros( size(inImg), class(inImg) );
    outMap=cell( 1, nChans );
    for iChan=1:nChans
        [outImg(:, :, iChan), outMap{iChan}]=tightHistImgChan( inImg(:, :, iChan),...
            isTight, minQuant(iChan), inMap{iChan}, outMap{iChan} );
    end
else % if isChanWise
    [outImg, outMap]=tightHistImgChan(inImg, isTight, minQuant, inMap, outMap);
end % if isChanWise

if nargout==2
    vargout{2}=outMap;
end

function [outImg, outMap]=tightHistImgChan(inImg, isTight, minQuant, inMap, outMap)

if ~isempty(minQuant) % qunatise
    inImg=minQuant*round(inImg/minQuant);
end
inClass=class(inImg);

if isempty(inMap)
    uniqueInVals=unique(inImg);
    inMap=uniqueInVals; % Source values
end

nInMapVals=length(inMap);
inMin=double( inMap(1) );

if isTight
    % inImg=inImg/minQuant; % now, that all numbers are integers, we can use intlut
    if isempty(minQuant)
        minQuant=double(min( diff(inMap) ));
    end
    outMax=inMin+(nInMapVals-1)*minQuant;
else
    outMax=double( inMap(end) );
end

if isempty(outMap)
    outMap=cast( linspace(inMin, outMax, nInMapVals), inClass); % Target values
end

outImg=zeros( size(inImg), inClass );
for iVal=1:nInMapVals
    outImg( inImg==inMap(iVal) )=outMap(iVal);
end
