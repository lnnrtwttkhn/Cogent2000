function XYZ=xyy2xyz(xyY)
% xyy2xyz v1.33
%
% This function converts an array of CIE xyY to XYZ values
%
% Usage: XYZ = xyy2xyz(xyY)
%
%        xyY,XYZ = (n x 3) matrix
%
if (nargin ~= 1)|(nargout ~= 1)
   if nargout == 1
      XYZ = [0 0 0];
   end
   PrintUsage
   return
elseif ~isnumeric(xyY)
   XYZ = [0 0 0];
   PrintUsage
   return
end

z = 1 - xyY(:,1) - xyY(:,2);
XYZ = [xyY(:,1).*xyY(:,3)./xyY(:,2) xyY(:,3) z.*xyY(:,3)./xyY(:,2)];

return
%--------------------------------------------------------
% This function prints the usage guide
%
function PrintUsage

fprintf('\n xyy2xyz v1.33\n\n')
fprintf(' This function converts an array of CIE xyY to XYZ values\n\n')
fprintf(' Usage: XYZ = xyy2xyz(xyY)\n\n')
fprintf('        xyY,XYZ = (n x 3) matrix\n\n')

return