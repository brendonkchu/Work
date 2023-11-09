clear

$csvfile="C:\Scripts\Test.csv"
Write-Host "Reading file" $csvfile
$csv = import-csv $csvfile -UseCulture 

foreach($line in $csv){ 
    $line
    $line.NAME
    $line.RESOURCEGROUP

    Add-Content C:\Scripts\test.txt "$VM = Get-AzVM -ResourceGroupName $line.RESOURCEGROUP -Name $line.NAME"

    Add-Content C:\Scripts\test.txt "$VM, $line.NAME, $line.RESOURCEGROUP"

    Add-Content C:\Scripts\test.txt "Stop-AzVM -ResourceGroupName $line.RESOURCEGROUP -Name $line.NAME -Force"

    Add-Content C:\Scripts\test.txt "Update-AzVM -VM $VM -ResourceGroupName $line.RESOURCEGROUP -EncryptionAtHost $true"

    Add-Content C:\Scripts\test.txt "Start-AzVM -ResourceGroupName $line.RESOURCEGROUP -Name $line.NAME"
} 

<#
$ResourceGroupName = "AVD-IT-RG"
$VMName = "AVDITDev-0"

$VM = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VMName

Stop-AzVM -ResourceGroupName $ResourceGroupName -Name $VMName -Force

Update-AzVM -VM $VM -ResourceGroupName $ResourceGroupName -EncryptionAtHost $true

Start-AzVM -ResourceGroupName $ResourceGroupName -Name $VMName
#>