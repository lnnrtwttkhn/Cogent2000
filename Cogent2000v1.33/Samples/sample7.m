% SAMPLE7.M - Visual presentation of words, reading and logging keyboard input. 
%             Reaction times calculated from keyboard input and written to a results file
 
config_display(0)
config_data( 'sample7.dat' );
config_log
config_results('sample7.res');
config_keyboard;
start_cogent;

% Draw fixation point in display buffer 2
preparestring( '+', 2 );

for i = 1:countdatarows
   
   code = getdata( i, 1 );
   word = getdata( i, 2 );
   
   logstring( code );
   logstring( word );
   
   % Draw word in display buffer 1
   clearpict( 1 );
   preparestring( word, 1 );
   
   % Display fixation point and wait 1500ms
   drawpict( 2 );
   wait( 1500 );
   
   % Display word 
   drawpict( 1 );
   
   % Record time at which word is presented
   t0 = time;
   logstring( t0 );
   
   % Clear all key events
   clearkeys;
   
   % Wait until 500ms after word was presented
   waituntil( t0+500 );
   
   % Clear screen and wait until 1000ms after word was presented
   drawpict( 3 );  
   waituntil( t0+1000 );
   
   % Read all key events since CLEARKEYS was called
   readkeys;
   
   % Write key events to log
   logkeys;
   
   % Check key press and calculate the reaction time
   [ key, t, n ] = getkeydown;
   if n == 0
      % no key press
      response = 0;
      rt = 0;
   elseif n == 1
      % single key press
      response = key(1);
      rt = t(1) - t0;
   else
      % multiple key press
      response = 0;
      rt = 0;
   end
   % Add the stimulus, reaction time and key press to the results file. 
   addresults( word, response, rt );
end

stop_cogent;