# Start transcript
Start-Transcript -Path C:\Scripts\OutputFiles\Add-ADUsers.log #-Append

# Import AD Module
Import-Module ActiveDirectory

# Import the data from CSV file and assign it to variable
$Users = Import-Csv "C:\Scripts\OutputFiles\Add-ADUsersToGroup.csv"

# Specify target group where the users will be added to
# You can add the distinguishedName of the group. For example: CN=Pilot,OU=Groups,OU=Company,DC=exoip,DC=local
$Group = "Personal Files Migrated to OneDrive" 
#$Group = "Intune_OneDriveAllowed"

foreach ($User in $Users) {
    # Retrieve UPN
    $UPN = $User.SamAccountName #Previously set to $User.UserPrincipleName which would reflect in the CSV file Column Header
    
    # Retrieve UPN related SamAccountName
    $ADUser = Get-ADUser -Filter "SamAccountName -eq '$UPN'" | Select-Object SamAccountName

    # User from CSV not in AD
    if ($ADUser -eq $null) {
        Write-Host "$UPN does not exist in AD" -ForegroundColor Red
    }
    else {
        # Retrieve AD user group membership
        #$ExistingGroups = Get-ADPrincipalGroupMembership $ADUser.SamAccountName | Select-Object Name
        $ExistingGroups = Get-ADUser $ADUser.SamAccountName -Properties MemberOf | Select-Object -ExpandProperty MemberOf | Get-ADGroup | Select-Object Name

        # User already member of group
        if ($ExistingGroups.Name -eq $Group) {
            Write-Host "$UPN already exists in $Group" -ForeGroundColor Yellow
        }
        else {
            # Add user to group. The WhatIf statment outputs the changes but doens't execute
            Add-ADGroupMember -Identity $Group -Members $ADUser.SamAccountName #-WhatIf
            Write-Host "Added $UPN to $Group" -ForeGroundColor Green
        }
    }
}
Stop-Transcript