% SAMPLE5 - Visual presentation of words using absolute time
config_display(0)
config_data( 'sample5.dat' );
config_log( 'sample5.log' ); % Configure log file
start_cogent;

preparestring( '+', 2 ); % Draw fixation point in display buffer 2
t0 = drawpict( 2 ); % Draw fixation point and get time 

for i = 1:countdatarows

   code = getdata( i, 1 ); % Get code and word from data file
   word = getdata( i, 2 );
   
   clearpict( 1 );  
   preparestring( word, 1 ); % Put word in buffer 1
   
   waituntil( t0 + 1000 ); % Display fixation point for 1000ms
   
   t1 = drawpict( 1 ); % Display word and get the time 
  
   logstring( word );  % Log word. 
   logstring( code );  % log code.
   logstring( t1 );    % Log time that word is displayed.
    
   waituntil( t0+1500 );% Wait until 1500ms after fixation was first presented
   
   drawpict( 3 );  % Clear screen and wait until 2000ms after fixation was first presented
   waituntil( t0+2000 );
   t0 = drawpict( 2 );   % Display fixation point and get time
end

stop_cogent;