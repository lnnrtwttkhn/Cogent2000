function alpha(bits)
% Sample script alpha v1.33
%
% Creates a fade-in/fade-out display using alpha blitting.
%
% Usage:-   alpha(bits)
%
%           bits = 16/24/32
%

switch nargin
case 0
    bits = 0;
case 1
	switch bits
	case {16 24 32}
	otherwise
		PrintUsage
        return
	end
otherwise
	PrintUsage
    return
end

%*************************************************************
% Initialise Cogent, check the version number, open the 
% graphics, get the screen dimensions and load up a suitable font
%
cgloadlib

csd = cggetdata('csd');
if csd.Version < 125
   	disp('This program requires Cogent graphics v1.25 or later')
    return;
end

cgopen(1,bits,0,1,'Alpha')

gsd = cggetdata('gsd');
ScrWid = gsd.ScreenWidth;
ScrHgh = gsd.ScreenHeight;
TxtPosY = ScrHgh/2 - 10;

cgfont('Courier',60)
%*************************************************************
% Make the background sprite.
% "Full-screen"
% "Alpha-blending" 
% "Screen 1"
% in white on a vertical striped red and magenta background
%
cgmakesprite(1,ScrWid,ScrHgh,1,0,1)
cgsetsprite(1)
%
% Draw the stripes
%
StripeWid = ScrWid/40;
StripeWid2 = StripeWid*2;
for y = -ScrHgh/2:StripeWid2:ScrHgh/2;
    cgrect(0,y,ScrWid,StripeWid,[1 0 0])
end
cgpencol(1,1,1)
cgtext('Full-screen',0,3*ScrHgh/8)
cgtext('Alpha-blending',0,2*ScrHgh/8)
cgtext('Screen 1',0,ScrHgh/8)
%
% Clear the top
%
cgrect(0,ScrHgh/2 - 10,ScrWid,20,[0 0 0])
%*************************************************************
% Make the foreground sprite.
% "Full-screen"
% "Alpha-blending" 
% "Screen 2"
% in black on a horizontal striped red and yellow background
%
cgmakesprite(2,ScrWid,ScrHgh,1,0,0)
cgsetsprite(2)
%
% Draw the stripes
%
for x = -ScrWid/2:StripeWid2:ScrWid/2;
    cgrect(x,0,StripeWid,ScrHgh,[1 1 0])
end
cgpencol(0,0,0)
cgtext('Full-screen',0,-1*ScrHgh/8)
cgtext('Alpha-blending',0,-2*ScrHgh/8)
cgtext('Screen 2',0,-3*ScrHgh/8)
%
% Clear the top
%
cgrect(0,ScrHgh/2 - 10,ScrWid,20,[0 0 0])
%*************************************************************
% Reset graphics values
%
cgfont('Courier',10)
cgsetsprite(0)
cgpencol(1,1,1)
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
S1 = cgflip;
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
% Initialize the blending factor to 0 (screen 1)
%
blend = 0;
blendinc = 1/255;

while ~kd(1)
%
% Read the keyboard
%
   kd = cgkeymap;
   t = t + 1;
%
% Save the previous timestamp in OldS, flip the screen, and 
% save the timestamp in 'S'.
%
   OldS = S;
   S = cgflip;
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
% Adjust the blend constant
%
    blend = blend + blendinc;
    if blend > 1
        blend = 1;
        blendinc = -1/255;
    elseif blend < 0
        blend = 0;
        blendinc = 1/255;
    end
%
% Draw up the display
%
    cgdrawsprite(1,0,0)
    cgdrawsprite(2,0,0,blend)
%
% Draw up the statistics
%
% Priority class for current process
% Time since start of test
% Frames since start of test
% Average refresh rate since start of test
% No of dropped frames
%
   str = sprintf('Alpha v1.33 P:%s Tim:%02d:%02d:%02d Frm:%d Av:%-.2fHz Drp:%d',...
   cogstd('spriority'),...
   fix(S/3600),mod(fix(S/60),60),mod(fix(S),60),...
   t,...
   (t/(S - S1)),...
   Drp);
   cgtext(str,0,TxtPosY)
end

cgshut

return
%-----------------------------------------------------
% Print the usage guide for this script
%
function PrintUsage

fprintf('\nusage - alpha(Bits)\n\n')
fprintf('       Bits = Bits per pixel (16/24/32)\n\n')

return
