function XYZOut = xyzcheck(XYZIn,Filename,PhotometerID,PortNum)
% Sample script xyzcheck v1.33
%
% Check calculated XYZ values with photometer
%
% Usage:- XYZOut = xyzcheck(XYZIn,Filename,PhotometerID,PortNum)
%
%          XYZIn = Requested XYZ values
%       Filename = display calibration file name
%   PhotometerID = Which photometer to use (eg. 'PR650')
%        PortNum = COM port for photometer.
%                  Use a negative value to request 'XYZB' meausrements
%         XYZOut = measured XYZ values
%
global  dcf

LeaveTime = 10;
SettleTime = 2;
%
% Initialize Cogent Graphics
%
cgloadlib

if nargout == 1
    XYZOut = zeros(0,0);
end
%
% Check the input arguments
%
if (nargin ~= 4)|(nargout ~= 1)
    PrintUsage
    return
end
%
% Adjust for negative PortNum values
%
if PortNum < 0
    PortNum = -PortNum;
    XYZStr = 'XYZB';
else
    XYZStr = 'XYZ';
end
%
% Read in the display calibration file
%
dcf = readdcf(Filename);
if ~isstruct(dcf)
    return
end
%
% Convert to RGB
%
xyz2rgb(Filename)
[RGB,Err] = xyz2rgb(XYZIn);
%
% Check for conversion errors
%
a = find(Err ~= 0);
if (~isempty(a))
    fprintf('Conversion error XYZ(%d) %s\n',a(1),WriteXYZ(XYZIn(a(1),:)))

    if bitand(Err(a(1)),1)
        fprintf('XYZ out of range\n')
    end
    if bitand(Err(a(1)),2)
        fprintf('Y value too high\n')
    end
    if bitand(Err(a(1)),4)
        fprintf('Gamut error\n')
    end
    
    return
end
%
% Initialize the photometer
%

if (strcmpi(PhotometerID,'PR670'))|(strcmpi(PhotometerID,'PR650'))
    if (strcmpi(PhotometerID,'PR650'))
        fprintf('\nConnect PR650 directly to serial port COM%d\n',...
            PortNum)
        fprintf('Switch in CTRL position\n');
    else
        fprintf('\nConnect PR670 directly to the USB port for COM%d\n',...
            PortNum)
    end
    fprintf('Hit a key when ready\n\n')
    pause
end

if (cgphotometer('Open',PhotometerID,PortNum) ~= 0)
    %
    % Initialize the graphics
    %
    if (InitGraphics(RGB,LeaveTime,SettleTime) ~= 0)
    %
    % Main program loop
    %
		%
		% How many values to measure ?
		%
        [NumVals,i] = size(RGB);
		%
		% Record starting time in seconds
		%
		s0 = cogstd('sGetTime',-1);

        for i=1:NumVals
			%
			% During the settle time, display some info
			%
            mypencol(1002,RGB(i,1),RGB(i,2),RGB(i,3))
            
			for j=1:SettleTime
	            mypencol(2,RGB(i,1),RGB(i,2),RGB(i,3))
		        cgrect
				mypencol(0,0,0,0)
				cgrect(0,-220,640,40)
				mypencol(1,1,1,1)
				%
				% Calculate the elapsed sec,min,hrs
				%
				s = fix(cogstd('sGetTime',-1) - s0);
				m = fix(s/60);
				h = fix(m/60);
				m = mod(m,60);
				s = mod(s,60);
				%
				% Display the info
				%
				mypencol(3,0.5,0.5,0.5)
				cgtext(sprintf('Measurement %d of %d.  XYZ:%s Elapsed time:%02d:%02d:%02d',i,NumVals,WriteXYZ(XYZIn(i,:)),h,m,s),0,-220)

		        cgflip
				%
				% Wait for one second
				%
		        pause(1)
				end
			%
			% Now display the colour full-screen
			%
            mypencol(2,RGB(i,1),RGB(i,2),RGB(i,3))
            cgrect
            cgflip
			%
			% Take the measurement
			%
            XYZOut(i,:) = cgphotometer(XYZStr);
        end
	    %
		% Close the graphics
	    %
        ShutGraphics
    end
    %
    % Close the photometer
    %
    cgphotometer('Shut')
end
%
% Clear global variables
%
clear global dcf

return
%-----------------------------------------------------
% This function initializes the graphics
%
function OK = InitGraphics(RGB,LeaveTime,SettleTime)

global  dcf
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
cgscale(640)
%
% Set the palette colours
%
mypencol(1000,0,0,0)
mypencol(1001,1,1,1)
mypencol(1002,0,0,0)
mypencol(1003,0.5,0.5,0.5)
%
% Display the focus screen
%
cgfont('Arial',40)
mypencol(0,0,0,0)
cgrect
mypencol(1,1,1,1)
cgdraw(-320,-240,320,240)
cgdraw(-320,240,320,-240)
cgellipse(0,0,20,20,'f')
mypencol(0,0,0,0)
cgellipse(0,0,10,10,'f')
mypencol(1,1,1,1)
cgtext('Focus photometer on central spot',0,-100)

[m,n] = size(RGB);

s = sprintf('%.0f measurements (Min %.0f sec)',...
   m,m*SettleTime);
cgtext(s,0,-150)
cgtext('Hit any key to continue',0,-200)
myflip(0,0,0,0)
pause

for s = 1:LeaveTime
   s = sprintf('You now have %.0f seconds',LeaveTime + 1 - s);
   cgtext(s,0,25)
   cgtext('to leave the room',0,-25)
   myflip(0,0,0,0)
   pause(1)
end
%
% Reset the font
%
mypencol(3,0.5,0.5,0.5)
cgfont('Arial',20)

return
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
% This function cleans up the graphics
%
function ShutGraphics

cgshut

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
%---------------------------------------------------------
% This function flips the screen
%
function myflip(lev,r,g,b)

global dcf

if dcf.DspCnf.Bits == 8
    cgflip(lev)
else
    cgflip(r,g,b)
end

return
%-----------------------------------------------------
% Print the usage guide for this script
%
function PrintUsage

fprintf('\nUsage:- XYZOut = xyzcheck(XYZIn,Filename,PhotometerID,PortNum)\n\n')
fprintf('           XYZIn = Requested XYZ values\n')
fprintf('        Filename = Display calibration file name\n')
fprintf('    PhotometerID = Which photometer to use (eg. ''PR670'', ''PR650'')\n')
fprintf('         PortNum = Serial port for photometer (1-8)\n')
fprintf('                   Use a negative value to request ''XYZB'' measurements\n')
fprintf('          XYZOut = Measured XYZ values\n\n')

return
