<#PSScriptInfo

.Version
    1.0
.Guid
    bf215750-33c6-473e-8562-fbbd52d2e124
.Author
    Thomas Malkewitz @dotps1
.Tags
    Lovibond, SRM
.ProjectUri
    https://github.com/dotps1/PSFunctions
.ReleaseNotes 
    Initial Release.

#>

<#

.Synopsis
    Converts Lovibond to SRM.
.Description
    Converts lovibond to SRM.
.Inputs
    System.Double
.Outputs
    System.Double
.Parameter Lovibond
    System.Double
    The Lovibond value to convert
.Example
    PS C:\> Convert-LovibondToSrm -Lovibond 3.5
    3.98
.Notes
    SRM = (1.3546 × °L) - 0.76
.Link
    https://dotps1.github.io
.Link
    https://www.brewtoad.com/tools/color-converter
.Link
    https://grposh.github.io

#>


[CmdletBinding()]
[OutputType(
    [Double]
)]

param (
    [Parameter(
        Mandatory = $true,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true
    )]
    [Double[]]
    $Lovibond
)

process {
    foreach ($lovibondValue in $Lovibond) {
        try {
            $srm = ( 1.3546 * $lovibondValue ) - .76
            
            Write-Output -InputObject ( [Math]::Round( $srm, 2 ))
        } catch {
            $PSCmdlet.WriteError(
                $_
            )
        }
    }
}
