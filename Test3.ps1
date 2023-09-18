#Import-Module ActiveDirectory
Get-ADUser -Filter * -SearchBase "OU=FSB,DC=flushingsavings,DC=com" -properties * `
| select CN, SamAccountName, Description, PasswordExpired, @{name=”MemberOf”;expression={$_.memberof -join “;”}}, LastLogonDate, PasswordLastSet `
<# @{name=”MemberOf”;expression={$_.memberof -join “;”}} Splits the output of MemberOf as multiple objects and joins it with the a conntecting semicolon. 
This is due to the MemberOf property being a object with multiple values, so it breaks it down from the coloumn. Then returns all the membership group Distinguished names. #>
|Export-CSV C:\Scripts\Test.csv 