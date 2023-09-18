#Compare-Object (Get-ADUser -SearchBase “OU=FSB,DC=flushingsavings,DC=com” -Filter * |Where-Object {$_.DistinguishedName -notmatch "OU=ATMVideo|OU=Deleted|OU=Disable Users|OU=Distribution Lists|OU=FlushingBankLive|OU=IGOBanking|OU=Recovery|OU=Security Groups|OU=Service Accounts|OU=Special Mailboxes|OU=Training,OU=RXR Plaza|OU=Board Members,OU=RXR Plaza"}) (Get-ADGroupMember "FBNotificationList") -Property 'name' <#-IncludeEqual#> |Export-CSV C:\Scripts\FBSDiff.csv
#OLD CODE------------------------------------------------------------------------------

#ExportAllUsersFBNotifi.ps1
Get-ADUser -SearchBase "OU=FSB,DC=flushingsavings,DC=com" -Filter * |Where-Object {$_.DistinguishedName -notmatch "ATMVideo|Deleted|Disable Users|Distribution Lists|FlushingBankLive|IGOBanking|Recovery|Security Groups|Service Accounts|Special Mailboxes|Training|Board Members"} `
|select name,samaccountname,userprincipalname |Export-CSV C:\Scripts\AllUsers.csv
#Exports a list of users with the exception of Generic Accounts and Board Members to AllUser.csv

#--------------------------------------------------------------------------------------

#Get-ADGroupMember FBNotifi.ps1
#Exports a CSV of an AD Group's Members with listed UPNs. This one is specifically for FBNotifi that shows CURRENT members and exports to FBNotificationListCurrentMembers.csv
$SecurityGroup = "FBNotificationList"
Get-ADGroupMember -identity $SecurityGroup |get-aduser|
 select name,samaccountname,userprincipalname | 
 Export-csv -path C:\Scripts\FBNotificationListCurrentMembers.csv -NoTypeInformation

#--------------------------------------------------------------------------------------

#Compares both script exports above
$csv1 = Import-Csv C:\Scripts\AllUsers.csv
$csv2 = Import-Csv C:\Scripts\FBNotificationListCurrentMembers.csv
Compare-Object $csv1 $csv2 -Property samaccountname #-IncludeEqual
