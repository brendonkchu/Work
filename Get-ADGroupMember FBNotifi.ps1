#Exports a CSV of an AD Group's Members with listed UPNs. This one is specifically for FBNotifi that shows CURRENT members and exports to FBNotificationListCurrentMembers.csv

$SecurityGroup = "FBNotificationList"

Get-ADGroupMember -identity $SecurityGroup |get-aduser|
 select name,samaccountname,userprincipalname | 
 Export-csv -path C:\Scripts\FBNotificationListCurrentMembers.csv -NoTypeInformation