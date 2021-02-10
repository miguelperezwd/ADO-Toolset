# +-----------------------------------------------------------------------------------------------------
# | File: AzureDevOpsToolSet.psm1
# | Version: 1.00
# | Author: Miguel Perez (@miguelperezwd)
# | Purpose: Module with functions to peform common operations on Azure DevOps Services through the API.
# +-----------------------------------------------------------------------------------------------------

#=======================================================================================

function Get-ADOProjects {
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
        Write-Verbose "Setting the token headers for the API request..." -Verbose
        $token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($PersonalAccessToken)"))
        $headers = @{authorization = "Basic $token"}
    }
    
    process {
        # Connect to Azure DevOps and get all the projects from the given Organization
        Write-Verbose "Connecting to Azure DevOps..." -Verbose
        $URI = "https://dev.azure.com/$Organization/_apis/projects?api-version=6.0&`$top=500" # The default API will only bring the first 100 projects, adding the $top variable lets you retrieve more projects
        
        try {
            Write-Verbose "Retrieving list of Azure DevOps Projects..." -Verbose
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
