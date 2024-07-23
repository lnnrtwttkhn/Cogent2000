function readserialbytes( port )
% READSERIALBYTES reads bytes sent to serial port since last call to READSERIALBYTES or CLEARSERIALBYTES.
%
% Description:
%     Reads bytes sent to serial port since last call to READSERIALBYTES o CLEARSERIALBYTES.  Once read
%     the bytes can be sent to the log using LOGSERIALBYTES or accessed using GETSERIALPORT.
%
% Usage:
%   READSERIALBYTES( port )
%
% Arguments:
%     port - port number
%
% See also:
%     CONFIG_SERIAL, READSERIALBYTES, SENDSERIALBYTES, LOGSERIALBYTES, WAITSERIALBYTE, GETSERIALBYTES
%
% Cogent 2000 function.
%
% $Rev: 218 $ $Date: 2010-10-27 12:06:55 +0100 (Wed, 27 Oct 2010) $


global cogent;

error( checkserial(port) );

% get port
temp = cogent.serial{port};

% Get recorded bytes
[ temp.value, temp.time ] = CogSerial( 'GetEvents', temp.hPort );
temp.time = floor( temp.time * 1000 );
temp.number_of_responses = length( temp.time );

cogent.serial{port} = temp;