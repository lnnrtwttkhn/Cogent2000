function touch(Monitor,Port)
% Sample script touch v1.33
%
% Creates an interactive eyetracker demonstration.
%
% Usage:-   touch(Monitor,Port)
%
%           Monitor = Monitor number for touchscreen
%           Port = serial port for touchscreen (1 to 8)
%
% Default:- touch(1,1)
%
%           You may use any of the following forms:-
%
%           touch
%           touch(Monitor)
%           touch(Monitor,Port)
switch nargin
case 0
    Monitor = 1;
    Port = 1;
case 1
    Port = 1;
end
%
% Initialize a global structure used for the
% timing statistics
%
global tm

tm.FrmCnt = 0;
tm.Drp = 0;
%
% Initialize cogent
%
cgloadlib
%
% Check the version number
%
csd = cggetdata('csd');
if csd.Version < 125
   	disp('This program requires Cogent graphics v1.25 or later')
    return;
end
%
% Open a graphics display, set the font and drawing colour
%
cgopen(1,8,0,Monitor)
cgfont('Courier',40)
cgpencol(1,1,1)
%
% Open and calibrate the touchscreen
%
cgtouch('Open','ELOTouch',Port)
cgtouch('Calibrate')
%
% Initialize the time
%
S = cgflip;
%
% Go into a loop until the Esc key is pressed
%
kd(1) = 0;
while ~kd(1)
    kd = cgkeymap;
%
% Read the current touchscreen position and get the number of 
% touch points
%
    XYZ = cgtouch('touch');    
    [n,m] = size(XYZ);

    if (n > 0)
%
% At least one point - draw a spot there, diameter proportional
% to the pressure of the touch (max diameter 200)
%
        cgellipse(XYZ(1,1),XYZ(1,2),200*XYZ(1,3),200*XYZ(1,3),'f')
        
        if (n > 1)
%
% A second point - again draw a spot, diameter proportional to 
% the pressure of the touch (max diameter 200)
%
            cgellipse(XYZ(2,1),XYZ(2,2),200*XYZ(2,3),200*XYZ(2,3),'f')
        end
    else
%
% No touch - record the fact explicitly
%
        cgfont('Courier',40)
        cgtext('No touch',0,0)
        cgfont('Courier',10)
    end
%
% Add the timing statistics
%
    TimingStats(S);
%
% Flip the screen and start again
%
    S = cgflip(0,0,0);
end
%
% Close touchscreen communications and graphics prior to returning
%
cgtouch('shut')
cgshut

clear global tm

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
    str = sprintf('touch v1.33 P:%s Tim:%02d:%02d:%02d Frm:%d Av:%-.2fHz Drp:%d',...
        cogstd('spriority'),...
        fix(S/3600),mod(fix(S/60),60),mod(fix(S),60),...
        tm.FrmCnt,...
        (tm.FrmCnt/(S - tm.S1)),...
        tm.Drp);
else
	str = sprintf('touch v1.33 P:%s Tim:%02d:%02d:%02d Frm:%d Drp:%d',...
        cogstd('spriority'),...
        fix(S/3600),mod(fix(S/60),60),mod(fix(S),60),...
        tm.FrmCnt,...
        tm.Drp);
end
cgtext(str,0,240 - 7)

tm.S = S;
tm.FrmCnt = tm.FrmCnt + 1;

return
