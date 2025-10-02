$rg = "*"
$hostPool = "*"
$outFile = "C:\Scripts\OutputFiles\AllAVDHostPools.csv"
$header = "Name,Status,assignedUser,subscription,resourceGroup,sku"
Out-File -FilePath $outfile -Encoding utf8 -InputObject $header
$output = ""
$sessionHosts = (Get-AzWvdSessionHost -ResourceGroupName $rg -HostPoolName $hostPool) # .ResourceId
$sessionHosts | ForEach-Object {
    $vmName = ($_.ResourceId).Split("/")[-1]
    $vmObj = (Get-AzVM -Name $vmName)
    $vmStatus = (Get-AzVM -Name $vmName -Status).PowerState
    $vmRG = $vmObj.ResourceGroupName
    $vmSubscription = $vmObj.Id.Split("/")[2]
    $vmSize = $vmObj.HardwareProfile.VmSize
    $vmAssignedUser = $_.AssignedUser
    $output = "$vmName,$vmStatus,$vmAssignedUser,$vmSubscription,$vmRG,$vmSize"
    Out-File -FilePath $outfile -Encoding utf8 -InputObject $output -Append
}