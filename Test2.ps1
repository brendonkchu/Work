clear
Get-SharingPolicy | Where-Object { $_.Domains -like '*CalendarSharing*' }