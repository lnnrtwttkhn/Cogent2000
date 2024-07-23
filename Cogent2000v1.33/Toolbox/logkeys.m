function logkeys
% LOGKEYS transfers all keyboard events read by READKEYS to log.
%
% Description:
%     Transfer all keyboard events read by READKEYS to log.
%
% Usage:
%     LOGKEYS
%
% Arguments:
%     NONE
%
% Examples:
%
% See also:
%     CONFIG_KEYBOARD, READKEYS, LOGKEYS, WAITKEYDOWN, WAITKEYUP, LASTKEYDOWN, LASTKEYUP, GETKEYDOWN,
%     GETKEYUP, GETKEYMAP
%
% Cogent 2000 function.
%
% $Rev: 218 $ $Date: 2010-10-27 12:06:55 +0100 (Wed, 27 Oct 2010) $

global cogent;

error( checkkeyboard );

n = length(cogent.keyboard.id);

for i=1:n
    
    if cogent.keyboard.value(i)
        event = 'DOWN';
    else
        event = 'UP';
    end
    
    message = sprintf( 'Key\t%d\t%s\tat\t%-8d', cogent.keyboard.id(i), event, cogent.keyboard.time(i));
    logstring( message ) ;
    
end