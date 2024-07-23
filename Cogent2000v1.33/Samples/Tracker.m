function tracker(c1,c2,c3,c4,PortNum,Mode,BaudRate)
% Sample script tracker v1.33
%
% Creates an interactive eyetracker demonstration.
%
% Usage:-   tracker(c1,c2,c3,c4,PortNum,Mode,BaudRate)
%
%           c1,c2,c3,c4 = Eyetracker calibration constants
%           PortNum     = Serial port number (> 0)
%           Mode        = 1 (On demand) or 0 (Continuous)
%           BaudRate    = Serial speed 9600/19200/38400/57600
%
% Default:- tracker(40,40,220,200,1,1,57600)
%
%           You may use any of the following forms:-
%
%           tracker
%           tracker(c1,c2,c3,c4)
%           tracker(c1,c2,c3,c4,PortNum)
%           tracker(c1,c2,c3,c4,PortNum,Mode)
%           tracker(c1,c2,c3,c4,PortNum,Mode,BaudRate)
switch nargin
case 0
    c1 = 40;
    c2 = 40;
    c3 = 220;
    c4 = 200;
    PortNum = 1;
    Mode = 1;
    BaudRate = 57600;
case 4
    PortNum = 1;
    Mode = 1;
    BaudRate = 57600;
case 5
    Mode = 1;
    BaudRate = 57600;
case 6
    BaudRate = 57600;
case 7
otherwise
    PrintUsage
    return
end
%
% Check the values are valid
%
if CheckValues(c1,c2,c3,c4,PortNum,Mode,BaudRate) == 0
    PrintUsage
    return
end
%
% Initialize a global structure used for the
% timing statistics
%
global tm

tm.FrmCnt = 0;
tm.Drp = 0;
%
% OK, everything seems to be OK, initialize cogent
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
% Open the eyetracker
%
cgtracker('Open','ASL5000',PortNum,Mode,BaudRate,c1,c2,c3,c4)
%
% Open a graphics screen
%
cgopen(1,0,0,1)
%
% Prepare the background sprite
%
BackSprite(c1,c2,c3,c4,PortNum,Mode,BaudRate)
%
% Start the blink counter
%
Blinks = 0;
PrevPupil = 0;
%
% Initialize the time
%
S = cgflip;
%
% Go into a loop until the Esc key is pressed
%
kp(1)=0;
while kp(1) == 0
%
% Read the current state of keys
%
   [kd,kp]=cgkeymap;
%
% If the 'C' key is pressed go into calibration mode
% Reset the timing statistics afterwards.
%
    if kp(46) > 0
        cgtracker('calibrate')
        
        S = cgflip('V');
        tm.FrmCnt = 0;
   end
%
% If the 'R' key is pressed reset the blinks
%
    if kp(19) > 0
        Blinks = 0;
    end
%
% Draw the new background
%
    cgdrawsprite(1,0,0)
%
% Get the new eye data
%
    eyedat = cgtracker('eyedat');
%
% Check for blinks
%
    if (eyedat.Pupil > 0)&(PrevPupil == 0)
        Blinks = Blinks + 1;
    end
    PrevPupil = eyedat.Pupil;
%
% Write in the new data
%
    NewData(eyedat,Blinks,S)
%
% Display the new background
%
    S = cgflip;
end
%
% End of loop - close graphics and eyetracker
%
cgshut
cgtracker('shut')

clear global tm

return
%-----------------------------------------------------
% Check we have valid values.
% Return 0 if we don't
%
function Valid = CheckValues(c1,c2,c3,c4,PortNum,Mode,BaudRate)

Valid = 0;

if (c3 <= c1)|(c4 <= c2)
    return
end

if PortNum < 1
    return
end

switch Mode
case {0 1}
otherwise
    return
end

switch BaudRate
case {9600 19200 38400 57600}
otherwise
    return
end

Valid = 1;

return
%-----------------------------------------------------
% Write in the new eyedata
%
function NewData(eyedat,Blinks,S)

cgalign('l','c')
cgtext(sprintf('%d,%d',eyedat.X,eyedat.Y),0,60)
cgtext(sprintf('%d',eyedat.Pupil),0,40)
cgtext(sprintf('%.3f',eyedat.Timestamp),0,20)
cgtext(sprintf('%d',eyedat.Status),0,0)
cgtext(sprintf('%d',Blinks),0,-20)
cgalign('c','c')

TimingStats(S)
%
% Draw the crosshairs if the eye is there
%
if eyedat.Pupil > 0
    cgdraw(-320,eyedat.Y,320,eyedat.Y,[1 0 0])
    cgdraw(eyedat.X,-240,eyedat.X,240,[1 0 0])
    cgellipse(eyedat.X,eyedat.Y,10,10,[1 0 0],'f')
else
    cgpencol(1,0,0)
    cgtext('No eye data',0,-40)
    cgpencol(1,1,1)
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
cgpencol(0,0,0)
cgrect(0,240 - 7,640,14)
cgpencol(1,1,1)

if tm.FrmCnt > 0
    str = sprintf('tracker v1.33 P:%s Tim:%02d:%02d:%02d Frm:%d Av:%-.2fHz Drp:%d',...
        cogstd('spriority'),...
        fix(S/3600),mod(fix(S/60),60),mod(fix(S),60),...
        tm.FrmCnt,...
        (tm.FrmCnt/(S - tm.S1)),...
        tm.Drp);
else
	str = sprintf('tracker v1.33 P:%s Tim:%02d:%02d:%02d Frm:%d Drp:%d',...
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
% Create the background sprite
%
function BackSprite(c1,c2,c3,c4,PortNum,Mode,BaudRate)

cgfont('Courier',20)
cgpencol(1,1,1)
cgmakesprite(1,640,480,0,0,0)
cgsetsprite(1)
cgalign('c','c')

cgtext('Eyetracker demonstration',0,190)

cgalign('l','c')

cgtext(sprintf('%d,%d,%d,%d',c1,c2,c3,c4),0,160)
cgtext(sprintf('%d',PortNum),0,140)
if Mode == 0
    ModStr = 'Continuous';
else
    ModStr = 'On Demand';
end
cgtext(sprintf('%d (%s)',Mode,ModStr),0,120)
cgtext(sprintf('%d',BaudRate),0,100)

cgalign('r','c')

cgtext('c1,c2,c3,c4:',0,160)
cgtext('PortNum:',0,140)
cgtext('Mode:',0,120)
cgtext('BaudRate:',0,100)

cgtext('EyePos:',0,60)
cgtext('Pupil:',0,40)
cgtext('Timestamp:',0,20)
cgtext('Status:',0,0)

cgtext('Blinks:',0,-20)

cgalign('r','b')
cgtext('''Esc'' for exit, ''C'' for calibrate or ''R'' to reset',320,-240)

cgsetsprite(0)
cgalign('c','c')
return
%-----------------------------------------------------
% Print the usage guide for this script
%
function PrintUsage

fprintf('\nusage - tracker(c1,c2,c3,c4,PortNum,Mode,BaudRate)\n\n')
fprintf('       c1,c2,c3,c4 = Calibration points (c3 > c1, c4 > c2)\n')
fprintf('           PortNum = Serial port number 1-8\n') 
fprintf('              Mode = 1 ("On Demand") or 0 ("Continuous")\n') 
fprintf('          BaudRate = Serial port baud rate 9600/19200/38400/57600\n\n')
fprintf('    Default values are:-\n')
fprintf('       c1,c2,c3,c4 = 40,40,220,200\n')
fprintf('           PortNum = 1\n') 
fprintf('              Mode = 1\n') 
fprintf('          BaudRate = 57600\n\n')

return
