REM Convert .ulaw to .wav file
REM.
cmd /c C:\AudioConverter\sox-14.4.0\sox -t raw -e u-law -r 8k %1.ulaw -r 8k -c 1 -e signed-integer %1.wav

REM Convert .wav to .mp3 file
REM.
cmd /c C:\AudioConverter\lame3.98.2\lame.exe -V3  %1.wav  %1.mp3

del %1.wav