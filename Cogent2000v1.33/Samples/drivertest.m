function drivertest
% Sample script drivertest v1.33
%
% Checks for bugs in graphics drivers
%
% Usage:-   drivertest
%

switch nargin
case 0
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
if csd.Version < 128
   	disp('This program requires Cogent graphics v1.28 or later')
    return;
end

MirrorTest
TrnBltTest(1)
TrnBltTest(2)
SysMemTest

return
%*************************************************************
% Test for the "MIRROR" driver bug
%
function MirrorTest

cgopen(1,0,0,1)
cgpencol(1,1,1)
cgfont('Courier',10)

cgtext('This function tests your graphics driver for known bugs',0,230)
cgtext('This test is for the ''MIRROR'' driver bug',0,210)

w = 100;
h = 20;

w2 = w*2;
h2 = h*2;

cgmakesprite(1,w,h,0,0,0)
cgsetsprite(1)
cgtext('Correct',0,0)

cgmakesprite(2,w2,h2,0,0,0)
cgmakesprite(3,w2,h2,0,0,0)
cgmakesprite(4,w2,h2,0,0,0)

cgsetsprite(2)
cgblitsprite(1,0,0,w,h,0,0,-w2,-h2)
cgsetsprite(3)
cgblitsprite(2,0,0,w2,h2,0,0,-w2,-h2)

cgdriver('mirror','hide')
cgsetsprite(2)
cgblitsprite(1,0,0,w,h,0,0,-w2,-h2)
cgsetsprite(4)
cgblitsprite(2,0,0,w2,h2,0,0,-w2,-h2)

cgsetsprite(0)

y = 80;

cgrect(0,y,w2+10,h2+10,[1 1 1])
cgrect(0,y,w2,h2,[0 0 0])
cgdrawsprite(3,0,y)

y = 20;

cgrect(0,-y,w2+10,h2+10,[1 1 1])
cgrect(0,-y,w2,h2,[0 0 0])
cgdrawsprite(4,0,-y)

cgtext('You should see two identical boxes above, each containing the',0,-120)
cgtext('word "Correct".                                              ',0,-135)
cgtext('If you do not, you may need to apply the "MIRROR" driver fix ',0,-150)

cgtext('Press the spacebar to continue to the next test',0,-230)

cgflip

while 1
	cgflip('V');
	[kd,kp] = cgkeymap;
	if kp(57)
		[kd,kp] = cgkeymap;
		if ~kp(57)
			break
		end
	end
end

cgshut

return
%*************************************************************
% Test for the "TRNBLT" driver bug
%
function TrnBltTest(Mode)

if (Mode == 1)
	col0 = 0;
	col1 = 1;
    col2 = 2;
    col2b = col2;
	cgopen(1,8,0,1)
	cgcoltab(0,[0 0 0;1 1 1;1 0 0])
	cgnewpal
else
	col0 = [0 0 0];	
	col1 = [1 1 1];	
    col2 = 'r';
    col2b = [1 0 0];
	cgopen(1,0,0,1)
end

cgpencol(col1)
cgfont('Courier',10)

cgtext('This function tests your graphics driver for known bugs',0,230)
cgtext('This test is for the ''TRNBLT'' driver bug',0,210)

w = 100;
h = 20;

w2 = w*2;
h2 = h*2;
%
% Sprites 3 & 4 contain the word "Correct" drawn in colour index 1
% on a background of colour index 0
%
cgmakesprite(2,w,h,col0)
cgsetsprite(2)
cgtext('Correct',0,0)

cgmakesprite(3,w2,h2,col0)
cgsetsprite(3)
cgblitsprite(2,0,0,w,h,0,0,w2,h2)

cgmakesprite(4,w2,h2,col0)
cgsetsprite(4)
cgblitsprite(2,0,0,w,h,0,0,w2,h2)

for dstspr = 3:4
%
% Sprite 2 is initialised to colour 0
% We set transparent colour 2
%
	cgmakesprite(2,w2,h2,col0)
	cgtrncol(2,col2)
%
% We then do a transparent blit within this sprite
%
	cgsetsprite(2)
	cgblitsprite(2,0,0,1,1,0,0,1,1)
%
% From now on, when we try to do a cgrect with colour 2
% it will actually be colour 0
%
	cgrect(0,0,w2,h2,col2b)
%
% So now we draw sprite 2 into dstspr
%
	cgsetsprite(dstspr)
	cgdrawsprite(2,0,0)

	cgdriver('trnblt','hide')
end

cgsetsprite(0)

y = 80;

cgrect(0,y,w2+10,h2+10,col1)
cgrect(0,y,w2,h2,col0)
cgdrawsprite(3,0,y)

y = 20;

cgrect(0,-y,w2+10,h2+10,col1)
cgrect(0,-y,w2,h2,col0)
cgdrawsprite(4,0,-y)

cgtext('You should see two identical boxes above, each containing the',0,-120)
cgtext('word "Correct".                                              ',0,-135)
cgtext('If you do not, you may need to apply the "TRNBLT" driver fix ',0,-150)

cgtext('Press the spacebar to end the test',0,-230)

cgflip

while 1
	cgflip('V');
	[kd,kp] = cgkeymap;
	if kp(57)
		[kd,kp] = cgkeymap;
		if ~kp(57)
			break
		end
	end
end

cgshut

return
%*************************************************************
% Test for the "SYSMEM" driver bug
%
function SysMemTest

cgopen(1,0,0,1)
cgpencol(1,1,1)
cgfont('Courier',10)

cgtext('This function tests your graphics driver for known bugs',0,230)
cgtext('This test is for the ''SYSMEM'' driver bug',0,210)

w = 100;
h = 20;

w2 = w*2;
h2 = h*2;

cgmakesprite(10,w,h,0,0,0)
cgsetsprite(10)
cgtext('Correct',0,0)
cgmakesprite(11,w2,h2,0,0,0)
cgsetsprite(11)
cgblitsprite(10,0,0,w,h,0,0,w2,h2)

cgsetsprite(0)
for y=[20 80]
    cgrect(0,y,w2+10,h2+10,[1 1 1])
    cgrect(0,y,w2,h2,[0 0 0])
    cgdrawsprite(11,0,y)
end

for pass = 1:2
    if pass == 2
        cgdriver('SYSMEM','HIDE')
    end
%
% Sprite 1 is mainly black with some white dots
%
    cgmakesprite(1,w,h,0,0,0)
    cgsetsprite(1)
    cgpencol(1,1,1)
    for i=-11:2:11
        x = fix(-51:2:51);
        y = ones(1,length(x))*fix(i);
        cgdraw(x,y)
    end
%
% Sprite 2 is mainly white with some black dots
%
    cgmakesprite(2,w,h,1,1,1)
    cgsetsprite(2)
    cgpencol(0,0,0)
    for i=-11:2:11
        x = fix(-51:2:51);
        y = ones(1,length(x))*fix(i);
    	cgdraw(x,y)
    end
%
% Sprites 3 and 4 are enlarged versions of 1 & 2
%
% Sprite 3 mainly black with some white dots
% Sprite 4 mainly white with some black dots
%
    cgmakesprite(3,w2,h2,0,0,0)
    cgsetsprite(3)
    cgblitsprite(1,0,0,w,h,0,0,w2,h2)

    cgmakesprite(4,w2,h2,0,0,0)
    cgsetsprite(4)
    cgblitsprite(2,0,0,w,h,0,0,w2,h2)
%
% Now make white transparent in sprite 4 and draw it onto sprite 3
% Result should be all black
%
    cgtrncol(4,'w')
    cgsetsprite(3)
    cgdrawsprite(4,0,0)
    
    cgtrncol(3,'n')
    cgsetsprite(0)
    
    switch pass
        case 1
            cgdrawsprite(3,0,80)
        case 2
            cgdrawsprite(3,0,20)
    end
end

cgsetsprite(0)
cgpencol(1,1,1)

cgtext('You should see two identical boxes above, each containing the',0,-120)
cgtext('word "Correct".                                              ',0,-135)
cgtext('If you do not, you may need to apply the "SYSMEM" driver fix.',0,-150)
cgtext('However, as this can adversely affect graphics performance it',0,-165)
cgtext('is better to use ''SYSMEM'' as an argument in selected calls to',0,-180)
cgtext('cgmakesprite, cgloadbmp and cgloadarray instead.             ',0,-195)

cgtext('Press the spacebar to continue to the next test',0,-230)

cgflip

while 1
	cgflip('V');
	[kd,kp] = cgkeymap;
	if kp(57)
		[kd,kp] = cgkeymap;
		if ~kp(57)
			break
		end
	end
end

cgshut

return
%-----------------------------------------------------
% Print the usage guide for this script
%
function PrintUsage

fprintf('\nusage - drivertest\n\n')

return
