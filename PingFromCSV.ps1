<#

.SYNOPSIS
  Powershell script to ping all IP addresseses in a CSV file.
  
.DESCRIPTION
  This PowerShell script reads a CSV file and pings all the IP addresses listed in the IPAddress column.
  
.PARAMETER <csvfile>
   File name and path of the CSV file to read.
 
.NOTES
  Version:        1.0
  Author:         Open Tech Guides
  Creation Date:  12-Jan-2017
 
.LINK
    www.opentechguides.com
    
.EXAMPLE
  Ping-IPList c:\IPaddressList.csv
   
#>

$csvfile= 'C:\Scripts\OutputFiles\IPaddressList.csv'

Param(
  [Parameter(Mandatory=$true, position=0)][string]$csvfile
)

$ColumnHeader = "IPaddress"

Write-Host "Reading file" $csvfile
$ipaddresses = import-csv $csvfile | select-object $ColumnHeader

Write-Host "Started Pinging.."
foreach( $ip in $ipaddresses) {
    if (test-connection $ip.("IPAddress") -count 1 -quiet) {
        write-host $ip.("IPAddress") "Ping succeeded." -foreground green

    } else {
         write-host $ip.("IPAddress") "Ping failed." -foreground red
    }
    
}

Write-Host "Pinging Completed."
