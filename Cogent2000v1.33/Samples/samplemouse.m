% SAMPLEMOUSE.M - Demonstrates how mouse position can be used to update display.
% Configure mouse in polling mode with 10ms interval
config_mouse(10);  
config_display(0);
start_cogent;
% Define variable map to contain current information about mouse
map = getmousemap; 
x = 0;
y = 0;
while 1
   
   % Draw text at position defined by mouse (0,0 at first).
   clearpict( 1 );
   preparestring( 'SQUEEK!', 1, x, y );
   drawpict( 1 );
   
   % Update mouse map using readmouse.
   readmouse;     
   
   % Update coordinates for text.
   x = x + sum( getmouse(map.X) );
   y = y - sum( getmouse(map.Y) );
   
   % Exit if left mouse button is pressed
   if ~isempty(getmouse(map.Button1)) & any(getmouse(map.Button1) == 128 ) 
      break;
   end
end

stop_cogent;   
   


   