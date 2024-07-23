function n = countserialbytes( port )
% COUNTSERIALBYTES returns the number of serial bytes read by READSERIALBYTES
%
% Description:
%     COUNTSERIALBYTES returns the number of serial bytes read by READSERIALBYTES
%
% Usage:
%     n = COUNTSERIALBYTES( port )
%
% Arguments:
%     port   - port number
%     n      - number of serial bytes
%
% See also:
%     CONFIG_SERIAL, READSERIALBYTES, SENDSERIALBYTES, LOGSERIALBYTES, WAITSERIALBYTE, GETSERIALBYTES
%
% Cogent 2000 function.
%
% $Rev: 218 $ $Date: 2010-10-27 12:06:55 +0100 (Wed, 27 Oct 2010) $


global cogent;

error( checkserial(port) );

n = length( cogent.serial{port}.time );