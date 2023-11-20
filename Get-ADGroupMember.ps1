#Exports a CSV of an AD Group's Members with listed UPNs

$SecurityGroup = "SSO_AdobeAcrobatPro" #CHANGE NAME HERE

Get-ADGroupMember -identity $SecurityGroup |get-aduser|
 select name,samaccountname,userprincipalname | 
 Export-csv -path C:\Scripts\OutputFiles\ADGroupMembers.csv -NoTypeInformation