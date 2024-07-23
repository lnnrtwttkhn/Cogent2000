function config_mouse( varargin )
% CONFIG_MOUSE configures mouse
%
% Description:
%     Configures and sets up mouse
%
% Usage:
%     CONFIG_MOUSE              - configure mouse for non-polling mode
%     CONFIG_MOUSE( interval )  - configure mouse for polling mode
%
% Arguments:
%     interval - sample interval in milliseconds for polling mode
%
% Examples:
%
% See also:
%     CONFIG_MOUSE, WAITMOUSE, PAUSEMOUSE, READMOUSE, GETMOUSE, CLEARMOUSE, GETMOUSEMAP
%
% Cogent 2000 function.
%
% $Rev: 218 $ $Date: 2010-10-27 12:06:55 +0100 (Wed, 27 Oct 2010) $

global cogent;

error( nargchk(0,1,nargin) );

if nargin == 0
    cogent.mouse = config_device( 0, 10000, 5, 'exclusive' );
elseif nargin == 1
    resolution = varargin{1};
    cogent.mouse = config_device( 1, 10000, resolution, 'exclusive' );
end