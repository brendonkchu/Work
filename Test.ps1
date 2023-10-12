Get-ChildItem -Path "" <#-Recurse#> -Directory -Force -ErrorAction SilentlyContinue | Select-Object FullName
[System.IO.File]::Exists($path)

$filestowatch=get-content C:\H\files-to-watch.txt

$adminFiles=dir C:\H\admin\admin -recurse | ? { $fn=$_.FullName; ($filestowatch | % {$fn.contains($_)}) -contains $True}

$userFiles=dir C:\H\user\user -recurse | ? { $fn=$_.FullName; ($filestowatch | % {$fn.contains($_)}) -contains $True}

foreach($userfile in $userFiles)
{

      $exactadminfile= $adminfiles | ? {$_.Name -eq $userfile.Name} |Select -First 1
      $filetext1=[System.IO.File]::ReadAllText($exactadminfile.FullName)
      $filetext2=[System.IO.File]::ReadAllText($userfile.FullName)
      $equal = $filetext1 -ceq $filetext2 # case sensitive comparison

      if ($equal) { 
        Write-Host "Checking == : " $userfile.FullName 
        continue; 
      } 

      if($exactadminfile.LastWriteTime -gt $userfile.LastWriteTime)
      {
         Write-Host "Checking != : " $userfile.FullName " >> user"
         Copy-Item -Path $exactadminfile.FullName -Destination $userfile.FullName -Force
       }
       else
       {
          Write-Host "Checking != : " $userfile.FullName " >> admin"
          Copy-Item -Path $userfile.FullName -Destination $exactadminfile.FullName -Force
       }
