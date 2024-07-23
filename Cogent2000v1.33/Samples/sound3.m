% SOUND3.M - Presents visual stimuli, sound stimuli, reads key presses
% and presents feedback

% Configure hardware, input and output files
config_display( 0 );
config_keyboard;
config_sound;
config_data( 'sound3.dat' );
config_log('sound3.log');
config_results('sound3.res');

start_cogent;

% Get map of keyboard to check for key presses
keymap = getkeymap;

% Draw fixation point in display buffer 2
preparestring( '+', 2 );

% Prepare fixation sound (500ms, 200Hz sine wave) in sound buffer 2
preparepuretone( 500, 200, 2 );

for i = 1:countdatarows
   
   % Get data from file
   code      = getdata( i, 1 );
   word      = getdata( i, 2 );
   soundfile = getdata( i, 3 );
   
   % Load sound file into sound buffer 1
   loadsound( soundfile, 1 );
   
   % Draw word in display buffer 1
   clearpict( 1 );
   preparestring( word, 1 );
   
   % Display fixation point, play fixation sound and wait 1500ms
   drawpict( 2 );
   playsound( 2 );
   wait( 1500 );
   
   % Display word 
   drawpict( 1 );
   
   % Play sound file
   playsound( 1 );
   
   % Record time at which word is presented
   t0 = time;
   logstring( t0 );
   
   % Clear all key events
   clearkeys;
   
   % Wait until 500ms after word was presented
   waituntil( t0+500 );
   
   % Clear screen and wait until 2000ms after word was presented
   drawpict( 3 );  
   waituntil( t0+2000 );
   
   % Read all key events since CLEARKEYS was called
   readkeys;
   
   % Write key events to log
   logkeys;
   
   % Check key pressed, set feedback, error code and reaction time
   n = countkeydown;
   [ key, t ] = lastkeydown;
   rt = 0;
   if n == 0
      % no key pressed
      message = 'no response';
      error = 1;
   elseif n > 1
      % multiple key pressed
      message = 'multiple key press';
      error = 2;
   elseif key ~= keymap.Q & key ~= keymap.P
      % keys other than Q or P pressed
      message = 'invalid key press';
      error = 3;
   elseif key == keymap.Q & code == 1
      % Q pressed when P should have been pressed
      message = 'wrong';
      error = 4;
   elseif key == keymap.P & code == 2
      % P pressed when Q should have been pressed
      message = 'wrong';
      error = 5;
   else
      % Correct key press
      message = 'correct';
      rt = t - t0;
      error = 0;
   end
   
   % Present feedback
   clearpict( 1 );
   preparestring( message, 1 );
   drawpict( 1 );
   wait( 1000 );
   
   % Clear screen
   drawpict( 3 );  
   
   % Store code, reaction time and error code in results file
   addresults( code, rt, error );
   
   % Wait for 500ms
   wait( 500 );

end

stop_cogent;