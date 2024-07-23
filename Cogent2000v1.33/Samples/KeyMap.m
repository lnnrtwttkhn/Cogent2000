function keymap
% Sample script keymap v1.33
%
% Click in the display window to activate it
% and then press any key to see its keycode.
%
% Hit Esc to exit
%
fprintf('\nClick in the display window to activate it\n');
fprintf('and then press any key to see its keycode.\n\n');
fprintf('Hit Esc to exit\n\n')

cgloadlib
cgopen(1,0,0,0)
kd(1)=0;
while ~kd(1)
   [kd,kp]=cgkeymap;
   kp=find(kp);
   if length(kp)
      fprintf('Key:%d \n',kp)
   end
end
cgshut
return
