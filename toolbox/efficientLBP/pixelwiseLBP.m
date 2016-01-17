function LBP= pixelwiseLBP(inImg, varargin) % isRotInv, isChanWiseRot, filtR
%% pixelwiseLBP
% The function implements LBP (Local Binary Pattern analysis).
%
%% Syntax
%  LBP= pixelwiseLBP(inImg);
%
%% Description
% The LBP tests the relation between pixel and it's neighbors, encoding this relation into
%   a binary word. This allows detection of patterns/features.
% The function is inpired by materials published by Matti Pietik?inen in
%   http://www.cse.oulu.fi/CMV/Research/LBP . This implementation hovewer is not totally
%   allighned with the mthods proposed by Professor Pietik?inen (see Issues & Comments).
%
%% Input arguments (defaults exist):
% inImg- input image, a 2D matrix (3D color images will be converted to 2D intensity
%     value images)
% filtR- a 2D matrix representing a round/radial filter. It can be generated using
%   generateRadialFilterLBP function.
% isRotInv- a logical flag. When enabled generated rotation invariant LBP accuired via
%     fining an angle at whihc the LBP og a given pixelis minimal. Icreases run time, and
%     results in a relatively sparce hsitogram (as many combinations disappear).
% isChanWiseRot- a logical flag, when enabled (default value) allowes channel wise
%     rotation. When disabled/false rotation carried out based on roation of first color
%     channel. Supported only when "isEfficent" is enabled. When  "isEfficent" is
%     disabled "isChanWiseRot" is true.
%
%% Output arguments
%   LBP-    LBP image UINT8/UINT16/UINT32/UINT64/DOUBLE of same dimentions
%     [Height x Width] as inImg.
%
%% Issues & Comments
% - Currenlty, all neigbours are treated alike. Basically, we can use wighted/shaped
%     filter.
% - The rotation invariant LBP histogram includes less then bins then regular LBP BY
%     DEFINITION the zero trailing binary words are excluded for example, so it can be
%     reduced to a mush more component representation. Actually for 8 niegbours it's 37
%     bins, instead of 256. An efficnet way to calculate those bins value is needed.
%
%% Example
% img=imread('peppers.png');
% LBP=pixelwiseLBP(img, 'filtR', generateRadialFilterLBP(8, 1), 'isRotInv', true,...
%    'isChanWiseRot', false);
%
% figure;
% subplot(1, 2, 1)
% imshow(img);
% title('Original image');
%
% subplot(1, 2, 2)
% imshow( LBP );
% title('Pixel-wise LBP image');
%
%% See also
% efficientLBP              % an efficient implemetation of LBP, should achive 
%                           % same results MUCH FASTER
% generateRadialFilterLBP   % custom function generating circulat filters
%
%% Revision history
% First version: Nikolay S. 2014-01-09.
% Last update:   Nikolay S. 2014-01-16.
%
% *List of Changes:*
% 2014-01-16- support new radial filetr generation function
%   'generateRadialFilterLBP'. The new filter is 3D shaped, and it is alighned with 
%   "Gray Scale and Rotation Invariant Texture Classification with Local Binary Patterns" 
%   from http://www.ee.oulu.fi/mvg/files/pdf/pdf_6.pdf.
%   Changed filter direction (to CCW), starting point (3 o'clock instead of 12), support 
%   pixels interpolation.

%% Deafult params
isRotInv=false;
isChanWiseRot=false;
filtR=generateRadialFilterLBP(8, 1);

%% Get user inputs overriding default values
funcParamsNames={'filtR', 'isRotInv', 'isChanWiseRot'};
assignUserInputs(funcParamsNames, varargin{:});

if ischar(inImg) && exist(inImg, 'file')==2 % In case of file name input- read graphical file
    inImg=imread(inImg);
end

nClrChans=size(inImg, 3);

inImgType=class(inImg);
calcClass='single';

isCalcClassInput=strcmpi(inImgType, calcClass);
if ~isCalcClassInput
    inImg=cast(inImg, calcClass);
end
imgSize=size(inImg);

filtDims=size(filtR);
nNeigh=filtDims(3);
if nNeigh<=8
    outClass='uint8';
elseif nNeigh>8 && nNeigh<=16
    outClass='uint16';
elseif nNeigh>16 && nNeigh<=32
    outClass='uint32';
elseif nNeigh>32 && nNeigh<=64
    outClass='uint64';
else
    outClass=calcClass;
end

LBP=zeros(imgSize, outClass);
nEps=-3;
weigthVec=reshape(2.^( (1:nNeigh) -1), 1, nNeigh);
%% Primitive pixelwise solution
filtDimsR=floor(filtDims([1, 2])/2); % Filter Radius
% update index values, so it will be from 1 to N-1, where N is number of pixels in
% support area, including the central pixel

% Padding image with zeroes, to deal with the edges
chanImgPad=zeros(imgSize(1)+2*filtDimsR(1), imgSize(2)+2*filtDimsR(2), calcClass);
padImgSize=size(chanImgPad);
currChanLBP=zeros(padImgSize, outClass);
if isRotInv
    if verLessThan('matlab', '7.14') % due to some issue with circshift and non dounle inputs
        iCircShiftMinLBP=zeros(padImgSize, 'double');
    else
        iCircShiftMinLBP=zeros(padImgSize, 'int8'); % outClass % Limits number fo color channels to 127
    end
end

hWaitbar=waitbar(0, 'Calculating LBP in pixel-wise manner',...
    'Name', 'pixel-wise LBP!');
hTicPixelwiseLBP=tic;

for iChan=1:nClrChans
    chanImgPad(( 1+filtDimsR(1) ):( end-filtDimsR(1) ),...
        ( 1+filtDimsR(2) ): (end-filtDimsR(2) ))=inImg(:, :, iChan);
    nRows=padImgSize(1)-2*filtDimsR(1);
    for iRow=( filtDimsR(1)+1 ):( padImgSize(1)-filtDimsR(1) )
        for iCol=( filtDimsR(2)+1 ):( padImgSize(2)-filtDimsR(2) )
            subImg=chanImgPad(iRow+( -filtDimsR(1):filtDimsR(1) ),...
                iCol+( -filtDimsR(2):filtDimsR(2) ));
            % find differences between current pixel, and it's neighours
            diffVec=sum(sum( filtR.*repmat(subImg,[1, 1, nNeigh]) ));
            diffVec=roundnS(diffVec, nEps);
            binaryWord=( diffVec(:)>=0 );
            if isRotInv
                if iChan==1 || isChanWiseRot % go through all posible binary
                    % word combination, finding minimal LBP
                    [minLBP, iCircShiftMinLBP(iRow, iCol)]=...
                        sortNeighbours(binaryWord, weigthVec);
                else % if iChan==1 || isChanWiseRot
                    [minLBP, ~]=sortNeighbours( binaryWord, weigthVec,...
                        iCircShiftMinLBP(iRow, iCol) );
                end % if iChan==1 || isChanWiseRot
            else
                minLBP=weigthVec*binaryWord;
            end % if isRotInv
            currChanLBP(iRow, iCol)=cast( minLBP,  outClass);   % convert to decimal.
        end % for iCol=(1+filtDimsR(2)):(imgSize(2)-filtDimsR(2))
        
        % Present waitbar- a bar with progress, time passed and time remaining
        waitbarTimeRemaining(hWaitbar, hTicPixelwiseLBP,...
            (( iRow-filtDimsR(1) )+nRows*(iChan-1))/(nClrChans*nRows));
    end % for iRow=(1+filtDimsR(1)):(imgSize(1)-filtDimsR(1))
    
    % crop the margins resulting from zero padding
    LBP(:, :, iChan)=currChanLBP(( filtDimsR(1)+1 ):( end-filtDimsR(1) ),...
        ( filtDimsR(2)+1 ):( end-filtDimsR(2) ));
    if iChan==nClrChans
        close(hWaitbar); % close the waitbar
    end
end % for iChan=1:nClrChans


function [minLBP, iCircShift]=sortNeighbours( origBinWord, weigthVec, iShift)

nElems=numel(origBinWord);
if size(origBinWord, 1)~=nElems
    origBinWord=origBinWord(:);
end
if size(weigthVec, 2)~=nElems
    weigthVec=reshape(weigthVec, 1, nElems);
end


if nargin < 3 || isempty(iShift)
    % initial values- current LBP, zero shift
    iCircShift=0;
    minLBP=weigthVec*origBinWord;
    % go through all posible binary word combination, finding minimal LBP
    nShifts=numel(origBinWord)-1;
    
    for iCurrShift=1:nShifts
        origBinWord=circshift(origBinWord, 1);
        currLBP=weigthVec*origBinWord;
        if currLBP < minLBP
            minLBP=currLBP;
            iCircShift=iCurrShift;
        end % if currLBP < minLBP
    end % for iCurrShift=iShift
else
    iCircShift=iShift(1);
    minLBP=weigthVec*circshift(origBinWord, iCircShift);
end % if nargin < 3 || isempty(iShift)
