Get-ADUser bchuc #|Export-CSV C:\Scripts\Test.csv
Get-ADUser -Filter "SamAccountName -eq 'bchuc'" #| Select-Object SamAccountName