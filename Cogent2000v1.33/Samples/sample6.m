% SAMPLE6 - Visual presentation of words, reading and logging keyboard input.
config_display(0)
config_keyboard;
config_data( 'sample6.dat' );
config_log( 'sample6.log' );

start_cogent;

preparestring( '+', 2 ); % Draw fixation point in display buffer 2

for i = 1:countdatarows
   
   word = getdata( i, 1 );    
   clearpict( 1 );
   preparestring( word, 1 ); % Draw word in display buffer 1
   
   drawpict( 2 );  % Display fixation point and wait 1500ms
   wait( 1500 );
 
   clearkeys;    % Clear all key events
   t0 = drawpict( 1 ); % Display word and get time
   
   str=sprintf('%s: %d',word,t0);    % Log word and time it was displayed
   logstring(str);
   
   waituntil( t0+500 );    % Wait until 500ms after word was presented
   
   % Clear screen and wait until 1000ms after word was presented
   drawpict( 3 );  
   waituntil( t0+1000 );
   
   % Read all key events since CLEARKEYS was called
   readkeys;
   
   % Write key events to log
   logkeys;
end

stop_cogent;