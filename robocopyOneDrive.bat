@echo off

::echo %username%
::echo %userprofile%

::@echo on

::Pause

echo =====OneDrive=====
robocopy "C:\Users\%username%\OneDrive - flushingbank.com" "C:\TEMP\Backup\Desktop" /e /j /r:3 /w:3 /log+:C:\temp\backup.txt