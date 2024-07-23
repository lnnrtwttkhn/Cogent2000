% SAMPLE9.M - Visual presentation synchronised with incoming serial bytes.
config_display(1)
config_log;
config_serial(1);

start_cogent;

% Draw fixation point in display buffer 2
preparestring( '.', 1 );
loadpict('ralf.bmp',2);

% Clear serial bytes buffer
clearserialbytes(1);

% Repeat the following stimulus 10 times
% Show fixation, wait for scanner pulse, show stimulus, log subject response
for n=1:10
   drawpict( 1 );
  
   % Wait for a scanner pulse (ie for a zero at serial port 1). 
   % When a zero byte arries, it is logged and the serial buffer is emptied.
   % In the mean time, all other incoming bytes are also logged (ie any
   % subject responses).
   waitserialbyte(1,inf,0);
   
   % Note the time and show stimulus
   t0=time;
   t=drawpict( 2 );
 
   % log the onset
   logstring('onset');
   
   % Show stimulus for 1.5 sec, then back to fixation.
   waituntil( t0+1500 );
   t=drawpict( 1 );
  
   % Log the offset
   logstring('offset');
end

% Read and log any bytes that have arrived since the last waitserialbyte
readserialbytes(1);
logserialbytes(1);

% End of experiment
stop_cogent;