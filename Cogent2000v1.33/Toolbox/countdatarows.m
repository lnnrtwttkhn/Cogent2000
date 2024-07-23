function  n = countdatarows
% COUNTDATAROWS returns number of rows in cogent data file.
%
% Description:
%     Returns number of rows in file specified by CONFIG_DATA
%
% Usage:
%     COUNTDATAROWS
%
% Arguments:
%     NONE
%
% See also:
%     LOADDATA, GETDATA, COUNTDATAROWS
%
% Cogent 2000 function.
%
% $Rev: 218 $ $Date: 2010-10-27 12:06:55 +0100 (Wed, 27 Oct 2010) $

global cogent;

n = 0;
if isfield(cogent,'data')
    n = length(cogent.data);
end