function mouse
% Sample script mouse v1.33
%
% Move the cursor into the display.
%
% Hit a mouse button to exit
%
fprintf('\nMove the cursor into the display.\n\n');
fprintf('Hit a mouse button to exit\n\n')

cgloadlib
cgopen(1,0,0,0)
cgpencol(1,1,1)

bp=0;
while ~bp
   [x,y,bs,bp]=cgmouse;
   cgellipse(x,y,100,100,'f')  
   cgflip(0,0,0)
end

cgshut
return
