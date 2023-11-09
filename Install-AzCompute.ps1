Remove-Module AzureRM.Profile -Force -ErrorAction SilentlyContinue  # AzureRM causes a conflict with Az modules

if (!(Get-Module -ListAvailable -Name Az.Accounts)) {
  Install-Module -Name Az.Accounts -Repository PSGallery -AllowClobber -Force -Scope CurrentUser  
} 
if (!(Get-Module -ListAvailable -Name Az.KeyVault)) {
  Install-Module -Name Az.KeyVault -Repository PSGallery -AllowClobber -Force -Scope CurrentUser 
} 

Import-Module Az.Accounts
Import-Module Az.KeyVault

Enable-AzureRmAlias -Scope CurrentUser -ErrorAction SilentlyContinue  # solves type implementation exception