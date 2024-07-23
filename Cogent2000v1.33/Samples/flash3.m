% FLASH3.M - Flicker dartboard for approx 3 seconds and rest for 3 seconds
% The computer display must be in direct color mode to use two buffers
% and the refresh frequency=60Hz (for 3 sec flashing). 
config_display( 1, 1, [0 0 0], [1 1 1], 'Arial', 25, 4, 0)

start_cogent

% prepare the dartboard
preparedartboard([1 2],20,200,10,18);
% draw dartboard
paletteflicker([1 2],0,0,0,32767);

% Wait for keyboard input
pause;

for i=1:5
  
   paletteflicker([1 2],4,4,22,32767);
   wait(3000);

end
stop_cogent