Clear-Host

#$remoteUser = Read-Host "Enter the remote username"
    #$remotePassword = Read-Host "Enter the remote password" -AsSecureString
$remoteUser = "flushingsavings\bchuc-da"
    $remotePassword = ConvertTo-SecureString 'jh$Z4E6wF5+&28*' -AsPlainText -Force
$csvPath = "C:\Scripts\OutputFiles\PSDrive Copy-Item.csv"
    $computers = Import-Csv -Path $csvPath
Remove-PSDrive -Name "Z"

<#===================================================================================#>

while ($true) {
       foreach ($row in $computers) {
            
            # Prompt for parameters
            $localFile = "C:\TEMP\ZipReader0.exe"
            #$remoteComputer = Read-Host "Enter the remote computer name or IP address"
            #$remoteComputer = "10.111.16.124"
            $remoteComputer = $row.ComputerName  # Change 'ComputerName' to your actual column name
            $remoteDirectory = "C$\Users\Public\Desktop"

            <#===================================================================================#>

            # Build UNC path to remote share (default to C$)
            $remotePath = "\\$remoteComputer\$remoteDirectory"

            # Create credential object for PS drive mapping
            $cred = New-Object System.Management.Automation.PSCredential($remoteUser, $remotePassword)
            if (Test-Path "\\$remoteComputer\C$"){
            New-PSDrive -Name "Z" -PSProvider FileSystem -Root $remotePath -Credential $cred -ErrorAction Stop

            # Copy file to remote share
            Copy-Item -Path $localFile -Destination "Z:\" -Force

            # Remove mapped drive
            Remove-PSDrive -Name "Z"

            }
            else {
                Write-Output "Cannot access $remoteComputer\C$"
            }

            # Optionally, use PsExec for anything further on the remote machine,
            # like invoking a script:
            # & "C:\Path\To\PSTools\PsExec.exe" \\$remoteComputer -u $remoteUser -p (ConvertFrom-SecureString $remotePassword -AsPlainText) cmd.exe /c "dir C:\Folder"
        
            # Read CSV file and loop through each item
            $remoteComputer = $row.ComputerName  # Change 'ComputerName' to your actual column name
            Write-Host "$remoteComputer"
            # ...existing code for mapping drive, copying file, etc. can be placed here if needed...    
        
        }
    $input = Read-Host "Do you want to run again? (true/false)"
    if ($input -eq "false") {
        Write-Host "Exiting the loop."
        break
    }

}