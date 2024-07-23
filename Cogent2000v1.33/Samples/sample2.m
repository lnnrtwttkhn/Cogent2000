% SAMPLE2 - Visual presentation of pictures at a constant rate
%config_display( 0 )

% This is equivalent to:
config_display(0, 1, [0 0 0], [1 1 1], 'Helvetica', 50, 4, 24);

% Specifiy data file to be 'sample1.dat;
config_data( 'sample2.dat' );

start_cogent;


for i = 1:countdatarows
      
   % Draw name of picture file
   file = getdata( i, 1 );
   clearpict( 1 );
   % load picture into buffer 1
   loadpict( file, 1 );
   
   % Display buffer1 and wait 2000ms
   drawpict( 1 );
   wait( 2000 );
     
   % Clear screen and wait 500ms 
   drawpict( 2 );  
   wait( 1000 );
   
end

stop_cogent;
