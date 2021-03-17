# +-----------------------------------------------------------------------------------------------------
# | File: AzureDevOpsToolSet.psm1
# | Version: 1.00
# | Author: Miguel Perez (@miguelperezwd)
# | Purpose: Module with functions to peform common operations on Azure DevOps Services through the API.
# +-----------------------------------------------------------------------------------------------------

#=======================================================================================

function Get-AllADOProjects {
    <#
    .SYNOPSYS
        Get all Azure DevOps projects in the specified organization
    .DESCRIPTION
        Get all Azure DevOps projects in the specified organization
    .PARAMETER
        $Organization
        $PersonalAccessToken
    .EXAMPLE
        Get-ADOProjects -Organization YourOrg -PersonalAccessToken xxxxxxxxxx
    .INPUTS
        String
    .OUTPUTS
        System.Object[]
    #>
    [CmdletBinding()]
    param (
        # Name of the organization
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
        [string] $Organization,
        # User's Personal Access Token
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
        [string] $PersonalAccessToken
    )
    
    begin {
        # Set the token headers for the API request
        $token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($PersonalAccessToken)"))
        $headers = @{authorization = "Basic $token"}
    }
    
    process {
        
        $URI = "https://dev.azure.com/$Organization/_apis/projects?api-version=6.0&`$top=500" # The default API will only bring the first 100 projects, adding the $top variable lets you retrieve more projects

        try {
            # Connect to Azure DevOps and get all the projects from the given Organization
            Write-Verbose "Connecting to Azure DevOps and retrieving list of projects..." -Verbose
            $ADOProjects = (Invoke-RestMethod -Uri $URI -Method GET -ContentType "application/json" -Headers $headers).value
            return $ADOProjects # The API result is stored here, use this variable for getting projects information and properties.
        }
        catch {
            Write-Error "Something wrong happened during the API request, please review the parameters and make sure the information is correct." -ErrorAction Stop
        }
        
    }   
    
    end {
        Write-Verbose "All projects have been retrieved." -Verbose
    }
}

function Create-ADOProject {
    <#
    .SYNOPSYS
        Create a new ADO project in the specified organization
    .DESCRIPTION
        Create a new ADO project in the specified organization
    .PARAMETER
        $Organization
        $Project
        $Visibility
        $Process
        $VersionControl
        $Description
        $PersonalAccessToken
    .EXAMPLE
        Create-ADOProject -Organization YourOrg -Project PartsUnlimited -Visibility "Private" -Process "Agile" -VersionControl "Git" -Description "My new project" -PersonalAccessToken xxxxxxxxxx
    .INPUTS
        String
    .OUTPUTS
        System.Object[]
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
        [String] $Organization,

        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
        [String] $Project,

        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
        [ValidateSet("Private","Public")]
        [String] $Visibility,

        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
        [String] $Process,

        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
        [ValidateSet("Git","Tfvc")]
        [String] $VersionControl,
        
        [Parameter()][ValidateNotNullOrEmpty()]
        [String] $Description,

        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
        [String] $PersonalAccessToken
    )
    
    begin {
        # Set the token headers for the API request
        $token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($PersonalAccessToken)"))
        $headers = @{authorization = "Basic $token"}

        # Check if project already exists
        $existingProjects = (Get-AllADOProjects -Organization $Organization -PersonalAccessToken $PersonalAccessToken).name
        if ($existingProjects -match $Project) { Write-Error -Message "The organization already has a project called $Project" -ErrorAction Stop }
    }
    
    process {

        # Get list of processes from the org
        $processURI = "https://dev.azure.com/$Organization/_apis/work/processes?api-version=6.0-preview.2"
        $processTemplate = (Invoke-RestMethod -Uri $processURI -Method GET -ContentType "application/json" -Headers $headers).value | Where-Object {$_.name -match $Process}

        # Check if defined process matches with the existing ones
        if($processTemplate.Count -eq 0){ Write-Error -Message "No work-item process matched with $Process in this organization" -ErrorAction Stop }

        try {

            # Set the URI and project information
            $projectsURI = "https://dev.azure.com/$Organization/_apis/projects?api-version=6.0"
            $bodyInfo = @{
                        name = $Project
                        description = $Description
                        visibility = $Visibility
                        capabilities = @{
                            versioncontrol = @{
                                sourceControlType = $VersionControl
                            }
                            processTemplate = @{
                                templateTypeId = ($processTemplate.typeId)
                            }
                        } 
            }| ConvertTo-Json     

            # Execute the API call
            $newProject = Invoke-RestMethod -Method Post -Uri $projectsURI -Body $bodyInfo -ContentType "application/json" -Headers $headers
            $newProjectURL = "https://dev.azure.com/$Organization/$Project"
        }
        catch {
            Write-Error "Something wrong happened during the API request, please review the parameters and make sure the information is correct." -ErrorAction Stop
        }
        
    }   
    
    end {
        Write-Verbose "New project $Project has been created. Check it out: $newProjectURL" -Verbose
    }
}