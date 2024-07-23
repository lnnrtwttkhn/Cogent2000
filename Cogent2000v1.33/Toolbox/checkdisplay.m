function message = checkdisplay( varargin )
% $Rev: 218 $ $Date: 2010-10-27 12:06:55 +0100 (Wed, 27 Oct 2010) $

global cogent;

buf = default_arg( [], varargin, 1 );

if ~isfield( cogent, 'display' )
    message = [ 'display not configured' ];
elseif ~isempty(buf)  &  ( buf < 0 | buf > cogent.display.number_of_buffers )
    message = 'invalid buffer';
else
    message = [];
end