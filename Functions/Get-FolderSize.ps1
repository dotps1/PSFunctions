<#PSScriptInfo

.Version
    1.0
.Guid
    8b5756da-eb5a-46c7-a388-320817dbd315
.Author
    Thomas Malkewitz @tomohulk
.Tags
    DirectoryInfo, FileInfo, Metadata, Attribute
.ProjectUri
    https://github.com/dotps1/PSFunctions
.ReleaseNotes 
    Added pipeline support.
    
#>

<#

.SYNOPSIS
    Gets the size of a folder.
.DESCRITPION
    Enumerates all sub folders and file of a directory returning the entire folder structure size.
.INPUTS
    System.String
.OUTPUTS
    System.Management.Automation.PSCustomObject
.PARAMETER Path
    System.String
    The path represtation of the directory to enumerate.
.PARAMETER Unit
    System.String
    The unit of measurment to return the size value.
.EXAMPLE
    PS C:\> Get-FolderSize -Path C:\Users\tomohulk\Documents

    Path                          Size(MB)
    ----                          --------
    C:\Users\tomohulk\Documents 9732.33304
.EXAMPLE
    PS C:\> Get-ChildItem -Path C:\Usuers\tomohulk\Documents -Directory | Get-FolderSize -Unit MB

    Path                                                 Size(MB)
    ----                                                 --------
    C:\Users\tomohulk\Documents\Custom Office Templates         0
    C:\Users\tomohulk\Documents\GitHub                  211.29266
    C:\Users\tomohulk\Documents\GitLab                    4.45472
    C:\Users\tomohulk\Documents\My Received Files         0.24156
    C:\Users\tomohulk\Documents\WindowsPowerShell         0.07872
.LINK
    https://tomohulk.github.io

#>


[CmdletBinding()]
[OutputType(
    [PSCustomObject]
)]

param (
    [Parameter(
        Mandatory = $true,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true
    )]
    [Alias(
        "FullName"
    )]
    [String[]]
    $Path,

    [Parameter()]
    [ValidateSet(
        "KB","MB","GB", "TB"
    )]
    $Unit = "MB"
)

process {
    foreach ($pathValue in $Path) {
        if (Test-Path -Path $pathValue) {
            $item = Get-Item -Path ( Resolve-Path -Path $pathValue )
            if ($item.PSIsContainer) {
                $measure = Get-ChildItem $pathValue -Recurse -Force -ErrorAction SilentlyContinue | 
                    Measure-Object -Property Length -Sum
                $sum = [Math]::Round( ($measure.Sum / "1$Unit"), 2 )
                [PSCustomObject]@{
                    "Path" = $item.FullName
                    "Size($Unit)" = $sum
                }
            } else {
                Write-Error -Message "The path '$($item.FullName)' is not a directory."
                continue
            }
        } else {
            Write-Error -Message "Unable to find part of path '$pathValue'."
            continue
        }
    }
}
