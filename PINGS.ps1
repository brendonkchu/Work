cls
$ip = Get-Content -Path C:\TEMP\hope.txt

foreach ( $ip1 in $ip ) { $ip2 = ping $ip1

if ( $ip2 -imatch "(100% loss)")

 { Write-Host $ip1 " FALSE" }

else
{ Write-Host $ip1 "TRUE "}
}
