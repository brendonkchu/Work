xcopy "\\RPV-VMDEM\DEMProfileArchives\%username%\Desktop" "C:\TEMP\Backup\Desktop" /f /i /s /y /z 
xcopy "\\RPV-VMDEM\DEMProfileArchives\%username%\Documents" "C:\TEMP\Backup\Documents" /f /i /s /y /z 
xcopy "\\RPV-VMDEM\DEMProfileArchives\%username%\Downloads" "C:\TEMP\Backup\Downloads" /f /i /s /y /z
xcopy "\\RPV-VMDEM\DEMProfileArchives\%username%\Pictures" "C:\TEMP\Backup\Pictures" /f /i /s /y /z 

net share > "C:\TEMP\Backup\Local_Drives.txt"
net use > "C:\TEMP\Backup\Mapped_Drives.txt"
wmic printer list brief > "C:\TEMP\Backup\Installed_Printers.txt"

xcopy "C:\Users\%username%\Desktop" "C:\TEMP\Backup\Desktop" /f /i /s /y /z 
xcopy "C:\Users\%username%\Documents" "C:\TEMP\Backup\Documents" /f /i /s /y /z 
xcopy "C:\Users\%username%\Downloads" "C:\TEMP\Backup\Downloads" /f /i /s /y /z
xcopy "C:\Users\%username%\Pictures" "C:\TEMP\Backup\Pictures" /f /i /s /y /z 
xcopy "C:\Users\%username%\AppData\Local\Google\Chrome\User Data\Default\Bookmarks" "C:\TEMP\Backup" /z /y
xcopy "C:\Users\%username%\AppData\Local\Google\Chrome\User Data\Default\Bookmarks.bak" "C:\TEMP\Backup" /z /y

xcopy "C:\TEMP\Backup" "H:\Backup" /f /i /s /y /z 

Pause