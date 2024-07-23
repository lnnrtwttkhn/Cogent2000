function stopsound( bufnum )
% STOPSOUND stops a sound buffer playing.
%
% Description:
%    Stops a sound buffer playing.
%
% Usage:
%    STOPSOUND( buff ) - play sound in buffer 'buff'
%
% Arguments:
%     buff - buffer number
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
CogSound( 'stop', cogent.sound.buffer(bufnum) );