Get-ADUser bchuc #|Export-CSV C:\Scripts\Test.csv
Get-ADUser -Filter "SamAccountName -eq 'dobrien'" -Properties * ` #| Select-Object SamAccountNamepinf BCK