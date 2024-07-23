% SOUND2.M - plays a serious of tones created using preparepuretone.
config_display(0);
config_sound;

start_cogent;

% Create sound and play it before trials begin to
% work around problem with waitsound
preparepuretone( 200 + 200, 1000, 1 );
playsound( 1 );
waitsound( 1 ); 

for i = 1:5
   t0=time
   preparepuretone( 200 + 200*i, 1000, 1 );
   playsound( 1 );
   waitsound( 1 ); % Wait for sound to finish playing
   time-t0
   waituntil(t0+2000 ); % Leave 2000ms between each sound
end

stop_cogent;