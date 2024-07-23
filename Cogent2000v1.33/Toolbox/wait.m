function wait( duration )
% WAIT waits for a specified duration
%
% Description:
%     Wait for a specified duration (milliseconds)
%
% Usage:
%     WAIT( duration )
%
% Arguments:
%     duration - time in milliseconds to wait
%
% Examples:
%     WAIT( 1000 ) - wait for 1000 milliseconds
%
% See also:
%     TIME, WAIT, WAITUNTIL, START_COGENT
%
% Cogent 2000 function.
%
% $Rev: 297 $ $Date: 2012-08-28 16:06:39 +0100 (Tue, 28 Aug 2012) $

t=time+duration;
while( time < t )
    cogsleep(1)
end