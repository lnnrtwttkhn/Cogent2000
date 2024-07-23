function dcf = readdcf(Filename)
% readdcf v1.33
%
% This function reads in a display calibration file
%
% Usage: dcf = readdcf(Filename)
%
%           Filename = Display calibration file name
%
if (nargout ~= 1)|(nargin ~= 1)   
   if nargout == 1
      dcf = 0;
   end 
   PrintUsage
   return
end

if Filename == '?'
   if nargout == 1
      dcf = 0;
   end 
   PrintUsage
   return
end
%
% Global variables
%
% lincnt is the index number of the last data line read
%
global lincnt

lincnt = 0;
%
% Attempt to open the file
%
fid = fopen([Filename '.dcf.txt'],'r');

if fid == -1
   dcf = 0;
   cleanup(['Unable to open file ' Filename])
   
   dcf = 0;
   return
end

dcf = parsefile(fid);

fclose(fid);
%
% Clean up global variables
%
clear global lincnt
%
return

function dcf = parsefile(fid)

global lincnt

HeaderLine = 0;
CalPntLine = 0;
ColIndex = 1;
LevIndex = 0;
separator = 0;

ColStr = char('Red','Green','Yellow','Blue','Magenta','Cyan','Grey');

while 1
%
% read in the next line
%
    line = fgetl(fid);
    lincnt = lincnt + 1;
   
    if ~isstr(line)
        break
    end
%
% First read in the fixed header portion of the file
%
	if HeaderLine < 19
%
% Process the separator lines
%
        if line(1:1) == '-'
            separator = separator + 1;
        else
            if separator < 1
                cleanup('Expected a separator line');
                dcf = 0;
                return;
            elseif separator > 1
                cleanup('Unexpected separator line');
                dcf = 0;
                return
            end
         
            HeaderLine = HeaderLine + 1;
      
            substr = line(22:end);
      
            switch HeaderLine
                case 1
                    dcf.CalScript = substr;
            
                case 2
                    dcf.PhotometerDLL = substr;
            
        	    case 3
                    dcf.GScndDLL = substr;
            
                case 4
                    dcf.GPrimDLL = substr;
            
                case 5
                    dcf.GLibDLL = substr;
            
                case 6
                    dcf.CogStdDLL = substr;
                    separator = 0;
            
                case 7
                    dcf.PhotometerID = substr;
                    separator = 0;
            
                case 8
                    dcf.ComputerID = substr;
                    separator = 0;
            
                case 9
                    dcf.DspDsc = substr;
            
                case 10
                    dcf.DspModNo = substr;
            
                case 11
                    dcf.DspSerNo = substr;
            
                case 12
                    dcf.DspBrt = substr;
            
                case 13
                    dcf.DspCnt = substr;
            
                case 14
                    [a,n] = sscanf(substr,'%d x %d x %d x %f Hz Mon:%d',5);
                    if (n == 4)
                        a(5) = 1;
                        n = 5;
                    end
                    if (n ~= 5)
                        cleanup('Invalid Display Config line');
                        dcf = 0;
                        return;
                    end
                    if (a(1) < 1)|(a(1) > 1000000)|(a(2) < 1)|(a(2) > 1000000)|(a(3) < 1)|(a(3) > 32)|(a(4) < 1)|(a(4) > 10000)|(a(5) < 0)|(a(5) > 10000)
                        cleanup('Invalid Display Config data');
                        dcf = 0;
                        return;
                    end
                    dcf.DspCnf.Width = fix(a(1));
                    dcf.DspCnf.Height = fix(a(2));
                    dcf.DspCnf.Bits = fix(a(3));
                    dcf.DspCnf.Hz = a(4);
                    dcf.DspCnf.Mon = a(5);
                    separator = 0;
            
                case 15
                    %
                    % Keep reading in lines until we get to a separator
                    %
                    while 1
                        dcf.Notes(separator,:) = {substr};
                        separator = separator + 1;
               
                        substr = fgetl(fid);
                        lincnt = lincnt + 1;
   
                        if ~isstr(substr)
                            break
                        end
               
                        if substr(1:1) == '-'      
                            separator = 1;
                        break;
                        end
                    end
            
                    if ~isstr(line)
                        break
                    end
            
                case 16
                    [a,n] = sscanf(substr,'%d/%d/%d %d:%d:%d',6);
            
                    if n ~= 6
                        cleanup('Invalid StartTime line');
                        dcf = 0;
                        return;
                    end
            
                    if (a(1) < 1)|(a(1) > 31)|(a(2) < 1)|(a(2) > 12)|(a(3) < 0)|(a(3) > 99)|...
                        (a(4) < 0)|(a(4) > 23)|(a(5) < 0)|(a(5) > 59)|(a(6) < 0)|(a(6) > 59)
                        cleanup('Invalid TotalDuration value');
                        dcf = 0;
                        return;
                    end

                    dcf.StartTime.yr = a(3);
                    dcf.StartTime.mon = a(2);
                    dcf.StartTime.day = a(1);
                    dcf.StartTime.hr = a(4);
                    dcf.StartTime.min = a(5);
                    dcf.StartTime.sec = a(6);
            
                case 17
                    [a,n] = sscanf(substr,'%d:%d:%d',3);
                    if n ~= 3
                        cleanup('Invalid TotalDuration line');
                        dcf = 0;
                        return;
                    end
                    if (a(1) < 0)|(a(1) > 59)|(a(2) < 0)|(a(2) > 59)|(a(3) < 0)
                        cleanup('Invalid TotalDuration value');
                        dcf = 0;
                        return;
                    end
                    dcf.TotalDuration.hr = a(1);
                    dcf.TotalDuration.min = a(2);
                    dcf.TotalDuration.sec = a(3);
            
                case 18
                    [dcf.SettleTime,n] = sscanf(substr,'%d seconds',1);
                    if n ~= 1
                        cleanup('Invalid SettleTime line');
                        dcf = 0;
                        return;
                    end
                    if (dcf.SettleTime < 0)|(dcf.SettleTime > 1000000)
                        cleanup('Invalid SettleTime value');
                        dcf = 0;
                        return;
                    end
                    separator = 0;
            
                case 19
                    [dcf.CalibPoints,n] = sscanf(substr,'%d',1);
                    if n ~= 1
                        cleanup('Invalid CalibPoints line');
                        dcf = 0;
                        return;
                    end
                    if (dcf.CalibPoints < 2)|(dcf.CalibPoints > 256)
                        cleanup('Invalid CalibPoints value');
                        dcf = 0;
                        return;
                    end
            end
        end
%
% Next read in the calibration point levels
%
    elseif CalPntLine < dcf.CalibPoints
%
% Process the separator lines
%
        if line(1:1) == '-'
            separator = separator + 1;
        else
        	if separator < 1
           	cleanup('Expected a separator line');
        		dcf = 0;
            return;
            elseif separator > 1
                cleanup('Unexpected separator line');
                dcf = 0;
                return
            end
		   
            CalPntLine = CalPntLine + 1;
      
            substr = line(17:end);
            
            [a,n] = sscanf(substr,'%d:%d',2);
            
            if n ~= 2
                cleanup('Invalid Calib Level line');
                dcf = 0;
                return;
            end
            
            if (a(1) ~= CalPntLine)|(a(2) < 0)|(a(2) > 255)
                cleanup('Invalid Calib Level value');
                dcf = 0;
                return;
            end
         
            dcf.CalibLevel(CalPntLine) = a(2);
            
            if CalPntLine == dcf.CalibPoints
                separator = 0;
            end
        end
%
% Next read in the XYZ values
%
    elseif ColIndex < 8
%
% Process the separator lines
%
        if line(1:1) == '-'
            separator = separator + 1;
        else
            if separator < 1
               	cleanup('Expected a separator line');
                dcf = 0;
                return;
             elseif separator > 2
                cleanup('Unexpected separator line');
                dcf = 0;
               	return
            end
         
            if line(1:1) ~= ' '
                if separator ~= 1
                   cleanup('Unexpected XYZ header');
                   dcf = 0;
                   return
                end
            
                a = sprintf('%7.7s Pnt Lev          X          Y          Z      x      y       Y',ColStr(ColIndex,:));
            
                if ~strcmp(a,line)
                    cleanup('Invalid XYZ header');
                    dcf = 0;
                    return
                end
            
                separator = 2;
            else
                if separator ~= 2
                    cleanup('Unexpected XYZ line');
                    dcf = 0;
                    return   
                end
           
                LevIndex = LevIndex + 1;
            
                [a,n] = sscanf(line,'%f',8);
            
                if n ~= 8
                    cleanup(sprintf('Invalid %s XYZ line %d',ColStr(ColIndex,:),LevIndex));
                    dcf = 0;
                    return;
                end
                if (a(1) ~= LevIndex)|(a(2) ~= dcf.CalibLevel(LevIndex))|...
                    (a(3) < 0)|(a(3) > 1000000)|...
                    (a(4) < 0)|(a(4) > 1000000)|...
                    (a(5) < 0)|(a(5) > 1000000)|...
                    (a(6) < 0)|(a(6) > 1)|...
                    (a(7) < 0)|(a(7) > 1)|...
                    (a(6) + a(7) > 1)...
                    (a(8) < 0)|(a(8) > 1000000)
                    cleanup(sprintf('Invalid %s XYZ line %d',ColStr(ColIndex,:),LevIndex));
                    dcf = 0;
                    return;
                end
            
                dcf.XYZ(ColIndex,LevIndex,1) = a(3);
                dcf.XYZ(ColIndex,LevIndex,2) = a(4);
                dcf.XYZ(ColIndex,LevIndex,3) = a(5);
            
             	if LevIndex == dcf.CalibPoints
             	    LevIndex = 0;
                    ColIndex = ColIndex + 1;
                    separator = 0;
                    dcf.DspSpc = [];
                end
            end
        end
    else
%
% Next read in the spectra values
%
        switch separator
            case 0
                DspSpc = [];
                if line(1,1) ~= '-'
                   	cleanup('Expected a separator line');
                    dcf = 0;
                    return
                end
                separator = separator + 1;
            case 1
                if ~strcmp(line,'Spectral energies (W m-2 sr-1 nm-1) for peak intensity colours')
                   	cleanup('Expected a separator line');
                    dcf = 0;
                    return
                end
                separator = separator + 1;
            case 2
                if ~strcmp(line,'|Wlen |Red       |Green     |Yellow    |Blue      |Magenta   |Cyan      |White     |Black     |')
                   	cleanup('Expected a separator line');
                    dcf = 0;
                    return
                end
                separator = separator + 1;
            case 3
                 if line(1,1) == '-'
                     WL = DspSpc(:,1);
                     if (min(WL) < 10)|(max(WL) > 10000)
                         cleanup('Wavelength out of range')
                         dcf = 0;
                         return
                     end
                     d = diff(WL);
                     if min(d) ~= max(d)
                         cleanup('Inconsistent wavelength increments')
                         dcf = 0;
                         return
                     end
                     if (d(1) < 0.1)|(d(1) > 100)
                         cleanup('Unexpected wavelength increments')
                         dcf = 0;
                         return
                     end
                     dcf.DspSpc = DspSpc;
                     separator = 0;
                   	 break;
                 end
                 [vals,numvals] = sscanf(line,'|%e|%e|%e|%e|%e|%e|%e|%e|%e|');
                 if numvals ~= 9
                   	cleanup('Unexpected spectrum line');
                    dcf = 0;
                    return
                 end
                 if isempty(DspSpc)
                     DspSpc(1,1:9) = vals';
                 else
                     DspSpc((end + 1),1:9) = vals';
                 end
            otherwise
                 cleanup('Unexpected separator value');
                 dcf = 0;
        end
    end
end

if ColIndex ~= 8
   cleanup('Incomplete file');
   dcf = 0;
end

return
%---------------------------------------------------------
% This function cleans up, posts an error message and exits
%
function cleanup(Str)

global lincnt

if lincnt > 0
   fprintf(['\nreaddcf ERROR (Line %03d): ' Str '\n\n'],lincnt)
else
   fprintf(['\nreaddcf ERROR: ' Str '\n\n'])
end

return
%---------------------------------------------------------
% This function prints the usage guide
%
function PrintUsage

fprintf('\n readdcf v1.33\n\n')
fprintf(' This function reads in a display calibration file\n\n')
fprintf(' Usage: dcf = readdcf(Filename)\n\n')
fprintf('           Filename = Display calibration file name\n\n')

return