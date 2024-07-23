function logstring(a)
% LOGSTRING writes a time tag and string to the console and log file.
%
% Description:
%    Write a time tag and string to the console and log file.
%
% Usage:
%    LOGSTRING( str )
%
% Arguments:
%    str - string to write to console and log file
%
% Examples:
%    LOGSTRING( 'Hello' )
%
% See also:
%    CONFIG_LOG
%
% Cogent 2000 function.
%
% $Rev: 218 $ $Date: 2010-10-27 12:06:55 +0100 (Wed, 27 Oct 2010) $

global cogent;

if ischar(a)
    str = a;
elseif isnumeric(a)
    str = num2str(a);
else
    error( 'argument must be a string or a number' )
end

t = time;

tag = [num2str(t, '%8d') 9 '[' num2str(t-cogent.log.time, '%8d') ']' 9 ':' 9];

cogstd( 'sOutStr', [ tag str char(10) ]) ;
cogent.log.time=t;