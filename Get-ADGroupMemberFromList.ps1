#Exports CSVs of all AD Group's Members within an Imported CSV list of Groups

$SecurityGroup = "AzureAVD" #CHANGE NAME HERE
$AzureAVDAll = Import-Csv "C:\Scripts\AzureAVD-ALLGROUPS.csv"

ForEach($GroupName in $AzureAVDAll)
{
$GroupName = $GroupName.Group
Write-Host $SecurityGroup-$GroupName "Exporting..."
Get-ADGroupMember -identity "$SecurityGroup-$GroupName" |get-aduser|
 select name,samaccountname,userprincipalname | 
 Export-csv -path C:\Scripts\ADGroupMembers+$GroupName.csv -NoTypeInformation
 }