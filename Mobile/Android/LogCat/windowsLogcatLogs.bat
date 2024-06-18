@echo off
REM @author:Rohtash Singh
REM don't modify the caller's environment
setlocal

REM Set up environment.
set prog=%~f0
REM echo %prog%

REM Change current directory and drive to where the script is, to avoid
REM issues with directories containing whitespaces.
cd /d %~dp0
REM echo %cd%

REM Set ANDROID environment variable
REM set ANDROID_HOME=C:\Data\Android-SDK-Windows
set ANDROID_HOME=C:\Applications\Android\android-sdks
set ADB_HOME=%ANDROID_HOME%\platform-tools

ECHO.
ECHO Capturing Android LogCat Logs ...
set timestamp=%date:~-4,4%%date:~-7,2%%date:~-10,2%%time:~0,2%%time:~3,2%%time:~6,2%
set LOG_FILE_PATH="%UserProfile%\Desktop\APP-LogCat-%timestamp%.txt
%ADB_HOME%\adb logcat –d >"%LOG_FILE_PATH%"
%ADB_HOME%\adb logcat –c
