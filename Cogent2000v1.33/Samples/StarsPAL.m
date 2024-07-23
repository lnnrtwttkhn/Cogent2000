function starspal(StarType,NumStars)
% Sample script starspal v1.33
%
% Creates a smoothly moving starfield display.  The display 
% is in palette mode.
%
% Usage:-   starspal(StarType,NumStars)
%
%           StarType = Shape for the stars:-
%                          1 = dots
%                          2 = lines
%                          3 = squares
%                          4 = hollow circles
%                          5 = filled circles
%           NumStars = Number of stars to draw
%
% Default:- starspal(5,150)
%
%           You may omit any arguments sequentially right 
%           to left.
switch nargin
case 0
   StarType = 5;
   NumStars = 150;
case 1
   switch StarType
   case 1
      NumStars = 400;
   case 2
      NumStars = 300;
   otherwise
      NumStars = 150;
   end
end

if (StarType < 1)|(StarType > 5)|(NumStars < 1)|(NumStars > 10000)
   PrintUsage
   return
end
%
% Globals
%
global	Num x y Rad Spd MinRad tm
%
% Initialize some globals
%
Num = NumStars;
MinRad = 20;
tm.FrmCnt = 0;
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
cgopen(1,8,0,1)
%
% Set colour 0 to black, colour 201 to white
%
cgcoltab(0,0,0,0)
cgcoltab(201,1,1,1)
%
% Set colors 1 to 200 to a graded change from yellow to magenta
%
for i=1:200
   level = i/200;
   cgcoltab(i,1,1 - level,level);
end

cgnewpal('i')
%
% Initialize the stars
%
InitStars
%
% animate the starfield
%
animate(StarType)
%
% Close up and return
%
cgshut
%
% Clear globals
%
clear global Num x y Rad MinRad Spd
%
return
%-----------------------------------------------------
% This function initializes the sets of dots
%
function InitStars
%
% Globals
%
global Num x y Rad MinRad Spd
%
% The initial distance from centre screen (Rad) takes 
% values from MinRad to 400
%
RngRad = 400 - MinRad;
%
% However, the steady state distribution of stars around
% the centre is logarithmic so perform a log transformation
%
k1 = log(MinRad);
k2 = log(RngRad/MinRad);

Rad = exp(k1 + rand(1,Num)*k2);
%
% The speed factor takes values between 1.01 and 1.02
%
RngSpd = 0.01;
MinSpd = 1 + RngSpd;
%
Spd = MinSpd + rand(1,Num)*RngSpd;
%
% The direction of motion is evenly spaced from 0 to 
% 2.Pi radians (0 - 360 degrees).
%
Dir = linspace(0,2*pi,Num);
%
% Set the initial x and y positions
%
x = Rad.*sin(Dir);
y = Rad.*cos(Dir);

return
%-----------------------------------------------------
% This function animates the starfield
%
function animate(StarType,TimeFactor)
%
% Globals
%
global Num x y Rad MinRad Spd
%
% Set pen colour 1 (white)
%
cgpencol(201)
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
   %
   % Set the offscreen area black
   %
   S = cgflip(0);
   %
   % Set the colour from 1 to 200
   % based on the distance from centre
   %
   Col = 1 + Rad'/2;
   %
   % draw the stars
   %
   switch StarType
   case 1
      %
      % Dots
      %
      cgdraw(x,y,Col)
   case 2
      %
      % lines - draw a short line segment in the direction of 
      % the next dot. These will appear as short 'rays'.
      %      
      cgdraw(x,y,x*1.05,y*1.05,Col)
   case 3
      %
      % Squares - use the returned Rad array
      %
      s = Rad/20;
      cgrect(x,y,s,s,Col)
   case 4
      %
      % Hollow circles - use the returned size array 's'
      %
      s = Rad/20;
      cgellipse(x,y,s,s,Col);
   case 5
      %
      % Filled circles - use the returned size array 's'
      %
      s = Rad/20;
      cgellipse(x,y,s,s,Col,'f');
   end
   %
   % Update the positions
   %
   x = x.*Spd;
   y = y.*Spd;
   Rad = Rad.*Spd;
   %
   % Check for wraparound
   %
   a = find(Rad > 400);
   k = Rad(a)/MinRad;
   x(a) = x(a)./k;
   y(a) = y(a)./k;
   Rad(a) = MinRad;
   %
   % Add the timing statistics
   %
   TimingStats(S)
end

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
   cgfont('Courier',10)
   cgalign('c','c')
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
cgpencol(0)
cgrect(0,240 - 7,640,14)
cgpencol(201)

if tm.FrmCnt > 0
    str = sprintf('starspal v1.33 P:%s Tim:%02d:%02d:%02d Frm:%d Av:%-.2fHz Drp:%d',...
        cogstd('spriority'),...
        fix(S/3600),mod(fix(S/60),60),mod(fix(S),60),...
        tm.FrmCnt,...
        (tm.FrmCnt/(S - tm.S1)),...
        tm.Drp);
else
	str = sprintf('starspal v1.33 P:%s Tim:%02d:%02d:%02d Frm:%d Drp:%d',...
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
% Print the usage guide for this script
%
function PrintUsage

fprintf('\nusage - starspal(StarType,NumStars)\n\n')
fprintf('    StarType = Type of object to draw (1 to 5)\n')
fprintf('               1 = Dot\n')
fprintf('               2 = Short line\n')
fprintf('               3 = Square\n')
fprintf('               4 = Circle outline\n')
fprintf('               5 = Solid circle\n')
fprintf('    NumStars = Number of objects to draw (1 to 10000)\n\n')

return
