function t = time
% TIME returns current time in milliseconds since START_COGENT called.
%
% Description:
%     Returns current time in milliseconds since START_COGENT called.
%
% Usage:
%     t = TIME
%
% Arguments:
%     t - time in milliseconds
%
% Examples:
%
% See also:
%     TIME, WAIT, WAITUNTIL, START_COGENT
%
% Cogent 2000 function.
%
% $Rev: 218 $ $Date: 2010-10-27 12:06:55 +0100 (Wed, 27 Oct 2010) $

t = floor( cogstd('sGetTime',-1) * 1e3 );