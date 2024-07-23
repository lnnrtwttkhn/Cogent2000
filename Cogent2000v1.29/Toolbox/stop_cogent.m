function stop_cogent
% STOP_COGENT returns matlab from Cogent to normal mode.
%
% Description:
%    STOP_COGENT shudown all devices and return Matlab to normal mode
%
% Usage:
%    STOP_COGENT
%
% Arguments:
%     NONE
%
% Examples:
%
% See also:
%    START_COGENT
%
% Cogent 2000 function.

global cogent;

logstring( 'COGENT STOP' );

% Close log file
if isfield( cogent, 'log' )
   cogStd('sLogFil', '');
end

% Save results
if isfield( cogent, 'results' )
   saveresults;
end;

% Restore process priority class
cogprocess( 'setpriority', cogent.priority.old );

if isfield(cogent,'keyboard') | isfield(cogent,'mouse')
   coginput( 'shutdown' );
end

if isfield( cogent, 'sound' )
   cogsound('shutdown');
   cogcapture( 'shutdown' );
end

if isfield( cogent, 'display' )
   cgshut;
end

if isfield( cogent, 'serial' )
   cogserial( 'close' );
end

