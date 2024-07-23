function freq = getsoundfreq( bufnum )
% GETSOUNDFREQ sets frequency of sound buffer
%
% Description:
%    Sets frequency of sound buffer in samples per second
%
% Usage:
%    freq = GETSOUNDFREQ( buff )
%
% Arguments:
%     buff - buffer number
%     freq  - frequency of buffer in sampleds per second
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
freq = CogSound( 'get', cogent.sound.buffer(bufnum), 'frequency');