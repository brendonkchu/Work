#Displays all Security Access information for a Folder and its Subfolders on A Mapped Drive or Local Drive

$FolderPath = Get-ChildItem -Directory -Path "C:\TEMP" -Force 
$Output = @() 
ForEach ($Folder in $FolderPath) { 
    $Acl = Get-Acl -Path $Folder.FullName 
    ForEach ($Access in $Acl.Access) { 
$Properties = [ordered]@{'Folder Name'=$Folder.FullName;'Group/User'=$Access.IdentityReference;'Permissions'=$Access.FileSystemRights;'Inherited'=$Access.IsInherited} 
$Output += New-Object -TypeName PSObject -Property $Properties 
    } 
} 
$Output | Out-GridView