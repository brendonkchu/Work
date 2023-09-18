#Enter a path to your import CSV file
$WXCUsers = Import-csv C:\AP\WXCusers.csv

foreach ($User in $WXCUsers)
{

       $Username    = $User.username
       $Password    = $User.password
       $Firstname   = $User.firstname
       $Lastname    = $User.lastname
       $OU           = $User.ou

       #Check if the user account already exists in AD
       if (Get-ADUser -F {SamAccountName -eq $Username})
       {
               #If user does exist, output a warning message
               Write-Warning "A user account $Username has already exist in Active Directory."
       }
       else
       {
              #If a user does not exist then create a new user account
          
        #Account will be created in the OU listed in the $OU variable in the CSV file; don’t forget to change the domain name in the"-UserPrincipalName" variable
              New-ADUser `
            -SamAccountName $Username `
            -UserPrincipalName "$Username@flushingbank.com" `
            -Name "$Firstname $Lastname" `
            -GivenName $Firstname `
            -Surname $Lastname `
            -Enabled $True `
            -ChangePasswordAtLogon $False `
            -DisplayName "$Lastname, $Firstname" `
            -emailaddress "$Username@flushingbank.com" `
            -Path $OU `
            -AccountPassword (convertto-securestring $Password -AsPlainText -Force)

       }
}