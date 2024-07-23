function setsoundposition( bufnum, pos )
% SETSOUNDPOSITION sets current play position of sound buffer
%
% Description:
%     Sets current play position of sound buffer.
%
% Usage:
%     SETSOUNDPOSITION( buff, pos )  - set play position of buffer 'buff'
%
% Arguments:
%     buff - sound buffer number
%     pos  - play position
%
% Examples:
%
% See also:
%     CONFIG_SOUND, PREPARESOUND, PREPAREPURETONE, PREPAREWHITENOISE, LOADSOUND, WAITSOUND,
%     SOUNDPOSITION, LOOPSOUND, STOPSOUND.
%
% Cogent 2000 function.
%
% $Rev: 218 $ $Date: 2010-10-27 12:06:55 +0100 (Wed, 27 Oct 2010) $

global cogent;

error( checksound(bufnum) );

CogSound( 'set', cogent.sound.buffer(bufnum), 'position', pos );