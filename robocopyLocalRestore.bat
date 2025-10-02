OneDrive - flushingbank.com
C:\Users\BChuc.ITNOTEBOOK001\OneDrive - flushingbank.com

@echo off

::echo %username%
::echo %userprofile%

::@echo on

::Pause

echo =====H TO TEMP=====
robocopy "H:\Backup" "C:\TEMP\Backup" /e /j /r:3 /w:3 /log+:C:\temp\restore.txt

echo:
echo =====Desktop=====
robocopy "C:\TEMP\Backup\Desktop" "C:\Users\%username%\Desktop" /e /j /r:3 /w:3 /mov
echo:
echo =====Documents=====
robocopy "C:\TEMP\Backup\Documents" "C:\Users\%username%\Documents" /e /j /r:3 /w:3 /mov
echo:
echo =====Downloads=====
robocopy "C:\TEMP\Backup\Downloads" "C:\Users\%username%\Downloads" /e /j /r:3 /w:3 /mov
echo:
echo =====Pictures=====
robocopy "C:\TEMP\Backup\Pictures" "C:\Users\%username%\Pictures" /e /j /r:3 /w:3 /mov
echo:
echo =====Google=====
robocopy "C:\TEMP\Backup\Bookmarks" "C:\Users\%username%\AppData\Local\Google\Chrome\User Data\Default\Bookmarks" /e /j /r:3 /w:3 /mov
echo:
echo =====Google2=====
robocopy "C:\TEMP\Backup\Bookmarks.bak" "C:\Users\%username%\AppData\Local\Google\Chrome\User Data\Default\Bookmarks.bak" /e /j /r:3 /w:3 /mov

echo:
echo =====Desktop=====
robocopy "C:\TEMP\Backup\Desktop" "%Userprofile%\Desktop" /e /j /r:3 /w:3 /mov
echo:
echo =====Documents=====
robocopy "C:\TEMP\Backup\Documents" "%Userprofile%\Documents" /e /j /r:3 /w:3 /mov
echo:
echo =====Downloads=====
robocopy "C:\TEMP\Backup\Downloads" "%Userprofile%\Downloads" /e /j /r:3 /w:3 /mov
echo:
echo =====Pictures=====
robocopy "C:\TEMP\Backup\Pictures" "%Userprofile%\Pictures" /e /j /r:3 /w:3 /mov
echo:
echo =====Google=====
robocopy "C:\TEMP\Backup\Bookmarks" "%Userprofile%\AppData\Local\Google\Chrome\User Data\Default\Bookmarks" /e /j /r:3 /w:3 /mov
echo:
echo =====Google2=====
robocopy "C:\TEMP\Backup\Bookmarks.bak" "%Userprofile%\AppData\Local\Google\Chrome\User Data\Default\Bookmarks.bak" /e /j /r:3 /w:3 /mov

echo ---------------------Complete---------------------
Pause