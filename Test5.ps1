# Define the two user names/usernames you want to compare
$user1 = "bchuc"
$user2 = "GAndrade"

# Fetch both user objects
$u1 = Get-ADUser -Identity $user1 -Properties *
$u2 = Get-ADUser -Identity $user2 -Properties *

# Compare attributes and display in a side-by-side grid
Compare-Object -ReferenceObject $u1.PSObject.Properties -DifferenceObject $u2.PSObject.Properties -Property Name, Value | 
    Sort-Object Name | 
    Out-GridView -Title "Comparing Attributes: $user1 vs $user2"
