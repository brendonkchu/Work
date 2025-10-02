<#

.SYNOPSIS

    This script will establish RDP session to a computer with a local admin account

 

.DISCLAIMER

     IF THIS CODE AND INFORMATION IS MODIFIED, THE ENTIRE RISK OF USE OR RESULTS IN

     CONNECTION WITH THE USE OF THIS CODE AND INFORMATION REMAINS WITH THE USER. 

 

   

.DESCRIPTION

 

   Script will do following:   

        1. Script will propt you to enter a computer name that you whant to access using RDP session

        2. Script will copy LAPS saved password from a computer object in Active Directory and display it in the bottom of your screen highlighted in green

        3. It will open a RDP session prompt to a computer with a local admin account

        4. Please copy a password in the prompt windos and you are in.

        5. Force change of the LAPS password expiration attribute to 1 hour after a RDP session has started

        6. Write an Info AD attribute on the computer with the Last AD administrator account name login attempt and the time of login

 

.NOTES

      

    - Requires the PowerShell modules:  

      ActiveDirectory  

        

      [X] Active Directory module for Windows PowerShell Installed

 

   -  You must open a powershell script as a domain admin

    

   -  With RDP 10, the Session Zoom option scales the session display on the client machine.

      Simply navigate to the system menu left upper corner in your remote session window and select a zoom level under “Zoom”.

 

.CHANGES

    

 Created by Simon Zhitelzeyf 8/24/2018

Updated: 8/29/2020       - Force change of the LAPS password expiration attributeto 1 hour after a RDP session has started

Last Updated: 11/16/2020 - Set Last AD account login attempt

 


 https://www.powershellgallery.com/packages/MrAToolbox/1.2.0/Content/Reset-LapsAdministratorPassword.ps1

 

------------MSTSC set to full screen on second monitor----NOT IMPLEMENTED--------------

https://superuser.com/questions/1207641/mstsc-set-to-full-screen-on-second-monitor

 

$RDPFile=$Args[0]

 

Add-Type -AssemblyName System.Windows.Forms

$Screens = [System.Windows.Forms.Screen]::AllScreens

# Look for a non-primary screen - @todo - what if I have three screens?

$Screen = $Screens | where-object {$_.Primary -eq $FALSE}[0]

# If we dont have a screen which is not a Primary then use the primary   

if ($Screen -eq $Null) {

  $Screen = $Screens | where-object {$_.Primary -eq $TRUE}[0]

}

# Now connect using an RDP file - but set the width and height and full screen mode

mstsc.exe E:\cmds\RDP\$($RDPFILE).RDP /f /w:$($Screen.Bounds.Width) /h:$($Screen.Bounds.Height)

 

 

---------------------------------------------------------------------------------

 

 

 

 

#>

 

 

# ---------------------Find username of the user running this script, variable of $pid represents the current powershell instance-------------------------------------------

$PSDefaultParameterValues = @{"*-AD*:Server"='RPV-DC1.flushingsavings.com'}

$CredFileA= "C:\Scripts\Credent.txt"

        $FileExists = Test-Path $CredFileA

      

        if  ($FileExists -eq $false) {

            Write-Host 'Credential file not found. Please enter user password:' -ForegroundColor DarkYellow

      

       Read-Host -AsSecureString | ConvertFrom-SecureString | Out-File $CredFileA

          }

 

$cred= (get-process -IncludeUserName  |?{$_.Id -eq $pid}) |select username -ExpandProperty username

$UserpassA = get-content $CredFileA | convertto-securestring

$CredentialsA = New-Object System.Management.Automation.PSCredential $cred,$UserpassA

 

#-------------------------------------------------------------------END---------------------------------------------------------

 

$server=read-host Please enter a server name

$compnm = (Get-ADComputer $server).DNSHostName

Test-Connection $compnm  -Count 1

 

#Retrieve LASP password from AD computer attribute 'ms-Mcs-AdmPwd'

 

$pass=(Get-ADComputer -Properties * $server).'ms-Mcs-AdmPwd'

$LAPSExp=(Get-ADComputer -Properties * $server).'ms-Mcs-AdmPwdExpirationTime'

$LapsPassExpAttr = 'ms-Mcs-AdmPwdExpirationTime'

 

$lastLogonADUser=(get-aduser $env:username -Properties *).name

$lastLogonDate=Get-Date

$Info="Last login attempt from the script Get_Local_PW on the computer " + $compnm + " performed by " + $lastLogonADUser+ " on " + $lastLogonDate

#$Session = New-PSSession -ComputerName $compnm -Credential $CredentialsA

 

#By Changing LAPS password expiration attribute we are triggering a LASP password reset

 

Set-ADComputer -Identity $server -Replace @{"$LapsPassExpAttr" = $(Get-Date).Addhours(1).Ticks} -Credential $CredentialsA

$NewLASPExp=[DateTime]$((Get-ADcomputer -Identity $server -Properties $LapsPassExpAttr).$LapsPassExpAttr)

Write-host "The LAPS password expiration attribute in AD for the server $compnm has been set to a new time $NewLASPExp" -ForegroundColor Green

Set-ADComputer -Identity $server -Replace @{"info"= $Info} -Credential $CredentialsA

 

 

$User=$server+"\mmouse"

write-host "Copy password from here" -ForegroundColor Gray -NoNewline

write-host " $pass " -ForegroundColor Green -NoNewline

write-host "and past to the login screen" -ForegroundColor Gray