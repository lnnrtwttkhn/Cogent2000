function map = getkeymap
% GETKEYMAP returns key IDs
%
% Description:
%     Return a structure containing key IDs.  Structure fields correspond to key names and
%     field values are key IDs.
%
% Usage:
%     map = GETKEYMAP
%
% Arguments:
%     map - keyboard map
%
% Examples:
%     map = getkeymap;  waitkeydown( map.Space ); - wait for space key to be pressed
%     map = getkeymap;  waitkeyup( map.A );       - wait for key a to be released
%
% See also:
%     CONFIG_KEYBOARD, READKEYS, LOGKEYS, WAITKEYDOWN, WAITKEYUP, LASTKEYDOWN, LASTKEYUP, GETKEYDOWN,
%     GETKEYUP, GETKEYMAP, COUNTKEYDOWN, COUNTKEYUP
%
% Cogent 2000 function.
%
% $Rev: 218 $ $Date: 2010-10-27 12:06:55 +0100 (Wed, 27 Oct 2010) $

global cogent;

error( checkkeyboard );

map = cogent.keyboard.map;