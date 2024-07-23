function settextstyle( font, size )
% SETTEXTSTYLE sets font name and size
%
% Description:
%     Sets font name and size used by PREPAREASTRING.
%
% Usage:
%     SETTEXTSTYLE( font, size )
%
% Arguments:
%     font - font name (e.g. 'Arial', 'Helvetica' )
%     size - size of font
%
% Examples:
%     SETTEXTSTYLE( 'Arial', 50 ) - set font to 50 point Arial
%
% See also:
%     CONFIG_DISPLAY, CLEARPICT, DRAWPICT, LOADPICT, PREPAREPICT, PREPARESTRING, SETFORECOLOUR,
%     SETTEXTSTYLE
%
% Cogent 2000 function.
%
% $Rev: 218 $ $Date: 2010-10-27 12:06:55 +0100 (Wed, 27 Oct 2010) $

global cogent;

error( checkdisplay );

cogent.display.font = font;
cogent.display.size = size;
gprim( 'gfont', font, size );