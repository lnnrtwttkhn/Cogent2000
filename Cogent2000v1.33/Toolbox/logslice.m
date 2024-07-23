function logslice
% LOGSLICE Transfers scanner slices read by getslice to the log file.
%
% See also:
%   config_serial, getslice, waitslice.
%
% Cogent2000 function
%
% $Rev: 218 $ $Date: 2010-10-27 12:06:55 +0100 (Wed, 27 Oct 2010) $

global cogent;

temp = cogent.scanner;
n = length(temp.slices);
for i = 1:n
    message = sprintf( 'Slice\t%d\tat\t%-8d', temp.slices(i), temp.times(i));
    logstring( message ) ;
end