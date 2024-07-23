function scrollrgb(SqrSiz,Dir,Spd,Den,GMode)
% Sample script scrollrgb v1.33
%
% Creates a smoothly scrolling chessboard display of black
% and white squares.  The display is in direct colour mode.
%
% Usage:-   scrollrgb(SqrSiz,Dir,Spd,Den,GMode)
%
%           SqrSiz = Square size in pixels
%           Dir    = Direction of movement in degrees
%           Spd    = Speed of movement
%           Den    = Density of white to black (0 to 1)
%           GMode  = Graphics mode 1 to 6 
%                    (or -1 to -6 for sub-window mode)
%
% Default:- scrollrgb(8,45,1,0.5,1)
%
%           You may omit any arguments sequentially right 
%           to left.
if nargin == 0
   SqrSiz = 8;
   Dir = 45;
   Spd = 1;
   Den = 0.5;
   GMode = 1;
end

if nargin == 1
   Dir = 45;
   Spd = 1;
   Den = 0.5;
   GMode = 1;
end

if nargin == 2
   Spd = 1;
   Den = 0.5;
   GMode = 1;
end

if nargin == 3
   Den = 0.5;
   GMode = 1;
end

if nargin == 4
   GMode = 1;
end

if Den < 0
   Den = 0.;
end

if Den > 1
   Den = 1.;
end
%*************************************************************
% Calculate the monitor type (1=full display, 0=sub-window)
% from the GMode and make sure GMode is in the range 1 to 6.
%
% Then set the screen width and height appropriately
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
% Load up a suitable font and set alignment mode to horizontal
% and vertical centering
%
cgloadlib

csd = cggetdata('csd');
if csd.Version < 124
   	disp('This program requires Cogent graphics v1.24 or later')
    return;
end

cgopen(GMode,0,0,Mon)

gsd = cggetdata('gsd');
ScrWid = gsd.ScreenWidth;
ScrHgh = gsd.ScreenHeight;

cgscale(ScrWid)

cgfont('Courier',10)

cgalign('c','c')
%*************************************************************
% Make the sprite, initialising it to colour 0,0,0 (black)
% and set the drawing colour to 1,1,1 (white).
%
cgmakesprite(1,ScrWid,ScrHgh,0,0,0)
cgpencol(1,1,1)
%*************************************************************
% Draw the sprite.
%
% How many columns and how many rows are there in the display
% matrix ?
%
cols = fix(ScrWid/SqrSiz);
rows = fix(ScrHgh/SqrSiz);
%
% How many squares are there ?
%
sqrs = cols*rows;
%
% Make a random matrix of the integers 0 to sqrs - 1
%
allmat = randperm(sqrs) - 1;
%
% However, we only want to have a density of 'Den' so just use 
% some of these squares
%
denmat = allmat(1:fix(sqrs*Den));
%
% x co-ordinate is the number in denmat modulo cols multiplied 
% by the square size
%
x = mod(denmat,cols)*SqrSiz + (SqrSiz - ScrWid)/2;
%
% y co-ordinate is the number in denmat divided by cols 
% multiplied by the square size
%
y = fix(denmat/cols)*SqrSiz + (SqrSiz - ScrHgh)/2;
%
% Make an array for the square size, the same length as 
% x & y arrays
%
Siz = ones(1,length(x))*SqrSiz;

cgsetsprite(1)
cgrect(x,y,Siz,Siz)
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
S1 = cgflip;
S = S1;
Drp = 0;
%*************************************************************
% x,y give the current position of the random texture.
%
% dx,dy give the position increment per frame (scaled by the
% global speed argument).
%
x = 0;
y = 0;

dx = round(Spd*cos(Dir*3.141592653/180));
dy = round(Spd*sin(Dir*3.141592653/180));
%*************************************************************
% The main animation loop
%
%
% Set sprite zero
%
cgsetsprite(0)
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
   S = cgflip;
%
% Draw the sprite offset in nine positions.
%
% The sprite is effectively drawn nine times in a three by 
% three matrix to ensure that every part of the destination 
% rectangle is filled.  Any out of range parts are clipped
% so it is safe to do this.
%
   cgdrawsprite(1,x - ScrWid,y - ScrHgh)
   cgdrawsprite(1,x - ScrWid,y)
   cgdrawsprite(1,x - ScrWid,y + ScrHgh)
   cgdrawsprite(1,x         ,y - ScrHgh)
   cgdrawsprite(1,x         ,y)
   cgdrawsprite(1,x         ,y + ScrHgh)
   cgdrawsprite(1,x + ScrWid,y - ScrHgh)
   cgdrawsprite(1,x + ScrWid,y)
   cgdrawsprite(1,x + ScrWid,y + ScrHgh)
%
% Increment the position and keep within range
%
   x = x + dx;
   if (x > ScrWid/2)
      x = x - ScrWid;
      else if x < -ScrWid/2
         x = x + ScrWid;
      end
   end
   
   y = y + dy;
   if (y > ScrHgh/2)
      y = y - ScrHgh;
      else if y < -ScrHgh/2
         y = y + ScrHgh;
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
   cgpencol(0,0,0)
   cgrect(0,ScrHgh/2 - 7,ScrWid,14)
   cgpencol(1,1,1)

   str = sprintf('scrollrgb v1.33 P:%s Tim:%02d:%02d:%02d Frm:%d Av:%-.2fHz Drp:%d',...
   cogstd('spriority'),...
   fix(S/3600),mod(fix(S/60),60),mod(fix(S),60),...
   t,...
   (t/(S - S1)),...
   Drp);
   cgtext(str,0,ScrHgh/2 - 7)
end
cgshut

return