function spcplot(Spc,Mode)
% spcplot v1.33
%
% This function plota a radiant spectrum
%
% Usage: spcplot(Spc,Mode)
%
%           Spc = (n x 2) matrix
%                 Spc(:,1) = wavelength (nm)
%                 Spc(:,2) = Radiance (W m-2 sr-1 nm-1)
%
%           Mode = 1 (bw plot) or 2 (x-axis spectrum) or 3 (spectrum background)
%
switch nargin
case 1
   Mode = 3;
case 2   
otherwise
   PrintUsage
   return
end

switch Mode
case 1
case 2
case 3
otherwise
   PrintUsage
   return
end

[m,n] = size(Spc);

if n ~= 2
   PrintUsage
   return
end
%
% Global variables
%
% WaveN, WaveC - used to approximate RGB for a particular wavelength
%
global WaveN WaveC

WaveN = [380 476 494 515 580 632 780];
WaveC = [ 0 0 0; 0 0 1; 0 .6 1; 0 1 0; 1 1 0; 1 0 0; 0 0 0];
%
% Initialize graphics
%
gcf;
clf reset
%
% Fix the axis limits
%
plot([min(Spc(:,1)) max(Spc(:,1))],[min(Spc(:,2)) max(Spc(:,2))*1.2])
xlim = get(gca,'XLim');
ylim = get(gca,'YLim');
cla
%
% Now clear the figure and initialize
%
clf reset

set(gcf,'color',[1 1 1]);

axis([xlim(1) xlim(2) ylim(1) ylim(2)])
axis manual
set(gca,'Box','on','TickDir','out')

title('spectrum plot')
xlabel('Wavelength (nm)')
ylabel('Spectral radiance (W m^{-2} sr^{-1} nm^{-1})') 

hold on
%
% Draw the various figures
%
switch Mode
case 1
   %
   % Simple black and white plot
   %
   stairs(Spc(:,1),Spc(:,2),'k')
   
case 2
   %
   % Black and white plot with x-axis coloured spectrum
   %
   setcolormap(xlim)
   
	h=patch([Spc(1,1) Spc(1,1)],[min(Spc(:,2)) min(Spc(:,2))],[0 0;0 0],[Spc(1,1) Spc(end,1);Spc(1,1) Spc(end,1)]);
   
   stairs(Spc(:,1),Spc(:,2),'k')
   %
   % remove the x axis label
   % Label the colorbar instead
   %
   xlabel('')
   h = colorbar('h');
   set(h,'XTick',[])
   set(get(h,'Xlabel'),'String','Wavelength (nm)');
   
case 3
   %
   % Colour spectrum background
   %      
   surface([xlim(1) xlim(2)],[ylim(1) ylim(2)],[0 0;0 0],[xlim(1) xlim(2);xlim(1) xlim(2)]);
   shading interp
   
   h=bar(Spc(:,1),Spc(:,2),1,'w');
   
   set(h,'EdgeColor','w');
   plot([xlim(1) xlim(2)],[ylim(1) ylim(1)],'k-')
   
   setcolormap(xlim);   
end

hold off
%
% Clean up global variables
%
clear global WaveN WaveC

return
%
% This function converts a wavelength in nm to an rgb colour
%
function rgb=wave2rgb(nm)

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

function setcolormap(nmrng)
%
% Set the colour map to be the approximated colours
% for wavelengths nmrng(1:2)
%
k = 200;
nm = linspace(nmrng(1),nmrng(2),k);
for i=1:k
   cm(i,:) = wave2rgb(nm(i));
end
colormap(cm);
caxis(nmrng);

return
%--------------------------------------------------------
% This function prints the usage guide
%
function PrintUsage

fprintf('\n spcplot v1.33\n\n')
fprintf(' This function plota a radiant spectrum\n\n')
fprintf(' Usage: spcplot(Spc,Mode)\n\n')
fprintf('           Spc = (n x 2) matrix\n')
fprintf('                 Spc(:,1) = wavelength (nm)\n')
fprintf('                 Spc(:,2) = Radiance (W m-2 sr-1 nm-1)\n\n')
fprintf('           Mode = 1 (bw plot) or 2 (x-axis spectrum) or 3 (spectrum background)\n\n')

return