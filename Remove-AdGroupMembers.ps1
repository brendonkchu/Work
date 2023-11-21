# Start transcript
Start-Transcript -Path C:\Scripts\OutputFiles\Remove-ADUsers.log -Append

# Import AD Module
Import-Module ActiveDirectory

# Import the data from CSV file and assign it to variable
$Users = Import-Csv "C:\Scripts\OutputFiles\Remove-ADUsersToGroup.csv"

# Specify target group where the users will be removed from
# You can add the distinguishedName of the group. For example: CN=Pilot,OU=Groups,OU=Company,DC=exoip,DC=local
$Group = "AzureFiles-Marcus Public" 

foreach ($User in $Users) {
    # Retrieve UPN
    $UPN = $User.SamAccountName

    # Retrieve UPN related SamAccountName
    $ADUser = Get-ADUser -Filter "SamAccountName -eq '$UPN'" | Select-Object SamAccountName
    
    # User from CSV not in AD
    if ($ADUser -eq $null) {
        Write-Host "$UPN does not exist in AD" -ForegroundColor Red
    }
    else {
        # Retrieve AD user group membership
        #$ExistingGroups = Get-ADPrincipalGroupMembership $ADUser.SamAccountName | Select-Object Name
        $ExistingGroups = Get-ADUser bchuc -Properties MemberOf | Select-Object -ExpandProperty MemberOf | Get-ADGroup | Select-Object Name


        # User member of group
        if ($ExistingGroups.Name -eq $Group) {

            # Remove user from group. The WhatIf statment outputs the changes but doens't execute
            Remove-ADGroupMember -Identity $Group -Members $ADUser.SamAccountName -Confirm:$false #-WhatIf
            Write-Host "Removed $UPN from $Group" -ForeGroundColor Green
        }
        else {
            # User not member of group
            Write-Host "$UPN does not exist in $Group" -ForeGroundColor Yellow
        }
    }
}
Stop-Transcript