<#PSScriptInfo

.Version
    1.0
.Guid
    a4de76e8-d5c6-4592-8b04-324acbe17355
.Author
    Thomas Malkewitz @dotps1
.Tags
    Regex, Index
.ProjectUri
    https://github.com/dotps1/PSFunctions
.ReleaseNotes 
    Initial Release.
#>

<#

.Synopsis
    Finds the nth index of a char in a string.
.Description
    Finds the nth index of a char in a string, returns -1 if the char does not exist, or if nth is out of range.
.Inputs
    System.Int
    System.String
.Outputs
    System.Int
.Parameter Target
    System.String
    The string to evaluate.
.Parameter Value
    System.String
    The character to locate.
.Parameter Nth
    System.Int
    the occurrence of the character to find.
.Parameter IgnoreCase
    Preforms a case insensitive regex match.
.Example
    PS C:\> Find-NthIndexOf -Target "CN=me,OU=Users,DC=domain,DC=org" -Value "=" -Nth 2
    8
.Example
    PS C:\> ($dn = "CN=dotps1,OU=Users,DC=domain,DC=org").SubString((Find-NthIndexOf -Target $dn -Value "=" -Nth 2) - 2)
    OU=Users,DC=domain,DC=org
.Example
    PS C:\> Find-NthIndexOf -Target "Hello World." -Value "w" -IgnoreCase
    6
.Notes
    Returns -1 if the char does not exist, or if nth is out of range.
.Link
    http://stackoverflow.com/questions/186653/c-sharp-indexof-the-nth-occurrence-of-a-string
.Link
    https://dotps1.github.io
.Link
    https://www.powershellgallery.com/packages/Find-NthIndexOf
.Link
    https://grposh.github.io

#>


[CmdletBinding()]
[OutputType(
    [Int]
)]

param (
    [Parameter(
        Mandatory = $true,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true
    )]
    [String[]]
    $Target,

    [Parameter(
        Mandatory = $true,
        ValueFromPipelineByPropertyName = $true
    )]
    [ValidateLength(
        1,1
    )]
    [ValidateNotNullOrEmpty()]
    [String]
    $Value,

    [Parameter(
        ValueFromPipelineByPropertyName = $true
    )]
    [Int]
    $Nth = 1,

    [Parameter()]
    [Switch]
    $IgnoreCase
)

begin {
    $Value = [Regex]::Escape(
        $Value
    )
}

process {
    foreach ($targetValue in $Target) {
        if ($IgnoreCase.IsPresent) {
            $match = [Regex]::Match(
                $targetValue, "(?i)(($Value).*?){$Nth}" 
            )
        } else {
            $match = [Regex]::Match(
                $targetValue, "(($Value).*?){$Nth}" 
            )
        }

        if ($match.Success) {
            Write-Output -InputObject $match.Groups[2].Captures[$Nth - 1].Index
        } else {
            Write-Output -InputObject -1
        }
    }
}
