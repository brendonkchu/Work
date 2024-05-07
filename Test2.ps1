$lockedFolder="\\avdfslogix0001.file.core.windows.net\userprofiles001\gbuitrago_S-1-5-21-796845957-823518204-725345543-14825" 
Get-Process | % {
  $processVar = $_
  $_.Modules | %{ 
    if($_.FileName -like "$lockedFolder*"){
        $processVar.Name + " PID:" + $processVar.id + " FullName: " + $_.FileName 
    }
  }
}bkoo