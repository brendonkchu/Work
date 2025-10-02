$computerList = Import-Csv "C:\Scripts\OutputFiles\CopyToPC.csv"
foreach ($computer in $computerList) { 
    
    Write-Host $computer.IPaddress
    Copy-Item -Path "C:\Scripts\robocopyLocal - Copy.bat" -Destination "\\$computer\c$\Temp" -Recurse

}