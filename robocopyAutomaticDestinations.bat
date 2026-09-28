%appdata%\microsoft\windows\recent\automaticdestinations
@echo off

::echo %username%
::echo %userprofile%

::@echo on

::Pause

echo =====AutomaticDestinations=====
robocopy "%appdata%\microsoft\windows\recent\automaticdestinations" "C:\TEMP\Backup\AutomaticDestinations" /e /j /r:3 /w:3 /log+:C:\temp\backup.txt
echo: 