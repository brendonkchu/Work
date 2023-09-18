Write-Host "Lockedout:"
Search-ADAccount -Lockedout | FT Name, SamAccountName
Write-Host "ExpiredPassword:"
Search-ADAccount -PasswordExpired | FT Name, SamAccountName

Write-Host "Which account would you like to unlock?"
$User = Read-Host

If($User)
{unlock-adaccount -identity $User
Write-Host "$User has been unlocked"}

else {Break}