% SAMPLE8.M - Visual presentation of words, reading and logging serial bytes
config_display(0);
config_data( 'sample8.dat' );
config_log( 'sample8.log' );
config_serial( 1 )

start_cogent;

% Draw fixation point in display buffer 2
preparestring( '+', 2 );
for i = 1:countdatarows
   
   t0 = time; 
  % Draw word in display buffer 1
   word = getdata( i, 1 );
   clearpict( 1 );
   preparestring( word, 1 );
   
   % Display fixation point and wait 1500ms
   drawpict( 2 );
   waituntil( t0+1500 );
   
   % Display word 
   t1 = drawpict( 1 );
   
   % Log word and time
   str=sprintf('%s: %d',word,t1);
   logstring( str );
 
   % Clear all key events
   clearserialbytes( 1 );
   
   % Wait until 2000ms after start of trial
   waituntil( t0+2000 );
   
   % Clear screen and wait until 3000ms after start of trial
   drawpict( 3 );  
   waituntil( t0+3000 );
   
   % Read all key events since clearserialbytes was called
   readserialbytes( 1 );
   
   % Write key events to log
   logserialbytes( 1 );
   
end

stop_cogent;