function cieplot(Flags)
% cieplot v1.33
%
% This function plots the CIE (1931) Chromaticity diagram
%
% Usage: cieplot(Flags)
%
% Flags is the arithmetic sum of the following
%
%      1 plots the figure on a black background
%      2 plots an outline of visible wavelengths
%      4 plots approximate colours
%      8 plots the black body radiation curve
%   
global	x y z w WaveN WaveC bcol fcol fontsize bbt bbx bby bbz

if nargin == 0
   Flags = 14;
elseif ~isnumeric(Flags)
   PrintUsage
   return;
end

blackflag = 0;
outlineflag = 0;
blackbodyflag = 0;
coloursflag = 0;

if Flags < 16   
  	if Flags >= 8
      blackbodyflag = 1;
      Flags = Flags - 8;
   end
      
   if Flags >= 4
   	coloursflag = 1;
      Flags = Flags - 4;
   end
      
 	if Flags >= 2
    	outlineflag = 1;
     	Flags = Flags - 2;
   end
      
	if Flags >= 1
   	blackflag = 1;
      Flags = Flags - 1;
   end
end
%
% Initialize back and foreground colours 
%
if blackflag > 0
   bcol = [0 0 0];
	fcol = [1 1 1];
else
   bcol = [1 1 1];
	fcol = [0 0 0];
end
%
% Initialize tables
%
InitTables
%
% Clear and reset the graphics
%
gcf;
clf reset

figsz = get(gcf,'Position');
width = figsz(3);
height = figsz(4);
if width*9 > height*8
   width = height*8/9;
else
   height = width*9/8;
end
fontsize = height/100;

axis equal
axis([-.04 .8 -.05 .9]);
grid on;
set(gcf,'color',bcol);
set(gca,'color',bcol);
set(gca,'xcolor',fcol);
set(gca,'ycolor',fcol);
set(gca,'xtick',[.0 .1 .2 .3 .4 .5 .6 .7 .8],'FontSize',fontsize);
set(gca,'ytick',[.0 .1 .2 .3 .4 .5 .6 .7 .8 .9],'FontSize',fontsize);

xlabel('x','FontSize',fontsize)
ylabel('y','FontSize',fontsize)

text(0.41,0.71,{'C.I.E. 1931';'CHROMATICITY'; 'DIAGRAM'},'HorizontalAlignment','left','VerticalAlignment','bottom','FontSize',fontsize*12/8,'Color',fcol);

hold on

if (blackflag ~= 0)&(coloursflag == 0)
   PlotWhite = 1;
else
   PlotWhite = 0;
end

if outlineflag > 0
   annotateoutline
end

if blackbodyflag > 0
   plotblackbody(PlotWhite)
end

if coloursflag > 0
   plotcolours
end

if outlineflag > 0
	plotoutline
end

hold off
%
% Clean up global variables
%
clear global	x y z w WaveN WaveC bcol fcol fontsize bbt bbx bby bbz

return
%
% plot an approximation to the colours on the graph
%
function plotcolours

global	x y z w

[m,n] = size(w);

xx=zeros(n,1);
yy=zeros(n,1);

xx(1) = x(1)/(x(1) + y(1) + z(1));
yy(1) = y(1)/(x(1) + y(1) + z(1));

px = [0 xx(1) 0.3333];
py = [0 yy(1) 0.3333];

pc(1,1,1:3) = [0 0 0];
pc(1,2,1:3) = w2rgb(w(1));
pc(1,3,1:3) = [1 1 1];

k = 2;

for i=2:n + 1
   if i <= n
      xx(i) = x(i)/(x(i) + y(i) + z(i));
      yy(i) = y(i)/(x(i) + y(i) + z(i));
      nm = w(i);
   else
	   xx(i) = xx(1);
      yy(i) = yy(1);
      nm = w(1);
   end
   
   k = 3 - k;
   
   px(k) = xx(i);
   py(k) = yy(i);
      
   pc(1,k,1:3) = w2rgb(nm);
   
	patch(px,py,pc,'EdgeColor','none')
end

return
%
% plot the outline of visible wavelengths on the graph
%
function plotoutline

global	x y z w fcol

[m,n] = size(w);

xx=zeros(n,1);
yy=zeros(n,1);

xx(1) = x(1)/(x(1) + y(1) + z(1));
yy(1) = y(1)/(x(1) + y(1) + z(1));

for i=2:n + 1
   if i <= n
      xx(i) = x(i)/(x(i) + y(i) + z(i));
      yy(i) = y(i)/(x(i) + y(i) + z(i));
      nm = w(i);
   else
	   xx(i) = xx(1);
      yy(i) = yy(1);
      nm = w(1);
   end
end

plot(xx,yy,'-','Color',fcol);

return
%
% Approximate an rgb triplet to a wavelength
%
function rgb = w2rgb(nm)

global WaveN WaveC

if nm < WaveN(1)
   rgb = [0 0 0];
   return;
elseif nm > WaveN(end)
   rgb = [0 0 0];
   return
end
   
rgb = [interp1(WaveN,WaveC(:,1),nm,'linear') interp1(WaveN,WaveC(:,2),nm,'linear') interp1(WaveN,WaveC(:,3),nm,'linear') ];

return
%
% add marker points and text to annotate the wavelength outline
%
function annotateoutline

plotw = [380 450 460 470 480 490 500 510 520 530 540 550 560 570 580 590 600 610 620 630 640 770];

global x y z w fcol fontsize

[m,n] = size(plotw);

xx=zeros(n,1);
yy=zeros(n,1);

for i=1:n
   px = interp1(w,x,plotw(i));
   py = interp1(w,y,plotw(i));
   pz = interp1(w,z,plotw(i));

   xx(i) = px/(px + py + pz);
   yy(i) = py/(px + py + pz);

	str = sprintf('%.2f',plotw(i)/1000);
   
   if plotw(i) < 515
      text(xx(i),yy(i),[str(2:end) '  '],'HorizontalAlignment','right','VerticalAlignment','top','FontSize',fontsize,'Color',fcol);
   elseif plotw(i) == 770
      text(xx(i),yy(i),['  ' str(2:end) '\mu'],'HorizontalAlignment','left','VerticalAlignment','bottom','FontSize',fontsize,'Color',fcol);
   else
      text(xx(i),yy(i),['  ' str(2:end)],'HorizontalAlignment','left','VerticalAlignment','bottom','FontSize',fontsize,'Color',fcol);
   end
end

text(0.75,0.25,{'\uparrow';'Wavelength'; 'in microns'},'HorizontalAlignment','center','VerticalAlignment','top','FontSize',fontsize,'Color',fcol);

xx(n + 1) = xx(1);
yy(n + 1) = yy(1);

plot(xx,yy,'o','MarkerSize',fontsize*4/8,'MarkerEdgeColor',fcol,'MarkerFaceColor',fcol);

return

function plotblackbody(PlotWhite)

global fontsize fcol bbt bbx bby
 
ptemp = [1000 1500 1900 2366 2856 3600 4800 6500 10000 20000 999999];

if PlotWhite ~= 0
   cstr = 'w';
else
   cstr = 'k';
end

plot(bbx,bby,[cstr '-'])

[m,n] = size(ptemp);

for i=1:n
   xx(i) = interp1(bbt,bbx,ptemp(i));
   yy(i) = interp1(bbt,bby,ptemp(i));
   
   if i == n
      str = '\infty \rightarrow';
   else
      str = [sprintf('%d',ptemp(i)) ' \rightarrow'];
   end
   
   text(xx(i),.03,str,'Rotation',90, ...
      'VerticalAlignment','middle','HorizontalAlignment','right', ...
      'FontSize',fontsize,'Color',fcol)
end

px = interp1(bbt,bbx,6500);
py = interp1(bbt,bby,6500);

text(.23,.25,'BLACK BODY CURVE','FontSize',fontsize*6/8,'Rotation',50,'Color',cstr)
text(bbx(end),bby(end),'\infty ','FontSize',fontsize,...
	'VerticalAlignment','middle','HorizontalAlignment','right',...
	'Rotation',50,'Color',cstr)
text(px,py,'  6500','FontSize',fontsize*6/8,...
  	'VerticalAlignment','top','HorizontalAlignment','left','Color',cstr)
plot(xx,yy,'o','MarkerFaceColor',cstr,'MarkerEdgeColor',cstr,'MarkerSize',fontsize*4/8)

text(.43,.05,'Colour temperature in kelvin','FontSize',fontsize,'Color',fcol);

return

function InitTables
%
% Initialize some constants
%
global	x y z w bcol fcol fontsize WaveN WaveC bbt bbx bby bbz
%
% w, x, y and z are used to estimate xyz for any wavelength
%
%       w = wavelength in nm
% x, y, z = CIE (1931) colour-matching functions
%
w = [ 380 384 388 392 396   400 404 408 412 416 ...
      420 424 428 432 436   440 444 448 452 456 ...
      460 464 468 472 476   480 484 488 492 496 ...
      500 504 508 512 516   520 524 528 532 536 ...
      540 544 548 552 556   560 564 568 572 576 ...
		580 584 588 592 596   600 604 608 612 616 ...
      620 624 628 632 636   640 644 648 652 656 ...
      660 664 668 672 676   680 684 688 692 696 ...
      700 704 708 712 716   720 724 728 732 736 ...
      740 744 748 752 756   760 764 768 772 776 ...
      780];

x = [0.001368 0.001996 0.003301 0.005330 0.008751 		0.014310 0.020748 0.033881 0.055023 0.086958 ...
	  0.134380 0.198611 0.258777 0.304897 0.334351 		0.348280 0.349287 0.341809 0.330041 0.314025 ...
	  0.290800 0.260423 0.218407 0.173327 0.132179 		0.095640 0.064581 0.041151 0.024144 0.012162 ...
	  0.004900 0.002236 0.005175 0.015536 0.034815 		0.063270 0.099456 0.142368 0.189140 0.238321 ...
	  0.290400 0.345483 0.403378 0.464336 0.528296 		0.594500 0.661570 0.728828 0.794826 0.857933 ...
	  0.916300 0.967218 1.009089 1.040986 1.059794 		1.062200 1.050977 1.022666 0.979331 0.923194 ...
	  0.854450 0.772954 0.685602 0.601114 0.522600 		0.447900 0.377533 0.313019 0.256118 0.207097 ...
	  0.164900 0.129147 0.099690 0.076804 0.059807 		0.046770 0.035405 0.026345 0.019600 0.014791 ...
	  0.011359 0.008679 0.006627 0.005053 0.003834 		0.002899 0.002197 0.001660 0.001246 0.000929 ...
	  0.000690 0.000512 0.000383 0.000289 0.000219 		0.000166 0.000126 0.000095 0.000072 0.000055 ...
     0.000042];

y = [0.000039 0.000057 0.000094 0.000151 0.000247 		0.000396 0.000572 0.000941 0.001531 0.002455 ...
     0.004000 0.006546 0.009768 0.013583 0.018007 		0.023000 0.028351 0.034521 0.041768 0.050244 ...
	  0.060000 0.070911 0.083667 0.099046 0.117532 		0.139020 0.162718 0.191274 0.226734 0.270185 ...
	  0.323000 0.389288 0.463394 0.544512 0.629346 		0.710000 0.777837 0.836307 0.884962 0.923735 ...
	  0.954000 0.976023 0.990313 0.998098 0.999857 		0.995000 0.982724 0.963857 0.938499 0.907006 ...
	  0.870000 0.827581 0.781192 0.732422 0.682219 		0.631000 0.579638 0.528353 0.478030 0.429080 ...
	  0.381000 0.332818 0.286594 0.244890 0.208162 		0.175000 0.145126 0.118779 0.096189 0.077121 ...
	  0.061000 0.047550 0.036564 0.028077 0.021801 		0.017000 0.012835 0.009533 0.007085 0.005343 ...
	  0.004102 0.003134 0.002393 0.001825 0.001384 		0.001047 0.000793 0.000599 0.000450 0.000335 ...
	  0.000249 0.000185 0.000138 0.000104 0.000079 		0.000060 0.000045 0.000034 0.000026 0.000020 ...
     0.000015];

z = [0.006450 0.009415 0.015588 0.025203 0.041438 		0.067850 0.098540 0.161304 0.262611 0.416209 ...
     0.645600 0.959439 1.258123 1.494804 1.656405 		1.747060 1.780433 1.779198 1.764039 1.733560 ...
     1.669200 1.564528 1.389880 1.187824 0.994198 		0.812950 0.652105 0.520338 0.416184 0.334858 ...
     0.272000 0.223453 0.179225 0.138376 0.103905 		0.078250 0.060788 0.047753 0.036936 0.027712 ...
     0.020300 0.014585 0.010378 0.007382 0.005304 		0.003900 0.002935 0.002309 0.001948 0.001766 ...
     0.001650 0.001458 0.001205 0.001049 0.000969 		0.000800 0.000645 0.000435 0.000283 0.000230 ...
     0.000190 0.000117 0.000065 0.000039 0.000028 		0.000020 0.000012 0.000003 0.000000 0.000000 ...
     0.000000 0.000000 0.000000 0.000000 0.000000     0.000000 0.000000 0.000000 0.000000 0.000000 ...
     0.000000 0.000000 0.000000 0.000000 0.000000     0.000000 0.000000 0.000000 0.000000 0.000000 ...
     0.000000 0.000000 0.000000 0.000000 0.000000     0.000000 0.000000 0.000000 0.000000 0.000000 ...
     0.000000];
%
% These interpolation fiducials are used to approximate a wavelength to an RGB triplet
%
WaveN = [380 476 494 515 580 632 780];
WaveC = [ 0 0 1; 0 0 1; 0 .6 1; 0 1 0; 1 1 0; 1 0 0; 1 0 0];
%
% Interpolation points for blackbody radiation curve
%
bbt = [ 1000   1336   1667   1739   1818      1905   2000   2105   2222   2353 ...
         2500   2677   2857   3077   3333      3636   4000   4444   5000   5714 ...
         6667   8000  10000  11111  12500     14286  16667  20000  25000  33333 ...
        50000 100000 999999 ];
   
bbx =   [.63549 .60700 .56508 .55640 .54712    .53723 .52669 .51541 .50338 .49059 ...
       .47701 .46262 .45464 .43156 .41502    .39792 .38045 .36276 .34510 .32775 ...
       .31101 .29518 .28063 .27524 .27011    .26526 .26070 .25645 .25251 .24890 ...
       .24560 .24258 .23987 ];
 
bby =   [.36407 .38100 .40271 .40593 .40882    .41131 .41331 .41465 .41525 .41498 ...
       .41368 .41121 .40742 .40216 .39535    .38690 .37676 .36496 .35162 .33690 ...
       .32116 .30477 .28828 .28182 .27547    .26930 .26333 .25763 .25222 .24714 ...
       .24240 .23802 .23404 ];

return

function PrintUsage

fprintf('\n cieplot v1.33\n\n')
fprintf(' This function plots the CIE (1931) Chromaticity diagram\n\n')
fprintf(' Usage: cieplot(Flags)\n\n')
fprintf(' Flags is the arithmetic sum of the following\n\n')
fprintf('      1 plots the figure on a black background\n')
fprintf('      2 plots an outline of visible wavelengths\n')
fprintf('      4 plots approximate colours\n')
fprintf('      8 plots the black body radiation curve\n\n')

return