#This looks through a text file of First Name and Last Names to find the SamAccountName of a user

clear
$users = Get-Content 'C:\Scripts\OutputFiles\DisplayNames.txt'
$Results = ForEach ($user in $users) {
    $sam = Get-ADUser -Filter "Name -eq '$user'" -Properties Name, SamAccountName
    if ($sam) {
        $sam | Select-Object Name, SamAccountName
    } else {
        New-Object PSObject -Property @{
            Name = $user
            SamAccountName = "Not found in AD"
        }
    }
}
#Appends at the end, all users who have Not Found in AD and does search using Surname instead
$ResultsNotFound = ForEach ($NotFound in $Results){ 
   if ($NotFound.SamAccountName -contains "Not Found in AD") {
      $pos = $NotFound.Name.IndexOf(", ")
      $lastname = $NotFound.Name.Substring(0, $pos)
      $sam = Get-ADUser -Filter "Surname -eq '$lastname'" -Properties Name, SamAccountName
      $sam | Select-Object Name, SamAccountName
   }
}
$Results | Export-Csv -Path C:\Scripts\OutputFiles\output.csv -NoTypeInformation
$ResultsNotFound | Export-Csv -Path C:\Scripts\OutputFiles\output2.csv -NoTypeInformation
