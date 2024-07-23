function chessrgb(SqrWid,SqrHgh,Frm,GMode)
% Sample script chessrgb v1.33
%
% Creates a chessboard display of black and white squares
% which flashes at a constant rate, swapping black and 
% white.  The display is in direct colour mode.
%
% Usage:-   chessrgb(SqrWid,SqrHgh,Frm,GMode)
%
%           SqrWid = Square width in pixels
%           SqrHgh = Square height in pixels
%           Frm    = Flash duration in frames
%           GMode  = Graphics mode 1 to 6 
%                    (or -1 to -6 for sub-window mode)
%
% Default:- chessrgb(8,8,1,1)
%
%           You may omit any arguments sequentially right 
%           to left.
if nargin == 0
   SqrWid = 8;
   SqrHgh = 8;
   Frm = 1;
   GMode = 1;
end

if nargin == 1
   SqrHgh = SqrWid;
   Frm = 1;
   GMode = 1;
end

if nargin == 2
   Frm = 1;
   GMode = 1;
end

if nargin == 3
   GMode = 1;
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
% Make the two sprites
%
% The two sprites will be negatives of each other.
%
% Sprite 1 is initialised to 0,0,0 (black)
% Sprite 2 is initialised to 1,1,1 (white)
%
cgmakesprite(1,ScrWid,ScrHgh,0,0,0)
cgmakesprite(2,ScrWid,ScrHgh,1,1,1)
%*************************************************************
% Draw the two sprites.
%
% How many columns and how many rows are there in the display
% matrix ?
%
cols = fix((ScrWid + SqrWid - 1)/SqrWid);
rows = fix((ScrHgh + SqrHgh - 1)/SqrHgh);
%
% How many squares are there ?
%
sqrs = cols*rows;
%
% Make a random matrix of the integers 0 to sqrs - 1 in
% steps of 2
%
allmat = 0:2:sqrs-1;
%
% The y co-ordinate is the number divided by cols multiplied
% by the square height and offset appropriately
%
y = fix(allmat/cols)*SqrHgh + (SqrHgh - ScrHgh)/2;
%
% The x co-ordinate is the number modulo cols multiplied by
% the square width and offset appropriately. A further offset
% of one square width is required for alternate lines.
%
x = (mod(allmat,cols) + mod(fix(allmat/cols),2))*SqrWid + (SqrWid - ScrWid)/2;
%
% Make arrays for the square dimensions, the same length as 
% x & y arrays
%
Wid = ones(1,length(x))*SqrWid;
Hgh = ones(1,length(x))*SqrHgh;

cgsetsprite(1)
cgpencol(1,1,1)
cgrect(x,y,Wid,Hgh)
         
cgsetsprite(2)
cgpencol(0,0,0)
cgrect(x,y,Wid,Hgh)
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
% FrmCount counts the frames and when it exceeds the global 
% Frm argument it gets reset to zero and we then change 
% sprites.  SprNum indicates which sprite to use (1 or 2)
% 
FrmCount = 0;
SprNum = 1;
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
% Increment FrmCount, take appropriate actions and then draw 
% the sprite.
%
   FrmCount = FrmCount + 1;
   if FrmCount >= Frm
      FrmCount = 0;
      SprNum = 3 - SprNum;
   end

   cgdrawsprite(SprNum,0,0)
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

   str = sprintf('chessrgb v1.33 P:%s Tim:%02d:%02d:%02d Frm:%d Av:%-.2fHz Drp:%d',...
   cogstd('spriority'),...
   fix(S/3600),mod(fix(S/60),60),mod(fix(S),60),...
   t,...
   (t/(S - S1)),...
   Drp);
   cgtext(str,0,ScrHgh/2 - 7)
end
cgshut

return