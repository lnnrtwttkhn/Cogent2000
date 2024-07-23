function device = config_device( varargin )
% CONFIG_DEVICE configures Direct Input device
%
% $Rev: 218 $ $Date: 2010-10-27 12:06:55 +0100 (Wed, 27 Oct 2010) $

global cogent;

if nargin > 4
    error( 'wrong number of arguments' );
end

device.polling_flag = default_arg( 1,   varargin, 1 );
device.queuelength  = default_arg( 100, varargin, 2 );
device.resolution   = default_arg( 5,   varargin, 3 );
device.mode         = default_arg( 'exclusive', varargin, 4 );
device.time  = [];
device.id    = [];
device.value = [];