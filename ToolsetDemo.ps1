# +-----------------------------------------------------------------------------------------------------
# | File: ToolsetDemo.ps1
# | Version: 1.00
# | Author: Miguel Perez (@miguelperezwd)
# | Purpose: Script for testing the functions from AzureDevOpsToolset.pms1 module
# +-----------------------------------------------------------------------------------------------------

#=======================================================================================

# 0. Import the module
Write-Verbose "Importing AzureDevOpsToolset Module..." -Verbose
Import-Module "./Module/AzureDevOpsToolset.psm1"

# 1. Define common use variables
$Organization         = "" # Organization name
$PersonalAccessToken  = "" # User's Personal Access Token

Get-ADOProjects -Organization $Organization -PersonalAccessToken $PersonalAccessToken