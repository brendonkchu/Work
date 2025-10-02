#*******************
$MigrationType= 'Express' #Virtual, HNS, Core or Express
$WebServer = 'https://synweb136p.jha-sys.com' #FQDN (including 'jha-sys.com domain suffix) for existing Express clients or migrations to Express
$AUStagingServer = 'synweb136p.jha-sys.com'


#------------------------------------------------------
$logFile = "$env:Temp\CutoverScript $(Get-Date -Format "MM-dd-yyyy Hmm").txt"


#Copies the settings files for Auto Update staging server
Add-Content -Path $logFile -Value 'Stopping Services and Copying Settings Files'

$service = Get-Service -DisplayName "Synergy Automated Update Service" -ErrorAction SilentlyContinue
if ($service.Length -gt 0) { Stop-Service -DisplayName "Synergy Automated Update Service" }

#Checks for existing AutoUpdate ClientConfig.xml settings file 

if ($MigrationType -eq "HNS" -or $MigrationType -eq "Virtual"-or $MigrationType -eq "Express") #File is not updated for a core migration
{
    if (-not (Test-Path "c:\ProgramData\JHA\Synergy\AutoUpdate\ClientConfig.xml")) #File does not exist
    {
     [xml]$xmlNodes = "<?xml version='1.0' encoding='UTF-8'?><ClientConfiguration><PrimaryStagingServer>$AUStagingServer</PrimaryStagingServer><CheckForDownloadsInterval>5</CheckForDownloadsInterval><FileDownloadInterval>5</FileDownloadInterval>#<FileChunkDownloadInterval>5</FileChunkDownloadInterval>#<FileChunkHighPriorityDownloadInterval>5</FileChunkHighPriorityDownloadInterval><RequestTimeout>0</RequestTimeout><FileChunkSizeKB>100</FileChunkSizeKB></ClientConfiguration>"
     $xmlNodes.Save("$env:SystemDrive\ProgramData\JHA\Synergy\AutoUpdate\ClientConfig.xml")
     Add-Content -Path $logFile -Value 'AutoUpdate config file created'
    }
    else #File exists so change only the name of the staging server
    {
     [xml]$xmlNodesExisting = Get-Content "c:\ProgramData\JHA\Synergy\AutoUpdate\ClientConfig.xml"
     $xmlNodesExisting.ClientConfiguration.PrimaryStagingServer = $AUStagingServer
     $xmlNodesExisting.Save("c:\ProgramData\JHA\Synergy\AutoUpdate\ClientConfig.xml")
     Add-Content -Path $logFile -Value 'AutoUpdate config file updated'
    }
    
}

$userFolders = Get-ChildItem -Path "$env:SystemDrive\Users" -Directory #Get all user profiles for the workstation
foreach ($folder in $userFolders)
{
  $folderpath = $folder.FullName
  Add-Content -Path $logFile -Value "Performing file operations for user: $folder"

 
  $desktopClientApplicableInstances = "Synergy Client","Synergy Reports Administration","Synergy System Administration","Synergy Capture"
  foreach ($clientInstanceFolder in $desktopClientApplicableInstances) {
    if (-not (Test-Path "$folderpath\AppData\Local\Jack Henry & Associates, Inc\$clientInstanceFolder"))
    {
      New-Item -Path "$folderpath\AppData\Local\Jack Henry & Associates, Inc\" -Name $clientInstanceFolder -ItemType "directory" -Verbose
    }
    if (-not (Test-Path "$folderpath\AppData\Local\Jack Henry & Associates, Inc\$clientInstanceFolder\PreviousAuthData.dat"))
    {
      [xml]$xmlNodes = "<PreviousAuthData xmlns=""Synergy"" xmlns:i=""http://www.w3.org/2001/XMLSchema-instance""></OrgName><Server>$webServer</Server></PreviousAuthData>"
      $xmlNodes.Save("$folderpath\AppData\Local\Jack Henry & Associates, Inc\$clientInstanceFolder\PreviousAuthData.dat")
      Add-Content -Path $logFile -Value "PreviousAuthData.dat file created for the $clientInstanceFolder for user: $folder."
    }

    else
    {
      [xml]$xmlNodesExisting = Get-Content "$folderpath\AppData\Local\Jack Henry & Associates, Inc\$clientInstanceFolder\PreviousAuthData.dat"
      $xmlSelect = $xmlNodesExisting.SelectSingleNode("PreviousAuthData")
      if($MigrationType -eq "HNS" -or $MigrationType -eq "Virtual" -or $MigrationType -eq "Express") #Update server name for HNS, Virtual and Express Migration
        {
          $xmlNodesExisting.PreviousAuthData.Server = $webServer
          if ($xmlNodesExisting.PreviousAuthData.OrgName -ne $newOrgNumber)
		{
		$xmlNodesExisting.PreviousAuthData.OrgName = $NewOrgNumber
		}	
        }
     elseif ($MigrationType -eq 'Core')
        {
          $xmlNodesExisting.PreviousAuthData.OrgName = $NewOrgNumber
         
          
    }
      $xmlNodesExisting.Save("$folderpath\AppData\Local\Jack Henry & Associates, Inc\$clientInstanceFolder\PreviousAuthData.dat")
      Add-Content -Path $logFile -Value "PreviousAuthData.dat file updated for $clientInstanceFolder for user: $folder"
    }
  }
}


$service = Get-Service -DisplayName "Synergy Automated Update Service" -ErrorAction SilentlyContinue
if ($service.Length -gt 0) { Start-Service -DisplayName "Synergy Automated Update Service" }


$logtime = (Get-Date -Format "MM-dd-yyyy H:mm")
Add-Content -Path $logFile -Value "Script Completed at $logtime"