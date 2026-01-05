@echo off
REM Creates a log file with timestamp.
REM Created By: Rohtash Singh
REM Created On: 04/16/2013
 
REM define path to log file
set logFileName=C:\NetStatLog.txt
 
REM Delete the logfile if it already exists.
if exist %logFileName% del %logFileName% >NUL

Echo Working...
REM When sending something to the log routine, enclose the message in quotes.
Call :LogEntry "Starting %logFileName%"
REM Call :LogEntry "Sleeping for 15 seconds"
REM Sleep 15

:NextIteration
REM Call :LogEntry "Sleeping for 15 seconds"
REM Sleep 15
REM SLEEP does not work in some operating systems, so using ping.
ping -n 15 127.0.0.1 >nul
Call :LogEntry "Getting NETSTAT Information..."
REM Sending results of a NETSTAT command to the log.
REM The output is encosed in quotes, otherwise, only the first part of the output is logged.
for /f "tokens=*" %%t in ('netstat ^|find /i "TCP"') do @Call :LogEntry "%%t"
GOTO :NextIteration
Call :LogEntry "Finishing logging in %logFileName%"
GOTO :EOF
 
:LogEntry
REM Output will be like: Tue 04/16/2013 11:42 AM "Starting C:\NetStatLog.txt"
for /f "tokens=*" %%i in ('date /t') do @for /f "tokens=*" %%j in ('time /t') do @echo %%i%%j %1 >>%logFileName%
GOTO :EOF
 
:EOF
