function tennisrgb(BatLen,BalSiz)
% Sample script tennisrgb v1.33
%
% Creates a bouncing ball tennis game.  The display is in 
% direct colour mode.
%
% Usage:-   tennisrgb(BatLen,BalSiz)
%
%           BatLen = Bat size in pixels (1 to 150)
%           BalSiz = Ball size in pixels (1 to 150)
%
% Default:- tennisrgb(50,30)
%
%           You may omit any arguments sequentially right 
%           to left.
switch nargin
case 0
   BatLen = 50;
   BalSiz = 30;
case 1
   BalSiz = 30;
case 2
otherwise
   PrintUsage
   return
end

if (BatLen < 1)|(BatLen > 150)|(BalSiz < 1)|(BalSiz > 150)
   PrintUsage
   return
end
%
% Rather a lot of globals
%
global	tm BatThick BatLength TopBorder XMouseFactor 
global	YMouseFactor YMouseOffset mode BestScore
global	LastScore BallSize BallPosX BallPosY
global	BallIncX BallIncY BallSpd StartTime
global	BallMinX BallMaxX BallMinY BallMaxY
global	MissDist BatX BatY MinSpd MaxSpd
global	BorderX1 BorderY1 BorderX2 BorderY2
global	SpdFactor
%
% Initialize some globals
%
BatLength = BatLen;
BallSize = BalSiz;
%
% Bat thickness is a constant ratio of the bat length
%
BatThick = fix(1 + 9*BatLength/50);
%
% Speed variables - min, max and factor by which it increases 
% each bounce
%
MinSpd = 2;
MaxSpd = 10;
SpdFactor = 1.05;
%
% Leave some space at the top for the timing statistics
%
TopBorder = 14;
%
% Initialize the starting mode and scores
%
mode = 1;
BestScore = -1;
LastScore = -1;
%
% Initialize the timing statistics
%
tm.FrmCnt = 0;
%
% Pre-calculate the conversion from mouse position
% to bat position
%
XMouseFactor = (640 - BatLength - 2*BatThick)/640;
YMouseFactor = (480 - BatLength - TopBorder - 2*BatThick)/480;
YMouseOffset = -TopBorder/2;
%
% The ball must be within these limits or it either bounces
% or goes off-field (game over)
%
BallMinX = -320 + BatThick + BallSize/2;
BallMaxX = 320 - BatThick - BallSize/2;
BallMinY = -240 + BatThick + BallSize/2;
BallMaxY = 240 - TopBorder - BatThick - BallSize/2;
%
% If the ball is further away than this from the bat when outside
% the above limits it is game over
%
MissDist = (BallSize + BatLength)/2;
%
% These are the in field borders drawn when the game is over
%
BorderX1 = [(BatThick - 320) (BatThick - 320) (320 - BatThick) (320 - BatThick)];
BorderY1 = [(BatThick - 240) (240 - TopBorder - BatThick) (240 - TopBorder - BatThick) (BatThick - 240)];

BorderX2 = [BorderX1(2:end) BorderX1(1)];
BorderY2 = [BorderY1(2:end) BorderY1(1)];
%
% Initialize cogent
%
cgloadlib
%
% Check the version number
%
csd = cggetdata('csd');
if csd.Version < 124
   	disp('This program requires Cogent graphics v1.24 or later')
    return;
end
%
% Open the graphics
%
cgopen(1,0,0,1)
cgalign('c','c')
%
% Create and draw the startup and lose banners
%
cgmakesprite(1,300,100)
cgmakesprite(2,300,100)
DrawBanners
%
% Start the animation loop
%
while animate
end
%
% Close up and return
%
cgshut
%
% Clear globals
%
clear global	tm BatThick BatLength TopBorder 
clear global	XMouseFactor YMouseFactor YMouseOffset
clear global	mode BestScore LastScore BallSize
clear global	BallPosX BallPosY BallIncX BallIncY
clear global	StartTime BallSpd BallMinX BallMaxX
clear global	BallMinY BallMaxY BatX BatY MinSpd MaxSpd
clear global	BorderX1 BorderY1 BorderX2 BorderY2
clear global	MissDist SpdFactor
%
return
%-----------------------------------------------------
% Animation loop
%
function loop = animate

global	BatThick BatLength TopBorder XMouseFactor 
global	YMouseFactor YMouseOffset mode BestScore
global	LastScore BallSize BallPosX BallPosY
global	BallIncX BallIncY StartTime tm BallSpd
global	BallMinX BallMaxX BallMinY BallMaxY
global	BatX BatY StartTime MinSpd MaxSpd
global	BorderX1 BorderY1 BorderX2 BorderY2
%
% Set 'loop' to zero to quit the script
%
loop = 1;
%
% Read the mouse
%
[x,y,bd,bp] = cgmouse;
%
% Upate the bat positions unless we have just lost a game
%
if mode ~= 3
	BatX = x*XMouseFactor;
	BatY = y*YMouseFactor + YMouseOffset;
end
%
% Always draw the bats
%
cgpencol(1,0,0)
cgrect(BatX,BatThick/2 - 240,BatLength,BatThick)
cgrect(BatX,240 - TopBorder - BatThick/2,BatLength,BatThick)

cgpencol(0,0,1)
cgrect(BatThick/2 - 320,BatY,BatThick,BatLength)
cgrect(320 - BatThick/2,BatY,BatThick,BatLength)
%
% Depending on where we are in the game, do different things
%
switch mode
case 1
   %
   % Waiting for a button press to start new game or quit
   %
   if bp > 0
      if bitand(bp,6) > 0
         %
         % Quit the script if middle or right button pressed
         %
         loop = 0;
         return
      elseif bitand(bp,1) > 0
         %
         % Start new game if left button pressed
         %
         % Centre the ball, set mode 2 (play)
         % and record the starting time
         %
         BallPosX = 0;
         BallPosY = 0;
         mode = 2;
         StartTime = tm.S;
         %
         % Start off with the minimum speed and select a random
         % direction
         %
         BallSpd = MinSpd;
         Dir = rand*2*pi;
         BallIncX = BallSpd*cos(Dir);
         BallIncY = BallSpd*sin(Dir);
      end
   end
   %
   % Draw the start new game banner centre-screen
   %
   cgdrawsprite(1,0,0)
case 2
   %
   % Playing the game
   %
   % Draw the ball in the new position
   %
   cgpencol(1,1,1)
   cgrect(BallPosX,BallPosY,BallSize,BallSize)
   %
   % Label it with the score (survival time in seconds)
   %
   cgpencol(0,0,0)
   cgtext(sprintf('%d',fix(tm.S - StartTime)),BallPosX,BallPosY)
   %
   % Update the ball position
   %
   NewPos
   %
   % If we have lost, record the time and update the scores
   %
   if mode == 3
      LastScore = fix(tm.S - StartTime);
      if LastScore > BestScore
         BestScore = LastScore;
		   DrawBanners
      end
   end
case 3
   %
   % Oh dear, just lost a game
   %
   % Wait for a button press to start a new game (mode 1)
   %
   if bp ~= 0
      mode = 1;
      return;
   end
   %
   % Otherwise draw the frozen state of play
   %
   cgpencol(1,1,0)
   cgdraw(BorderX1,BorderY1,BorderX2,BorderY2)
   cgpencol(1,1,1)
   cgrect(BallPosX,BallPosY,BallSize,BallSize)
   %
   % Add the game lost banner
   %
   cgdrawsprite(2,0,0)
end
%
% Flip the screen, clear it and draw up the new timing 
% statistics in the top border
%
TimingStats(cgflip(0,0,0))

return
%-----------------------------------------------------
% Draw up the startup and lose banners
%
function DrawBanners

global	LastScore BestScore

cgfont('Arial',20)
%
% Start new game banner
%
cgsetsprite(1)

cgpencol(1,1,1)
cgrect
cgpencol(0,0,0)
if BestScore > 0
	cgtext(sprintf('LastScore %d BestScore %d',LastScore,BestScore),0,20)
end

cgtext('Hit left mouse button to start',0,0)
cgtext('Hit other button to exit',0,-20)
%
% Lost a game banner
%
cgsetsprite(2)

cgpencol(1,1,1)
cgrect
cgpencol(0,0,0)

cgtext('Sorry, you lose',0,10)
cgtext(sprintf('Your score was %d',LastScore),0,-10)
cgtext('Hit a mouse button to continue',0,-30)

cgsetsprite(0)

cgfont('Courier',10)

return
%-----------------------------------------------------
% Print the timing statistics
%
function TimingStats(S)
%
% Globals
%
global	tm
%
% Has a frame been dropped ?
%
% The average time between frames is (S - tm.S1)/tm.FrmCnt
%
% If the interval differs from the average by more than 2mS
% then assume that a frame has been dropped.
%
% Wait until 100 frames have been completed before applying
% this test though, so that the average is accurate.
%   
if tm.FrmCnt == 0
   tm.S1 = S;
   tm.S = S;
   tm.Drp = 0;
end

if (tm.FrmCnt > 100)
   sAvg = (S - tm.S1)/tm.FrmCnt;
   sDif = S - tm.S;
   if (abs(sAvg - sDif) > 0.002)
      tm.Drp = tm.Drp + 1;
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
cgpencol(1,1,1)

if tm.FrmCnt > 0
    str = sprintf('tennisrgb v1.33 P:%s Tim:%02d:%02d:%02d Frm:%d Av:%-.2fHz Drp:%d',...
        cogstd('spriority'),...
        fix(S/3600),mod(fix(S/60),60),mod(fix(S),60),...
        tm.FrmCnt,...
        (tm.FrmCnt/(S - tm.S1)),...
        tm.Drp);
else
	str = sprintf('tennisrgb v1.33 P:%s Tim:%02d:%02d:%02d Frm:%d Drp:%d',...
        cogstd('spriority'),...
        fix(S/3600),mod(fix(S/60),60),mod(fix(S),60),...
        tm.FrmCnt,...
        tm.Drp);
end

cgtext(str,0,240 - 7)

tm.S = S;
tm.FrmCnt = tm.FrmCnt + 1;

return
%-----------------------------------------------------
% Update the ball position
%
function NewPos

global	BallPosX BallPosY BallIncX BallIncY
global	BallMinX BallMaxX BallMinY BallMaxY
global	BallSpd mode MissDist BatX BatY MaxSpd
global	SpdFactor
%
% Increment the ball position
%
BallPosX = BallPosX + BallIncX;
BallPosY = BallPosY + BallIncY;

Overshoot = 0;

%
% Are we off to the left ?
%
if BallPosX < BallMinX
   if abs(BatY - BallPosY) > MissDist
      %
      % Overshot and missed the bat - game over (mode 3)
      %
      mode = 3;
      return
   end
   %
   % Speed the ball up on the bounce
   % but don't let it get faster than the maximum speed
   %
   BallSpd = min([MaxSpd BallSpd*SpdFactor]);
   %
   % We have overshot by a little way.
   % Bring the ball back to the limit
   %
   Overshoot = (BallMinX - BallPosX)/BallIncX;
   BallPosX = BallMinX;
   BallPosY = BallPosY - Overshoot*BallIncY;
   %
   % Bounce off the left can be -90 to 90 degrees
   % (-0.5 to 0.5 pi radians)
   %
   Dir = (rand - .5)*pi;
   
   BallIncX = BallSpd*cos(Dir);
   BallIncY = BallSpd*sin(Dir);
   %
   % We still have a little bit to travel in the new direction
   %
   Overshoot = 1 - Overshoot; 
elseif BallPosX > BallMaxX
   %
   % Off to the right
   %
   if abs(BatY - BallPosY) > MissDist
      %
      % Overshot and missed the bat - game over (mode 3)
      %
      mode = 3;
      return
   end
   %
   % Speed the ball up on the bounce
   % but don't let it get faster than the maximum speed
   %
   BallSpd = min([MaxSpd BallSpd*SpdFactor]);
   %
   % We have overshot by a little way.
   % Bring the ball back to the limit
   %
   Overshoot = (BallPosX - BallMaxX)/BallIncX;
   
   BallPosX = BallMaxX;
   BallPosY = BallPosY - Overshoot*BallIncY;
   %
   % Bounce off the right can be 90 to 270 degrees
   % (0.5 to 1.5 pi radians)
   %
   Dir = (rand + .5)*pi;
   
   BallIncX = BallSpd*cos(Dir);
   BallIncY = BallSpd*sin(Dir);
   %
   % We still have a little bit to travel in the new direction
   %
   Overshoot = 1 - Overshoot; 
end
%
% Complete any further motion left from the overshoot
%
BallPosX = BallPosX + Overshoot*BallIncX;
BallPosY = BallPosY + Overshoot*BallIncY;

Overshoot = 0;

if BallPosY < BallMinY
   %
   % Off at the bottom
   %
   if abs(BatX - BallPosX) > MissDist
      %
      % Overshot and missed the bat - game over (mode 3)
      %
      mode = 3;
      return
   end
   %
   % Speed the ball up on the bounce
   % but don't let it get faster than the maximum speed
   %
   BallSpd = min([MaxSpd BallSpd*SpdFactor]);
   %
   % We have overshot by a little way.
   % Bring the ball back to the limit
   %
   Overshoot = (BallMinY - BallPosY)/BallIncY;
   
   BallPosY = BallMinY;
   BallPosX = BallPosX - Overshoot*BallIncX;
   %
   % Bounce off the bottom can be 0 to 180 degrees
   % (0 to pi radians)
   %
	Dir = rand*pi;
   
   BallIncX = BallSpd*cos(Dir);
   BallIncY = BallSpd*sin(Dir);
   %
   % We still have a little bit to travel in the new direction
   %
   Overshoot = 1 - Overshoot; 
elseif BallPosY > BallMaxY
   %
   % Off at the top
   %
   if abs(BatX - BallPosX) > MissDist
      %
      % Overshot and missed the bat - game over (mode 3)
      %
      mode = 3;
      return
   end
   %
   % Speed the ball up on the bounce
   % but don't let it get faster than the maximum speed
   %
   BallSpd = min([MaxSpd BallSpd*SpdFactor]);
   %
   % We have overshot by a little way.
   % Bring the ball back to the limit
   %
   Overshoot = (BallPosY - BallMaxY)/BallIncY;
   
   BallPosY = BallMaxY;
   BallPosX = BallPosX - Overshoot*BallIncX;
   %
   % Bounce off the top can be 180 to 360 degrees
   % (1 to 2 pi radians)
   %
	Dir = (rand + 1)*pi;
   
   BallIncX = BallSpd*cos(Dir);
   BallIncY = BallSpd*sin(Dir);
   %
   % We still have a little bit to travel in the new direction
   %   
   Overshoot = 1 - Overshoot; 
end
%
% Complete any further motion left from the overshoot
%
BallPosX = BallPosX + Overshoot*BallIncX;
BallPosY = BallPosY + Overshoot*BallIncY;
%
% It is just possible that a further limit violation has occurred
% If so, just kill it here
%
if BallPosX < BallMinX
   BallPosX = BallMinX;
elseif BallPosX > BallMaxX
   BallPosX = BallMaxX;
end

if BallPosY < BallMinY
   BallPosY = BallMinY;
elseif BallPosY > BallMaxY
   BallPosY = BallMaxY;
end

return
%-----------------------------------------------------
% Print the usage guide for this script
%
function PrintUsage

fprintf('\nusage - tennisrgb(BatLength,BallSize)\n\n')
fprintf('      BatLength = Length of bats (1-150)\n')
fprintf('       BallSize = Size of ball(1-150)\n\n') 

return
