
Get-ADUser -SearchBase "OU=FSB,DC=flushingsavings,DC=com" -Filter * -Properties * `
|select name, samaccountname, Description, HomePhone, ipPhone, Manager, MobilePhone, OfficePhone ` 
#|select name,samaccountname,Description,PasswordExpired,@{name=”MemberOf”;expression={$_.memberof -join “;”}},@{Name='LastLogon';Expression={[DateTime]::FromFileTime($_.LastLogon)}},PasswordLastSet `
|sort-object –property name |Export-CSV C:\Scripts\OutputFiles\AllUsers.csv

#Exports a list of ALL Users with select properties to AllUser.csv for Audit Purposes


<#
Get-ADUser -SearchBase "OU=FSB,DC=flushingsavings,DC=com" `
    -LDAPFilter "(&(!employeeID=*)(!SamAccountName=*Appointment*))" -Properties * `
| Select-Object Name, SamAccountName, employeeID `
| Sort-Object -Property Name `
| Export-Csv C:\Scripts\OutputFiles\Users_NoEmployeeID.csv -NoTypeInformation
#>

<#
$SearchBases = @(
    "OU=FSB,DC=flushingsavings,DC=com",
    "DC=flushingsavings,DC=com"
)

$SearchBases |
    ForEach-Object {
        Get-ADUser -SearchBase $_ `
            -LDAPFilter "(!employeeID=*)" -Properties employeeID
    } |
    Where-Object { $_.DistinguishedName -notlike "*OU=ServiceAccounts,*" } |
    Select-Object Name, SamAccountName, EmailAddress, UserPrincipalName, employeeID |
    Sort-Object -Property Name |
    Export-Csv C:\Scripts\OutputFiles\Users_NoEmployeeID.csv -NoTypeInformation
    #Exports All Users 
#>

<#
Get-ADGroup -SearchBase "OU=FSB,DC=flushingsavings,DC=com" -Filter * `
| Where-Object { $_.SamAccountName -like "*#*" } `
| Select-Object Name, SamAccountName, UserPrincipalName `
| Sort-Object -Property Name `
| Export-CSV C:\Scripts\OutputFiles\HashtagGroups.csv -NoTypeInformation
#Finds All AD Groups with a # in the SamAccountName and exports to HashtagGroups.csv
#>