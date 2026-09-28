OneDrive - flushingbank.com
C:\Users\BChuc.ITNOTEBOOK001\OneDrive - flushingbank.com

@echo off

::echo %username%
::echo %userprofile%

::@echo on

::Pause

echo =====Desktop=====
robocopy "C:\Users\%username%\Desktop" "C:\Users\%username%\OneDrive - flushingbank.com\Desktop" /e /j /r:3 /w:3 /mov
echo:
echo =====Documents=====
robocopy "C:\Users\%username%\Documents" "C:\Users\%username%\OneDrive - flushingbank.com\Documents" /e /j /r:3 /w:3 /mov
echo:
echo =====Downloads=====
robocopy "C:\Users\%username%\Downloads" "C:\Users\%username%\Downloads" /e /j /r:3 /w:3 /mov
echo:
echo =====Pictures=====
robocopy "C:\Users\%username%\Pictures" "C:\Users\%username%\OneDrive - flushingbank.com\Pictures" /e /j /r:3 /w:3 /mov
echo:
echo =====Google=====
robocopy "C:\Users\%username%\Bookmarks" "C:\Users\%username%\AppData\Local\Google\Chrome\User Data\Default\Bookmarks" /e /j /r:3 /w:3 /mov
echo:
echo =====Google2=====
robocopy "C:\Users\%username%\Bookmarks.bak" "C:\Users\%username%\AppData\Local\Google\Chrome\User Data\Default\Bookmarks.bak" /e /j /r:3 /w:3 /mov

echo ---------------------Complete---------------------
Pause