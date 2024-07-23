function [XYZ,Err]=rgb2xyz(R,G,B)
% rgb2xyz v1.33
%
% This function calculates the CIE (1931) XYZ values for an RGB triplet
%
% Usage: GAMXYZ = rgb2xyz(filename) (= initialization) or
%
%           XYZ = rgb2xyz(RGB) or
%           XYZ = rgb2xyz(R,G,B)
%
%           filename = display calibration file name
%             GAMXYZ = 3 x 3 matrix of monitor gamut XYZ values
%                RGB = (n x 3) matrix or
%			   R,G,B = individual RGB arrays of equal size
%                XYZ = (n x 3) matrix
%                Err = (n x 1) matrix of error values:-
%			  Err(i) = 1 - RGB was reset to range 0-1
%
BadArg = 1;
NumVal = 0;
switch nargin
case 0
    global COGGPH_RGB2XYZ
	clear global COGGPH_RGB2XYZ
    return
case 1
	if isnumeric(R)
		[m,n] = size(R);
		if (n == 3)
		    NumVal = m;
			RGB = R;
			BadArg = 0;
		end
	elseif ischar(R)
		dcf = readdcf(R);
		if isstruct(dcf)
            GAMXYZ = RGB2XYZINIT(dcf);
            if nargout > 0
                XYZ = GAMXYZ;
            end
		end
		return
	end
case 3
	if (length(R(:)) == length(G(:)))&(length(R(:)) == length(B(:)))
		RGB = [R(:) G(:) B(:)];
		BadArg = 0;
		NumVal = length(R(:));
	end
end

if BadArg
	PrintUsage
	return
end

global COGGPH_RGB2XYZ

BadArg = 1;
if exist('COGGPH_RGB2XYZ')
	if isstruct(COGGPH_RGB2XYZ)
		BadArg = 0;
	end
end

if BadArg
	fprintf('\nERROR - First initialize with rgb2xyz(filename)\n')
	fprintf('where filename = display calibration file name\n\n')
	return
end

jstr = {'R' 'G' 'B'};

Err = zeros(NumVal,1);

for j = 1:3
	i = find(RGB(:,j) < 0);
	if ~isempty(i)
	    Err(i) = bitor(Err(i),1);
		RGB(i,j) = 0;
	end

	i = find(RGB(:,j) > 1);
	if ~isempty(i)
	    Err(i) = bitor(Err(i),1);
		RGB(i,j) = 1;
	end
end

XYZ = RGBXYZM(RGB);

return
%--------------------------------------------------------
% This function prints the usage guide
%
function PrintUsage

fprintf('\n rgb2xyz v1.33\n\n')
fprintf(' This function calculates the CIE (1931) XYZ values for an RGB triplet\n\n')
fprintf(' Usage: GAMXYZ = rgb2xyz(filename) (= initialization) or\n\n')
fprintf('     [XYZ,Err] = rgb2xyz(RGB) or\n')
fprintf('     [XYZ,Err] = rgb2xyz(R,G,B)\n\n')
fprintf('            filename = display calibration file name\n')
fprintf('              GAMXYZ = 3 x 3 matrix of monitor gamut XYZ values\n')
fprintf('                 RGB = (n x 3) matrix\n')
fprintf('               R,G,B = individual RGB vectors of equal length\n\n')
fprintf('                 XYZ = (n x 3) matrix\n')
fprintf('                 Err = (n x 1) matrix of error values:-\n')
fprintf('				        Err(i)=1 - RGB was reset to range 0-1\n\n')

return
%--------------------------------------------------------
% This function initializes the conversion table
%
function GAMXYZ = RGB2XYZINIT(dcf)

clear global COGGPH_RGB2XYZ

global COGGPH_RGB2XYZ

CALRGB = dcf.CalibLevel/255;

CALNUM = length(CALRGB);
RAWXYZ = dcf.XYZ([1 2 4],:,:);
TMPXYZ = zeros(3,CALNUM,3);
TMPXYZ(:,[end:-1:1],:) = RAWXYZ(:,[end:-1:1],:) - RAWXYZ(:,ones(1,CALNUM),:);
for RGB = 1:3
    [TMPMAX,INDXYZ(RGB)] = max(max(squeeze(TMPXYZ(RGB,:,:))));
    [TMPMAX,INDLEV(RGB)] = max(squeeze(TMPXYZ(RGB,:,INDXYZ(RGB))));
    CALXYZ(RGB,:) = TMPXYZ(RGB,:,INDXYZ(RGB))/TMPXYZ(RGB,INDLEV(RGB),INDXYZ(RGB));
    ZERXYZ(RGB) = RAWXYZ(RGB,1,INDXYZ(RGB));
end

for RGB = 1:3
    MAXXYZ(RGB,:) = squeeze(TMPXYZ(RGB,INDLEV(RGB),:))';
end

INTRGB = (0:255)/255;
%
% Make an extra check here for repeated CALRGB values
% This may happen if someone does a calibration with too many 
% X points (e.g. 256)
%
% In that case, just use the average XYZ values and compress 
% the CALRGB values into a single unit
%
CALRGB0 = CALRGB;
CALXYZ0 = CALXYZ;
CALNUM0 = CALNUM;
i = 1;
CALRGB = [];
CALXYZ = [];
CALNUM = 0;
while i <= CALNUM0;
    CALNUM = CALNUM + 1;
    CALRGB(CALNUM) = CALRGB0(i);
    j = find(CALRGB0 == CALRGB0(i));
    n = length(j);
    
    CALXYZ(:,CALNUM) = sum(CALXYZ0(:,j),2)/n;
    i = i + n;
end
%
% There are three types of interpolation that we can try
% The preferred interpolation method is spline interpolation
%
for RGB = 1:3
    INTXYZ(RGB,:) = interp1(CALRGB,CALXYZ(RGB,:),INTRGB,'spline');
end
%
% However, there may be out of range values in some parts
% of the distribution, in which case we will substitute
% another interpolation method and smooth the outlying
% areas.  The second interpolation choice is pchip
%
if (min(INTXYZ(:)) < 0)|(max(INTXYZ(:)) > 1)
    for RGB = 1:3
        INTXYZ(RGB,:) = interp1(CALRGB,CALXYZ(RGB,:),INTRGB,'pchip');
    end
end
%
% The final choice is linear interpolation
%
if (min(INTXYZ(:)) < 0)|(max(INTXYZ(:)) > 1)
    for RGB = 1:3
        INTXYZ(RGB,:) = interp1(CALRGB,CALXYZ(RGB,:),INTRGB,'linear');
    end
end

COGGPH_RGB2XYZ.INDXYZ = INDXYZ;
COGGPH_RGB2XYZ.MAXXYZ = MAXXYZ;
COGGPH_RGB2XYZ.ZERXYZ = ZERXYZ;
COGGPH_RGB2XYZ.INTRGB = INTRGB;
COGGPH_RGB2XYZ.INTXYZ = INTXYZ;

GAMXYZ = MAXXYZ + [ZERXYZ;ZERXYZ;ZERXYZ];

return
%--------------------------------------------------------
% This function converts RGB to XYZ
%
function XYZ = RGBXYZ(RGB)

global COGGPH_RGB2XYZ

XYZ = COGGPH_RGB2XYZ.ZERXYZ;

for i = 1:3
    Factor = interp1(COGGPH_RGB2XYZ.INTRGB,COGGPH_RGB2XYZ.INTXYZ(i,:),RGB(i),'linear');
    XYZ = XYZ + COGGPH_RGB2XYZ.MAXXYZ(i,:)*Factor;
end

return
%--------------------------------------------------------
% This function converts multiple RGB to multiple XYZ
%
function XYZ = RGBXYZM(RGB)

global COGGPH_RGB2XYZ

[m,n] = size(RGB);

XYZ = repmat(COGGPH_RGB2XYZ.ZERXYZ,m,1);

for i = 1:3
    Factor = interp1(COGGPH_RGB2XYZ.INTRGB,COGGPH_RGB2XYZ.INTXYZ(i,:),RGB(:,i),'linear');
    MAXXYZM = repmat(COGGPH_RGB2XYZ.MAXXYZ(i,:),m,1);
    FACTORM = repmat(Factor,1,3);
    XYZ = XYZ + MAXXYZM.*FACTORM;
end

return
