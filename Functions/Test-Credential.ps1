<#PSScriptInfo

.Version
	1.4
.Guid
	6a18515f-73d3-4fb4-884f-412395aa5054
.Author
	Thomas Malkewitz @dotps1
.Tags
	PSCredential Credential Function PSFunction
.ProjectUri
	 https://github.com/dotps1/PSFunctions
.ReleaseNotes
	Removed pipeline support and PSCredential Array functionality.
    This Script-Function can now only be used to test one credential at a time.

#> 

<#

.Synopsis
    Test if a Credential Object is valid.
.Description 
    Simulates an Authentication Request in a Domain environment using a PSCredential Object. Returns $true if both Username and Password pair are valid. 
.Inputs
    System.Management.Automation.PSCredential
.Outputs
    System.Boolean
.Parameter Credential
    System.Management.Automation.PSCredential
    Credential object to test.
.Parameter Domain
    System.String
    The domain to test the Credential against.  Defaults to the domain used in the Credential Parameter.
.Example
    PS C:\> Test-Credential -Credential (Get-Credential)
    True
.Example
    PS C:\> $credential = (Get-Credential)
    
    cmdlet Get-Credential at command pipeline position 1
    Supply values for the following parameters:
    Credential
    PS C:\> Test-Credential -Credential $credential
    True
.Link
    https://dotps1.github.io
.Link
    https://www.powershellgallery.com/packages/Test-Credential
.Link
    https://grposh.github.io

#>


[CmdletBinding()]
[OutputType(
    [Bool]
)]

param (
    [Parameter(
        Mandatory = $true
    )]
    [Alias(
        'PSCredential'
    )]
    [ValidateNotNull()]
    [PSCredential]
    $Credential,

    [Parameter()]
    [String]
    $Domain = $Credential.GetNetworkCredential().Domain
)

[System.Reflection.Assembly]::LoadWithPartialName("System.DirectoryServices.AccountManagement") |
    Out-Null

$principalContext = New-Object System.DirectoryServices.AccountManagement.PrincipalContext(
    [System.DirectoryServices.AccountManagement.ContextType]::Domain, $Domain
)

$networkCredential = $Credential.GetNetworkCredential()

Write-Output -InputObject $(
    $principalContext.ValidateCredentials(
        $networkCredential.UserName, $networkCredential.Password
    )
)

$principalContext.Dispose()
