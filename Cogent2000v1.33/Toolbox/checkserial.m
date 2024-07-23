function message = checkserial( i )
% $Rev: 218 $ $Date: 2010-10-27 12:06:55 +0100 (Wed, 27 Oct 2010) $

global cogent;

if ~isfield( cogent, 'serial' )
    message = [ 'COM' num2str(i) ' not configured' ];
elseif i < 1 | i > length(cogent.serial)
    message = [ 'COM' num2str(i) ' not configured' ];
elseif isempty(cogent.serial{i})
    message = [ 'COM' num2str(i) ' not configured' ];
elseif ~isfield(cogent.serial{i},'hPort')
    message = 'COGENT not started';
else
    message = [];
end