function saverecording( filename )
% SAVERECORDING saves contents of recording buffer as a WAV file
%
% Description:
%     Saves contents of recording buffer as a WAV file
%
% Usage:
%     SAVERECORDING( filename ) - save recording to file 'filename'

%
% Arguments:
%     filename  - name of recording file
%
% See also:
%     GETRECORDING, RECORDSOUND, WAITRECORD, SAVERECORDING
%
% Cogent 2000 function.
%
% $Rev: 218 $ $Date: 2010-10-27 12:06:55 +0100 (Wed, 27 Oct 2010) $

global cogent;

wave = getrecording;

wavwrite( wave, cogent.sound.frequency, cogent.sound.nbits, filename );