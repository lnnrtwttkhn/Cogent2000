function dspcalib(PhotoModel,Port,CalPoints,SettleTime,LeaveTime,Filename,Res,BPP,Ref,Mon)
% dspcalib v1.33
%
% This function calibrates a display
%
% Usage: dspcalib(Port,CalPoints,SettleTime,LeaveTime,Filename) or
%        dspcalib(Port,CalPoints,SettleTime,LeaveTime,Filename,Res,BPP,Ref) or
%        dspcalib(PhotoModel,Port,CalPoints,SettleTime,LeaveTime,Filename) or
%        dspcalib(PhotoModel,Port,CalPoints,SettleTime,LeaveTime,Filename,Res,BPP,Ref)
%
%         PhotoModel = Photometer model ('PR650' or 'PR670'). Assume 'PR670' if omitted.
%               Port = serial or COM port (1-8)
%          CalPoints = Number of calibration points (2-256)
%         SettleTime = seconds to allow display to settle (0-60)
%          LeaveTime = seconds to leave the room (0-60)
%           Filename = name for display calibration data file
%                Res = Display resolution (1-6) [1] or [HorPix VerPix]
%                BPP = Bits per pixel (0/8/16/24/32) [0]
%                Ref = Refresh rate in Hz (>0) [0]
%                Mon = Monitor number (>=0) [1]
%
% If CalPoints is a negative number we use the "XYZB" light measurement function
%
if (nargin == 5)|(nargin == 9)
   if (nargin == 9)
      Mon = Ref;
      Ref = BPP;
      BPP = Res;
      Res = Filename;
   end
   Filename = LeaveTime;
   LeaveTime = SettleTime;
   SettleTime = CalPoints;
   CalPoints = Port;
   Port = PhotoModel;
   PhotoModel = 'PR670';
end
      
BadArg = 1;
switch nargin
    case {5 6}
        Res = 1;
        BPP = 0;
        Ref = 0;
        Mon = 1;
        BadArg = 0;
    case {9 10}
        if (BPP == 0)|(BPP == 8)|(BPP == 16)|(BPP == 24)|(BPP == 32)
            if (Ref >= 0)&(Ref < 10000)
                if (Mon >= 0)&(Mon < 10000)
                    if numel(Res) == 1
                        if (Res >= 1)&(Res <= 6)
                            BadArg = 0;
                        end
                    elseif numel(Res) == 2
                        if (min(Res) > 0)&(max(Res) < 10000)
                            BadArg = 0;
                        end
                    end
                end
            end
        end
end

if BadArg == 0
    if ~ischar(PhotoModel)
        BadArg = 1
    else
        PhotoModel = upper(PhotoModel);
        if isempty(strmatch(PhotoModel,{'PR650' 'PR670'},'exact'))
            BadArg = 1;
        end
    end
end

if BadArg == 0
   Mode = 0;
   if CalPoints < 0
       Mode = 1;
       CalPoints = -CalPoints;
   end
   BadArg = 1;
   if (Port >= 1)&(Port <= 8)
      if (CalPoints >= 2)&(CalPoints <= 256)
         if (SettleTime >= 0)&(SettleTime <= 60)
            if (LeaveTime >= 0)&(LeaveTime <= 60)
               fid = fopen([Filename '.dcf.txt'],'w');
               if fid ~= -1
                  BadArg = 0;
                  fclose(fid);
               end
            end
         end
      end
   end
end

if BadArg > 0
   PrintUsage
   return
end
%
% Global variables
%
%     DspDsc - Display description (text string)
%     DspCnf - Display Configuration (array) [Res BPP Ref Mon]
%     DspMod - Display model number (text string)
%     DspSrn - Display serial number (text string)
%     DspBrt - Display brightness setting (text string)
%     DspCnt - Display contrast setting (text string)
%      Notes - Operator defined notes for this calibration (text string)
%     VERNUM - Version number of this script
%      Count - What measurement are we on ?
%  Countdown - How many measurements for this calibration
%         S1 - Time in seconds of start of calibration
%        Lev - Array of intensity levels for the calibration
%         t0 - Date and time code of start of calibration
%        CSD - CogStdData structure
%        GPD - GPrimData structure
%        GSD - GScndData structure
%        PHD - Photometer ID string (text string)
%        CPU - PC ID string (text string)
%      ApStr - Which measurement aperture has been selected (PR670 only)
%
% TimeFactor - Prior to v1.17 time was returned in microseconds
%              This value will correct for this.
%
global DspDsc DspMod DspSrn DspBrt DspCnt Notes VERNUM
global Count Countdown S1 Lev t0 CSD GPD GSD PHD CPU
global TimeFactor DspCnf BlkSpc

DspCnf = [Res BPP Ref Mon];
%
% Obtain input from the operator
%
VERNUM = 131;

DspDsc = '';
DspSrn = '';
DspMod = '';
DspBrt = '';
DspCnt = '';
Notes = '';

fprintf('\n');
%
% For the PR670 we select a measurement aperture
%
ApIns = '';
if strcmp(PhotoModel,'PR670')
   while 1
      disp('      The PR670 can use 4 aperture sizes:-')
      disp('         A) 1 degree (default)')
      disp('         B) 1/2 degree')
      disp('         C) 1/4 degree')
      disp('         D) 1/8 degree (for very bright light sources)')
      disp(' ')
      
      a = upper(input('    Select an aperture A/B/C/D: ','s'));
      ApIns = ['AP' a];
      switch a
         case {'A' 'B' 'C' 'D'}
            break
      end
      disp(' ')
   end
end

DspDsc = GetStr('Display Description');
DspMod = GetStr('Display Model Number');
DspSrn = GetStr('Display Serial Number');
DspBrt = GetStr('Display Brightness');
DspCnt = GetStr('Display Contrast');
Notes = GetStr('a line of notes',0);

global Count Countdown S1 Lev t0
%
% Initialize Cogent Graphics
%
cgloadlib
%
% Open photometer communications
%
Success = openphotometer(PhotoModel,Port,ApIns);
if Success < 1
   cleanup('Unable to open photometer')
   return
end
%
% open graphics
%
if numel(DspCnf) == 4
    cgopen(DspCnf(1),DspCnf(2),DspCnf(3),DspCnf(4))
else
    cgopen(DspCnf(1),DspCnf(2),DspCnf(3),DspCnf(4),DspCnf(5))
end
if (gprim('gHWnd') == 0)
    cleanup('Unable to open graphics display')
    return
end

gsd = cggetdata('gsd');
if gsd.Version < 117
   TimeFactor = 1/1000000;
else
   TimeFactor = 1;
end
%
% Get DLL information
%
global CSD GPD GSD

CSD = cggetdata('CSD');
GPD = cggetdata('GPD');
GSD = cggetdata('GSD');

if CSD.Version < 107
   cleanup('CogStd library must be version 107 or later')
   return
elseif GPD.Version < 107
   cleanup('GPrim library must be version 107 or later')
   return
elseif GSD.Version < 107
   cleanup('GScnd library must be version 107 or later')
   return
end

Countdown = 12 + (CalPoints - 2)*7;
Count = 0;
S1 = cogstd('sgettime',0)*TimeFactor;
%
% Initialisation for palette mode
%
mypencol(1000,0,0,0)
mypencol(1001,1,1,1)
mypencol(1002,.3,.3,.3)
%
% Put up the initial focus screen
%
focusscreen(Countdown,SettleTime,LeaveTime)
t0 = now;
%
% Measure black
%
BlkXYZ(1:3) = measurelight('Black Lev',SettleTime,0,0,Mode);
if BlkXYZ(1) < 0
    return
end
BlkSpc = cgphotometer('SPC');
if max(BlkXYZ) <= 0.
    BlkSpc(:,2) = 0.;
end

Lev = zeros(1,CalPoints);
%
% Measure some intermediate levels for interpolation
%
IntLev = [0 63 127 191 255];
YVals = [BlkXYZ(2) 0 0 0 0];

for i = 2:5
   Str = sprintf('Grey IntLev %d (%d)',i,IntLev(i));
   GryXYZ(1:3) = measurelight(Str,SettleTime,7,IntLev(i),Mode);
   if GryXYZ(1) < 0
      return
   end
   YVals(i) = GryXYZ(2);
end
%
% Now set all the intermediate levels
%
setlevels(CalPoints,IntLev,YVals)
%
% Remove any duplicate Lev values
% This may change the Lev array and
% the value of 'CalPoints'
%
CalPoints0 = CalPoints;
Lev0 = Lev;

CalPoints = 0;
Lev = [];
i = 1;
while i <= CalPoints0
    CalPoints = CalPoints + 1;
    Lev(CalPoints) = Lev0(i);
    while i <= CalPoints0
        i = i + 1;
        if i > CalPoints0
            break
        elseif Lev0(i) ~= Lev(CalPoints)
            break
        end
    end
end

XYZ = zeros(7,CalPoints,3);
for ColCod = 1:7
   XYZ(ColCod,1,:) = BlkXYZ;
end

ColStr = char('Red','Grn','Yel','Blu','Mag','Cyn','Gry');

for Cal = 2:CalPoints
    for ColCod = 1:7
        Str = sprintf('%s Lev %d (%d)',ColStr(ColCod,:),Cal,Lev(Cal));
        XYZ(ColCod,Cal,:) =  measurelight(Str,SettleTime,ColCod,Lev(Cal),Mode);
        if XYZ(ColCod,Cal,1) < 0
            return
        end
        if Cal == CalPoints
            Spc = cgphotometer('SPC');
            if max(XYZ(ColCod,Cal,:) <= 0)
                Spc(:,2) = 0.;
            end
            if ColCod == 1
               [m,n] = size(Spc); 
                DspSpc = zeros(m,8);
             DspSpc(:,1) = Spc(:,1);
              DspSpc(:,2) = Spc(:,2);
            else
                DspSpc(:,(ColCod + 1)) = Spc(:,2);
            end
        end
   end
end
%
% shut graphics
%
cgshut
%
% Close photometer communications
%
shutphotometer
%
% Save data as a file
%
savemonitorrawdata(CalPoints,SettleTime,Lev,XYZ,DspSpc,Filename)
%
% Clean up global variables
%
clear global DspDsc DspMod DspSrn DspBrt DspCnt Notes VERNUM BlkSpc
clear global Count Countdown S1 Lev t0 CSD GPD GSD PHD CPU TimeFactor
%
% Goodbye message
%
fprintf('\n    ********************************************\n');
fprintf('    * %-40.40s *\n','Calibration completed successfully');
fprintf('    * %-40.40s *\n',['Calibration file "' Filename '" saved']);
fprintf('    * %-40.40s *\n','Now disconnect and pack the photometer');
fprintf('    ********************************************\n\n');

return
%*********************************************************
% Local functions
%
%---------------------------------------------------------
% This function gets an operator string
%
function Ans = GetStr(Prompt,ForceAnswer)

if nargin < 2
   ForceAnswer = 1;
end

AskStr = sprintf('%30.30s: ',['Enter ' Prompt]);

if ForceAnswer ~= 1
   Ans = input(AskStr,'s');
   return
end

m = 0;
n = 0;

while m ~= 1
   Ans = input(AskStr,'s');
   [m,n] = size(Ans);
end

return
%---------------------------------------------------------
% This function opens communications with the photometer
%
function Success = openphotometer(PhotoModel,Port,ApIns)

global PHD CPU

   SerPrtStr = sprintf('COM%d',Port);

   fprintf('\nConnect %s directly to serial port %s\n',...
      PhotoModel,SerPrtStr)
   fprintf('Switch in CTRL position\n');
   fprintf('Hit a key when ready\n\n')
   pause

   Success = cgphotometer('Open',PhotoModel,Port);
   if ~isempty(ApIns)
      ApStr = cgphotometer('Setup',ApIns);
   else
      ApStr = '';
   end
   %
   % Add the aperture info to the photometer ID
   %
   PHD = cgphotometer('ID');
   PHD = [PHD [blanks(length(ApStr));ApStr]];

   CPU = cogstd('sMachineID');

return
%---------------------------------------------------------
% This function shuts communications with the photometer
%
function shutphotometer
   cgphotometer('Shut')
return
%---------------------------------------------------------
% This function measures light
%
function XYZ = measurelight(ErrStr,SettleTime,ColCod,Level,Mode)

global Count Countdown S1 TimeFactor

ColCodStr = {'black';'red';'green';'yellow';'blue';'magenta';'cyan';'white'};

   R = 0.;
   G = 0.;
   B = 0.;

   gpd = cggetdata('GPD');
    scrwid = gpd.PixWidth;
    scrhgt = gpd.PixHeight;
    sw2 = scrwid/2;
    sh2 = scrhgt/2;
    txtsiz = 20*scrhgt/480;

   switch ColCod
      case {1}
        R = Level/255.;
      case {2}
        G = Level/255.;
      case {3}
        R = Level/255.;
        G = Level/255.;
      case {4}
        B = Level/255.;
      case {5}
        R = Level/255.;
        B = Level/255.;
      case {6}
        G = Level/255.;
        B = Level/255.;
      case {7}
        R = Level/255.;
        G = Level/255.;
        B = Level/255.;
   end

   Count = Count + 1;

   cgfont('Arial',txtsiz)
   mypencol(1003,R,G,B)
   mypencol(3,R,G,B)
   cgrect
   for i = 1:SettleTime
      mypencol(0,0,0,0)
      cgrect(0,txtsiz - sh2,scrwid,2*txtsiz)
      mypencol(2,0.3,0.3,0.3)
      str = sprintf('Measure %s level %.0f',ColCodStr{ColCod + 1},Level);
      cgtext(str,0,txtsiz*1.5 - sh2)
      S = cogstd('sgettime',-1)*TimeFactor;
      str = sprintf('Time:%.0f Measurement %.0f of %.0f Settle:%.0f',...
         (S - S1),Count,Countdown,SettleTime + 1 - i);
      cgtext(str,0,txtsiz/2 - sh2)
      myflip(3,R,G,B)
      pause(1)
  end
  cgflip
  
  if Mode
     XYZ = cgphotometer('XYZB');
  else
     XYZ = cgphotometer('XYZ');
  end
   
  if XYZ(1) < 0
    cleanup(['Failed to measure ' ErrStr])
  end

return
%---------------------------------------------------------
% This function displays the focus screen
%
function focusscreen(Countdown,SettleTime,LeaveTime)

gpd = cggetdata('GPD');

scrwid = gpd.PixWidth;
scrhgt = gpd.PixHeight;

sw2 = scrwid/2;
sh2 = scrhgt/2;

rad = scrwid*20/640;
txtsiz = 20*scrhgt/480;

cgfont('Arial',txtsiz)
mypencol(0,0,0,0)
cgrect
mypencol(1,1,1,1)
cgdraw(-sw2,-sh2,sw2,sh2)
cgdraw(-sw2,sh2,sw2,-sh2)
cgellipse(0,0,rad,rad,'f')
mypencol(0,0,0,0)
cgellipse(0,0,rad/2,rad/2,'f')
mypencol(1,1,1,1)
cgtext('Focus photometer on central spot',0,-sh2/2.4)
s = sprintf('%.0f measurements (Min %.0f sec)',...
   Countdown,Countdown*SettleTime);
cgtext(s,0,-sh2/1.6)
cgtext('Hit any key to continue',0,txtsiz - sh2)
myflip(0,0,0,0)
pause

for s = 1:LeaveTime
   s = sprintf('You now have %.0f seconds',LeaveTime + 1 - s);
   cgtext(s,0,txtsiz)
   cgtext('to leave the room',0,-txtsiz)
   myflip(0,0,0,0)
   pause(1)
end

return
%---------------------------------------------------------
% This function sets the pencolour
%
function mypencol(lev,r,g,b)

global  GPD

if GPD.BitDepth == 8
    if lev >= 1000
        cgcoltab(lev - 1000,r,g,b)
        cgnewpal
    else
        cgpencol(lev)
    end
else
    if lev < 1000
        cgpencol(r,g,b)
    end
end

return
%---------------------------------------------------------
% This function flips the screen
%
function myflip(lev,r,g,b)

global GPD

if GPD.BitDepth == 8
    cgflip(lev)
else
    cgflip(r,g,b)
end

return
%---------------------------------------------------------
% This function saves the data to file
%
function savemonitorrawdata(CalPoints,SettleTime,Lev,XYZ,DspSpc,Filename)

global t0 DspDsc DspMod DspSrn DspBrt DspCnt PHD CPU GPD GSD CSD Notes VERNUM DspCnf BlkSpc

Separator = '--------------------------------------------------------------------------------';

Duration = (now - t0)*3600*24;

fid = fopen([Filename '.dcf.txt'],'w');

fprintf(fid,'%s\n Calibration Script: dspcalib v%d.%02d\n',Separator,fix(VERNUM/100),rem(VERNUM,100));
fprintf(fid,'     Photometer dll: %s\n',PHD(1,:));
fprintf(fid,'          GScnd dll: %s\n',GSD.GScndString);
fprintf(fid,'          GPrim dll: %s\n',GPD.GPrimString);
fprintf(fid,'           GLib dll: %s\n%',GPD.GLibString);
fprintf(fid,'         CogStd dll: %s\n%s\n',CSD.CogStdString,Separator);

fprintf(fid,'      Photometer ID: %s\n%s\n',PHD(2,:),Separator);
   
fprintf(fid,'        Computer ID: %s\n%s\n',CPU,Separator);

fprintf(fid,'Display Description: %s\n',DspDsc);
fprintf(fid,'   Display Model No: %s\n',DspMod);
fprintf(fid,'  Display Serial No: %s\n',DspSrn);
fprintf(fid,' Display brightness: %s\n',DspBrt);
fprintf(fid,'   Display contrast: %s\n',DspCnt);

fprintf(fid,'     Display Config: %d x %d x %d x %.2f Hz Mon:%d\n%s\n',...
   GPD.PixWidth,GPD.PixHeight,GPD.BitDepth,GPD.RefRate100/100.,DspCnf(end),Separator);
fprintf(fid,'              Notes: %s\n%s\n',Notes,Separator);

fprintf(fid,'         Start time: %s/%s/%s %s\n',datestr(t0,7),datestr(t0,5),datestr(t0,11),datestr(t0,13));

h = fix(Duration/3600);
m = fix(rem(Duration/60,60));
s = fix(rem(Duration,60));
fprintf(fid,'     Total duration: %02d:%02d:%02d\n',h,m,s);
fprintf(fid,'        Settle time: %d seconds\n%s\n',SettleTime,Separator);
fprintf(fid,'       Calib points: %d\n%',CalPoints);
for i=1:CalPoints
   fprintf(fid,'                %3d: %3d\n',i,Lev(i));
end

ColStr = char('Red','Green','Yellow','Blue','Magenta','Cyan','Grey');
for i=1:7
   fprintf(fid,'%s\n%7.7s Pnt Lev          X          Y          Z      x      y       Y\n',Separator,ColStr(i,:));
   for j=1:CalPoints
      X = XYZ(i,j,1);
      Y = XYZ(i,j,2);
      Z = XYZ(i,j,3);
      xx = X/(X + Y + Z);
      yy = Y/(X + Y + Z);
      fprintf(fid,'        %3d %3d %10.3e %10.3e %10.3e %6.4f %6.4f %7.1f\n',j,Lev(j),X,Y,Z,xx,yy,Y);
   end
end

fprintf(fid,Separator);
fprintf(fid,'\nSpectral energies (W m-2 sr-1 nm-1) for peak intensity colours\n');
fprintf(fid,'|Wlen |Red       |Green     |Yellow    |Blue      |Magenta   |Cyan      |White     |Black     |\n');
[m n] = size(DspSpc);
for i = 1:m
    fprintf(fid,'|%5.1f|%10.3e|%10.3e|%10.3e|%10.3e|%10.3e|%10.3e|%10.3e|%10.3e|\n',...
        DspSpc(i,1),DspSpc(i,2),DspSpc(i,3),DspSpc(i,4),DspSpc(i,5),DspSpc(i,6),DspSpc(i,7),DspSpc(i,8),BlkSpc(i,2));
end
fprintf(fid,Separator);

fclose(fid);
return
%---------------------------------------------------------
% These functions set the calibration levels
%
function setlevels1(CalPoints)
%
% A simple linear distribution ignoring the monitor gamma
%
   global Lev
   
   Lev = fix(linspace(0,255,CalPoints));
      
return

function setlevels(CalPoints,IntLev,YVals)
%
% A linear interpolation modelling the monitor gamma as 
% a set of straight lines
%  
   n = size(IntLev,2);
   
   for i=2:n
      if YVals(i) <= YVals(i - 1)
         setlevels1(CalPoints)
         return
      end
   end
   
   global Lev
   
   Lev = zeros(1,1);
   
   Lev(1) = IntLev(1);
   
   for Cal=2:(CalPoints - 1)
      YTarget = YVals(1) + (YVals(n) - YVals(1))*(Cal - 1)/(CalPoints - 1);
      Lev(Cal) = round(interp1(YVals,IntLev,YTarget,'linear'));
   end
   
   Lev(CalPoints) = IntLev(end); 
   
return
%---------------------------------------------------------
% This function cleans up, posts an error message and exits
%
function cleanup(Str)

cgshut
cgphotometer('shut')

fprintf(['\ndspcalib ERROR: ' Str '\n\n'])

return
%---------------------------------------------------------
% This function printd the usage guide
%
function PrintUsage

fprintf('\n dspcalib v1.33\n\n')
fprintf(' This function calibrates a display\n\n')
fprintf(' Usage: dspcalib(Port,CalPoints,SettleTime,LeaveTime,Filename) or\n')
fprintf(' Usage: dspcalib(Port,CalPoints,SettleTime,LeaveTime,Filename,Res,BPP,Ref,Mon) or\n\n')
fprintf(' Usage: dspcalib(PhotoModel,Port,CalPoints,SettleTime,LeaveTime,Filename) or\n')
fprintf(' Usage: dspcalib(PhotoModel,Port,CalPoints,SettleTime,LeaveTime,Filename,Res,BPP,Ref,Mon)\n\n')
fprintf('         PhotoModel = Photometer model (''PR650'' or ''PR670''). Assume ''PR670'' if omitted.\n')
fprintf('               Port = serial or COM port (1-8)\n')
fprintf('          CalPoints = Number of calibration points (2-256)\n')
fprintf('         SettleTime = seconds to allow display to settle (0-60)\n')
fprintf('          LeaveTime = seconds to leave the room (0-60)\n')
fprintf('           Filename = name for display calibration data file\n')
fprintf('                Res = Display resolution (1-6) [1]\n')
fprintf('                      or [HorPix VerPix]\n')
fprintf('                BPP = Bits per pixel (0/8/16/24/32) [0]\n')
fprintf('                Ref = Refresh rate in Hz (>=0) [0]\n')
fprintf('                Mon = Monitor number (>= 0) [1]\n\n')
fprintf('         N.B. If CalPoints is negative we use the ''XYZB'' light\n')
fprintf('              measurement function to average several readings.\n\n')

return
