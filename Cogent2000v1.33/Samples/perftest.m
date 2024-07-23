function perftest
% Sample script perftest v1.33
%
% This script tests the Cogent Graphics
% performance for drawing dots, lines, rectangles
% and ellipses on 8, 16, 24 and 32 bit screens
%
% Results are reported to the screen and saved in 
% file perfdata.txt
%
% Usage:-   perftest
global	bits TypeStr MaxArraySize
%
% Are we on Student Matlab ?
%
try
   MaxArraySize = 1000000;
   a = zeros(3,MaxArraySize);
   a = 0;
catch
   MaxArraySize = 5000;
end
%
% What are the different types ?
%
TypeStr = {'Dot' 'Line' 'Rect' 'Ellipse'};
%
% Initialize results variables to null values
% They will be printed out at the end
%
mean = zeros(4,4);
sdev = zeros(4,4);
sdev(:,1) = [-1;-1;-1;-1];
gpd = 0;

for b = 1:4
   bits = b*8;
   
	switch InitGraphics
   case -1
      %
      % Major failure - close and exit program
      %
      ShutGraphics
      break
   case 0
      %
      % Minor failure - try another graphics mode
      %
   otherwise
      gpd = cggetdata('gpd');
      %
      % Success - perform each test in turn
      %     
      for i=1:4
         [mean(b,i),sdev(b,i)] = testobj(i);
      end
   end
   %
   % Tests done - clean up the graphics
   %
	ShutGraphics
end

disp(' ')
%
% Save data to file and write to screen too
%
fid = fopen('perfdata.txt','wt');
OutStr(fid,sprintf('%s %s\nMachine:%s\n',verstr,date,cogstd('sMachineID')))
if isstruct(gpd)
   OutStr(fid,sprintf('%s\nGLib %s\nDisplay %dx%d %.2fHz\n',...
      gpd.GPrimString,gpd.GLibString,...
      gpd.PixWidth,gpd.PixHeight,gpd.RefRate100/100))
end

for b=1:4
   if sdev(b,1)>=0
     	OutStr(fid,sprintf('\n   Cogent Graphics perfomance test (%d bit graphics)\n',b*8))
      for i=1:4
   	  	OutStr(fid,sprintf('%7.7ss per second:%-8d StdErr:%-8d\n',TypeStr{i},fix(mean(b,i)),fix(sdev(b,i))))
      end
   else
      OutStr(fid,sprintf('\n%d bit graphics unavailable\n',b*8))
   end  
end
fclose(fid);
%
% Put up an extra message just for the screen
%
disp(' ')
disp('Data saved in text file:perfdata.txt')
disp(' ')
%
% Clean up our global variables
%
clear global bits TypeStr MaxArraySize
%
% All done - return
%
return
%--------------------------------------
% Output a string to screen and logfile
%
function OutStr(fid,str)

fprintf(str);
fprintf(fid,str);

return
%--------------------------------------
% Return this program's ID string
%
function str = verstr

str = 'perftest v1.33';

return
%--------------------------------------
% Initialize the graphics
%
% Returns 1 if successful, 0 if it couldn't
% open the graphics or -1 if Cogent graphics 
% v1.17 or later not present
%
function Success = InitGraphics
%
% Global variables
%
global bits
%
% Open cogent graphics
%
cgloadlib
cgopen(1,bits,0,1)

Success = 1;

if gprim('ghwnd')
   %
   % Success - check the cogent version number
   %
	gpd = cggetdata('gpd');

	if gpd.Version < 117
   	disp('This program requires Cogent graphics v1.17 or later')
   	Success = -1;
	end
else
   %
   % Failed to open graphics
   %
   Success = 0;
end
%
% Return if unsuccessful
%
if Success ~= 1
   return
end
%
% Basic graphics initialisation
% Set the font
%
cgfont('Courier',10)
%
% This next bit depends on graphics mode
%
switch bits
case 8
   %
   % Palette mode
   % set cols 0 to 8 to Blk, Red, Grn, Yel, Blu, Mag, Cyn, Wht
   % set drawing colour to 0 (Blk)
   %
   cgpencol(0)
   cgcoltab(0,[0 0 0;1 0 0;0 1 0;1 1 0;0 0 1;1 0 1;0 1 1;1 1 1])
   cgnewpal
otherwise
   %
   % Direct mode
   % set drawing colour to 0,0,0 (Blk)
   %
   cgpencol(0,0,0)
end
%
% Clear the offscreen buffer
%
cgrect(0,0,640,480)
%
% All done - return
%
return
%--------------------------------------
% Shut the graphics
%
function ShutGraphics

cgshut

return
%--------------------------------------
% Return an array of 'n' colours
%
function col = getcol(n)
%
% Global variables
%
global bits

if bits > 8
   %
   % Direct mode
   %
   % Colours must be an array of n x 3
   %
   cols = [0 0 0;1 0 0;0 1 0;1 1 0;0 0 1;1 0 1;0 1 1;1 1 1];
   %
   % Initialize the col array to zeros
   %
   col = zeros(n,3);
   %
   % Set the R, G & B elements to randomly 0 or 1
   %
   col(:,1) = fix(rand(n,1) + .5);
   col(:,2) = fix(rand(n,1) + .5);
   col(:,3) = fix(rand(n,1) + .5);
else
   %
   % Palette mode
   %
   % Simply return an array of 'n' random integers 0 to 7
   %
   col = fix(rand(1,n)*7.999)';
end

return
%--------------------------------------
% Flip the graphics screen and put up a title
%
function flipit(text)

global bits

if bits > 8
   %
   % palette mode
   %
   % Clear top rectangle
   % Draw up text in white in cleared section
   % Flip offscreen to visible
   %
   cgrect(0,230,640,20,[0 0 0]);
   cgpencol(1,1,1);
   cgtext(sprintf('%s %d bits %s',verstr,bits,text),0,230)
	cgflip(0,0,0)
else
   %
   % Direct mode
   %
   % Clear top rectangle
   % Draw up text in white in cleared section
   % Flip offscreen to visible
   %
   cgrect(0,230,640,20,0);
   cgpencol(7);
   cgtext(sprintf('%s %d bits %s',verstr,bits,text),0,230)
   cgflip(0)
end

return
%--------------------------------------
% The drawing functions are all similar and differ only
% in the type of graphic object drawn
%
function [mean,sdev] = testobj(type)
%
global MaxArraySize bits
%
% Make each test last about 1 second
% First get a rough estimate of the number of objects
% per second
%
n = 5000;

while 1
   i = TimingTest(type,n,1,1);
   
   if ((i/n) < 10)|(n >= MaxArraySize)
      break
   end
   
	n = min(i,MaxArraySize);
end
%
% Now choose n and m such that number of items will
% take at least a second to draw
%
%
if i < MaxArraySize
   n = i;
   m = 1;
else
   n = MaxArraySize;
   m = fix((i + n - 1)/n);
   n = fix((i + m - 1)/m);
end
%
% Do the timing test
%
ops = TimingTest(type,n,m,10);
%
% Calculate the mean and standard error
% and output to the screen and logfile
%
mean = sum(ops)/length(ops);
sdev = std(ops)/sqrt(length(ops));

return
%
% This function performs a single timing test
%
function ops = TimingTest(type,n,m,l)
%
% Globals
%
global TypeStr
%
% Get an array of random colours for the graphics objects
%
col = getcol(n);
%
% Initialize variables for each type of object
%
switch type
case 1
   %
	% DOTS
	%
	x = rand(1,n)*638 - 319;
	y = rand(1,n)*478 - 239;
case 2
   %
   % LINES
	%
	x1 = rand(1,n)*638 - 319;
	y1 = rand(1,n)*478 - 239;
   
   x2 = x1 + rand(1,n)*40 - 20;
  	y2 = y1 + rand(1,n)*40 - 20;
case 3
   %
   % RECTANGLES
   %
	x = rand(1,n)*638 - 319;
	y = rand(1,n)*478 - 239;
   
   w = 1 + rand(1,n)*39;
   h = 1 + rand(1,n)*39;
case 4
   %
   % ELLIPSES
   %
	x = rand(1,n)*638 - 319;
	y = rand(1,n)*478 - 239;
   	
   w = 1 + rand(1,n)*39;
   h = 1 + rand(1,n)*39;
end
%
% Perform the tests
%
for i = 1:l
	switch type
	case 1
   	%
		% DOTS
   	%
		t1 = cogstd('sgettime',-1);
   	for j = 1:m
      	cgdraw(x,y,col);
	   end
   	t2 = cogstd('sgettime',-1);
	case 2
   	%
	   % LINES
		%
		t1 = cogstd('sgettime',-1);
  		for j = 1:m
     		cgdraw(x1,y1,x2,y2,col);
	   end
   	t2 = cogstd('sgettime',-1);
	case 3
   	%
	   % RECTANGLES
   	%
		t1 = cogstd('sgettime',-1);
   	for j = 1:m
      	cgrect(x,y,w,h,col);
	   end
   	t2 = cogstd('sgettime',-1);
	case 4
   	%
	   % ELLIPSES
   	%
		t1 = cogstd('sgettime',-1);
   	for j = 1:m
      	cgellipse(x,y,w,h,col,'f');
	   end
   	t2 = cogstd('sgettime',-1);
	end
   
   ops(i) = fix(n*m/(t2 - t1));
   
   if l == 1
     	flipit(sprintf('%s test timing evaluation',TypeStr{type}))
   else
      flipit(sprintf('%s test %d of %d',TypeStr{type},i,l))
   end
end

return