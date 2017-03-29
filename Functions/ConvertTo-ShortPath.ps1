<#PSScriptInfo

.Version
    1.0
.Guid
    6f926344-d186-4470-ab96-cea272bd5848
.Author
    Thomas Malkewitz @dotps1
.Tags
    8.3, ShortPath
.ProjectUri
    https://github.com/dotps1/PSFunctions
.ReleaseNotes 
    Initial Release.

#>

<#

.Synopsis
    Converts a path to the 8.3 equivalent.
.Description
    Converts each element of a file object path to the 8.3 path and return the short path string. 
.Inputs
    System.String
.Outputs
    System.String
.Parameter Path
    System.String
    Path to convert.
.Example
    PS C:\Users\dotps1\Documents\GitHub\PSFunctions\Functions> ConvertTo-ShortPath
    C:\Users\dotps1\DOCUME~1\GitHub\PSFUNC~1\FUNCTI~1
.Example
    PS C:\> Get-Item $env:WinDir\System32\WindowsPowerShell\v1.0\powershell.exe | .\ConvertTo-ShortPath.ps1
    C:\Windows\System32\WINDOW~1\v1.0\powershell.exe
.Notes
    This function requires a valid file path to do the conversion.
.Link
    https://dotps1.github.io
.Link
    https://www.powershellgallery.com/packages/ConvertTo-ShortPath
.Link
    https://grposh.github.io

#>


[OutputType(
    [String]
)]

param (
    [Parameter(
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true
    )]
    [Alias(
        'FullName'
    )]
    [ValidateNotNull()]
    [String[]]
    $Path = $pwd
)

begin {
    $fso = New-Object -ComObject Scripting.FileSystemObject
}

process {
    foreach ($pathValue in $Path){
        try {
            if (($item = Get-Item -Path $pathValue -ErrorAction Stop).PSIsContainer) {
                $fso.GetFolder($item.FullName).ShortPath
            } else {
                $fso.GetFile($item.FullName).ShortPath
            }
        } catch {
            Write-Error -Message $_.ToString()
        }
    }
}

end {
    # Clean up COM Object.
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject(
        $fso
    ) | Out-Null
    Remove-Variable -Name fso
}
