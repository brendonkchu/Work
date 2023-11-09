$Group = "SSO_AdobeAcrobatPro" #Group Name
$ADUser = Get-ADUser "jtellekamp" | Select-Object SamAccountName #Username
Add-ADGroupMember -Identity $Group -Members $ADUser.SamAccountName