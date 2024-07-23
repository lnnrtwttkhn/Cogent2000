% testmouse.m - testing mouse functionality
config_display(0);
config_mouse(100);
config_keyboard;

start_cogent;

map = getmousemap; 
x=0;
y=0;
n=0
while(1)
    n=n+1
    % Draw text at position defined by mouse (0,0 at first).
    clearkeys;
   clearpict( 1 );
   preparestring( '+', 1, x,y );
   drawpict( 1 );
   
    readmouse;     
    x=x+sum(getmouse(map.X));
    y=y+sum(getmouse(map.Y));
    getmouse(map.Button1)
    getmouse(map.Button2)
    wait(1000);
    readkeys;
    logkeys;
end

stop_cogent;