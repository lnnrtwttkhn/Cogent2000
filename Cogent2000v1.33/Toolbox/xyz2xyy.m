function xyY=xyz2xyy(XYZ)
% xyz2xyy v1.33
%
% This function converts an array of CIE XYZ to xyY values
%
% Usage: xyY = xyz2xyy(XYZ)
%
%        XYZ,xyY = (n x 3) matrix
%
if (nargin ~= 1)|(nargout ~= 1)
   if nargout == 1
      xyY = [0 0 0];
   end
   PrintUsage
   return
elseif ~isnumeric(XYZ)
   if nargout == 1
      xyY = [0 0 0];
   end
   PrintUsage
   return
end

S = XYZ(:,1) + XYZ(:,2) + XYZ(:,3);
xyY = [XYZ(:,1)./S XYZ(:,2)./S XYZ(:,2)];

return
%--------------------------------------------------------
% This function prints the usage guide
%
function PrintUsage

fprintf('\n xyz2xyy v1.33\n\n')
fprintf(' This function converts an array of CIE XYZ to xyY values\n\n')
fprintf(' Usage: xyY = xyz2xyy(XYZ)\n\n')
fprintf('        XYZ,xyY = (n x 3) matrix\n\n')

return