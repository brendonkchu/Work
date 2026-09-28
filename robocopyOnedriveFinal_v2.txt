@echo off

::echo %username%
::echo %userprofile%

::@echo on

::Pause

C:\Users\%Username%\OneDrive - flushingbank.com


echo =====Desktop=====
robocopy "C:\Users\%Username%\Desktop" "C:\TEMP\Backup\Desktop" /e /j /r:3 /w:3 /log+:C:\temp\backup.txt
echo:
echo =====Documents=====
robocopy "C:\Users\%Username%\Documents" "C:\TEMP\Backup\Documents" /e /j /r:3 /w:3 /log+:C:\temp\backup.txt
echo:
echo =====Downloads=====
robocopy "C:\Users\%Username%\Downloads" "C:\TEMP\Backup\Downloads" /e /j /r:3 /w:3 /log+:C:\temp\backup.txt
echo:
echo =====Pictures=====
robocopy "C:\Users\%Username%\Pictures" "C:\TEMP\Backup\Pictures" /e /j /r:3 /w:3 /log+:C:\temp\backup.txt
echo:
echo =====Google=====
xcopy "C:\Users\%Username%\AppData\Local\Google\Chrome\User Data\Default\Bookmarks" "C:\TEMP\Backup" /z /y
xcopy "C:\Users\%Username%\AppData\Local\Google\Chrome\User Data\Default\Bookmarks.bak" "C:\TEMP\Backup" /z /y
echo: 

echo =====AutomaticDestinations=====
robocopy "%appdata%\microsoft\windows\recent\automaticdestinations" "C:\TEMP\Backup\AutomaticDestinations" /e /j /r:3 /w:3 /log+:C:\temp\backup.txt
echo: 

echo =====Net Backup=====
net share > "C:\TEMP\Backup\Local_Drives.txt"
net use > "C:\TEMP\Backup\Mapped_Drives.txt"
wmic printer list brief > "C:\TEMP\Backup\Installed_Printers.txt"
echo:

echo =====OneDrive Upload=====
xcopy "C:\TEMP\Backup" "%Userprofile%\OneDrive - flushingbank.com\" /s /e /t /y /z
echo:

echo ---------------------Complete---------------------
for /l %%a in (1,1,48) do timeout 300 >nul
::Pause