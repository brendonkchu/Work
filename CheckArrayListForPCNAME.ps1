clear

$PCNames = New-Object -TypeName System.Collections.ArrayList
$PCNames.add("ITNOTEBOOK002") #Adds String to ArrayList
$PCNames.add("FBLT-PF40DLXB") #976
#$PCNames.add("FBLT-PF40DM0R") #977
$PCNames.add("FBLT-PF40DGPB") #979
$PCNames.add("FBLT-PF3W5W1L") #966
$PCNames.add("FBLT-PF40DQZS")
$PCNames.add("FBLT-PF40D5BC")
$PCNames.add("FBLT-PF40DGNY")
$PCNames.add("FBLT-PF40GXYB") #1008
$PCNames.add("FBLT-PF40DGPG") #1007
$PCNames.add("FBLT-PF40HF5C") #1004
$PCNames.add("FBLT-PF40DM02") #1003

#$env:COMPUTERNAME #Prints PC Name for Testing

if ($env:COMPUTERNAME -contains $PCNames){ #If your PCNAME is in the List
    mkdir C:\Temp\PSTEST\
}
else{
    Write-Host("PC NOT ON LIST") 
}