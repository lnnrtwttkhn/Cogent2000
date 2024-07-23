function pos = soundposition( bufnum )
% SOUNDPOSITION returns current play position of sound buffer
%
% Description:
%     Returns current play position of sound buffer.
%
% Usage:
%     SOUNDPOSITION( buff )  - play position of buffer 'buff'
%
% Arguments:
%     buff - sound buffer number
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

pos = CogSound( 'get', cogent.sound.buffer(bufnum), 'position' );