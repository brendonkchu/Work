#Exports a CSV of an AD Group's Members with listed UPNs

$SecurityGroup = "BCS_AllowedZoom" #CHANGE NAME HERE

Get-ADGroupMember -identity $SecurityGroup |get-aduser|
 select name,samaccountname,userprincipalname | 
 Export-csv -path C:\Scripts\ADGroupMembers.csv -NoTypeInformation