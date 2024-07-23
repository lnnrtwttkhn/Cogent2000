function equil
% Sample script equil v1.33
%
% This script uses flicker equiluminance to find
% the equiluminance point between two colours.
%
% Usage:-   equil
global	col colx boxx boxy numbox Mode255 FshCtDwn gpd
%
% Initial colour values are black and white
%
col = [0 0 0;1 1 1];
%
% At this point 0 mouse boxes have been defined
%
numbox = 0;
%
% Initialize Mode255 so that colours are expressed as 
% 0 to 1 and set the flash half-period to 1 frame
%
Mode255 = 0;
FshCtDwn = 1;
%
% Initialize the graphics and if successful go into
% the animation loop
%
if InitGraphics
	AnimGraphics;
end
%
% All done - clear up the graphics
%
ShutGraphics
%
% Clear global variables
%
clear global boxx boxy numbox col colx Mode255 FshCtDwn gpd
%
% and finally return
%
return
%****************************************
% This function initializes the graphics
%
function Success = InitGraphics

global gpd
%
% If Success is returned as zero, it means failure
%
Success = 0;
%
% Open the graphics and check they opened OK
%
cgloadlib
cgopen(1,8,0,1)
if ~gprim('ghwnd')
   return
end

gpd = cggetdata('gpd');
%
% Open OK
%
Success = 1;
%
% Set the font and alignment mode
%
cgfont('Courier',10)
cgalign('c','c')
%
% Set the drawing pen to palette index 1
%
cgpencol(1)
%
% Make the cursor sprite
%
% Palette index 0 appears as black, 1 as white
% and 2 will be transparent
%
CursorImage = [0 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 ...
   				0 0 2 2 2 2 2 2 2 2 2 2 2 2 2 2 ...
               0 1 0 2 2 2 2 2 2 2 2 2 2 2 2 2 ...
               0 1 1 0 2 2 2 2 2 2 2 2 2 2 2 2 ...
               0 1 1 1 0 2 2 2 2 2 2 2 2 2 2 2 ...
               0 1 1 1 1 0 2 2 2 2 2 2 2 2 2 2 ...
               0 1 1 1 1 1 0 2 2 2 2 2 2 2 2 2 ...
               0 1 1 1 1 1 1 0 2 2 2 2 2 2 2 2 ...
               0 1 1 1 1 1 1 1 0 2 2 2 2 2 2 2 ...
               0 1 1 1 1 1 1 1 1 0 2 2 2 2 2 2 ...
               0 1 1 1 1 1 1 1 1 1 0 2 2 2 2 2 ...
               0 1 1 1 1 1 1 0 0 0 0 0 2 2 2 2 ...
               0 1 1 1 0 1 1 0 2 2 2 2 2 2 2 2 ...
               0 1 1 0 0 1 1 0 2 2 2 2 2 2 2 2 ...
               0 1 0 2 2 0 1 1 0 2 2 2 2 2 2 2 ...
               0 0 2 2 2 0 1 1 0 2 2 2 2 2 2 2 ...
               0 2 2 2 2 2 0 1 1 0 2 2 2 2 2 2 ...
               2 2 2 2 2 2 0 1 1 0 2 2 2 2 2 2 ...
               2 2 2 2 2 2 2 0 1 1 0 2 2 2 2 2 ...
               2 2 2 2 2 2 2 0 1 1 0 2 2 2 2 2 ...
               2 2 2 2 2 2 2 2 0 0 2 2 2 2 2 2 ...
            	];
%
% Load up the cursor into sprite 2
%
cgloadarray(2,16,21,CursorImage,[0 0 0;1 1 1;1 0 0],0)
cgtrncol(2,2)
%
% Palette colours are:-
%
% 0 = Background (black)
% 1 = Captions & outlines (white)
% 2 = Red
% 3 = Green
% 4 = Blue
% 5 = Grey
% 6 = Colour 1
% 7 = Colour 2
% 8 = Flashing section
%
cgcoltab(0,[0 0 0;1 1 1;1 0 0;0 1 0;0 0 1;.5 .5 .5;0 0 0;0 0 0;0 0 0])
cgnewpal
%
% Make the background sprite
%
cgmakesprite(1,640,480,0)
cgsetsprite(1)

cgtext('Program equil v1.33 © J Romaya WDCN UCL',0,230)
cgtext('L Mse:Step',-260,-210)
cgtext('R Mse:Cont',-260,-220)
cgtext('  Esc:Exit',-260,-230)
%
% Draw large flashing section
%
cgrect(0,55,632,322,1)
cgrect(0,55,630,320,8)
%
% Draw up the slider controls for rgb colours 1 & 2
%
DrawSliders
%
% Return to offscreen drawing
%
cgsetsprite(0)
cgalign('c','c')

return
%****************************************
% This function checks whether the point 
% is within one of the action boxes
%
function boxnum = CheckBox(x,y)

global boxx boxy
%
% boxx and boxy give the box centre co-ords.
% if x,y is within 5 pixels or less of the
% centre we are inside the box.
%
a = find((abs(x - boxx) < 6)&(abs(y - boxy) < 6));

if length(a) == 1
   boxnum = a;
else
   boxnum = 0;
end

return
%****************************************
% This function draws a slider triangle
%
function Triangle(x,y,size)

global boxx boxy numbox
%
% We are drawing a new mouse control box
% Increment the number of boxes and save
% the centre box position
%
numbox = numbox + 1;

boxx(numbox) = x;
boxy(numbox) = y;
%
% Draw the box outline
%
cgrect(x,y,12,12,1)
cgrect(x,y,10,10,0)
%
% Draw the triangle unless size = 0
%
siz2 = size/2;
size = abs(siz2);

if size > .1
	cgpolygon([(x - siz2) (x + siz2) (x - siz2)],[(y - size) y (y + size)])
end 

return
%****************************************
% This function draws the slider controls
%
function DrawSliders
%
% colx gives the horizontal position for
% colour1 and colour2 respectively
%
% coly gives the vertical position for
% red, grn, blu & gry controls respectively
%
global colx coly

colx = [-180 120];
coly = [-120 -140 -160 -180];
%
% Set drawing pen 1 and alignment mode c,c
%
cgpencol(1)
cgalign('c','c')
%
% What are the captions 1-4 ?
%
RGBStr = {'R' 'G' 'B' 'Grey'};
%
% First draw colour 1 controls, then colour 2
%
for Col=1:2
   x = colx(Col);
   y = coly(1);
   %
   % Draw up the big colour patch (palind = 6 or 7)
   % and label it
   %
   cgrect(x - 110,y - 20,52,52,1)
   cgrect(x - 110,y - 20,50,50,5 + Col)
   cgtext(sprintf('Col%d',Col),x - 110,y - 57)
   %
   % For each colour element Red, Grn, Blu, Gry
   % draw the slider and control buttons
   %
	for RGB=1:4
      y = coly(RGB);
      %
      % Slider box
      %
      cgrect(x,y,102,12,1)
      %
      % Mouse control boxes
      % Big Dec, Sml Dec, Big Inc, Sml Inc
      %
      Triangle(x - 75,y,-10)
      Triangle(x - 60,y,-6)
      Triangle(x + 75,y,10)
      Triangle(x + 60,y,6)
      %
      % Caption for what this is (R/G/B/Grey)
      %
      cgalign('l','c')
      cgtext(RGBStr{RGB},x + 83,y)
      cgalign('c','c')
   end
end
%
% Now the flash period controls
%
x = 0;
y = y - 30;

cgrect(x,y,202,22,1)
cgrect(x,y,200,20,0)
cgtext('Flash period',x,y - 20)

Triangle(x - 125,y,-10)
Triangle(x - 110,y,-6)
Triangle(x + 125,y,10)
Triangle(x + 110,y,6)
%
% Tick box for 255 mode
%
Triangle(x + 250,y,0)
cgtext('255 Mode',x + 250,y - 20)
%
% Show the current values for Mode255 and 
% flash period.  DrwMode255 also redraws
% all the colour sliders and captions.
%
DrwMode255
DrwFsh

return
%****************************************
% This function closes the graphics
%
function ShutGraphics

cgshut

return
%****************************************
% This function returns a mock grey for a 
% colour
%
function gcol = GryCol(ColInd)

global col
%
% Stock conversion colour to b/w is
% Red 35%, Grn 50%, Blu 15%
%
gcol = col(ColInd,1)*.35 + col(ColInd,2)*.5 + col(ColInd,3)*.15;

return;
%****************************************
% This function draws the 255 mode box
%
function DrwMode255

global boxx boxy Mode255
%
% Set sprite 1
%
cgsetsprite(1)
%
% Get the box centre co-ordinates
%
x = boxx(37);
y = boxy(37);
%
% Clear the box contents
%
cgrect(x,y,10,10,0)
%
% If we are in 255 mode draw a thick tick
%
if Mode255
   cgpenwid(2)
   cgdraw(x - 2,y,x,y - 2)
   cgdraw(x,y - 2,x + 4,y + 4)
   cgpenwid(1)
end
%
% Redraw all the colour slider bars so that
% the text captions change
%
for ColInd=1:2
   for RGBInd=1:4
      DrwCol(ColInd,RGBInd)
   end
end
%
% Reset back to sprite 0
%
cgsetsprite(0)

return
%****************************************
% This function draws a colour level
%
function DrwCol(ColInd,RGBInd)

global col colx coly Mode255
%
% Set sprite 1 and left alignment
%
cgsetsprite(1)
cgalign('l','c')
%
% Get the box centre co-ords
%
x = colx(ColInd);
y = coly(RGBInd);

cgpencol(1)

if RGBInd < 4   
   %
   % Get the colour level (0 to 1)
   %
   c = col(ColInd,RGBInd);
   %
   % Clear the caption area
   %
   cgrect(x + 100,y,50,20,0)
   %
   % Write the level in the caption area
   %
   if Mode255
      cgtext(sprintf('%03d',round(c*255)),x + 100,y)
   else
      cgtext(sprintf('%6.4f',c),x + 100,y)
   end
else
   %
   % Grey level has no caption
   %
   c = GryCol(ColInd);
end
%
% Draw the slider contents
%
cgrect(x - 48,y,96,6,0)
cgrect(x - 48,y,round(96*c),6,RGBInd + 1)
%
% Reset back to sprite 0 and centre alignment
%
cgsetsprite(0)
cgalign('c','c')

return
%****************************************
% This function draws the flash rate
%
function DrwFsh

global FshCtDwn boxx boxy gpd
%
% Set sprite 1
%
cgsetsprite(1)
%
% Get the box centre co-ords
%
x = (boxx(33) + boxx(35))/2;
y = boxy(33);
%
% Clear the box and then write the caption
%
cgrect(x,y,200,20,0)
cgtext(sprintf('%d Frames (%.2f Hz)',2*FshCtDwn,gpd.RefRate100/(200*FshCtDwn)),x,y)
%
% Reset back to sprite 0
%
cgsetsprite(0)

return
%****************************************
% This function increments the flash rate
%
function IncFsh(Inc)

global FshCtDwn
%
% Change the value
%
if Inc < 0
   FshCtDwn = max(FshCtDwn + Inc,1);
else
   FshCtDwn = min(FshCtDwn + Inc,100);
end
%
% Draw the new value
%
DrwFsh

return
%****************************************
% This function increments a colour
%
function IncCol(ColInd,RGBInd,Inc)

global col
%
% Increment the value
%
if RGBInd < 4
   %
   % Red, Grn or Blu
   %
	if Inc < 0
	   col(ColInd,RGBInd) = max(col(ColInd,RGBInd) + Inc/255,0);
	else
	   col(ColInd,RGBInd) = min(col(ColInd,RGBInd) + Inc/255,1);
   end
else
   %
   % Grey - first calculate the current pseudo-grey level
   % and store it as the red level
   col(ColInd,1) = GryCol(ColInd);
   %
   % Change the red value
   %
	if Inc < 0
	   col(ColInd,1) = max(col(ColInd,1) + Inc/255,0);
	else
	   col(ColInd,1) = min(col(ColInd,1) + Inc/255,1);
   end
   %
   % Set green and blue the same as red
   %
   col(ColInd,2) = col(ColInd,1);
   col(ColInd,3) = col(ColInd,1);
end

if RGBInd < 4
   %
   % When red, grn or blu has changed, change it
   % and also draw up the new grey slider pos
   %
   DrwCol(ColInd,RGBInd)
   DrwCol(ColInd,4)
else
   %
   % Grey has changed - redraw all sliders
   %
   DrwCol(ColInd,1)
   DrwCol(ColInd,2)
   DrwCol(ColInd,3)
   DrwCol(ColInd,4)
end

return
%****************************************
% This function animates the graphics
%
function AnimGraphics

global	col Mode255 FshCtDwn gpd
%
% FlashState changes between 1 and 2 indicating
% the current flashing colour
%
FlashState = 1;
%
% When the mouse button is held down we only repeat
% the action 20 times a second.  Since we operate
% on a display frame timebase this is the number
% of frames per second divided by 20.  We use 
% RefRate100/2000 here because RefRate100 is 100 
% times the number of frames per second.
%
% Also initialize BtnCount to zero to initiate a 
% button check.
%
BtnCtDwn = round((gpd.RefRate100 + 1000)/2000);
BtnCount = 0;
%
% Set FshCount = 0 to initiaite a flash change
%
FshCount = 0;

while 1
   %
   % Change the button count and reset if 
   % necessary.  Mouse button down commands
   % will only occur if BtnCount = 1.
   %
   BtnCount = BtnCount - 1;
   if BtnCount < 1
      BtnCount = BtnCtDwn;
   end
   %
   % Read the mouse and keyboard
   %
   [x,y,ms,mp] = cgmouse;
   [ks,kp] = cgkeymap;
   %
   % If the escape key has been pressed,
   % return (and exit program).
   %
   if kp(1)
      break
   end
   %
   % Update the display
   %
   cgcoltab(6,col)
   cgcoltab(8,col(FlashState,1:3))   
   cgdrawsprite(1,0,0)
   %
   % Draw the cursor
   %
   cgalign('l','t')
   cgdrawsprite(2,x,y)
   cgalign('c','c')
   %
   % Update the display and palette
   % This is the 'tick' of the animation loop
   %
 	cgflip
   cgnewpal('I')
   %
   % Change the equiluminance colour if necessary
   %
   FshCount = FshCount - 1;
   if FshCount < 1
      FshCount = FshCtDwn;
      FlashState = 3 - FlashState;
   end
   %
   % Now take actions depending on mouse buttons
   % If the left button is pressed or the right or
   % middle buttons are held down AND BtnCount == 1
   % the do the action
   %
   if (bitand(ms,6)&(BtnCount == 1)) | bitand(mp,1)
      %
      % Is the mouse in a box ?
      %
      boxnum = CheckBox(x,y);
      %
      % Carry out actions appropriate to each box
      %
      switch boxnum
      case 0
      case {33 34 35 36}
         %
         % Change the flash period
         %
         if bitand(boxnum,1)
            Inc = 10;
         else
            Inc = 1;
         end
            
         if boxnum < 35
            Inc = -Inc;
         end
            
         IncFsh(Inc)
         FshCount = 0;
      case 37
         %
         % Change the Mode255 state
         %
         if bitand(mp,1)
	         Mode255 = 1 - Mode255;
            DrwMode255
         end
      otherwise
         %
         % Slider controls
         %
         if boxnum < 33
            %
            % Calculate the colour and RGB control
            %
            if boxnum < 17
               ColInd = 1;
            else
               ColInd = 2;
               boxnum = boxnum - 16;
            end
            RGBInd = 1 + fix((boxnum - 1)/4);
            boxnum = boxnum - 4*(RGBInd - 1);
            %
            % Change the value appropriately
            %
            switch boxnum
		      case 1
      		   IncCol(ColInd,RGBInd,-10)
		      case 2
      		   IncCol(ColInd,RGBInd,-1)
		      case 3
      		   IncCol(ColInd,RGBInd,10)
		      case 4
      		   IncCol(ColInd,RGBInd,1)
		      end
         end
      end      
   end
end

return