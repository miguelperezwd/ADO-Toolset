# +-----------------------------------------------------------------------------------------------------
# | File: ToolsetDemo.ps1
# | Version: 1.00
# | Author: Miguel Perez (@miguelperezwd)
# | Purpose: Script for testing the functions from AzureDevOpsToolset.pms1 module
# +-----------------------------------------------------------------------------------------------------

#=======================================================================================

# 0. Import the module
Write-Verbose "Importing AzureDevOpsToolset Module..." -Verbose
Import-Module "./Module/AzureDevOpsToolset.psm1" -Force

# 1. Define common use variables
$Organization         = "" # Organization name
$PersonalAccessToken  = "" # User's Personal Access Token

# 2. Execute the functions, just uncomment the line you want to test/execute

# Get-AllADOProjects -Organization $Organization -PersonalAccessToken $PersonalAccessToken

# Create-ADOProject -Organization $Organization -Project "PartsUnlimited" -Visibility "Private" -Process "Agile" -VersionControl "Git" -Description "My new project" -PersonalAccessToken $PersonalAccessToken

