Get-ADUser -SearchBase "OU=FSB,DC=flushingsavings,DC=com" -Filter * -Properties * `
|select name, samaccountname, Description, HomePhone, ipPhone, Manager, MobilePhone, OfficePhone ` 
#|select name,samaccountname,Description,PasswordExpired,@{name=”MemberOf”;expression={$_.memberof -join “;”}},@{Name='LastLogon';Expression={[DateTime]::FromFileTime($_.LastLogon)}},PasswordLastSet `
|sort-object –property name |Export-CSV C:\Scripts\Output\AllUsers.csv
#Exports a list of ALL Users with select properties to AllUser.csv for Audit Purposes