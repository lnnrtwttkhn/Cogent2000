function soundadj
% Sample script soundadj v1.33
%
% Creates a display of expanding coloured concentric circles
% with an accompanying audio tone.  Use the mouse and mouse
% buttons to adjust the frequency, volume and stereo balance
% of the sound.  The display is in palette mode.
%
% Usage:-   soundadj
%
%*************************************************************
% Initialise Cogent, check the version number, open the 
% graphics, get the screen dimensions and set the scale.
% Load up a suitable font
%
cgloadlib

csd = cggetdata('csd');
if csd.Version < 125
   	disp('This program requires Cogent graphics v1.25 or later')
    return;
end

cgopen(1,8,0,1)

gsd = cggetdata('gsd');
ScrWid = gsd.ScreenWidth;
ScrHgh = gsd.ScreenHeight;

ScrWid2 = ScrWid/2;
ScrHgh2 = ScrHgh/2;

cgscale(ScrWid)

cgfont('Courier',10)
%*************************************************************
% Initialise the palette
%
cgcoltab(0,0,0,0)	% palette index 0 r,g,b = 0,0,0 = black
cgcoltab(1,1,1,1)	% palette index 1 r,g,b = 1,1,1 = white

cgnewpal
%
% Make the background sprite.
% It should be twice the width of the screen
%
cgmakesprite(1,ScrWid*2,ScrHgh)
cgsetsprite(1)
%
% Now fill it with concentric circles.
% The diameter of the biggest circle should be
% the same length as the diagonal of a rectangle
% 2xScrWid wide by ScrH high.
%
m = fix(sqrt(ScrWid*ScrWid*4 + ScrHgh*ScrHgh));
%
% Start with the biggest diameter (m) and draw
% decreasing filled circles down to diameter 1
%
% Palette colour should cycle from 2 to 202
%
for i = m:-2:1
    cgellipse(0,0,i,i,2 + mod(fix(i/2),200),'f')
end
%
% Make the colour table.  This has 200 entries
% repeated twice so 400 entries...
%
coltab = zeros(400,3);
%
% Entries 1 to 67 are a colour ramp from red to
% green
%
for i=1:67
    lev = (i-1)/66;
    coltab(i,:) = [(1 - lev) lev 0];
end
%
% Entries 68 to 133 are a colour ramp from green
% to blue
%
for i=1:66
    lev = (i-1)/65;
    coltab(i + 67,:) = [0 (1 - lev) lev];
end
%
% Entries 134 to 200 are a colour ramp from blue
% to red
%
for i=1:67
    lev = (i-1)/66;
    coltab(i + 133,:) = [lev 0 (1 - lev)];
end
%
% Entries 201 to 400 are a copy of 1 to 200
%
coltab(201:400,:) = coltab(1:200,:);
%*************************************************************
% Set sprite zero and set the pen colour to white
%
cgsetsprite(0)
cgpencol(1)
%*************************************************************
% Initialize the sound system
%
% Stereo (2 channel), 16 bits per sample, 48KHz playing rate,
% -50db volume attenuation, sound device 0 (default sound device)
%
cgsound('open',2,16,48000,-50,0)
%
% Create and load a sinewave; 1500Hz, 1 second, 48,000 samples
% per second
%
MaxFrq = 1500;

mat = sinwav(MaxFrq,1,48000);
cgsound('MatrixSND',1,mat,48000)
%
% Set the sound playing continuously at zero volume
%
cgsound('vol',1,0)
cgsound('play',1,1)

vol = 1;
frq = 0.5;
pan = 0;
phs = 1;

oldvol = -10;
oldfrq = -10;
oldpan = -10;
%*************************************************************
% Initialise the statistics...
%
% S1   is the timestamp at the beginning of the test
% S    is the timestamp of the current frame
% OldS is always the timestamp of the previous flip
% Drp   is the number of frames that have been 'dropped', i.e.
%       the number of times that the time taken between frames
%       indicates that a VBL has been missed
%
S1 = cgflip(0);
S = S1;
Drp = 0;
%*************************************************************
% The main animation loop
%
% t gives the frame number.
% You must break this loop with Ctrl+C and then use Alt+Tab to
% restore the screen
%
t = 0;
%
% We break out of the loop when the escape key is pressed.
% Initialize the state to 'not pressed' (0).
%
kd(1) = 0;
%
%
% Initialize the mouse to 0,-(ScrHgh - 1)/18.  This corresponds
% to pan = 0, frq = 0.5
%
cgmouse(0,-ScrHgh/18)
%
while ~kd(1)
%
% Read the keyboard
%
   kd = cgkeymap;
   t = t + 1;
%
% Read the mouse
%
   [x,y,bs,bp] = cgmouse;
%
% Save the previous timestamp in OldS, flip the screen, clear 
% the next screen to black and save the timestamp in 'S'.
%
   OldS = S;
   S = cgflip;
   setcols(coltab,vol,phs)
%
% Has a frame been dropped ?
%
% The average time between frames is (S - S1)/t
%
% If the interval differs from the average by more than 4mS
% then assume that a frame has been dropped.  When using sound
% there may be more variability in the frame periods so allow
% 4mS here rather than the usual 2mS
%
% Wait until 100 frames have been completed before applying
% this test though, so that the average is accurate.
%   
   if (t > 100)
      sAvg = (S - S1)/t;
      sDif = S - OldS;
      if (abs(sAvg - sDif) > 0.004)
         Drp = Drp + 1;
      end
   end
%
% Update the sound settings
%
    if bitand(bs,1) ~= 0
        vol = max(vol - .01,0);
    end
    if bitand(bs,4) ~= 0
        vol = min(vol + .01,1);
    end
    
    pan = x/ScrWid2;
    frq = 0.1 + (y + ScrHgh2 - 1)*0.9/(ScrHgh - 1);

    if oldvol ~= vol
        cgsound('vol',1,vol)
        oldvol = vol;
    end
    if oldfrq ~= frq
        cgsound('frq',1,frq)
        oldfrq = frq;
    end
    if oldpan ~= pan
        cgsound('pan',1,pan)
        oldpan = pan;
    end

    phs = phs + 10*(frq - 0.01);
%
% Draw up the display
%
   cgalign('c','c')   
   cgblitsprite(1,-x,0,ScrWid,ScrHgh,0,-22,ScrWid,ScrHgh)
%
% Draw up the statistics
%
% Priority class for current process
% Time since start of test
% Frames since start of test
% Average refresh rate since start of test
% No of dropped frames
%
   cgalign('c','t')
   cgrect(0,ScrHgh2,ScrWid,45,0)
   str = sprintf('soundadj v1.33 P:%s Tim:%02d:%02d:%02d Frm:%d Av:%-.2fHz Drp:%d',...
   cogstd('spriority'),...
   fix(S/3600),mod(fix(S/60),60),mod(fix(S),60),...
   t,...
   (t/(S - S1)),...
   Drp);
   cgtext(str,0,ScrHgh2)
   cgtext(sprintf('Vol: %.2f  Pan: %.2f  Frq: x%.2f (%.0fHz)',vol,pan,frq,frq*MaxFrq),0,ScrHgh2 - 15)
   cgtext('Use mouse position and buttons to adjust the sound',0,ScrHgh2 - 30)
end
cgsound('shut')
cgshut

return
%*************************************************************
% return a sinewave array
%
function mat = sinwav(Frequency,Duration,SamplingRate)
	
mat = sin((1:Duration*SamplingRate)*2*pi*Frequency/SamplingRate);

return
%*************************************************************
% This function sets the colours
%
function setcols(coltab,vol,phs)

phs = 200 - mod(fix(phs),200);

cols = coltab(phs:199 + phs,:)*vol;
cgcoltab(2,cols)
cgnewpal('i')

return
