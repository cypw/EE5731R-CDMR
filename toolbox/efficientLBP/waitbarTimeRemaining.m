function waitbarTimeRemaining(h_waitbar,h_tic,waitbar_progress)
%function waitbarTimeRemaining(h_waitbar,h_tic,waitbar_progress)
%
% Functional purpose: To dispaly a modified waitbar with values of "ealpsed
%   time" and "remaining time"
%  
% Input arguments:
%   h_waitbar- a handle to matlab waitbar (it is assumed that appropriate title is added to the waibar figure.
%
%   h_tic- a handle to a tic enabled at the begining of the measured processes.
%
%   waitbar_progress- value between [0,1] describing procces done vs total process that is- current index/total indexes
%
% Output Arguments: None
%  
% Issues & Comments: 
%  
% Author and Date:  Nikolay Skarbnik 14/04/2011 
% Last update: 18/12/2012  waitbar_progress casted to double       
 
toc_val=toc(h_tic)*1e-5;
waitbar_progress=double(waitbar_progress); % for some reason datestr fails to work with single type

waitbar(waitbar_progress,h_waitbar,...
    sprintf('Time  passed   %s  [H:Min:Sec.mSec].\nTime remaining %s  [H:Min:Sec.mSec].',...
    datestr(toc_val,'HH:MM:SS.FFF'),...
    datestr(((1-waitbar_progress)/waitbar_progress*toc_val),'HH:MM:SS.FFF')));
