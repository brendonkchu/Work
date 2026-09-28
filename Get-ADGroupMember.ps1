#Exports a CSV of an AD Group's Members with listed UPNs

$SecurityGroup = "AzureAVD-LoanServicing" #CHANGE NAME HERE


<#
Function Get-ADNestedGroups {  
    param($Members)  
  
    foreach ($member in $Members) {  
        $out = Get-ADGroup -filter "DistinguishedName -eq '$member'" -properties members  
        $out | Select-Object Name  
        Get-ADNestedGroups -Members $out.Members  
    }  
}  
  
$members = (Get-ADGroup -Identity $SecurityGroup -Properties Members).Members  
Get-ADNestedGroups $members 
#>

#===========================================================


Get-ADGroupMember -identity $SecurityGroup -Recursive| get-aduser |
select name,samaccountname,userprincipalname |
Export-csv -path C:\Scripts\OutputFiles\ADGroupMembers.csv -NoTypeInformation
 

 #==========================================================

<#
 # Retrieve members of the group, including members from nested groups
$members = Get-ADGroupMember -Identity $SecurityGroup -Recursive

# Display member names
$members | select name,samaccountname,userprincipalname | 
 Export-csv -path C:\Scripts\OutputFiles\ADGroupMembers.csv -NoTypeInformation
 #>