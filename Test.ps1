$UserList = Import-CSV C:\Scripts\Add-ADUsersToGroup.csv

ForEach ($u in $UserList) {
    $DP = $u.DisplayName

    Get-ADUser -Filter "DisplayName -eq '$DP'" | Select samAccountName | Export-Csv C:\Scripts\Add-ADUsersToGroupUDP.csv -NoType -Append}