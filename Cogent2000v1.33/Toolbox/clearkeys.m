function clearkeys
% CLEARKEYS clears all keyboard events
%
% Description:
%     Clears all keyboard events.
%
% Usage:
%     CLEARKEYS
%
% Arguments:
%     NONE
%
% Examples:
%
% See also:
%
% Cogent 2000 function.
%
% $Rev: 218 $ $Date: 2010-10-27 12:06:55 +0100 (Wed, 27 Oct 2010) $

global cogent;

error( checkkeyboard );

if ~isfield(cogent.keyboard,'hDevice')
    message = 'START_COGENT must called before calling CLEARKEYS';
end

CogInput( 'GetEvents', cogent.keyboard.hDevice );

cogent.keyboard.time  = [];
cogent.keyboard.id    = [];
cogent.keyboard.value = [];
cogent.keyboard.number_of_responses = 0;