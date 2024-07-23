function config_log( varargin )
% CONFIG_LOG configures log file
%
% Description:
%     Sets the name of the log file.
%
% Usage:
%    CONFIG_LOG               - log file will be named 'Cogent-YYYY-MM-DD-HH-MM-SS.log'
%    CONFIG_LOG( 'test.log' ) - log file is named 'test.log'
%
% Arguments:
%    NONE
%
% Examples:
%
% See also:
%     CONFIG_LOG, LOGSTRING, LOGKEYS, LOGSERIALBYTES
%
% Cogent 2000 function.
%
% $Rev: 218 $ $Date: 2010-10-27 12:06:55 +0100 (Wed, 27 Oct 2010) $

global cogent;

if nargin > 1
    error( 'wrong number of arguments' );
elseif nargin == 1
    cogent.log.filename = varargin{1};
else
    cogent.log.filename = ['Cogent' num2str(datevec(now),'-%02.0f') '.log'];
end