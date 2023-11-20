clear

$PCNames = New-Object -TypeName System.Collections.ArrayList
$PCNames.add("ITNOTEBOOK002") #Adds String to ArrayList

#$env:COMPUTERNAME #Prints PC Name for Testing

if ($env:COMPUTERNAME -contains $PCNames){ #If your PCNAME is in the List
    mkdir C:\Temp\PSTEST\
}
else{
    Write-Host("PC NOT ON LIST") 
}