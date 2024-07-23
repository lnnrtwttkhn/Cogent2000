function ballspal(Size,Speed,GMode)
% Sample script ballspal v1.33
%
% Creates a display of coloured circles bouncing around
% at different speeds.  The display is in palette mode.
%
% Usage:-   ballspal(Size,Speed,GMode)
%
%           Size  = Size for the circles
%           Speed = Speed of the circles
%           GMode = Graphics mode 1 to 6 
%                    (or -1 to -6 for sub-window mode)
%
% Default:- ballspal(10,1,1)
%
%           You may omit any arguments sequentially right 
%           to left.
if nargin == 0
   Size = 10;
   Speed = 1;
   GMode = 1;
end

if nargin == 1
   Speed = 1;
   GMode = 1;
end

if nargin == 2
   GMode = 1;
end
%*************************************************************
% Calculate the monitor type (1=full display, 0=sub-window)
% from the GMode and make sure GMode is in the range 1 to 6.
%
Mon = 1;
if GMode < 0
   GMode = -GMode;
   Mon = 0;
end

if GMode < 1
   GMode = 1;
end

if GMode > 6
   GMode = 6;
end
%*************************************************************
% Initialise Cogent, check the version number, open the 
% graphics, get the screen dimensions and set the scale.
% Load up a suitable font
%
cgloadlib

csd = cggetdata('csd');
if csd.Version < 124
   	disp('This program requires Cogent graphics v1.24 or later')
    return;
end

cgopen(GMode,8,0,Mon)

gsd = cggetdata('gsd');
ScrWid = gsd.ScreenWidth;
ScrHgh = gsd.ScreenHeight;

cgscale(ScrWid)

cgfont('Courier',10)
%*************************************************************
% Initialise the palette
%
cgcoltab(1,0,0,0)	% palette index 0 r,g,b = 0,0,0 = black
cgcoltab(1,1,1,1)	% palette index 1 r,g,b = 1,1,1 = white
cgcoltab(2,0,1,1)	% palette index 2 r,g,b = 0,1,1 = cyan
cgcoltab(3,1,0,1)	% palette index 3 r,g,b = 1,0,1 = magenta
cgcoltab(4,0,0,1)	% palette index 4 r,g,b = 0,0,1 = blue
cgcoltab(5,1,1,0)	% palette index 5 r,g,b = 1,1,0 = yellow
cgcoltab(6,0,1,0)	% palette index 6 r,g,b = 0,1,0 = green
cgcoltab(7,1,0,0)	% palette index 7 r,g,b = 1,0,0 = red

cgnewpal
%*************************************************************
% Initialise each 'ball'
%
% maxx,maxy give the maximum position that each ball may move 
% to before it has to bounce off the wall.  This is different
% for different ball sizes as the position is for the centre.
%
% Make a sprite for each ball and set the transparent colour 
% to black for each sprite
%
maxx = [0 0 0 0 0 0 0];
maxy = [0 0 0 0 0 0 0];

for i = 1:7
   j = 8 - i;
   
   maxx(i) = ScrWid/2 - Size*j;
   maxy(i) = ScrHgh/2 - Size*j;
   
   cgmakesprite(i,2*Size*j,2*Size*j,0)
   cgtrncol(i,0)
   cgsetsprite(i)
   cgpencol(i)
   cgellipse(0,0,2*Size*j,2*Size*j,'f')
end
%*************************************************************
% x and y give the co-ordinates of the centre of each ball.
% Start them all off centre-screen
%
x = [0 0 0 0 0 0 0];
y = [0 0 0 0 0 0 0];
%*************************************************************
% dx and dy give the initial speeds of each ball.  These are
% prime numbers.  Scale up by the global Speed value...
%
dx = [ 1  2  3  5  7 11 13];
dy = [ 2  5 11  1  3  7 17];

for i=1:7
   dx(i) = dx(i)*Speed;
   dy(i) = dy(i)*Speed;
end
%*************************************************************
% Set sprite zero and set the pen colour to white
%
cgsetsprite(0)
cgpencol(1)
%*************************************************************
% Initialise the statistics...
%
% S1   is the timestamp at the beginning of the test
% S    is the timestamp of the current frame
% OldS is always the timestamp of the previous flip
% Drp   is the number of frames that have been 'dropped', i.e.
%       the number of times that the time taken between frames
%       indicates that a VBL has been missed
%
S1 = cgflip(0);
S = S1;
Drp = 0;
%*************************************************************
% The main animation loop
%
% t gives the frame number.
% You must break this loop with Ctrl+C and then use Alt+Tab to
% restore the screen
%
t = 0;
%
% We break out of the loop when the escape key is pressed.
% Initialize the state to 'not pressed' (0).
%
kd(1) = 0;
%
while ~kd(1)
%
% Read the keyboard
%
   kd = cgkeymap;
   t = t + 1;
%
% Save the previous timestamp in OldS, flip the screen, clear 
% the next screen to black and save the timestamp in 'S'.
%
   OldS = S;
   S = cgflip(0);
%
% Draw each sprite in turn
%
   cgalign('c','c')

   for i = 1:7
      cgdrawsprite(i,x(i),y(i))
%
% Increment the position of each sprite.  If it goes out of   
% range, bounce it and reverse the direction of movement.
%
      x(i) = x(i) + dx(i);
   
      if (x(i) > maxx(i))
         x(i) = 2*maxx(i) - x(i);
         dx(i) = -dx(i);
      end
      
      if (x(i) < -maxx(i))
         x(i) = -2*maxx(i) - x(i);
         dx(i) = -dx(i);
      end
      
      y(i) = y(i) + dy(i);
      
      if (y(i) > maxy(i))
         y(i) = 2*maxy(i) - y(i);
         dy(i) = -dy(i);
      end
      
      if (y(i) < -maxy(i))
         y(i) = -2*maxy(i) - y(i);
         dy(i) = -dy(i);
      end
   end
%
% Has a frame been dropped ?
%
% The average time between frames is (S - S1)/t
%
% If the interval differs from the average by more than 2mS
% then assume that a frame has been dropped.
%
% Wait until 100 frames have been completed before applying
% this test though, so that the average is accurate.
%   
   if (t > 100)
      sAvg = (S - S1)/t;
      sDif = S - OldS;
      if (abs(sAvg - sDif) > 0.002)
         Drp = Drp + 1;
      end
   end
%
% Draw up the statistics
%
% Priority class for current process
% Time since start of test
% Frames since start of test
% Average refresh rate since start of test
% No of dropped frames
%   
   cgalign('c','t')
   str = sprintf('ballspal v1.33 P:%s Tim:%02d:%02d:%02d Frm:%d Av:%-.2fHz Drp:%d',...
   cogstd('spriority'),...
   fix(S/3600),mod(fix(S/60),60),mod(fix(S),60),...
   t,...
   (t/(S - S1)),...
   Drp);
   cgtext(str,0,ScrHgh/2)
end
cgshut

return