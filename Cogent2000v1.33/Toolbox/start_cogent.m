function start_cogent
% START_COGENT initialises Matlab for running Cogent 2000 commands.
%
% Description:
%	  Start initialise Malab for running Cogent 2000.	Call this after devices have been configued.
%
% Usage:
%	  START_COGENT
%
% Arguments:
%	  NONE
%
% Examples:
%
% See also:
%	  STOP_COGENT, TIME, CONFIG_DATA, CONFIG_KEYBOARD, CONFIG_PARALLEL, CONFIG_SOUND, CONFIG_DEVICE,
%	  CONFIG_LOG, CONFIG_RESULTS, CONFIG_DISPLAY  CONFIG_MOUSE, CONFIG_SERIAL
%
% Cogent 2000 function.
%
% $Rev: 218 $ $Date: 2010-10-27 12:06:55 +0100 (Wed, 27 Oct 2010) $

global cogent;
cgloadlib;
cogent.version = '1.29';

cogstd( 'soutstr', [ 'Cogent 2000 Version ' num2str(cogent.version) char(10) ] )
cogstd( 'svers' );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set process priority to high
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CogProcess( 'version' );
cogent.priority.class = CogProcess( 'enumpriorities' );
cogent.priority.old = CogProcess( 'getpriority' );
CogProcess( 'setpriority', cogent.priority.class.high );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialise log file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isfield(cogent,'log') & isfield(cogent.log,'filename')
    cogstd( 'sLogFil', cogent.log.filename );
end
cogent.log.time=0;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialise display
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isfield( cogent, 'display' )
    
    % Clear screen to background colour
    cgopen( cogent.display.res, cogent.display.nbpp, 0, cogent.display.mode );
    bg = cogent.display.bg;
    fg = cogent.display.fg;
    if cogent.display.nbpp~=8
        cgpencol( bg(1), bg(2), bg(3) );
    else
        cgpencol( bg(1) );
    end
    cgrect;
    cgflip;
    if cogent.display.nbpp~=8
        cgpencol( fg(1), fg(2), fg(3) );
    else
        cgpencol( fg(1) );
    end
    
    % Create offscreen buffers
    for i=1:cogent.display.number_of_buffers
        if cogent.display.nbpp~=8
            cgmakesprite( i, cogent.display.size(1), cogent.display.size(2), bg(1), bg(2), bg(3) );
        else
            cgmakesprite( i, cogent.display.size(1), cogent.display.size(2), bg(1) );
        end % if
    end % for
    
    % Setup drawing parameters
    if cogent.display.nbpp~=8
        cgpencol( cogent.display.fg(1), cogent.display.fg(2), cogent.display.fg(3) );
    else
        cgpencol( cogent.display.fg(1) );
    end
    cgfont( cogent.display.font, cogent.display.fontsize );
    
    if isfield( cogent.display, 'scale' )
        cgscale( cogent.display.scale );
    end
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialise sound
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isfield( cogent, 'sound' )
    CogSound( 'Version' );
    CogSound( 'Initialise', cogent.sound.nbits, cogent.sound.frequency, cogent.sound.nchannels );
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialise record
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isfield( cogent, 'record' )
    CogCapture( 'Version' );
    CogCapture( 'Initialise' );
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load and initialise DirectInput if required
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isfield(cogent,'keyboard') | isfield(cogent,'mouse')
    CogInput( 'Version' );
    CogInput( 'Initialise' );
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialise keyboard
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isfield( cogent, 'keyboard' )
    hDevice = CogInput( 'Create', 'keyboard', cogent.keyboard.mode, cogent.keyboard.queuelength );
    cogent.keyboard.hDevice = hDevice;
    cogent.keyboard.map = CogInput( 'GetMap', hDevice );
    CogInput( 'Acquire', hDevice );
    if ( cogent.keyboard.polling_flag )
        CogInput( 'StartPolling', hDevice, cogent.keyboard.resolution );
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialise mouse
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isfield( cogent, 'mouse' )
    cogent.mouse.hDevice = CogInput( 'Create', 'mouse', cogent.mouse.mode, cogent.mouse.queuelength );
    cogent.mouse.map = CogInput( 'GetMap', cogent.mouse.hDevice );
    CogInput( 'Acquire', cogent.mouse.hDevice );
    if ( cogent.mouse.polling_flag )
        CogInput( 'StartPolling', cogent.mouse.hDevice, cogent.mouse.resolution );
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialise serial
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isfield( cogent, 'serial' )
    CogSerial( 'version' );
    for i = 1 : length(cogent.serial)
        port = cogent.serial{i};
        if ~isempty(port)
            port.hPort = CogSerial( 'open', port.name );
            
            attr.Baud = port.baudrate;
            attr.Parity = port.parity;
            attr.StopBits = port.stopbits;
            attr.ByteSize = port.bytesize;
            CogSerial( 'setattr', port.hPort, attr );
            CogSerial( 'record', port.hPort, 200000 );
            
            cogent.serial{i} = port;
        end
    end
end


% Set timer to 0
cogstd( 'sgettime', 0 );

logstring( 'COGENT START' );