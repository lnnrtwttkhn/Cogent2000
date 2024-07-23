function addresults( varargin )
% ADDRESULTS add row of items to results file
%
% Description:
%
% Usage:
%     ADDRESULTS( field1, field2, field3, ... )
%
% Arguments:
%
% Examples:
%
% See also:
%
% Cogent 2000 function.
%
% $Rev: 218 $ $Date: 2010-10-27 12:06:55 +0100 (Wed, 27 Oct 2010) $


global cogent;

for i = 1:nargin
    switch class( varargin{i} )
        case 'double'
        case 'char'
        otherwise
            error( 'cell must be string or numeric' );
    end
end

cogent.results.data{ length(cogent.results.data)+1 } = varargin;