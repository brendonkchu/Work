#Select desired Timezone and press OK to set. 

$tz = Get-TimeZone -ListAvailable |Out-Gridview -Outputmode Single

Set-TimeZone -ID $tz.Id