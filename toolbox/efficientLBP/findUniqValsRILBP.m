function uniqueRotInvLBP=findUniqValsRILBP(nNeigh)
%% Eliminate obsolite values form LBP, mapping only relevant ones
% find mapping of all legal binary words to values
valsLBP=(1:2^nNeigh)-1;
weigthVec=2.^( ( 0:(nNeigh-1) ).' );
nVals=numel(valsLBP);

binStr=dec2bin( valsLBP, nNeigh);
histValsBin=false(nVals, nNeigh);
histValsBin(binStr=='1')=true;

possibleLBP=zeros(nVals, nNeigh, 'single');
for iShift=1:nNeigh
    possibleLBP(:, iShift)=histValsBin*weigthVec;
    weigthVec=circshift(weigthVec, 1);
end
valsRotInvLBP=min(possibleLBP, [], 2);

% Find list of unique Rotation invariant LBP values
uniqueRotInvLBP=unique(valsRotInvLBP);