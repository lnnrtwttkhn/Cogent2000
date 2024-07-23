% FLASH30.M - Flicker dartboard for 30 seconds and return to fixation
% spot for 30 seconds.
% The computer display must be in palette mode 
% and the refresh frequency=60Hz (for 30 flashing). 
config_display( 1, 1, [0 0 0], [1 1 1], 'Arial', 25, 4, 8 )

start_cogent

% prepare the dartboard
preparedartboard(1,20,200,10,18);
% Run paletteflickerrest to get fixation spot.
paletteflickerrest(1,0,0,0,32767);
% Wait for keyboard input
pause;

for i=1:5

   paletteflickerrest(1,4,4,225,32767);
   wait(30000);
 
end
stop_cogent