function message = checkkeyboard
% $Rev: 218 $ $Date: 2010-10-27 12:06:55 +0100 (Wed, 27 Oct 2010) $

global cogent;

if ~isfield(cogent,'keyboard')
    message = 'keyboard not configured';
else
    message = [];
end