function dartboard
% Sample script dartboard v1.33
%
% Creates a display of spinning dartboards bouncing
% around the screen.  Uses palette animation to
% revolve the dartboards.
%
% Usage:-   dartboard
global	NumDB db tm NewS rgb
%
% Initialize the timing
%
tm.FrmCnt = 0;
%
% NumDB is the number of dartboard objects created
%
% db is an array of dartboard structures, one for
% each dartboard.  The structure contains data about
% the dartboard position, rotation, movement and
% speed of rotation as well as the colours used
%
NumDB = 0;
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
% Open the graphics and
% set background to mid grey
%
cgopen(1,8,0,1)
cgcoltab(0,.5,.5,.5)
%
% Set colours 201 & 202 to black and white
%
cgcoltab(201,0,0,0);
cgcoltab(202,1,1,1);
cgnewpal
%
% Clear background to black
%
cgflip(201);
%
% Prepare to draw text
%
cgfont('Arial',20);
%
% Create three dartboard objects
%
drawdartboard(160,[0 1 0],[1 1 0],[1 1 1],[0 0 0],-3,-4,3)
drawdartboard(100,[1 0 0],[0 0 1],[1 1 0],[0 1 0],1.2,2,3)
drawdartboard(60,[0 0 0],[1 1 1],[1 0 0],[0 0 1],5,7,9)
%
% Animate until user does a Ctrl+C
%
NewS = cgflip(0);
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

   Animate
end
%
% Shut the graphics and then quit
%
cgshut
%
% Be nice and tidy and clear the variables we have made
%
clear global NumDB db tm OldS rgb

return
%------------------------------------------------------------
% This function puts up some informative text for the user
%
function TellUser(Text)

cgsetsprite(0)
cgpencol(202)
cgtext(Text,0,0)
cgflip(201)

return
%------------------------------------------------------------
% This function animates the display
%
function Animate
%
% Get our global data about the dartboards
%
global NumDB db NewS rgb
%
% Draw into the background
%
cgsetsprite(0)
%
% For each dartboard in turn...
%
for i=1:NumDB
   %
   % Set the colours of the dartboard (these change as it spins)
   %
   setpalette(i)
   %
   % Copy the dartboard sprite into the background at its new pos
   %
   cgdrawsprite(i,db(i).x,db(i).y)
   %
   % Update the rotation angle of the dartboard according to its
   % rotation speed
   %
   db(i).Angle = rem(db(i).Angle + db(i).Rotate,360);
   %
   % Update the dartboard position according to xinc and yinc
   % and make it bounce at the screen edges
   %
   db(i).x = db(i).x + db(i).xinc;
   if (db(i).x < db(i).xmin)|(db(i).x > db(i).xmax)
      db(i).xinc = -db(i).xinc;
      if (db(i).x < db(i).xmin)
         db(i).x = 2*db(i).xmin - db(i).x;
      else
         db(i).x = 2*db(i).xmax - db(i).x;
      end
   end
   
   db(i).y = db(i).y + db(i).yinc;
   if (db(i).y < db(i).ymin)|(db(i).y > db(i).ymax)
      db(i).yinc = -db(i).yinc;
      if (db(i).y < db(i).ymin)
         db(i).y = 2*db(i).ymin - db(i).y;
      else
         db(i).y = 2*db(i).ymax - db(i).y;
      end
   end
end
%
% All dartboards have been drawn into the background.
%
% Add the timing statistics
%
TimingStats(NewS)
%
% Now flip the background to the visible display,
% clearing the background to palette index 0 and
% then activate the new palette colours
%
cgcoltab(1,rgb);
NewS = cgflip(0);
cgnewpal('I')

return
%------------------------------------------------------------
% This function creates a dartboard object
%
function drawdartboard(radius,c1,c2,c3,c4,Rotate,xinc,yinc)
%
% Access the globals
%
global NumDB db rgb
%
% OK - we are making a new dartboard so increment the count by one
%
NumDB = NumDB + 1;
%
% Tell the user what we are doing
%
TellUser(sprintf('Please wait - preparing dartboard number %d',NumDB));
%
% Create the new dartboard structure and initialize all the elements
%
db(NumDB).x = 0;
db(NumDB).y = 0;
db(NumDB).Angle = 0;
db(NumDB).Rotate = rem(Rotate + 360,360);
db(NumDB).xinc = xinc;
db(NumDB).yinc = yinc;
db(NumDB).xmin = radius - 320;
db(NumDB).xmax = 320 - radius;
db(NumDB).ymin = radius - 240;
db(NumDB).ymax = 240 - radius;
%
% Set the starting palette index for this dartboard.
%
% A dartboard has 20 segments so each segment occupies
% 18 degrees.  Adjacent segments are different colours
% and then the pattern repeats.  We allocate enough
% colours for two segments (36 degrees) and we draw 1 
% degree slices so we use 36 colours plus two other
% colours for the bullseye outer and inner rings
%
% Colour 0 is used for the background so the first dartboard
% starts at index 1 and successive dartboards shift by steps
% of 38 colours
%
db(NumDB).PalInd = 38*NumDB - 37;
%
% Initialize the colours in the rgb table
%
% We make a crib table of four blocks of 18 colours; c1, c2, c1, c2
%
% We can then access a block of 36 colours corresponding to any
% rotation angle of 0 to 35 degrees simply by taking the appropriate
% offset into this crib table.  Since the pattern repeats every 36
% degrees we can use this method to set the dartboard colour block 
% for any desired angle.
%
% For example, the 36 colours corresponding to a rotation angle
% of 7 degrees is given by:-
%
%         db.rgb(7:7 + 35,:)
%
for i=1:18
   db(NumDB).rgb(i,1:3) = c1;
   db(NumDB).rgb(i + 18,1:3) = c2;
   db(NumDB).rgb(i + 36,1:3) = c1;
   db(NumDB).rgb(i + 54,1:3) = c2;
end
%
% Set the bullseye colours which never change in the
% main rgb array
%
rgb(db(NumDB).PalInd + 36,1:3) = c3;
rgb(db(NumDB).PalInd + 37,1:3) = c4;
%
% Create a sprite just big enough for the dartboard
% initialing it to palette index 0.
% Set the transparent colour to be palette index 0.
% Set the sprite to receive drawing instructions
%
cgmakesprite(NumDB,radius*2,radius*2,0)
if NumDB > 1
   cgtrncol(NumDB,0)
end
cgsetsprite(NumDB)
%
% For each degree, 0 to 359, draw a one degree segment
% of the circle
%
for i=0:359
   drawseg(db(NumDB).PalInd,i,0,radius)
end
%
% Offset the colour by 18 degrees (to flip the colours)
% and draw the inner rings of the dartboard in a similar 
% way
%
for i=0:359
   drawseg(db(NumDB).PalInd,i,18,radius*.925)
end

for i=0:359
   drawseg(db(NumDB).PalInd,i,0,radius*.5)
end

for i=0:359
   drawseg(db(NumDB).PalInd,i,18,radius*.425)
end
%
% Draw the outer bullseye ring
%
cgpencol(db(NumDB).PalInd + 36)
cgellipse(0,0,radius*.15,radius*.15,'f')
%
% Draw the inner bullseye ring
%
cgpencol(db(NumDB).PalInd + 37)
cgellipse(0,0,radius*.075,radius*.075,'f')

return
%-----------------------------------------------------------
% This function draws a thin 1 degree slice of the dartboard
%
function drawseg(PalInd,angle,coloffset,radius)
%
% Set the colour of the segment
% This is the angle in degrees, modulo 36.
% The coloffset argument is only ever set to 0 or 18
% and it is used to flip the colour on the inner rings
% of the dartboard where necessary
%
c1 = PalInd + rem(angle + coloffset,36);
%
% Calculate the co-ordinates of the three vertices of the 
% triangle used to draw the thin 1 degree segment
%
radian1 = angle*pi/180;
radian2 = (angle + 1)*pi/180;

sin1 = sin(radian1);
cos1 = cos(radian1);

sin2 = sin(radian2);
cos2 = cos(radian2);

x = [0 radius*cos1 radius*cos2];
y = [0 radius*sin1 radius*sin2];
%
% Draw the triangle in the appropriate colour and return
%
cgpencol(c1)
cgpolygon(x,y);

return
%----------------------------------------------------------
% This function sets the palette entries for a particular 
% dartboard.
%
function setpalette(dartboardnum)
%
% Globals
%
global	db rgb
%
% Set some local variables from the dartboard structure
%
angle = db(dartboardnum).Angle;
%
% Get the starting palette index for the dartboard
%
palind = db(dartboardnum).PalInd;

i1 = 1 + fix(rem(angle,36));

rgb(palind:palind + 35,:) = db(dartboardnum).rgb(i1:i1 + 35,:);

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
    str = sprintf('dartboard v1.33 P:%s Tim:%02d:%02d:%02d Frm:%d Av:%-.2fHz Drp:%d',...
        cogstd('spriority'),...
        fix(S/3600),mod(fix(S/60),60),mod(fix(S),60),...
        tm.FrmCnt,...
        (tm.FrmCnt/(S - tm.S1)),...
        tm.Drp);
else
	str = sprintf('dartboard v1.33 P:%s Tim:%02d:%02d:%02d Frm:%d Drp:%d',...
        cogstd('spriority'),...
        fix(S/3600),mod(fix(S/60),60),mod(fix(S),60),...
        tm.FrmCnt,...
        tm.Drp);
end

cgtext(str,0,240 - 7)

tm.S = S;
tm.FrmCnt = tm.FrmCnt + 1;

return
