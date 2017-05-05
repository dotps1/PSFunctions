<#PSScriptInfo

.Version
    1.0
.Guid
    aa16f836-627c-4369-82f5-2a52e71cb80d
.Author
    Thomas J. Malkewitz @dotps1
.Tags
    WindowsStore, Registry
.ProjectUri
    https://github.com/dotps1/PSFunctions

#>

<#

.Synopsis
    Gets the ADSiteName for a computer.
.Description 
    Queries DNS to get the computers IPAddress then, returns the ADSiteName base on AD Sites and Services.
.Inputs
    System.String
.Outputs
    System.Management.Automation.PSCustomObject
.Parameter Name
    System.String
    The name of the system to get the ADSiteName for.
.Example
    PS C:\> Get-ADComputerSiteName
    
    PSComputerName ADSiteName            
    -------------- ----------            
    MyComputer     Default-First-Site
.Example
    PS C:\> Get-ADComputer -Filter { Name -like '*Computer*' } | Get-ADComputerSiteName

    PSComputerName ADSiteName            
    -------------- ----------            
    MyComputer     Default-First-Site
.Notes
    Domain Connectivity is required.
.Link
    http://www.powershellmagazine.com/2013/04/23/pstip-get-the-ad-site-name-of-a-computer/
.Link
    https://dotps1.github.io
.Link
    https://www.powershellgallery.com/packages/Get-ADComputerSiteName
.Link
    https://grposh.github.io

#>


[CmdletBinding()]
[OutputType(
    [PSCustomObject]
)]

param (
    [Parameter(
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true
    )]
    [Alias(
        "ComputerName"
    )]
    [String[]]
    $Name = $env:COMPUTERNAME
)

process {
    foreach ($nameValue in $Name) {
        try {
            $adSiteName = nltest /server:${nameValue} /dsgetsite 2>$null

            if ($LASTEXITCODE -eq 0) {
                $output = [PSCustomObject] @{
                    PSComputerName = $nameValue
                    ADSiteName = $adSiteName[0]
                }

                Write-Output -InputObject $output
            } else {
                Write-Warning -Message "No ADSiteName found for: '$nameValue'."

                continue
            }
        } catch {
            Write-Error -Message $_.ToString()
        }
    }
}
