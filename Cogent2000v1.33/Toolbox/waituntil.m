function waituntil( t )
% WAITUNTIL waits until specified time.
%
% Description:
%     Wait until specified time (as measured by function TIME)
%
% Usage:
%     WAITUNTIL( t )
%
% Arguments:
%     t - time in milliseconds measured by function TIME
%
% Examples:
%     WAITUNTIL( 10000 )     - wait until 10000 milliseconds after START_COGENT
%     WAITUNTIL( TIME+1000)  - wait for 1000 milliseconds
%
% See also:
%     TIME, WAIT, WAITUNTIL, START_COGENT
%
% Cogent 2000 function
%
% $Rev: 297 $ $Date: 2012-08-28 16:06:39 +0100 (Tue, 28 Aug 2012) $

while(time < t)
    cogsleep(1)
end