function config_data( filename )
% CONFIG_DATA loads data file
%
% Description:
%     Loads specified data file.  Get data using the GETDATA command.
%
% Usage:
%     CONFIG_DATA( filename )
%
% Arguments:
%     filename - name of data file
%
% Examples:
%     CONFIG_DATA( 'test.dat' )
%
% See also:
%     CONFIG_DATA, GETDATA
%
% Cogent 2000 function.
%
% $Rev: 218 $ $Date: 2010-10-27 12:06:55 +0100 (Wed, 27 Oct 2010) $

global cogent;

if ~ischar(filename)
    error( 'argument must be a string' );
end

fid = fopen( filename );
if fid == -1
    error( [ 'cannot open file ' filename ] );
end

cogent.data = {};

text = fgetl( fid );
row = 1;
col = 1;
try
    while ~isnumeric(text)
        field = getfields(text);
        for col = 1:length(field)
            cogent.data{row}{col} = eval( field{col} );
        end
        row = row + 1;
        text = fgetl( fid );
    end
catch
    fclose( fid );
    error( [ 'error loading ' filename ' (row=' num2str(row) ',col=' num2str(col) ') : ' field{col} ] );
end

fclose( fid );

return;