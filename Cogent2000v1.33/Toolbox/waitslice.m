function [s, t] = waitslice( port, n )
% [s, t] = waitslice( port, n )
%
% Waits (forever!) for MRI scanner slice n or greater.
% Returns the actual slice number used and its timestamp.
%
% See also:
%   config_serial, getslice, logslice.
%
% Cogent2000 function
%
% $Rev: 218 $ $Date: 2010-10-27 12:06:55 +0100 (Wed, 27 Oct 2010) $

[s, t] = getslice( port );
while ( s( end ) < n ) % wait for correct slice number
    [s, t] = getslice( port );
end
% discard all but the last slice received.
s = s( end );
t = t( end );