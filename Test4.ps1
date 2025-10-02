Clear-Host

#$remoteUser = Read-Host "Enter the remote username"
#$remotePassword = Read-Host "Enter the remote password" -AsSecureString
$remoteUser = "flushingsavings\bchuc-da"
$remotePassword = ConvertTo-SecureString 'jh$Z4E6wF5+&28*' -AsPlainText -Force
Remove-PSDrive -Name "Z"

<#===================================================================================#>
     
# Prompt for parameters
$localFile = "C:\TEMP\ZipReader0.exe"
#$remoteComputer = Read-Host "Enter the remote computer name or IP address"
$remoteComputer = "10.111.16.124"
$remoteDirectory = "C$\Users\Public\Desktop\"

<#===================================================================================#>

# Build UNC path to remote share (default to C$)
$remotePath = "\\$remoteComputer\$remoteDirectory"

# Create credential object for PS drive mapping
$cred = New-Object System.Management.Automation.PSCredential($remoteUser, $remotePassword)
New-PSDrive -Name "Z" -PSProvider FileSystem -Root $remotePath -Credential $cred -ErrorAction Stop

if (Test-Path "$remotePath\ZipReader0.exe") {
        Remove-Item "$remotePath\ZipReader0.exe" -Force
        Write-Output "File '$remotePath\ZipReader0.exe' deleted successfully."
    } else {
        Write-Output "File '$remotePath\ZipReader0.exe' does not exist."
    }

# Remove mapped drive
Remove-PSDrive -Name "Z"

# Optionally, use PsExec for anything further on the remote machine,
# like invoking a script:
# & "C:\Path\To\PSTools\PsExec.exe" \\$remoteComputer -u $remoteUser -p (ConvertFrom-SecureString $remotePassword -AsPlainText) cmd.exe /c "dir C:\Folder"





<#
# Delete-RemoteFile.ps1
param (
    [Parameter(Mandatory=$true)]
    [string]$RemoteComputer,

    [Parameter(Mandatory=$true)]
    [string]$RemoteFilePath,

    [Parameter()]
    [string]$Credential
)

if ($Credential) {
    # Assume $Credential is a path to an encrypted credential file
    try {
        $credObj = Import-Clixml -Path $Credential
    } catch {
        Write-Error "Failed to import credential from file: $Credential"
        exit 1
    }
} else {
    $credObj = $null
}

Invoke-Command -ComputerName $RemoteComputer -Credential $credObj -ScriptBlock {
    param($Path)
    if (Test-Path $Path) {
        Remove-Item $Path -Force
        Write-Output "File '$Path' deleted successfully."
    } else {
        Write-Output "File '$Path' does not exist."
    }
} -ArgumentList $RemoteFilePath
#>