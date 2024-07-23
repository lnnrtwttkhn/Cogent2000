function logserialbytes( port )
% LOGSERIALBYTES transfers serial bytes read by READSERIALBYTES to log file.
%
% Description:
%     Transfers serial bytes read by READSERIALBYTES to log file.
%
% Usage:
%     LOGSERIALBYTES( port )
%
% Arguments:
%     port - port number
%
% Examples:
%
% See also:
%     CONFIG_SERIAL, READSERIALBYTES, SENDSERIALBYTES, LOGSERIALBYTES, WAITSERIALBYTE, GETSERIALBYTES
%
% Cogent 2000 function.
%
% $Rev: 218 $ $Date: 2010-10-27 12:06:55 +0100 (Wed, 27 Oct 2010) $

global cogent;

error( checkserial(port) );

temp = cogent.serial{port};
n = length(temp.value);
for i = 1:n
    message = sprintf( 'Byte\t%d\t%s\tat\t%-8d', temp.value(i), temp.name, temp.time(i));
    logstring( message ) ;
end