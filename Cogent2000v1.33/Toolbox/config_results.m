function config_results( varargin )
% CONFIG_RESULTS configures results file
%
% Description:
%     Configure results file.  If the filename is not specified then the default filename
%     is 'Cogent-YEAR-MONTH-DAY-HOUR-MIN-SEC.res'
%
%
% Usage:
%     CONFIG_RESULTS
%     CONFIG_RESULTS( filename )
%
% Arguments:
%     filename - name of file for saved results
%
% Examples:
%     CONFIG_RESULTS
%     CONFIG_RESULTS( 'test1.res' )
%
% See also:
%     ADDRESULTS
%
% Cogent 2000 function.
%
% $Rev: 218 $ $Date: 2010-10-27 12:06:55 +0100 (Wed, 27 Oct 2010) $


global cogent;

if nargin == 0
    
    cogent.results.filename = ['Cogent' num2str(datevec(now),'-%02.0f') '.res'];
    
elseif nargin == 1
    
    if ~ischar(varargin{1})
        error( 'argument must be a string' );
    end
    cogent.results.filename = varargin{1};
    
else
    
    error( 'wrong number of arguments' );
    
end

cogent.results.data = {};