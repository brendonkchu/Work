#This Script sends a count of all Users (both people and bots) 

$root_ou = "ou=RXR Plaza,ou=FSB,dc=flushingsavings,dc=com"
$User = get-aduser -filter * -SearchBase $root_ou -SearchScope Subtree | Select @{Name="OU";Expression={$_.distinguishedName -match "cn=.*?,OU=(?<OU>.*)" | Out-Null;$Matches.OU}}
$User | Group -Property OU | Select Name,Count #| Export-csv C:\Scripts\Test2.csv