# Import the PsExec module
#Import-Module PsExec

# Get the list of computers from the text file
$computers = Get-Content c:\temp\computers.txt

# Loop through the list of computers
foreach ($computer in $computers) {

    # Copy the MSI file to the remote computer
    C:\Scripts\PsExec.exe \\AVDITDEV-4 -u [flushingsavings]\[bchucda] -p ['w8047Ec*ZC@#v'] -s -i -d -c "copy c:\temp\LVExcelAddInSetup.msi \\$computer\c$\"

    # Run the MSI file on the remote computer
    C:\Scripts\PsExec.exe \\AVDITDEV-4 -u [flushingsavings]\[bchucda] -p ['w8047Ec*ZC@#v'] -s -i -d -c "msiexec /i \\AVDITDEV-4\c$\LVExcelAddInSetup.msi /norestart"
}