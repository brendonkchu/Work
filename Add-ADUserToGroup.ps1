$Group = "Personal Files Migrated to OneDrive" #Group Name
$ADUser = Get-ADUser "Bbateman" | Select-Object SamAccountName #Username
Add-ADGroupMember -Identity $Group -Members $ADUser.SamAccountName