function XYZDemo(Filename)
% Sample script XYZDemo v1.33
%
% Interactive CIE XYZ/xyY display utility.
%
% Usage:- XYZDemo(Filename)
%
%            Filename = display calibration file name
global  dcf
%
% Check the input arguments
%
if nargin < 1
    PrintUsage
    return
end
%
% Read in the display calibration file
%
dcf = ReadDCF(Filename);
if ~isstruct(dcf)
    return
end
%
% Initialize the graphics
%
if (InitGraphics(Filename) ~= 0)
%
% Main program loop
%
    AnimGraphics
%
% Close the graphics
%
    ShutGraphics
end
%
% Clear global variable
%
clear global dcf

return
%-----------------------------------------------------
% This function initializes the graphics
%
function OK = InitGraphics(Filename)

global  dcf
%
% Initialize the XYZ/RGB conversion functions
%
XYZ2RGB(Filename)
%
% Calculate the phosphor XYZ and xyY values
%
n = length(dcf.CalibLevel);
dcf.RedXYZ = dcf.XYZ(1,n,1:3);
dcf.GrnXYZ = dcf.XYZ(2,n,1:3);
dcf.BluXYZ = dcf.XYZ(4,n,1:3);

dcf.RedxyY = [dcf.RedXYZ(1)/sum(dcf.RedXYZ) dcf.RedXYZ(2)/sum(dcf.RedXYZ) dcf.RedXYZ(2)];
dcf.GrnxyY = [dcf.GrnXYZ(1)/sum(dcf.GrnXYZ) dcf.GrnXYZ(2)/sum(dcf.GrnXYZ) dcf.GrnXYZ(2)];
dcf.BluxyY = [dcf.BluXYZ(1)/sum(dcf.BluXYZ) dcf.BluXYZ(2)/sum(dcf.BluXYZ) dcf.BluXYZ(2)];
%
% Initialize cogent graphics
%
cgloadlib
%
% Select the same resolution as in the display calibration
%
Res = 1;
switch dcf.DspCnf.Width
case 800
    Res = 2;
case 1024
    Res = 3;
case 1152
    Res = 4;
case 1280
    Res = 5;
case 1600
    Res = 6;
end
%
% Open the graphics
%
OK = 0;
cgopen(Res,dcf.DspCnf.Bits,round(dcf.DspCnf.Hz),dcf.DspCnf.Mon)
%
% This bit checks to see whether the graphics were opened 
% successfully
%
if gprim('ghwnd') == 0
    fprintf('Failed to open graphics\n')
	return
end
%
% OK - set the scale and font
%
OK = 1;
cgscale(640);
cgfont('Courier',10)
%
% Set palette colours
%
mypencol(1000,0,0,0)        % 0 = black
mypencol(1001,1,1,1)        % 1 = white
mypencol(1002,1,0,0)        % 2 = red
mypencol(1003,0,1,0)        % 3 = green
mypencol(1004,0,0,1)        % 4 = blue
mypencol(1005,0.5,0.5,0.5)  % 5 = grey
                            %
                            % N.B. palette colour 6 = colour-coded results
                            %      palette colour 7 = sample rectangle colour
%
% Set drawing colour white
%
mypencol(1,1,1,1)
%
% Load up the cursor into sprite 2
% This is done differently for palette and direct mode
%
if dcf.DspCnf.Bits == 8
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
    cgloadarray(2,16,21,CursorImage,[0 0 0;1 1 1;1 0 0],0)
    cgtrncol(2,2)
else
    CursorImage = [0 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; ...
               0 0 0; 0 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; ...
               0 0 0; 1 1 1; 0 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; ...
               0 0 0; 1 1 1; 1 1 1; 0 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; ...
               0 0 0; 1 1 1; 1 1 1; 1 1 1; 0 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; ...
               0 0 0; 1 1 1; 1 1 1; 1 1 1; 1 1 1; 0 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; ...
               0 0 0; 1 1 1; 1 1 1; 1 1 1; 1 1 1; 1 1 1; 0 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; ...
               0 0 0; 1 1 1; 1 1 1; 1 1 1; 1 1 1; 1 1 1; 1 1 1; 0 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; ...
               0 0 0; 1 1 1; 1 1 1; 1 1 1; 1 1 1; 1 1 1; 1 1 1; 1 1 1; 0 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; ...
               0 0 0; 1 1 1; 1 1 1; 1 1 1; 1 1 1; 1 1 1; 1 1 1; 1 1 1; 1 1 1; 0 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; ...
               0 0 0; 1 1 1; 1 1 1; 1 1 1; 1 1 1; 1 1 1; 1 1 1; 1 1 1; 1 1 1; 1 1 1; 0 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; ...
               0 0 0; 1 1 1; 1 1 1; 1 1 1; 1 1 1; 1 1 1; 1 1 1; 0 0 0; 0 0 0; 0 0 0; 0 0 0; 0 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; ...
               0 0 0; 1 1 1; 1 1 1; 1 1 1; 0 0 0; 1 1 1; 1 1 1; 0 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; ...
               0 0 0; 1 1 1; 1 1 1; 0 0 0; 0 0 0; 1 1 1; 1 1 1; 0 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; ...
               0 0 0; 1 1 1; 0 0 0; 1 0 0; 1 0 0; 0 0 0; 1 1 1; 1 1 1; 0 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; ...
               0 0 0; 0 0 0; 1 0 0; 1 0 0; 1 0 0; 0 0 0; 1 1 1; 1 1 1; 0 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; ...
               0 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 0 0 0; 1 1 1; 1 1 1; 0 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; ...
               1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 0 0 0; 1 1 1; 1 1 1; 0 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; ...
               1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 0 0 0; 1 1 1; 1 1 1; 0 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; ...
               1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 0 0 0; 1 1 1; 1 1 1; 0 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; ...
               1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 0 0 0; 0 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; ...
              ];
    cgloadarray(2,16,21,CursorImage)
    cgtrncol(2,'r')
end
%
% Draw the basic screen sprite (#1)
%
cgmakesprite(1,640,480)
cgsetsprite(1)
mypencol(0,0,0,0)
cgrect
mypencol(1,1,1,1)
cgalign('c','t')
cgtext(sprintf('Display calibration file:%s',Filename),0,240)

cgalign('c','c')
[Buff1,Buff2] = WriteXYZ(dcf.RedXYZ);
cgtext(sprintf('Red phosphor X,Y,Z:%-20.20s x,y,Y:%-20.20s',Buff1,Buff2),0,210)

[Buff1,Buff2] = WriteXYZ(dcf.GrnXYZ);
cgtext(sprintf('Grn phosphor X,Y,Z:%-20.20s x,y,Y:%-20.20s',Buff1,Buff2),0,195)

[Buff1,Buff2] = WriteXYZ(dcf.BluXYZ);
cgtext(sprintf('Blu phosphor X,Y,Z:%-20.20s x,y,Y:%-20.20s',Buff1,Buff2),0,180)
%
% Placing objects on the screen
%
s = 250;
s2 = s/2;
xc = -320 + 20 + s2;
yc = -5;

x1 = xc - s2;
y1 = yc - s2;
x2 = xc + s2;
y2 = yc + s2;
%
% dcf.x1,dcf.y1 = placement of CIE xy triangle
% dcf.s = size of triangle
%
dcf.x1 = x1;
dcf.y1 = y1;
dcf.s = s;
%
% dcf.x3,dcf.y3 = centre of "Sample" square
% dcf.s2 = size of "Sample" square
%
dcf.s2 = 100;
dcf.x3 = (320 + x2)/2;
dcf.y3 = -240 + dcf.s2/2 + 30;
%
% dcf.x4,dcf.y4 = centre of "Y" rectangle
%
% s4a = width of "Y" rectangle
% s4b = height of "Y" rectangle and size of triangle boxes
% s4c = spacing between boxes
%
dcf.x4 = (x1 + x2)/2;
dcf.y4 = (y1 - 240)/2;

dcf.s4a = 50;
dcf.s4b = 15;
dcf.s4c = 5;
%
% Draw the "Y" square and triangle boxes
%
cgalign('c','b')
cgtext('Y',dcf.x4,dcf.y4 + dcf.s4b/2 + 5)

drawbox(dcf.x4,dcf.y4,dcf.s4a,dcf.s4b)

off = (dcf.s4a + dcf.s4b)/2 + dcf.s4c;

drawbox(dcf.x4 + off,dcf.y4,dcf.s4b)
drawtri(dcf.x4 + off,dcf.y4,dcf.s4b/2)
drawbox(dcf.x4 - off,dcf.y4,-dcf.s4b)
drawtri(dcf.x4 - off,dcf.y4,-dcf.s4b/2)

off = off + dcf.s4c + dcf.s4b;

drawbox(dcf.x4 + off,dcf.y4,dcf.s4b)
drawtri(dcf.x4 + off,dcf.y4,dcf.s4b)
drawbox(dcf.x4 - off,dcf.y4,-dcf.s4b)
drawtri(dcf.x4 - off,dcf.y4,-dcf.s4b)
%
% Draw the CIE xy triangle
%
cgdraw([x1 x1 x2 x1],[y1 y2 y1 y1],[x1 x2 x1 x1],[y2 y1 y1 y1])
%
% Label the axes
%
cgalign('c','t')
cgtext('0',x1,y1 - 5)
cgtext('x',xc,y1 - 5)
cgtext('1',x2,y1 - 5)

cgalign('r','c')
cgtext('0',x1 - 5,y1)
cgtext('y',x1 - 5,yc)
cgtext('1',x1 - 5,y2)
%
% Draw the monitor gamut triangle
%
rx = dcf.RedxyY(1)*s + x1;
ry = dcf.RedxyY(2)*s + y1;

gx = dcf.GrnxyY(1)*s + x1;
gy = dcf.GrnxyY(2)*s + y1;

bx = dcf.BluxyY(1)*s + x1;
by = dcf.BluxyY(2)*s + y1;

cgdraw([rx gx bx rx],[ry gy by ry],[gx bx rx rx],[gy by ry ry])
%
% Draw the white point at 0.3333,0.3333
%
cgdraw(x1 + s/3,y1 + s/3)
%
% Label the color-coded phosphor vertices
%
cgalign('l','c')
mypencol(2,1,0,0)
cgtext('R',rx,ry)

cgalign('c','b')
mypencol(3,0,1,0)
cgtext('G',gx,gy)

cgalign('r','c')
mypencol(4,0,0,1)
cgtext('B',bx,by)
%
% Prepare for normal drawing
%
cgsetsprite(0)
cgalign('c','c')
mypencol(1,1,1,1)

return
%-----------------------------------------------------
% This function draws a rectangle centred on xc,yc.
% Width w, height h.
%
function drawbox(xc,yc,w,h)

if nargin < 4
    h = w;
end

h = h/2;
w = w/2;

x = [(xc - w) (xc - w) (xc + w) (xc + w) (xc - w)];
y = [(yc - h) (yc + h) (yc + h) (yc - h) (yc - h)];

x2 = [x(2:5) x(1)];
y2 = [y(2:5) y(1)];

cgdraw(x,y,x2,y2)

return;
%-----------------------------------------------------
% This function sets the pen colour according to
% palette/direct mode
%
function mypencol(pal,r,g,b)

global dcf

if dcf.DspCnf.Bits == 8
    if (pal >= 1000)
        cgcoltab(pal - 1000,r,g,b)
        cgnewpal
    else
        cgpencol(pal)
    end
else
    cgpencol(r,g,b)
end

return
%-----------------------------------------------------
% This function draws an arrow triangle centred on 
% xc,yc of size 's'.  Negative S points right.
%
function drawtri(xc,yc,s)

s = s/2;

s2 = abs(s);

x = [(xc - s) (xc - s) (xc + s) (xc - s)];
y = [(yc - s2) (yc + s2) (yc) (yc - s2)];

x2 = [x(2:4) x(1)];
y2 = [y(2:4) y(1)];

cgdraw(x,y,x2,y2)

return;
%-----------------------------------------------------
% This function cleans up the graphics
%
function ShutGraphics

cgshut

return
%-----------------------------------------------------
% This function animates the graphics
%
function AnimGraphics

global  dcf
%
% If a colour is selected with a mouse click, sel becomes 1
%
sel = 0;
%
% Set the initial value of Y to be the lowest phosphor
% brightness and find the maximum value for the monitor
%
YYY = [dcf.RedXYZ(2) dcf.GrnXYZ(2) dcf.BluXYZ(2)];

Y = fix(min(YYY));
MaxY = fix(sum(YYY));

YStr = sprintf('%d',Y);
%
% Main processing loop waits for escape key
%
kd(1) = 0;
while ~kd(1)
    kd = cgkeymap;
    %
    % Read the mouse
    %
    [x,y,bs,bp] = cgmouse;
    %
    % Is the left button down ?
    %
    if bitand(bp,1)
        %
        % If a new colour is selected, NewVal will become 1
        %
        NewVal = 0;
        %
        % Convert MouseX/Y to CIE x/y
        %
        xx = (x - dcf.x1)/dcf.s;
        yy = (y - dcf.y1)/dcf.s;
        
        if ((xx >= 0)&(xx <= 1)&(yy >= 0)&(yy <= 1)&(xx + yy <= 1))
            %
            % OK - this is a valid point within the triangle
            % so we have selected a new value
            %
            CIEx = xx;
            CIEy = yy;
            sel = 1;
            selx = x;
            sely = y;
            NewVal = 1;
        end
        %
        % OK - maybe we are clicking in a "Y" arrow box
        %
        xx = x - dcf.x4;
        yy = y - dcf.y4;

        OldY = Y;
        %
        % Check if we are in a "Y" arrow box and then
        % change "Y" appropriately if we are
        %
        if abs(yy) <= dcf.s4b/2
            xxx = abs(xx) - dcf.s4a/2 - dcf.s4c;
            if (xxx >= 0)&(xxx <= dcf.s4b)
                if xx > 0
                    Y = Y + 1;
                else
                    Y = Y - 1;
                end
            end
            
            xxx = xxx - dcf.s4b - dcf.s4c;
            if (xxx >= 0)&(xxx <= dcf.s4b)
                if xx > 0
                    Y = Y + 10;
                else
                    Y = Y - 10;
                end
            end
        end
        %
        % Keep "Y" within the valid range
        %
        if Y < 0
            Y = 0;
        elseif Y > MaxY
            Y = MaxY;
        end
        %
        % If there is a new value of Y then set NewVal
        %
        if Y ~= OldY
            YStr = sprintf('%d',Y);
            
            NewVal = sel;
        end
        
        if NewVal            
            %
            % We have new xyY - display it
            %
            selstr = sprintf('Selected xyY:%s',WritexyY(CIEx,CIEy,Y));
            %
            % Convert xyY to XYZ
            %
            XYZ = xyY2XYZ([CIEx CIEy Y]);
            %
            % Now calculate RGB from XYZ
            %
            [ResRGB,CIEErr] = XYZ2RGB(XYZ);
            %
            % Set palette colour 7 to ResRGB
            %
            mypencol(1007,ResRGB(1),ResRGB(2),ResRGB(3))
            %
            % Convert from RGB back to XYZ
            %
            ResXYZ = RGB2XYZ(ResRGB);
            %
            % Code up the conversion info
            %
            rgbstr = sprintf('  Result RGB:%.4f,%.4f,%.4f',ResRGB);
            [Buff1,Buff2] = WriteXYZ(ResXYZ);
            XYZstr = sprintf('  Result XYZ:%s',Buff1);
            xyYstr = sprintf('  Result xyY:%s',Buff2);
            %
            % Calculate the position on the plot for the back-calculated
            % XYZ
            %
            resx = dcf.x1 + dcf.s*ResXYZ(1)/sum(ResXYZ);
            resy = dcf.y1 + dcf.s*ResXYZ(2)/sum(ResXYZ);
            %
            % If there has been an error, select a different colour 
            % for the results text and prepare the error string
            %
			ErrStr = '';
            switch CIEErr
            case 0
                rescol = [0.5 0.5 0.5]; % Gry - no error
            case {1 2 3 4 5 6 7}
				rescol = [0 0 0];
 				if bitand(CIEErr,1)
                   rescol(3) = 1;       % Blue - XYZ range
				   ErrStr = [ErrStr 'Range/'];
				end
 				if bitand(CIEErr,2)
                   rescol(1) = 1;       % Red - Y too high 
				   ErrStr = [ErrStr 'High Y/'];
				end
 				if bitand(CIEErr,4)
                   rescol(2) = 1;       % Grn - gamut
				   ErrStr = [ErrStr 'Gamut/'];
			    end 
				l = length(ErrStr);
				if l > 0
					ErrStr = ErrStr(1:l - 1);
				end
			 otherwise
				rescol = [0.5 0.5 0]	% brown - other error
				ErrStr = sprintf('%d',CIEErr);
             end
            
            mypencol(1006,rescol(1),rescol(2),rescol(3))
        end
    end
    %
    % Draw the background sprite
    %
    mypencol(0,0,0,0)
    cgrect
    cgdrawsprite(1,0,0)
    %
    % Add the current value of "Y"
    %
    mypencol(1,1,1,1)
    cgtext(YStr,dcf.x4,dcf.y4)
    
    cgalign('l','t')

    if sel
        %
        % Draw the selected xy values as a white ellipse
        %
        cgellipse(selx,sely,8,8,'f')
        %
        % Colour-code the next drawn items for errors
        %
        mypencol(6,rescol(1),rescol(2),rescol(3))
        %
        % Draw the back-calculated xy as a cross.
        %
        cgdraw(resx - 6,resy,resx + 6,resy)
        cgdraw(resx,resy - 6,resx,resy + 6)
        %
        % Write up error message if necessary
        %
		if CIEErr ~= 0
	        cgtext(['ERROR:- ' ErrStr],dcf.x1 + dcf.s + 10,dcf.y1 + dcf.s - 15);
		end
        %
        % Put up the rest of the results
        %
        cgtext(rgbstr,dcf.x1 + dcf.s + 10,dcf.y1 + dcf.s - 30);
        cgtext(XYZstr,dcf.x1 + dcf.s + 10,dcf.y1 + dcf.s - 45);
        cgtext(xyYstr,dcf.x1 + dcf.s + 10,dcf.y1 + dcf.s - 60);
        %
        % Stop colour-coding - back to white
        %
        mypencol(1,1,1,1)
        %
        % Display the selected xyY values, repeated for convenience
        %
        cgtext(selstr,dcf.x1 + dcf.s + 10,dcf.y1 + dcf.s);
        cgtext(selstr,dcf.x1 + dcf.s + 10,dcf.y1 + dcf.s - 75);
        
        cgalign('c','t')
        cgtext('Sample',dcf.x3,dcf.y3 - dcf.s2/2 - 5)

        cgalign('c','c')
        cgrect(dcf.x3,dcf.y3,dcf.s2 + 4,dcf.s2 + 4)
        mypencol(7,ResRGB(1),ResRGB(2),ResRGB(3))
        cgrect(dcf.x3,dcf.y3,dcf.s2,dcf.s2)
        mypencol(1,1,1,1)

        cgalign('l','t')
    else
        cgalign('c','b')
        cgtext('Click in the gamut triangle',dcf.x1 + dcf.s/2,dcf.y1 + dcf.s + 5)
        cgalign('l','t')
    end

    cgdrawsprite(2,x,y)
    cgalign('c','c')
    
    cgflip
end

return
%-----------------------------------------------------
% Code up an XYZ value into a string
%
function [Txt1,Txt2] = WriteXYZ(XYZ)

T1a = sprintf('%.4f',XYZ(1));
T1b = sprintf('%.4f',XYZ(2));
T1c = sprintf('%.4f',XYZ(3));

Txt1 = sprintf('%s,%s,%s',T1a(1:5),T1b(1:5),T1c(1:5));

T2c = sprintf('%.4f',XYZ(2));

Txt2 = sprintf('%.4f,%.4f,%s',XYZ(1)/sum(XYZ),XYZ(2)/sum(XYZ),T2c(1:5));

return
%-----------------------------------------------------
% Code up xyY value into a string
%
function Str = WritexyY(x,y,Y2)

s = sprintf('%.4f',Y2);

Str = sprintf('%.4f,%.4f,%s',x,y,s(1:5));

return
%-----------------------------------------------------
% Print the usage guide for this script
%
function PrintUsage

fprintf('\nUsage:- XYZDemo(Filename)\n\n')
fprintf('            Filename = display calibration file name\n\n')

return
