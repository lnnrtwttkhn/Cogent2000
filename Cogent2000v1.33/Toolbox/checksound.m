function message = checksound( bufnum )
% $Rev: 218 $ $Date: 2010-10-27 12:06:55 +0100 (Wed, 27 Oct 2010) $

global cogent;

if ~isfield( cogent, 'sound' )
    message = 'sound not configured';
elseif bufnum > length(cogent.sound.buffer)  |  bufnum < 1
    message = 'invalid sound buffer';
elseif cogent.sound.buffer(bufnum) == 0
    error( [ 'sound buffer ' num2str(bufnum) ' not prepared' ] );
else
    message = [];
end