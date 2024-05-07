#Remove-MailboxFolderPermission -Identity apersaud@flushingbank.com:\Calendar -User bchuc@flushingbank.com
#Get-MailboxFolderPermission -Identity apersaud@flushingbank.com:\Calendar -User bchuc@flushingbank.com
Add-MailboxFolderPermission -Identity apersaud@flushingbank.com:\Calendar -User bchuc@flushingbank.com -AccessRights Editor -SharingPermissionFlags Delegate -SendNotificationToUser $true
# https://learn.microsoft.com/en-us/powershell/module/exchange/add-mailboxfolderpermission?view=exchange-psping 