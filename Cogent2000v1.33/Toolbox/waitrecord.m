function waitrecord
% WAITRECORD wait for recording to finish
%
% Description:
%    Wait for recording to finish.
%
% Usage:
%    WAITRECORD
%
% Arguments:
%    NONE
%
% See also:
%     PREPARERECORDING, GETRECORDING, RECORDSOUND
%
% Cogent 2000 function.
%
% $Rev: 297 $ $Date: 2012-08-28 16:06:39 +0100 (Tue, 28 Aug 2012) $


while( CogCapture('recording') )
	cogsleep(1)
end