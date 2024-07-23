function dspcheck(Filename,Levels,PhotometerID,PortNum)
% Sample script dspcheck v1.33
%
% Check calculated XYZ values for monitor with photometer
%
% Usage:- dspcheck(DCFname,Levels,PhotometerID,PortNum) or
%         dspcheck(DCFname,XYZ,PhotometerID,PortNum) or
%         dspcheck(DCKname)
%
%        DCFname = Display calibration file name
%         Levels = Number of levels to check
%   PhotometerID = Which photometer to use (eg. 'PR670', 'PR650')
%        PortNum = COM port for photometer
%                  N.B. a negative value here requests the 'XYZB' 
%                       measurement rather than 'XYZ'
%            XYZ = Requested XYZ values
%        DCKname = dspcheck file name
%
global  dcf ChkDat
%
% Standardize 'Filename' extensions
%
if nargin == 1
%
% if nargin == 1 this must be a '.dck.mat' file
% Strip off '.mat'
%
    [path,name,ext] = fileparts(Filename);
    if strcmpi(ext,'.mat')
        Filename = fullfile(path,name);
    end
%
% Add '.dck' if absent
%
    [path,name,ext] = fileparts(Filename);
    if ~strcmpi(ext,'.dck')
        Filename = fullfile(path,[name ext '.dck']);
    end
%
% Add '.mat'
%
    Filename = [Filename '.mat'];
    
elseif nargin == 4
%
% If nargin >= 4 this must be a '.dcf.txt' file
% Strip off '.txt'
%
    [path,name,ext] = fileparts(Filename);
    if strcmpi(ext,'.txt')
        Filename = fullfile(path,name);
    end
%
% Strip off '.dcf'
%
    [path,name,ext] = fileparts(Filename);
    if strcmpi(ext,'.dcf')
        Filename = fullfile(path,name);
    end
%
% Are we requesting 'XYZB' ?
%
    if PortNum < 0
        PortNum = -PortNum;
        XYZStr = 'XYZB';
    else
        XYZStr = 'XYZ';
    end

    [m,n] = size(Levels);
    
    if (m == 1)&(n == 1)
        XYZFlag = 0;
    elseif (n == 3)
        XYZFlag = 1;
        XYZ = Levels;
    else
        PrintUsage
        return
    end
end
%
% Check the input arguments
%
if nargin == 1
    %
    % If nargin == 1 this means just display the data and return
    %
    tmp = load(Filename);
  
    ShowCheck(tmp.ChkDat)
    
    return
end
%
% Otherwise, nargin must equal 4 and we take the measurements
%
if nargin ~= 4
    PrintUsage
    return
elseif (Levels < 1)|(Levels > 10)
    PrintUsage
    return
end
%
% Initialize Cogent Graphics
%
cgloadlib
%
% Read in the display calibration file
%
dcf = readdcf(Filename);
if ~isstruct(dcf)
    return
end

ChkDat.Filename = Filename;
ChkDat.dcf = dcf;
%
% Initialize conversions
%
xyz2rgb(Filename)

if XYZFlag == 1
    [RGB,Err] = xyz2rgb(XYZ);
    %
    % Check for conversion errors
    %
    a = find(Err ~= 0);
    if (~isempty(a))
        fprintf('Conversion error XYZ(%d) %s\n',a(1),WriteXYZ(XYZ(a(1),:)))

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
    [ChkDat.NumVals,m] = size(XYZ);
    ChkDat.XYZIn = XYZ;
    ChkDat.RGB = RGB;
    ChkDat.NumLev = 0;
    ChkDat.Lev = [];
else
    %
    % What is the peak white XYZ ?
    %
    XYZPeak = rgb2xyz(1,1,1);
    %
    % OK - now get RGB levels for each of the level intensities
    %
    % The levels we choose are equally spaced in "Y"...
    %
    ChkDat.NumLev = Levels;
    for i = 0:Levels - 1
        RGB = xyz2rgb(XYZPeak*i/(Levels - 1));
        ChkDat.Lev(i + 1) = RGB(2);
    end
    %
    % OK - calculate the RGB values and requested XYZ values (XYZIn)
    %
    ChkDat.NumVals = Levels*Levels*Levels - 1;
    ChkDat.RGB   = zeros(ChkDat.NumVals,3);
    ChkDat.XYZIn = zeros(ChkDat.NumVals,3);

    for i=1:ChkDat.NumVals
        k = i;
        TmpRGB(1) = ChkDat.Lev(1 + mod(k,Levels));
        k = fix(k/Levels);
        TmpRGB(2) = ChkDat.Lev(1 + mod(k,Levels));
        k = fix(k/Levels);
        TmpRGB(3) = ChkDat.Lev(1 + mod(k,Levels));
        ChkDat.XYZIn(i,:) = rgb2xyz(TmpRGB);

		ChkDat.RGB(i,:) = xyz2rgb(ChkDat.XYZIn(i,:));
    end
end
%
% Initialize the photometer
%
if strcmpi(PhotometerID,'PR670')|strcmpi(PhotometerID,'PR650')
    if strcmpi(PhotometerID,'PR650')   
        fprintf('\nConnect %s directly to serial port COM%d\n',...
            PhotometerID,PortNum)
        fprintf('Switch in CTRL position\n');
    else
        fprintf('\nConnect %s directly to USB port for COM%d\n',...
            PhotometerID,PortNum)
    end
    fprintf('Hit a key when ready\n\n')
    pause
end

RGB = ChkDat.RGB;

if (cgphotometer('Open',PhotometerID,PortNum) ~= 0)
    %
    % Initialize a couple of variables
    %
    while 1
        LeaveTime = input('How long do you need to leave the room ? (sec):');     % How long you have to get out of the room (sec)
        if ((LeaveTime >=0)&(LeaveTime < 10000))
            break
        end
    end

    while 1
        SettleTime = input('How long for the display to settle ? (sec):');     % How long you have to get out of the room (sec)
        if ((SettleTime >= 0)&(SettleTime < 10000))
            break
        end
    end 
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
				cgtext(sprintf('Measurement %d of %d.  XYZ:%s Elapsed time:%02d:%02d:%02d',i,NumVals,WriteXYZ(ChkDat.XYZIn(i,:)),h,m,s),0,-220)

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
            ChkDat.XYZOut(i,:) = cgphotometer(XYZStr);
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
% Store some ancilliary information - you never know
% when it will come in useful!
%
ChkDat.MachineID = cogstd('sMachineID');
ChkDat.UserID = cogstd('sUserID');
ChkDat.Date = datestr(now);
%
% Save the file with a unique name
%
for i = 1:9999
    if ChkDat.NumLev == 0
        tmpnam = sprintf('%s_XYZ%04d.dck.mat',Filename,i);
    else
        tmpnam = sprintf('%s_%04d.dck.mat',Filename,i);
    end
    if exist(tmpnam) == 0 
        save(tmpnam,'ChkDat')
        fprintf('Saving display check file:%s',tmpnam)
        break
    end
end
%
% Display the results graphically
%
ShowCheck(ChkDat)
%
% Clear global variables
%
clear global dcf ChkDat

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

fprintf('\nUsage:- dspcheck(DCFname,Levels,PhotometerID,PortNum) or\n')
fprintf('\n        dspcheck(DCFname,Levels,PhotometerID,PortNum,XYZ) or\n')
fprintf('          dspcheck(DCKname)\n\n')
fprintf('         DCFname = Display calibration file name\n')
fprintf('          Levels = Number of levels to check\n')
fprintf('    PhotometerID = Which photometer to use (eg. ''PR670'', ''PR650'')\n')
fprintf('         PortNum = Serial port for photometer (1-8)\n')
fprintf('                   Use a negative value to request ''XYZB'' measurements\n')
fprintf('             XYZ = Requested XYZ values\n')
fprintf('         DCKname = dspcheck file name\n\n')

return
%-----------------------------------------------------
% Display the check data graphically
%
function ShowCheck(ChkDat)
%
% Convert XYZ to xyY for plotting
%
xyYIn = xyz2xyy(ChkDat.XYZIn);
xyYOut = xyz2xyy(ChkDat.XYZOut);
%
% Get the maximum deviations between requested and measured
%
xymax = -1;
Ymax = -1;

for i=1:ChkDat.NumVals    
    dx = xyYIn(i,1) - xyYOut(i,1);
    dy = xyYIn(i,2) - xyYOut(i,2);
    
    xyErr = sqrt(dx*dx + dy*dy);
    YErr = abs(xyYIn(i,3) - xyYOut(i,3));
    
    if xyErr > xymax
        xymax = xyErr;
        xyind = i;
    end
    if YErr > Ymax
        Ymax = YErr;
        Yind = i;
    end     
end
%
% Make a new figure
%
figure('color',[1 1 1])
%
% Have a separate area for the deviation text
%
h = axes('Position',[0 0 0.25 1],'Visible','off');
[a,Txt1]=WriteXYZ(ChkDat.XYZIn(xyind,:));
[Txt2,a]=WriteXYZ(ChkDat.XYZIn(Yind,:));
text(0,0,...
    sprintf('Max xy deviation:%-8.4f (%03d xyY: %s)\n Max Y deviation:%-8.2f (%03d XYZ: %s)',...
    xymax,xyind,Txt1,Ymax,Yind,Txt2),...
    'VerticalAlignment','bottom','FontUnits','normalized','FontName','Courier','FontSize',0.03)
%
% and a different area for the graph
%
axes('Position',[.25 0.1 0.7 0.8])
%
% Plot the requested values as '.'
%
plot3(xyYIn(:,1),xyYIn(:,2),xyYIn(:,3),'k.')
%
% hold on adds subsequent plots to the graph
%
hold on
%
% Draw the connecting lines between requested & measured
%
for i=1:ChkDat.NumVals
    plot3([xyYIn(i,1) xyYOut(i,1)],[xyYIn(i,2) xyYOut(i,2)],[xyYIn(i,3) xyYOut(i,3)],'k-')
end
%
% Plot the measured values as '+'
%
plot3(xyYOut(:,1),xyYOut(:,2),xyYOut(:,3),'k+')
%
% Finishing touches...
%
axis([0 1 0 1])
axis square
grid on
title(sprintf('Display calibration check (dcf:%s)',ChkDat.Filename),'interpreter','none')
xlabel('x')
ylabel('y')
zlabel('Y')
legend('Requested xyY','Measured xyY')
%
% All done - return
%
return
