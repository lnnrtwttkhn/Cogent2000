% SOUND1.M - Plays sound stimuli loaded from a sound file.
config_display(0);
config_sound;
config_data('sound1.dat');

start_cogent;

% Load sound file and play it before trials begin to
% work around problem with waitsound
file = getdata( 1, 1 );
loadsound( file, 1 );         %  Load sound file into buffer 1
playsound( 1);                %  Play sound in buffer 1
waitsound( 1);                %  Wait for sound to finish

for n=1:countdatarows
    file = getdata( n, 1 );       % Get name of sound file
    loadsound( file, 1 );         % Load sound file into buffer 1
    playsound( 1);                % play sound in buffer 1
    waitsound( 1);                % Wait for sound to finish
end

stop_cogent;