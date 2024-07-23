function [RGB,Err] = xyz2rgb(X,Y,Z,Options)
% xyz2rgb v1.33
%
% This function calculates RGB triplets for CIE (1931) XYZ values
%
% Usage: GAMXYZ = xyz2rgb(filename) (= initialization) or
%
%     [RGB,Err] = xyz2rgb(XYZ<,option>) or
%     [RGB,Err] = xyz2rgb(X,Y,Z<,option>)
%
%           filename = display calibration file name
%             GAMXYZ = 3 x 3 matrix of monitor gamut XYZ values
%                XYZ = (n x 3) matrix or
%			   X,Y,Z = individual X,Y,Z arrays of equal size
%            Options = 0 (keep hue) or 1 (keep int) for Err=2
%                      or 2 to return uncorrected linear RGB
%                RGB = (n x 3) matrix
%                Err = (n x 1) matrix of error values:-
%                      Err(i) is the sum of the following errors
%                      Err(i)=1 - XYZ reset from -ve to zero
%                      Err(i)=2 - High Y value reset
%                      Err(i)=4 - Gamut error correction
%
global COGGPH_RGB2XYZ

BadArg = 1;
switch nargin
case 0
	clear global COGGPH_RGB2XYZ
    return
case {1 2}
	if isnumeric(X)
		[m,n] = size(X);
		if (n == 3)
			XYZ = X;
			BadArg = 0;
		end
	elseif ischar(X)
		if X == '?'
			PrintUsage
			return
		end
			
        GAMXYZ = rgb2xyz(X);
        if nargout > 0
            RGB = GAMXYZ;
        end
		return
    end
    if nargin == 2
        Options = Y;
    else
        Options = 0;
    end
case {3 4}
	if (length(X(:)) == length(Y(:)))&(length(X(:)) == length(Z(:)))
		XYZ = [X(:) Y(:) Z(:)];
		BadArg = 0;
    end
    if nargin == 3
        Options = 0;
    end
end

if ~isnumeric(Options)
    BadArg == 1;
elseif (Options ~= 0)&(Options ~= 1)&(Options ~= 2)
    BadArg = 1;
end

if BadArg
	PrintUsage
	return
end

BadArg = 1;
if exist('COGGPH_RGB2XYZ')
	if isstruct(COGGPH_RGB2XYZ)
		BadArg = 0;
	end
end

if BadArg
	fprintf('\nERROR - First initialize with xyz2rgb(filename)\n')
	fprintf('where filename = display calibration file name\n\n')
	return
end

[RGB,Err] = XYZRGB(XYZ,Options);

return
%--------------------------------------------------------
% This function prints the usage guide
%
function PrintUsage

fprintf('\n xyz2rgb v1.33\n\n')
fprintf('This function calculates RGB triplets for CIE (1931) XYZ values\n\n')
fprintf('Usage: GAMXYZ = xyz2rgb(filename) (= initialization) or\n\n')
fprintf('    [RGB,Err] = xyz2rgb(XYZ<,Options>) or\n')
fprintf('    [RGB,Err] = xyz2rgb(X,Y,Z<,Options>)\n\n')
fprintf('            filename = display calibration file name\n')
fprintf('              GAMXYZ = 3 x 3 matrix of monitor gamut XYZ values\n')
fprintf('                 XYZ = (n x 3) matrix\n')
fprintf('               X,Y,Z = individual X,Y,Z arrays of equal length\n')
fprintf('             Options = 0 (keep hue) or 1 (keep int) for Err=2\n')
fprintf('                       or 2 to return uncorrected linear RGB\n\n')
fprintf('                 RGB = (n x 3) matrix\n')
fprintf('                 Err = (n x 1) matrix of error values:-')
fprintf('                       Err(i) is the sum of the following errors\n')
fprintf('                       Err(i)=1 - XYZ reset from -ve to zero\n')
fprintf('                       Err(i)=2 - High Y value reset\n')
fprintf('                       Err(i)=4 - Gamut error correction\n\n')
return
%
% This function moves the requested XYZ point towards the white point(x,y,z) = (1/3,1/3,1/3)
% to get it within monitor gamut
%
function newXYZ = MoveXYZ(XYZ)

global COGGPH_RGB2XYZ

BigY = XYZ(:,2);
sXYZ = sum(XYZ,2);
x = XYZ(:,1)./sXYZ;
y = BigY./sXYZ;

for i = 1:3
    xp(i) = COGGPH_RGB2XYZ.MAXXYZ(i,1)/sum(COGGPH_RGB2XYZ.MAXXYZ(i,:));
    yp(i) = COGGPH_RGB2XYZ.MAXXYZ(i,2)/sum(COGGPH_RGB2XYZ.MAXXYZ(i,:));
end

x0 = 1/3;
y0 = 1/3;
dmin = -1*ones(1,length(BigY));
xmin = zeros(1,length(BigY));
ymin = zeros(1,length(BigY));
for i = 1:3
    j = 1 + mod(i,3);
    
    x1 = xp(i);
    y1 = yp(i);
    x2 = xp(j);
    y2 = yp(j);
    
    [xi,yi,e] = Intersect(x0,y0,x,y,x1,y1,x2,y2);
    
    i1 = find(e < 1);
    if ~isempty(i1)
        dx = x1 - x2;
        dy = y1 - y2;
        
        d1 = dx*dx + dy*dy;

        dx = xi(i1) - x1;
        dy = yi(i1) - y1;

        d2 = dx.*dx + dy.*dy;
        
        dx = xi(i1) - x2;
        dy = yi(i1) - y2;

        d3 = dx.*dx + dy.*dy;

        itmp = find((d1 >= d2)&(d1 >= d3));
        if ~isempty(itmp)
            i2 = i1(itmp);

            dx = xi(i2) - x(i2)';
            dy = yi(i2) - y(i2)';
            
            d = dx.*dx + dy.*dy;
    
            itmp = find((dmin(i2) < 0)|(d < dmin(i2)));
            if ~isempty(itmp)
                i3 = i2(itmp);
                dmin(i3) = d(itmp);
                xmin(i3) = xi(i3);
                ymin(i3) = yi(i3);
            end
        end
    end
end

i = find(dmin < 0);
if ~isempty(i)
    newXYZ(i,1:3) = XYZ(i,:);
end
i = find(dmin >= 0);
if ~isempty(i)
    newXYZ(i,1) = (xmin(i).*BigY(i)'./ymin(i))';
    newXYZ(i,2) = BigY(i);
    newXYZ(i,3) = ((1 - xmin(i) - ymin(i)).*BigY(i)'./ymin(i))';
end

return

function [xi,yi,e] = Intersect(x1,y1,x2,y2,x3,y3,x4,y4)

b1_b2 = (y2 - y1)*(x4 - x3) - (y4 - y3)*(x2 - x1);

e = zeros(1,length(b1_b2));
xi = e;
yi = e;

i = find(b1_b2 == 0);
if ~isempty(i)
    e(i) = 1;
end

ib = find(b1_b2 ~= 0);
x2b = x2(ib);
y2b = y2(ib);
b1_b2b = b1_b2(ib);

a1_a2 = (x2b*y1 - x1*y2b)*(x4 - x3) - (x4*y3 - x3*y4)*(x2b - x1);
xi(ib) = -a1_a2./b1_b2b;

a1_a2 = (y4*x3 - y3*x4)*(y2b - y1) - (y2b*x1 - y1*x2b)*(y4 - y3);
yi(ib) = -a1_a2./b1_b2b;

return
%--------------------------------------------------------
% This function converts XYZ to RGB
%
function [RGB,ERR] = XYZRGB(XYZ,Options)

global COGGPH_RGB2XYZ

[m,n] = size(XYZ);

ERR = uint8(zeros(1,m));
ERR2 = ERR;

a = find(XYZ < 0);
if ~isempty(a)
	XYZ(a) = 0;
    a2 = 1 + mod((a - 1),m);
	ERR(a2) = bitor(ERR(a2),1);
    ERR2(a2) = bitor(ERR2(a2),1);
end

XYZ = XYZ - repmat(COGGPH_RGB2XYZ.ZERXYZ,m,1);
a = find(XYZ < 0);
if ~isempty(a)
	XYZ(a) = 0;
end
%
% Convert XYZ to F values, which correspond to linear combinations of the
% R,G and B monitor levels (off = 0, max = 1).  Note that these linear F
% values do not correspond to raw RGB values passed to the graphics card
%
F = COGGPH_RGB2XYZ.MAXXYZ'\XYZ';
%
% Ignore small discrepancies (e.g. just less than 0 or just greater than 1)
%
Factor = 10000;
F = round(F*Factor)/Factor;

if Options == 2
    RGB = F';
    
    a = find(F > 1);
    if ~isempty(a)
        a2 = sort(fix((a + 2)/3));
        k = 1 + find((a2(2:end) - a2(1:(end - 1))) ~= 0);
        a3 = [a2(1)' a2(k)'];
        ERR(a3) = bitor(ERR(a3),2);
    end
    a = find(F < 0);
    if ~isempty(a)
        a2 = sort(fix((a + 2)/3));
        k = 1 + find((a2(2:end) - a2(1:(end - 1))) ~= 0);
        a3 = [a2(1)' a2(k)'];
        ERR(a3) = bitor(ERR(a3),4);
    end
    return
end

a = find(F > 1);

if ~isempty(a)
    a2 = sort(fix((a + 2)/3));
    %
    % a2 has the indices of all F values greater than one.
    %
    % There may be some duplicates. Remove them.
    %
    k = 1 + find((a2(2:end) - a2(1:(end - 1))) ~= 0);
    a3 = [a2(1)' a2(k)'];
    ERR(a3) = bitor(ERR(a3),2);
    if Options == 1
        %
        % Correct the brightness by desaturating the colour
        %
        FB1 = F(:,a3);                          % FB1 is the linear RGB levels (some may exceed 1)
        FB2 = FB1./repmat(max(FB1,[],1),3,1);   % FB2 is the linear levels normalized to 1
        FB3 = 1 - FB2;                          % FB3 is the anti-colour of FB2
        XYZ1 = XYZ(a3,:);
        XYZ2 = (COGGPH_RGB2XYZ.MAXXYZ'*FB2)';
        XYZ3 = (COGGPH_RGB2XYZ.MAXXYZ'*FB3)';
        %
        % The correction factor CF says how much of the anti-colour needs
        % to be added to the normalized colour in order to make it up to
        % the requested brightness
        %
        CF = (XYZ1(:,2) - XYZ2(:,2))./XYZ3(:,2);
        
        FB4 = FB2 + FB3.*repmat(CF',3,1);
        %
        % Do not allow any out-of-range values
        %
        a = find(FB4 > 1);
        if ~isempty(a)
            FB4(a) = 1;
        end
        
        F(:,a3) = FB4;
    else
        %
        % Correct the brightness by dimming the colour
        %
        F(:,a3) = F(:,a3)./repmat(max(F(:,a3)),3,1);
    end
end

a = find(F < 0);

if ~isempty(a)
    a2 = sort(fix((a + 2)/3));
    %
    % a2 has the indices of all F values less than zero.
    %
    % There may be some duplicates. Remove them.
    %
    k = 1 + find((a2(2:end) - a2(1:(end - 1))) ~= 0);
    a3 = [a2(1)' a2(k)'];
    ERR(a3) = bitor(ERR(a3),4);
    
    F(a) = 0;
    %
    % Try moving towards white
    %
    XYZ2 = MoveXYZ(XYZ(a3,:));
    F2 = COGGPH_RGB2XYZ.MAXXYZ'\XYZ2';
    F2 = round(F2*Factor)/Factor;
    ERR2(a3) = bitor(ERR2(a3),4);
    j = find(max(F2) > 1);
    if ~isempty(j)
        a4 = a3(j);
        ERR2(a4) = bitor(ERR2(a4),2);
        F2(:,j) = F2(:,j)./repmat(max(F2(:,j)),3,1);
    end
    j = find(min(F2) >= 0);
    if ~isempty(j)
        a5 = a3(j);
        F(:,a5) = F2(:,j);
        ERR(a5) = ERR2(a5);
    end
end

RGB = zeros(3,m);

for i = 1:3
    tmpINTXYZ = COGGPH_RGB2XYZ.INTXYZ(i,:);
    tmpF = F(i,:);
    
    aa = tmpF;
    bb = tmpINTXYZ;
    
    mm = size(aa,2);
    nn = size(bb,2);
    [cc,pp] = sort([aa,bb]);
    qq = 1:mm+nn;
    qq(pp) = qq;
    tt = cumsum(pp>mm);
    rr = 1:nn; rr(tt(qq(mm+1:mm+nn))) = rr;
    ss = tt(qq(1:mm));
    id = rr(max(ss,1));
    iu = rr(min(ss+1,nn));
    [dd,it] = min([abs(aa-bb(id));
    abs(bb(iu)-aa)]);
    ib = id+(it-1).*(iu-id);    
    
    minind = ib;
    
    RGB(i,:) = COGGPH_RGB2XYZ.INTRGB(minind);
end

RGB = RGB';
ERR = ERR';

return
