% SAMPLE10 - Visual presentation of pictures and control of parallel port
config_display(0)
config_data( 'sample10.dat' );
start_cogent;

for i = 1:countdatarows
      
   % Draw name of picture file
   file = getdata( i, 1 );
   code = getdata(i, 2);
   clearpict( 1 );
   % load picture into buffer 1
   loadpict( file, 1 );
   
   % Send signal to parallel port
   outportb(888,bin2dec(code));
   
   % Display buffer1 and wait 2000ms
   drawpict( 1 );
   wait( 2000 );
     
   % Clear screen and wait 500ms 
   drawpict( 2 );  
   wait( 1000 );
   
end

stop_cogent;
