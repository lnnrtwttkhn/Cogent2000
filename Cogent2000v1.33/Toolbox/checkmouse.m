function message = checkmouse
% $Rev: 218 $ $Date: 2010-10-27 12:06:55 +0100 (Wed, 27 Oct 2010) $

global cogent;

if ~isfield( cogent, 'mouse' )
    message = [ 'mouse not configured' ];
elseif ~isfield( cogent.mouse, 'hDevice' )
    message = 'COGENT not started';
else
    message = [];
end