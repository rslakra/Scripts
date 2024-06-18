@echo off
set PATH=%PATH%;%ANT_HOME%\bin;%cd%;.
echo %PATH%
java -jar ftp.jar TestDownloadUpload
@echo on
