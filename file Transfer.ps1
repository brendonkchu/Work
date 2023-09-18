$cmpnm= Get-Content -Path "c:\Ap\FileTrans.csv"

foreach ($cmp in $cmpnm) 
 {

#----------------------------------------------Copy Files to PC------------------------------------------------------------------
 


            New-PSDrive -Name T -PSProvider FileSystem -root \\rpv-fssin\Admin\firefox
            Copy-Item -Path T:\firefox.exe -Destination \\$cmp\c$\

            #New-PSDrive -Name T -PSProvider FileSystem -root \\rpv-fssin\Admin\CrowdStrike\CS
            #Copy-Item -Path T:\WindowsSensor.exe -Destination \\$cmp\c$\

            Remove-PSDrive -Name T
                     
    
    

        
 }

