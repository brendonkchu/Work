@echo off

::echo %username%
::echo %userprofile%

::@echo on

::Pause

echo =====Desktop=====
robocopy "C:\Users\%username%\Desktop" "C:\TEMP\Backup\Desktop" /e /j /r:3 /w:3 /log+:C:\temp\backup.txt
echo:
echo =====Documents=====
robocopy "C:\Users\%username%\Documents" "C:\TEMP\Backup\Documents" /e /j /r:3 /w:3 /log+:C:\temp\backup.txt
echo:
echo =====Downloads=====
robocopy "C:\Users\%username%\Downloads" "C:\TEMP\Backup\Downloads" /e /j /r:3 /w:3 /log+:C:\temp\backup.txt
echo:
echo =====Pictures=====
robocopy "C:\Users\%username%\Pictures" "C:\TEMP\Backup\Pictures" /e /j /r:3 /w:3 /log+:C:\temp\backup.txt
echo:
echo =====Google=====
robocopy "C:\Users\%username%\AppData\Local\Google\Chrome\User Data\Default\Bookmarks" "C:\TEMP\Backup" /e /j /r:3 /w:3 /log+:C:\temp\backup.txt
echo:
echo =====Google2=====
robocopy "C:\Users\%username%\AppData\Local\Google\Chrome\User Data\Default\Bookmarks.bak" "C:\TEMP\Backup" /e /j /r:3 /w:3 /log+:C:\temp\backup.txt

echo:
echo =====Desktop=====
robocopy "%Userprofile%\Desktop" "C:\TEMP\Backup\Desktop" /e /j /r:3 /w:3 /log+:C:\temp\backup.txt
echo:
echo =====Documents=====
robocopy "%Userprofile%\Documents" "C:\TEMP\Backup\Documents" /e /j /r:3 /w:3 /log+:C:\temp\backup.txt
echo:
echo =====Downloads=====
robocopy "%Userprofile%\Downloads" "C:\TEMP\Backup\Downloads" /e /j /r:3 /w:3 /log+:C:\temp\backup.txt
echo:
echo =====Pictures=====
robocopy "%Userprofile%\Pictures" "C:\TEMP\Backup\Pictures" /e /j /r:3 /w:3 /log+:C:\temp\backup.txt
echo:
echo =====Google=====
robocopy "%Userprofile%\AppData\Local\Google\Chrome\User Data\Default\Bookmarks" "C:\TEMP\Backup" /e /j /r:3 /w:3 /log+:C:\temp\backup.txt
echo:
echo =====Google2=====
robocopy "%Userprofile%\AppData\Local\Google\Chrome\User Data\Default\Bookmarks.bak" "C:\TEMP\Backup" /e /j /r:3 /w:3 /log+:C:\temp\backup.txt
echo:
echo =====TO H Drive=====
robocopy "C:\TEMP\Backup" "H:\Backup" /e /j /r:3 /w:3 /log+:C:\temp\backup.txt


echo:
echo =====Move Old OneDrive=====
robocopy "%Userprofile%\OneDrive - flushingbank.com\" "C:\TEMP\Backup"/move
robocopy "%Userprofile%\OneDrive" "C:\TEMP\Backup"/move
robocopy "C:\Users\%username%\OneDrive - flushingbank.com\" "C:\TEMP\Backup"/move
robocopy "C:\Users\%username%\OneDrive" "C:\TEMP\Backup"/move

echo:
echo =====TO OneDrive=====
robocopy "C:\TEMP\Backup" "%Userprofile%\OneDrive - flushingbank.com" /e /j /r:3 /w:3 /log+:C:\temp\backup.txt

net share > "C:\TEMP\Backup\Local_Drives.txt"
net use > "C:\TEMP\Backup\Mapped_Drives.txt"
wmic printer list brief > "C:\TEMP\Backup\Installed_Printers.txt"

echo ---------------------Complete---------------------
for /l %%a in (1,1,48) do timeout 300 >nul
::Pause