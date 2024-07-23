function sendserialbytes( port, bytes )
% SENDSERIALBYTES send bytes to serial port
%
% Description:
%     Send bytes to serial port.
%
% Usage:
%     SENDSERIALBYTES( port, bytes )
%
% Arguments:
%     port    - port number
%     bytes   - array of bytes
%
% Examples:
%     SENDSERIALBYTES( 1, 10 )          - Send 10 to COM1
%     SENDSERIALBYTES( 2, [ 1 2 4 8 ] ) - Send the bytes 1, 2, 4, 8 and 16 (in sequence) to COM2
%
% See also:
%     CONFIG_SERIAL, READSERIALBYTES, SENDSERIALBYTES, LOGSERIALBYTES, WAITSERIALBYTE, GETSERIALBYTES
%
% Cogent 2000 function.
%
% $Rev: 218 $ $Date: 2010-10-27 12:06:55 +0100 (Wed, 27 Oct 2010) $

global cogent;

error( checkserial(port) );

CogSerial( 'Write', cogent.serial{port}.hPort, bytes );