@echo off

SET This_Dir=%~dp0
C:\Windows\System32\setx MCsquare_Materials_Dir %This_Dir%Materials >NUL

echo Calling MCsquare...

echo Trying avx512 optimizations
start /low /min /wait /B %This_Dir%MCsquare_win_avx512.exe | findstr /i "processor support Intel(R)" >NUL || exit 
echo Not supported. Trying avx2 optimizations
start /low /min /wait /B  %This_Dir%MCsquare_win_avx2.exe | findstr /i "processor support Intel(R)" >NUL || exit
echo  Not supported. Trying avx optimizations
start /low /min /wait /B  %This_Dir%MCsquare_win_avx.exe | findstr /i "processor support Intel(R)" >NUL || exit
echo Not supported. Trying sse4 optimizations
start /low /min /wait /B  %This_Dir%MCsquare_win_sse4.exe | findstr /i "processor support Intel(R)" >NUL || exit
echo Not supported. Starting MCsquare without Intel optimizations.
start /low /min /wait /B  %This_Dir%MCsquare_win.exe 

