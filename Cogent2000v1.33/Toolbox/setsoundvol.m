function setsoundvol( bufnum, vol )
% SETSOUNDVOL sets volume of sound buffer
%
% Description:
%    Sets volume of sound buffer in hundredths of decibels ( 0 to -10000 )
%
% Usage:
%    SETSOUNDVOL( buff )
%
% Arguments:
%     buff - buffer number
%     vol  - volume of buffer in hundredths of decibels ( 0 to -10000 )
%
% Examples:
%
% See also:
%      CONFIG_SOUND, PREPARESOUND, PREPAREPURETONE, PREPAREWHITENOISE, LOADSOUND, WAITSOUND,
%      SOUNDPOSITION, SETSOUNDFREQ, GETSOUNDFREQ, GETSOUNDVOL, SETSOUNDVOL
%
% Cogent 2000 function.
%
% $Rev: 218 $ $Date: 2010-10-27 12:06:55 +0100 (Wed, 27 Oct 2010) $

global cogent;

error( checksound(bufnum) );
CogSound( 'set', cogent.sound.buffer(bufnum), 'volume', vol );