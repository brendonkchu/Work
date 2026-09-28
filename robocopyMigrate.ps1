Enable-PSRemoting -Force

<#
.SYNOPSIS
    Migrates user data remotely and unattended.
.DESCRIPTION
    Copies user Documents, Desktop, and Google Chrome bookmarks remotely
    between specified computers, and generates a software inventory.
#>

param(
    [Parameter(Mandatory=$true)] [string]$SourceComputer,
    [Parameter(Mandatory=$true)] [string]$DestinationComputer,
    [Parameter(Mandatory=$true)] [string]$Username,
    [Parameter(Mandatory=$true)] [string]$BackupPath
)

# Enable remoting if not already enabled
Invoke-Command -ComputerName $SourceComputer -ScriptBlock {
    Enable-PSRemoting -Force
} -ErrorAction SilentlyContinue

# Define paths
$UserProfile = "\\$SourceComputer\C$\Users\$Username"
$DestProfile = "\\$DestinationComputer\C$\Users\$Username"
$ChromeBookmarksPath = "$UserProfile\AppData\Local\Google\Chrome\User Data\Default\Bookmarks"

# Create backup folder structure
New-Item -ItemType Directory -Force -Path "$BackupPath\$Username\Documents" | Out-Null
New-Item -ItemType Directory -Force -Path "$BackupPath\$Username\Desktop" | Out-Null
New-Item -ItemType Directory -Force -Path "$BackupPath\$Username\Bookmarks" | Out-Null
New-Item -ItemType Directory -Force -Path "$BackupPath\$Username\SoftwareInventory" | Out-Null

# Copy Documents and Desktop folders
Write-Output "Copying Documents and Desktop folders..."
robocopy "$UserProfile\Documents" "$BackupPath\$Username\Documents" /E /COPY:DAT /R:1 /W:5 /NP /NFL /NDL
robocopy "$UserProfile\Desktop" "$BackupPath\$Username\Desktop" /E /COPY:DAT /R:1 /W:5 /NP /NFL /NDL

# Copy Chrome Bookmarks (Bookmarks and Bookmarks.bak)
Write-Output "Copying Chrome Bookmarks..."
Copy-Item "\\$SourceComputer\C$\Users\$Username\AppData\Local\Google\Chrome\User Data\Default\Bookmarks*" `
  -Destination "$BackupPath\$Username\Bookmarks" -Force -ErrorAction SilentlyContinue

# Export installed software list
Write-Output "Exporting installed software list..."
Invoke-Command -ComputerName $SourceComputer -ScriptBlock {
    $apps = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |
        Select-Object DisplayName, DisplayVersion, Publisher, InstallDate
    $apps | Where-Object { $_.DisplayName } | Sort-Object DisplayName |
        Export-Csv "$using:BackupPath\$using:Username\SoftwareInventory\InstalledSoftware.csv" -NoTypeInformation
}

# Restore user data to destination if available
Write-Output "Restoring user data to destination..."
robocopy "$BackupPath\$Username\Documents" "$DestProfile\Documents" /E /COPY:DAT /R:1 /W:5 /NP /NFL /NDL
robocopy "$BackupPath\$Username\Desktop" "$DestProfile\Desktop" /E /COPY:DAT /R:1 /W:5 /NP /NFL /NDL
Copy-Item "$BackupPath\$Username\Bookmarks\*" "\\$DestinationComputer\C$\Users\$Username\AppData\Local\Google\Chrome\User Data\Default\" -Force

Write-Output "Migration completed for $Username"
