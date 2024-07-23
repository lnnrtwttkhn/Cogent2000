function loopsound( bufnum )
% LOOPSOUND starts a sound buffer playing in a continuous loop
%
% Description:
%    Starts a sound buffer playing in a continuous loop.  To create this buffer use commands LOADSOUND
%    or PREPARESOUND. To stop buffer from playing use command STOPSOUND.
%
% Usage:
%    LOOPSOUND( buff ) - play sound in buffer 'buff'
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
CogSound( 'play', cogent.sound.buffer(bufnum), 1 );