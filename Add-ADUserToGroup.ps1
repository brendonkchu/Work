$Group = "SSO_Percipio_Users" #Group Name
$ADUser = Get-ADUser "cyepez" | Select-Object SamAccountName #Username
Add-ADGroupMember -Identity $Group -Members $ADUser.SamAccountName