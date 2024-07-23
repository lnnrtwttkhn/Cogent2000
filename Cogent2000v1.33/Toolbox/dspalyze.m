function dspalyze(Filename)
% dspalyze v1.33
%
% This function analyzes a display calibration file
%
% Usage: dspalyze(Filename)
%
%           Filename = name for raw calibration data file
%   
if nargin ~= 1
    PrintUsage
    return
end

if (Filename == '?')|(~ischar(Filename))
    PrintUsage
    return
end
%
% Global variables
%
%         ColStr - Names of the possible colour selections
%         SpcStr - Names of the possible spectrum selections
%         IndStr - Names of the possible phosphor independence selections
%         ModStr - Names of the possible types of display
%         CIEStr - Names of the possible CIE plot options
%      CalPoints - How many calibration points were there ?
%            Lev - What internsity levels were used ?
%            XYZ - XYZ values of Red, Grn, Yel, Blu, Mag, Cyn, Gry
%         DspSpc - spectra for peak Red, Grn, Yel, Blu, Mag, Cyn, Wht and Blk
%         XYZSum - X + Y + Z for XYZ above
%         ColCod - Colour selection 1-9
%         SpcCod - Spectrum selection 1-14
%         IndCod - Phosphor Independence selection 1-4 or 'All'
%         ModCod - Display type selection 1-8
%         AllCod - Set to 1 if 'All' selected
% FilenameString - Title string for graphs
%       Fileroot - Filename without path or extension
%  winwid,winhgt - Main display width & height in pixels
%     BlackWhite - Set to 1 if black CIE plot required
%      OutlineOn - Set to 1 if CIE plot outline required
%      ColoursOn - Set to 1 if CIE plot colours required
%    BlackbodyOn - Set to 1 if CIE plot blackbody curve required
%      SpcPltMod - spectrum graph type - 1 = plain, 2 = spectrum on x-axis,
%                  3 = background spectrum
%         GamNrm - Set to 1 if gamma plots are normalized on y-axis
%         SpcNrm - Set to 1 if spectrum plots are normalized on y-axis
%            dcf - Display calibration file structure
% TxtX,TxtY,TxtH - Used for plotting Notes page
%
global ColStr SpcStr IndStr ModStr CIEStr CalPoints Lev XYZ DspSpc XYZSum
global ColCod SpcCod IndCod ModCod AllCod FilenameString Fileroot winwid winhgt 
global BlackWhite OutlineOn ColoursOn BlackbodyOn SpcPltMod GamNrm SpcNrm
global dcf TxtX TxtY TxtH
%
% Initialize some constants
%
ColStr = {'Red';'Green';'Yellow';'Blue';'Magenta';'Cyan';'Grey';'All';'Normalize Y'};
SpcStr = {'RGB';'Red';'Green';'Yellow';'Blue';'Magenta';'Cyan';'White';'Black';'All';'Plain plot';'X-axis spectrum';'Background spectrum';'Normalize Y'};
IndStr = {'Yellow';'Magenta';'Cyan';'Grey';'All'};
ModStr = {'Gamma curve';'Phosphor independence';'CIE (1931) x';'CIE (1931) y';'CIE plot';'Spectra';'Notes';'Quit'};
CIEStr = {'Black/White';'Outline on/off';'Colours on/off';'Black body curve on/off'};

ColCod = 7;
SpcCod = 1;
IndCod = 4;
ModCod = 1;
AllCod = 0;

BlackWhite = 0;
OutlineOn = 2;
ColoursOn = 4;
BlackbodyOn = 8;
SpcPltMod = 1;
GamNrm = 0;
SpcNrm = 1;
%
% Extract the root filename from the supplied argument
%
i = 0;
a = findstr(Filename,'/');
[m,n] = size(a);
if m ~= 0
    i = a(end);
end
a = findstr(Filename,'\');
[m,n] = size(a);
if m ~= 0
    if a(end) > i;
        i = a(end);
    end
end
Fileroot = Filename(i + 1:end);
%
% Read in the data from the calibration file
%
Success = readmonitorrawdata(Filename);
if Success < 1
    fprintf('Failed to open file:%s\n',Filename);
    return
end

FilenameString = sprintf('DspCal file:%s',Fileroot);
%
% loop through the possible operator responses until they press "quit"
%
while ModCod > 0      
    gcf;
    clf reset

    set(gcf,'Name',['dspalyze graph window:' Fileroot])
    set(gcf,'Numbertitle','off')
    set(gcf,'PaperOrientation','landscape')
    set(gcf,'color',[1 1 1]);
    scrsz = get(0,'ScreenSize');

    if (AllCod > 0)|(ModCod == 5)|(ModCod == 7)
%
% If we are plotting all elements or if we are writing notes or plotting 
% CIE values we use a different display size and cycle through all the
% possible values here
%
% If cycling through we record the current values of ColCod, SpcCod &
% IndCod
%
        OldColCod = ColCod;
        OldSpcCod = SpcCod;
        OldIndCod = IndCod;
      
        if (ModCod == 5)|(ModCod == 7)
            winwid = scrsz(4)*4/5;
            winhgt = winwid;
        else
            winwid = scrsz(3)*4/5;
            winhgt = scrsz(4)*4/5;
        end
      
        resize(winwid,winhgt)
 %
 % The data is recorded in the DCF in the sequence
 % Red, Grn, Yel, Blu, Mag, Cyn, Gry (*Blk)
 %
 % *Blk is recorded for the spectra data
 %
 % But it is plotted in a 3 x 3 array as follows:-
 %
 %    1)Red  2)Yel  3)Gry
 %    4)Grn  5)Mag
 %    6)Blu  7)Cyn  9)(*Blk)
 %
 % The plotseq array remaps the positions of the data
 % 
        plotseq = [1 4 2 7 5 8 3 9];
        %
        % We set normalize to zero to suppress normalization
        % for the Gamma and Spectrum plots.  Otherwise we
        % set it to the maximum value in the dataset
        %
        switch ModCod
            case {1 3 4}
                if (ModCod == 1)&(GamNrm == 1)
                    normalize = max(max(XYZ(:,:,2)));
                else
                    normalize = 0;
                end
                for ColCod = 1:7
                    subplot(3,3,plotseq(ColCod))
                    plotit(normalize)
                end
            case 2
                for IndCod = 1:4
                    subplot(2,2,IndCod)
                    plotit
                end
            case 6
                if SpcNrm
                    normalize = max(max(DspSpc(:,2:8)));
                else
                    normalize = 0;
                end
                
                for SpcCod = 2:9
                    i = plotseq(SpcCod - 1);
                    subplot(3,3,i)
                    plotit(normalize)
                end

            case {5 7}
                subplot(1,1,1)
                plotit
        end
 %
 % Restore the current values of ColCod, SpcCod & IndCod
 %
        ColCod = OldColCod;
        SpcCod = OldSpcCod;
        IndCod = OldIndCod;
    else
        if (ModCod == 6)&(SpcCod == 1)
            %
            % Special sized plot for Spectrum RGB
            %
            winwid = scrsz(3)*4/15;
            winhgt = scrsz(4)*4/5;
            resize(winwid,winhgt)
            %
            % We set normalize to zero to suppress normalization for the
            % Spectrum plots.  Otherwise we set it to the maximum value in 
            % the dataset
            %
            if SpcNrm
                normalize = max(max(DspSpc(:,[2 3 5])));
            else
                normalize = 0;
            end
           
            SpcCod = 2;
            subplot(3,1,1)
            plotit(normalize)
            
            SpcCod = 3;
            subplot(3,1,2)
            plotit(normalize)
            
            SpcCod = 5;
            subplot(3,1,3)
            plotit(normalize)
            
            SpcCod = 1;
        else
            %
            % Otherwise a standard size for a single graph
            %
            winwid = scrsz(3)/2;
            winhgt = scrsz(4)/2;
      
            resize(winwid,winhgt)     
            subplot(1,1,1)
            plotit
        end
    end
   
    figure(gcf)
%
% The menus are different depending on whether we have spectra data or not
%
    if isempty(DspSpc)
        getchoice2
    else
        getchoice1
    end
end
%
% Clean up global variables
%
clear global ColStr SpcStr IndStr ModStr CIEStr CalPoints Lev XYZ DspSpc XYZSum
clear global ColCod SpcCod IndCod ModCod AllCod FilenameString Fileroot winwid winhgt
clear global BlackWhite OutlineOn ColoursOn BlackbodyOn SpcPltMod GamNrm SpcNrm
clear global dcf TxtX TxtY TxtH

return
%
% resize the display window
%
function resize(width,height)

scrsz = get(0,'ScreenSize');
pos = get(gcf,'Position');
set(gcf,'Position',[(200 + scrsz(3) - width)/2 (scrsz(4) - height)/2 width height])
pos = get(gcf,'PaperPosition');
papsiz = get(gcf,'PaperSize');
pos(1) = (papsiz(1) - pos(3))/2;
pos(2) = (papsiz(2) - pos(4))/2;
set(gcf,'PaperPosition',pos);

return
%
% Set the chosen colour code and set the phosphor independence and spectrum codes to match
%
%     ColCod IndCod SpcCod
% RGB                  1
% Red    1             2
% Grn    2             3
% Yel    3      1      4
% Blu    4             5
% Mag    5      2      6
% Cya    6      3      7
% Gry    7      4      8
% Blk                  9
% All    8      5      10
%
function SetColCod(Choice)

global ColCod SpcCod IndCod AllCod
   
if Choice == 8
    AllCod = 1;
else
    AllCod = 0;
    ColCod = Choice;
    SpcCod = ColCod + 1;
    switch ColCod
        case 3
            IndCod = 1;
        case 5
            IndCod = 2;
        case 6
            IndCod = 3;
        case 7
            IndCod = 4;
    end
end
   
return
%
% Set the chosen phosphor independence code and set the colour and spectrum codes to match
%
%     ColCod IndCod SpcCod
% RGB                  1
% Red    1             2
% Grn    2             3
% Yel    3      1      4
% Blu    4             5
% Mag    5      2      6
% Cya    6      3      7
% Gry    7      4      8
% Blk                  9
% All    8      5      10
%
function SetIndCod(Choice)

global ColCod SpcCod IndCod AllCod
   
if Choice == 5
    AllCod = 1;
else
    AllCod = 0;
    IndCod = Choice;
   
    switch IndCod
        case 1
            ColCod = 3;
            SpcCod = 4;
        case 2
            ColCod = 5;
            SpcCod = 6;
        case 3
            ColCod = 6;
            SpcCod = 7;
        case 4
            ColCod = 7;
            SpcCod = 8;
    end
end

return
%
% Set the chosen spectrum code and set the colour and phosphor independence codes to match
%
%     ColCod IndCod SpcCod
% RGB                  1
% Red    1             2
% Grn    2             3
% Yel    3      1      4
% Blu    4             5
% Mag    5      2      6
% Cya    6      3      7
% Gry    7      4      8
% Blk                  9
% All    8      5      10
%
function SetSpcCod(Choice)

global ColCod SpcCod IndCod AllCod
   
if Choice == 10
    AllCod = 1;
else
    AllCod = 0;
    SpcCod = Choice;
   
    if SpcCod > 1
        ColCod = SpcCod - 1;
    end
    
    switch SpcCod
        case 4
            IndCod = 1;
        case {6 7 8}
            IndCod = SpcCod - 4;
    end
end

return
%
% Obtain the user's next selection (Spectra data present)
%
function getchoice1

global ColCod SpcCod IndCod ModCod AllCod
global ColStr SpcStr IndStr ModStr CIEStr
global BlackWhite OutlineOn ColoursOn BlackbodyOn SpcPltMod GamNrm SpcNrm
  
switch ModCod
    case 1  % Gamma plot
        Choice = menu(ModStr{ModCod},ColStr{1},ColStr{2},ColStr{3},ColStr{4},ColStr{5},ColStr{6},ColStr{7},ColStr{8},ColStr{9},ModStr{2},ModStr{3},ModStr{4},ModStr{5},ModStr{6},ModStr{7},ModStr{8});
        switch Choice
            %
            % Choices 1 to 8 select Red, Grn, Yel, Blu, Mag, Cyn, Gry, All
            % Choice 9 toggles normalization
            % Choices 10 to 15 select other modes
            % Choice 16 = Quit
            %
            case 9
                if GamNrm
                    GamNrm = 0;
                else
                    GamNrm = 1;
                end
            case {10 11 12 13 14 15}
                ModCod = Choice - 8;
            case {16}
                ModCod = 0;
            otherwise
                SetColCod(Choice)
        end
      
    case 2 % Phosphor Independence
        Choice = menu(ModStr{ModCod},IndStr{1},IndStr{2},IndStr{3},IndStr{4},IndStr{5},ModStr{1},ModStr{3},ModStr{4},ModStr{5},ModStr{6},ModStr{7},ModStr{8});
        switch Choice
            %
            % Choices 1 to 5 select Yel, Mag, Cyn, Gry, All
            % Choices 6 to 11 select other modes
            % Choice 12 = Quit
            %
            case 6
                ModCod = 1;
            case {7 8 9 10 11}
                ModCod = Choice - 4;
            case 12
                ModCod = 0;
            otherwise
                SetIndCod(Choice)
        end
      
    case {3 4} % CIE x & y respectively
        Choice = menu(ModStr{ModCod},ColStr{1},ColStr{2},ColStr{3},ColStr{4},ColStr{5},ColStr{6},ColStr{7},ColStr{8},ModStr{1},ModStr{2},ModStr{7 - ModCod},ModStr{5},ModStr{6},ModStr{7});
        switch Choice
            %
            % Choices 1 to 8 select Red, Grn, Yel, Blu, Mag, Cyn, Gry, All
            % Choices 9 to 14 select other modes
            % Choice 15 = Quit
            %
            case 9
                ModCod = 1;
            case 10
                ModCod = 2;
            case 11
                ModCod = 7 - ModCod;
            case {12 13 14}
                ModCod = Choice - 7;
            case 15 
                ModCod = 0;
            otherwise
                SetColCod(Choice);
        end
      
    case 5 % CIE plot
        Choice = menu(ModStr{ModCod},CIEStr{1},CIEStr{2},CIEStr{3},CIEStr{4},ModStr{1},ModStr{2},ModStr{3},ModStr{4},ModStr{6},ModStr{7},ModStr{8});
        switch Choice
            %
            % Choices 1 to 4 toggle Black/White, Outline On/Off, 
            %                       Colours On/Off and Blackbody On/Off
            % Choices 5 to 10 select other modes
            % Choice 11 = Quit
            %
            case 1
                if BlackWhite ~= 0
                    BlackWhite = 0;
                else
                    BlackWhite = 1;
                end
            case 2
                if OutlineOn ~= 0
                    OutlineOn = 0;
                else
                    OutlineOn = 2;
                end
            case 3
                if ColoursOn ~= 0
                    ColoursOn = 0;
                else
                    ColoursOn = 4;
                end
            case 4
                if BlackbodyOn ~= 0
                    BlackbodyOn = 0;
                else
                    BlackbodyOn = 8;
                end
            case {5 6 7 8}
                ModCod = Choice - 4;
            case {9 10}
                ModCod = Choice - 3;
            case 11
                ModCod = 0;
        end
        
    case 6 % Spectrum
        Choice = menu(ModStr{ModCod},SpcStr{1},SpcStr{2},SpcStr{3},SpcStr{4},SpcStr{5},SpcStr{6},SpcStr{7},SpcStr{8},SpcStr{9},SpcStr{10},SpcStr{11},SpcStr{12},SpcStr{13},SpcStr{14},ModStr{1},ModStr{2},ModStr{3},ModStr{4},ModStr{5},ModStr{7},ModStr{8});
        switch Choice
            %
            % Choices 11 to 13 select Plain / x-axis / background spectrum
            % Choice 14 toggles normalization
            % Choices 15 to 20 selct other modes
            % Choice 21 = Quit
            %
            case {11 12 13}
                SpcPltMod = Choice - 10;
            case 14
                if SpcNrm
                    SpcNrm = 0;
                else
                    SpcNrm = 1;
                end
            case {15 16 17 18 19}
                ModCod = Choice - 14;
            case 20
                ModCod = 7;
            case 21
                ModCod = 0;
            otherwise
                SetSpcCod(Choice)
        end
      
    case 7 % Notes
        Choice = menu(ModStr{ModCod},ModStr{1},ModStr{2},ModStr{3},ModStr{4},ModStr{5},ModStr{6},ModStr{8});
        switch Choice
            %
            % Choices 1 to 6 select other modes
            % Choice 7 = Quit
            %
            case {1 2 3 4 5 6}
                ModCod = Choice;
            case 7
                ModCod = 0;
        end
end
   
return
%
% Obtain the user's next selection (Spectra data not present)
%
function getchoice2

global ColCod SpcCod IndCod ModCod AllCod
global ColStr SpcStr IndStr ModStr CIEStr
global BlackWhite OutlineOn ColoursOn BlackbodyOn GamNrm
  
switch ModCod
    case 1 % Gamma plot
        Choice = menu(ModStr{ModCod},ColStr{1},ColStr{2},ColStr{3},ColStr{4},ColStr{5},ColStr{6},ColStr{7},ColStr{8},ColStr{9},ModStr{2},ModStr{3},ModStr{4},ModStr{5},ModStr{7},ModStr{8});
        switch Choice
            %
            % Choices 1 to 8 select Red, Grn, Yel, Blu, Mag, Cyn, Gry, All
            % Choice 9 toggles normalization
            % Choices 10 to 14 select other modes
            % Choice 15 = Quit
            %
            case 9
                if GamNrm
                    GamNrm = 0;
                else
                    GamNrm = 1;
                end
            case {10 11 12 13}
                ModCod = Choice - 8;
            case 14
                ModCod = 7;
            case 15
                ModCod = 0;
            otherwise
                SetColCod(Choice)
        end
      
    case 2 % Phosphor Independence
        Choice = menu(ModStr{ModCod},IndStr{1},IndStr{2},IndStr{3},IndStr{4},IndStr{5},ModStr{1},ModStr{3},ModStr{4},ModStr{5},ModStr{7},ModStr{8});
        switch Choice
            %
            % Choices 1 to 5 select Yel, Mag, Cyn, Gry, All
            % Choices 6 to 10 select other modes
            % Choice 11 = Quit
            %
            case 6
                ModCod = 1;
            case {7 8 9}
                ModCod = Choice - 4;
            case 10
                ModCod = 7;
            case 11
                ModCod = 0;
            otherwise
                SetIndCod(Choice)
        end
      
    case {3 4} % CIE x & y respectively
        Choice = menu(ModStr{ModCod},ColStr{1},ColStr{2},ColStr{3},ColStr{4},ColStr{5},ColStr{6},ColStr{7},ColStr{8},ModStr{1},ModStr{2},ModStr{7 - ModCod},ModStr{5},ModStr{7});
        switch Choice
            %
            % Choices 1 to 8 select Red, Grn, Yel, Blu, Mag, Cyn, Gry, All
            % Choices 9 to 13 select other modes
            % Choice 14 = Quit
            %
            case 9
                ModCod = 1;
            case 10
                ModCod = 2;
            case 11
                ModCod = 7 - ModCod;
            case 12
                ModCod = 5;
            case 13
                ModCod = 7;
            case 14 
                ModCod = 0;
            otherwise
                SetColCod(Choice);
        end
      
    case 5 % CIE plot
        Choice = menu(ModStr{ModCod},CIEStr{1},CIEStr{2},CIEStr{3},CIEStr{4},ModStr{1},ModStr{2},ModStr{3},ModStr{4},ModStr{7},ModStr{8});
        switch Choice
            %
            % Choices 1 to 4 toggle Black/White, Outline On/Off, 
            %                       Colours On/Off and Blackbody On/Off
            % Choices 5 to 9 select other modes
            % Choice 10 = Quit
            %
            case 1
                if BlackWhite ~= 0
                    BlackWhite = 0;
                else
                    BlackWhite = 1;
                end
            case 2
                if OutlineOn ~= 0
                    OutlineOn = 0;
                else
                    OutlineOn = 2;
                end
            case 3
                if ColoursOn ~= 0
                    ColoursOn = 0;
                else
                    ColoursOn = 4;
                end
            case 4
                if BlackbodyOn ~= 0
                    BlackbodyOn = 0;
                else
                    BlackbodyOn = 8;
                end
            case {5 6 7 8}
                ModCod = Choice - 4;
            case 9
                ModCod = 7;
            case 10
                ModCod = 0;
        end
      
    case 7 % Notes
        Choice = menu(ModStr{ModCod},ModStr{1},ModStr{2},ModStr{3},ModStr{4},ModStr{5},ModStr{8});
        switch Choice
            %
            % Choices 1 to 5 select other modes
            % Choice 6 = Quit
            %
            case {1 2 3 4 5}
                ModCod = Choice;
            case 6
                ModCod = 0;
        end
end
   
return
%
% Read in the data from file
%
function Success = readmonitorrawdata(Filename)

global CalPoints Lev XYZ DspSpc XYZSum dcf
      
dcf = readdcf(Filename);
   
if ~isstruct(dcf)
    Success = 0;
    return
end
   
Success = 1;
   
CalPoints = dcf.CalibPoints;
Lev = dcf.CalibLevel;
XYZ = dcf.XYZ;
DspSpc = dcf.DspSpc;
   
Success = 1;
XYZSum = zeros(7,CalPoints);
for i=1:7
    for j=1:CalPoints
        XYZSum(i,j) = XYZ(i,j,1) + XYZ(i,j,2) + XYZ(i,j,3);
    end
end

return
%
% Draw a single plot
%
function plotit(normalize)

if nargin < 1
    normalize = 0;
end

global ColStr SpcStr IndStr ModStr CIEStr FilenameString Fileroot
global CalPoints Lev XYZ DspSpc XYZSum
global ColCod SpcCod IndCod ModCod winwid winhgt
global TxtX TxtY TxtH dcf
global BlackWhite OutlineOn ColoursOn BlackbodyOn SpcPltMod
%
% There are four different plot types
% 1 = line graph (for Gamma, Phosphor Independence, CIE x & y
% 2 = CIE plot
% 3 = Spectrum
% 4 = Notes
%
Plot = 0;
   
switch ModCod
    case 1 % Gamma
        TitleStr = sprintf('%s %s',ColStr{ColCod},ModStr{ModCod});
        YLabStr = 'CIE 1931 Y cd/m2';
        Y = XYZ(ColCod,:,2);
        Plot = 1; % Plot Y as line graph
 
    case 2 % Phosphor independence
        TitleStr = sprintf('%s %s',IndStr{IndCod},ModStr{ModCod});
        switch IndCod
            case 1
                YLabStr = 'Yel/(Red+Grn) CIE (1931) Y ratio';
                Y(1:CalPoints) = XYZ(3,:,2)./(XYZ(1,:,2) + XYZ(2,:,2));
            case 2
                YLabStr = 'Mag/(Red+Blu) CIE (1931) Y ratio';
                Y(1:CalPoints) = XYZ(5,:,2)./(XYZ(1,:,2) + XYZ(4,:,2));
            case 3
                YLabStr = 'Cyn/(Grn+Blu) CIE (1931) Y ratio';
                Y(1:CalPoints) = XYZ(6,:,2)./(XYZ(2,:,2) + XYZ(4,:,2));
            case 4
                YLabStr = 'Gry/(Red+Grn+Blu) CIE (1931) Y ratio';
                Y(1:CalPoints) = XYZ(7,:,2)./(XYZ(1,:,2) + XYZ(2,:,2) + XYZ(4,:,2));
        end
        Plot = 1; % Plot Y as line graph

    case 3 % CIE x
        TitleStr = sprintf('%s %s',ColStr{ColCod},ModStr{ModCod});
        YLabStr = 'CIE 1931 x';
        Y(1:CalPoints) = XYZ(ColCod,:,1)./XYZSum(ColCod,:);
        Plot = 1; % Plot Y as line graph

    case 4 % CIE y
        TitleStr = sprintf('%s %s',ColStr{ColCod},ModStr{ModCod});
        YLabStr = 'CIE 1931 y';
        Y(1:CalPoints) = XYZ(ColCod,:,2)./XYZSum(ColCod,:);
        Plot = 1; % Plot Y as line graph

    case 5 % CIE plot
        Plot = 2; % CIE plot

    case 6 % Spectrum
        TitleStr = sprintf('Peak %s spectrum',SpcStr{SpcCod});
        YLabStr = 'W m-2 sr-1 nm-1';
        Spc = DspSpc(:,[1 SpcCod]);
        Plot = 3; % Plot as spectrum

    case 7 % Notes
        TitleStr = sprintf('%s',ModStr{ModCod});
        Plot = 4; % Plot Notes
end

switch Plot
    case 1 % Plot a line graph for Gamma, Phosphor Independence, CIE x & y
        plot(Lev,Y,'x-k')
        ax = axis;
        ax(1) = 0;
        ax(2) = 255;
        switch ModCod
            case 1
                if normalize
                    ax(4) = normalize*1.1;
                else
                    ax(4) = max(Y)*1.1;
                end
            case 2
                ax(3) = 0;
                if max(Y) < 1.05
                    ax(4) = 1.05;
                else
                    ax(4) = max(ax(4),1);
                end
            case {3 4}
                ax(3) = 0;
                ax(4) = 1;
        end
        axis(ax)
        xlabel('Computer RGB level 0-255')
        ylabel(YLabStr)
        title([FilenameString ' - ' TitleStr],'interpreter','none')
   
    case 2 % Plot CIE data
        xy(1:3,1:2)=[XYZ([1 2 4],end,1)./XYZSum([1 2 4],end) XYZ([1 2 4],end,2)./XYZSum([1 2 4],end)];
        xy(4,1:2) = xy(1,1:2);
   
        if (BlackWhite ~= 0)&(ColoursOn == 0)
            c1str = 'w';
            c2str = 'k';
        else
            c1str = 'k';
            c2str = 'w';
        end
   
        cieplot(BlackWhite+OutlineOn+ColoursOn+BlackbodyOn)
        set(gcf,'Name',['dspalyze graph window:' Fileroot])
        set(gcf,'Numbertitle','off')
        hold on
        plot(xy(:,1),xy(:,2),[c1str '-s'],'MarkerSize',4,'MarkerFaceColor',c2str,'MarkerEdgeColor',c1str)
        hold off
        warning off
        title([FilenameString ' - phosphor CIE values'],'Color',c1str,'FontSize',12,'interpreter','none')
        if ColoursOn ~= 0
            text(xy(1,1),xy(1,2)-0.005,'R','Color','k','HorizontalAlignment','center','VerticalAlignment','top');
            text(xy(2,1),xy(2,2)+0.005,'G','Color','k','HorizontalAlignment','center','VerticalAlignment','bottom');
            text(xy(3,1),xy(3,2)-0.005,'B','Color','w','HorizontalAlignment','center','VerticalAlignment','top');
        else
            text(xy(1,1),xy(1,2)-0.005,'R','Color',c1str,'HorizontalAlignment','center','VerticalAlignment','top');
            text(xy(2,1),xy(2,2)+0.005,'G','Color',c1str,'HorizontalAlignment','center','VerticalAlignment','bottom');
            text(xy(3,1),xy(3,2)-0.005,'B','Color',c1str,'HorizontalAlignment','center','VerticalAlignment','top');
        end
   
        if BlackWhite == 0
            c1str = 'k';
        else
            c1str = 'w';
        end
   
        text(.65,.69,...
            sprintf('CIE (1931) XYZ\nR: %5.5g,%5.5g,%5.5g\nG: %5.5g,%5.5g,%5.5g\nB: %5.5g,%5.5g,%5.5g',...
            XYZ(1,end,:),XYZ(2,end,:),XYZ(4,end,:)),...
            'HorizontalAlignment','center','VerticalAlignment','top','Color',c1str,'FontSize',8);
   
        text(.65,.59,...
            sprintf('CIE (1931) x,y\nR: %.4f,%.4f\nG: %.4f,%.4f\nB: %.4f,%.4f',xy(1,:),xy(2,:),xy(3,:)),...
            'HorizontalAlignment','center','VerticalAlignment','top','Color',c1str,'FontSize',8);

        warning on   

    case 3 % Plot a spectrum
        if normalize == 0
            normalize = max(Spc(:,2));
        end
        
        switch SpcPltMod
            case 1
                %
                % Standard plot
                %   
                plot([min(Spc(:,1)) max(Spc(:,1))],[min(Spc(:,2)) normalize*1.1],'w')
                axis tight
                xlim = get(gca,'XLim');
                ylim = get(gca,'YLim');
                cla
                stairs(Spc(:,1),Spc(:,2),'k');
                axis([xlim ylim])
                ylabel(YLabStr)
                %
                % remove the x axis label
                % Label the colorbar instead
                %
                xlabel('Wavelength (nm)')
                title([FilenameString ' - ' TitleStr],'interpreter','none')
            case 2
                %
                % Black and white plot with x-axis coloured spectrum
                % 
                plot([min(Spc(:,1)) max(Spc(:,1))],[min(Spc(:,2)) normalize*1.1],'w')
                axis tight
                xlim = get(gca,'XLim');
                ylim = get(gca,'YLim');
                cla
                stairs(Spc(:,1),Spc(:,2),'k');
                axis([xlim ylim])
                hold on
                ylabel(YLabStr)
                %
                % remove the x axis label
                % Label the colorbar instead
                %
                xlabel('')
                setcolormap([min(DspSpc(:,1)) max(DspSpc(:,1))])
                h = colorbar('h');
                set(h,'XTick',[])
                set(get(h,'Xlabel'),'String','Wavelength (nm)');
                title([FilenameString ' - ' TitleStr],'interpreter','none')
            case 3
                %
                % Colour spectrum background
                %      
                plot([min(Spc(:,1)) max(Spc(:,1))],[min(Spc(:,2)) normalize*1.1],'w')
                axis tight
                xlim = get(gca,'XLim');
                ylim = get(gca,'YLim');
                cla
                axis([xlim(1) xlim(2) ylim(1) ylim(2)])
                set(gca,'Box','on','TickDir','out')

                surface([xlim(1) xlim(2)],[ylim(1) ylim(2)],[0 0;0 0],[xlim(1) xlim(2);xlim(1) xlim(2)]);
                shading interp
                hold on
                setcolormap(xlim);
                xx = Spc(1,1) - (Spc(2,1) - Spc(1,1))/2;
                x(1) = xx;
                y(1) = 0;
                for i = 1:(length(Spc(:,1)) - 1)
                    yy = Spc(i,2);
                    x(end + 1) = xx;
                    y(end + 1) = yy;
                    xx = (Spc(i,1) + Spc((i + 1),1))/2;
                    x(end + 1) = xx;
                    y(end + 1) = yy;
                end
                x(end + 1) = (3*Spc(end,1) - Spc((end - 1),1))/2;
                y(end + 1) = 0;
                patch(x,y,1,'FaceColor','w','EdgeColor','k')
                xlabel('Wavelength nm')
                ylabel(YLabStr)
                title([FilenameString ' - ' TitleStr],'interpreter','none')
        end
        
    case 4 % Plot the notes
        clf
        axis([1 winwid 1 winhgt])
        axis off
      
        TxtH = 20;
        TxtX = winwid/8;
        TxtY = winhgt - TxtH;
      
        title(' ')
      
        ctrtext([FilenameString ' - ' TitleStr])
        ctrtext(' ')
   
        addtext('CalScript',dcf.CalScript)
        addtext('Photometer DLL',dcf.PhotometerDLL)
        addtext('GScnd DLL',dcf.GScndDLL)
        addtext('GPrim DLL',dcf.GPrimDLL)
        addtext('GLib DLL',dcf.GLibDLL)
        addtext('CogStd DLL',dcf.CogStdDLL)
        addtext('Photometer ID',dcf.PhotometerID)
        addtext('Computer ID',dcf.ComputerID)
        addtext('Display description',dcf.DspDsc)
        addtext('Display model number',dcf.DspModNo)
        addtext('Display serial number',dcf.DspSerNo)
        addtext('Display brightness',dcf.DspBrt)
        addtext('Display contrast',dcf.DspCnt)
        addtext('Display config',sprintf('%dx%dx%d %.2fHz Mon:%d',dcf.DspCnf.Width,dcf.DspCnf.Height,dcf.DspCnf.Bits,dcf.DspCnf.Hz,dcf.DspCnf.Mon))
      
        [m,n] = size(dcf.Notes);      
        if m < 1
            addtext('Notes',' ');
        else
            addtext('Notes',dcf.Notes{1})
            for i=2:m
                addtext(' ',dcf.Notes{i})
            end
        end
      
        addtext('Start time',sprintf('%02d/%02d/%02d %02d:%02d:%02d',...
        dcf.StartTime.day,dcf.StartTime.mon,dcf.StartTime.yr,dcf.StartTime.hr,dcf.StartTime.min,dcf.StartTime.sec))
      
        addtext('Total duration',sprintf('%02d:%02d:%02d',...
            dcf.TotalDuration.hr,dcf.TotalDuration.min,dcf.TotalDuration.sec))
        addtext('Settle time',sprintf('%d seconds',dcf.SettleTime))
        addtext('Calibration points',sprintf('%d',dcf.CalibPoints))
      
        for i=1:dcf.CalibPoints
            addtext(sprintf('Calibration level %d',i),sprintf('%03d',dcf.CalibLevel(i)))
        end
end
   
return
%
% Add some text on the next line
%
function addtext(Str1,Str2)

global TxtX TxtY TxtH

text(TxtX,TxtY,[Str1 ':'],'HorizontalAlignment','right','Interpreter','none');
text(TxtX,TxtY,[' ' Str2],'HorizontalAlignment','left','Interpreter','none');

TxtY = TxtY - TxtH;

return   
%
% Plot some text centred on the next line
%
function ctrtext(Str)

global TxtX TxtY TxtH

text(TxtX,TxtY,Str,'HorizontalAlignment','center','Interpreter','none');

TxtY = TxtY - TxtH;

return

function PrintUsage

fprintf('\n dspalyze v1.33\n\n')
fprintf(' This function analyzes a display calibration file\n\n')
fprintf(' Usage: dspalyze(Filename)\n\n')
fprintf('        Filename = name for raw calibration data file\n\n')

return
%
% This function converts a wavelength in nm to an rgb colour
%
function rgb=wave2rgb(nm)

WaveN = [380 476 494 515 580 632 780];
WaveC = [ 0 0 0; 0 0 1; 0 .6 1; 0 1 0; 1 1 0; 1 0 0; 0 0 0];

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
