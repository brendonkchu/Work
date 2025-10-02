$RemoteComputerLocalPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe"
Invoke-Command -ComputerName "$computername" -ScriptBlock { (Get-Item (Get-ItemProperty $Using:RemoteComputerLocalPath).'(Default)').VersionInfo 
}


$computerList = New-Object System.Collections.ArrayList
$computerList.Add("itnotebook001")
$computerList.Add("avdrc-9")
$computerList.Add("avdrc-8")
$computerList.Add("avddo-5")
$computerList.Add("avdcl-5")
$computerList.Add("avdrs-1")
$computerList.Add("avdmis-4")
$computerList.Add("avdsc-6")
$computerList.Add("avdbd-2")
$computerList.Add("avdbd-3")
$computerList.Add("10.111.14.65")
$computerList.Add("avdbsp-0")
# powershell loop thru array
ForEach ($computername in $computerList) {
  Invoke-Command -ComputerName $computername -ScriptBlock { (Get-Item (Get-ItemProperty $Using:RemoteComputerLocalPath).'(Default)').VersionInfo 
  }
}