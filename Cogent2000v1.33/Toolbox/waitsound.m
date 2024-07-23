function waitsound( bufnum )
% WAITSOUND waits until a sound buffer has stopped playing.
%
% Description:
%     Waits until a sound buffer has stopped playing
%
% Usage:
%     WAITSOUND( buff ) - wait until buffer 'buff' has stopped playing
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
% $Rev: 297 $ $Date: 2012-08-28 16:06:39 +0100 (Tue, 28 Aug 2012) $

global cogent;

error( checksound(bufnum) );

while(  CogSound( 'playing', cogent.sound.buffer(bufnum) )  )
	cogsleep(1)
end