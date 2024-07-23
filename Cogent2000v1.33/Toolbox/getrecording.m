function wave = getrecording
% GETRECORDING get recording buffer and return as matrix.
%
% Description:
%     Get current recording and return as a nchannels by nsamples matlab matrix.
%
% Usage:
%     wave = GETRECORDING
%
% Arguments:
%     NONE
%
% See also:
%     PREPARERECORDING, RECORDSOUND, WAITRECORD
%
%   Cogent 2000 function.
%
% $Rev: 218 $ $Date: 2010-10-27 12:06:55 +0100 (Wed, 27 Oct 2010) $

global cogent;


wave = CogCapture( 'getwave' )';

switch cogent.sound.nbits
    case 8
        wave = wave/127.5 - 1;
    case 16
        wave = wave / 32767;
    otherwise
        error( 'cogent.sound.nbit must be 8 or 16' );
end