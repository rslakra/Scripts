@echo off
set PATH=%PATH%;%ANT_HOME%\bin;%cd%;.
echo %PATH%
ant clean install
@echo on