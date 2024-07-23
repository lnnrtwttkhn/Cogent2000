config_display(1, 1, 1, 255, 'Arial', 25, 4, 8 )
%config_serial
start_cogent

%clearserialbytes(1);
preparedartboard(1,20,200,10,18);
paletteflickerrest(1,0,0,0,32767);
pause(1);
clear t
pause;
for i=1:6
   t0=time;
   %waitserialbyte(1,inf,0);
   paletteflickerrest(1,4,4,225,32767);
   t1=time-t0
   wait(30000);
   t2=time-t0-t1
end
stop_cogent
