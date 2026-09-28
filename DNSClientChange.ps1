#Requires -RunAsAdministrator

#netsh interface ip set dns name="Ethernet" static 192.168.100.8
#netsh interface ip set dns name="Ethernet" static 8.8.8.8 index=2

# Set primary and secondary DNS Server variables
$PrimaryDNS = '192.168.100.8'
$SecondaryDNS = '8.8.8.8'

# Get all active adapters (Status -eq 'Up')
$adapters = Get-NetAdapter | Where-Object {$_.Status -eq 'Up'}

# Loop through each adapter and configure the new DNS servers
foreach ($adapter in $adapters) {
    Write-Host ("Configuring DNS for adapter '{0}' to {1} and {2}" -f $adapter.InterfaceAlias, $PrimaryDNS, $SecondaryDNS) -ForegroundColor Green
    try {
        Set-DnsClientServerAddress -InterfaceIndex $adapter.InterfaceIndex -ServerAddresses ($PrimaryDNS, $SecondaryDNS) -ErrorAction Stop
    } catch {
        Write-Warning ("Error changing DNS on {0}: {1}" -f $adapter.InterfaceAlias, $_.Exception.Message)
    }
}

# (Optional) Verify changes
Write-Host "Verification:" -ForegroundColor Cyan
Get-NetAdapter | Where-Object {$_.Status -eq 'Up'} | ForEach-Object {
    Write-Host ("Adapter '{0}' DNS Servers: {1}" -f $_.InterfaceAlias, ((Get-DnsClientServerAddress -InterfaceIndex $_.InterfaceIndex).ServerAddresses -join ', '))
}
