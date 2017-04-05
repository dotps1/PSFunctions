<#PSScriptInfo

.Version
    1.0
.Guid
    c441b2d9-dcbc-4d91-9c36-5480348079e4
.Author
    Thomas Malkewitz @dotps1
.Tags
    DirectoryInfo, FileInfo, Metadata, Attribute
.ProjectUri
    https://github.com/dotps1/PSFunctions
.ReleaseNotes 
    Initial Release.
    
#>

<#

.Synopsis
    Get extended item metadata attribute value.
.Description
    Get extended item metadeta attribute value from an item using COM and referenced by attribute number.
.Inputs
    System.String
.Outputs
    System.Management.Automation.PSCustomObject
.Parameter Path
    System.String
    Path to the file or folder.
.Parameter Attribute
    System.Int
    Integer representation of the attribute value to retreive.
.Example
    PS C:\> Get-ItemExtendedAttribute -Path .\googlechromestandaloneenterprise.msi -Attribute 24

    Attribute Value
    --------- -----
    24 57.0.2987.98 Copyright 2011 Google Inc.
.Example
    PS C:\> Get-ItemExtendedAttribute -Path $env:WinDir

    Attribute Value
    --------- -----
            2 File folder
            3 3/24/2017 7:50 AM
            4 7/16/2016 2:04 AM
            5 3/24/2017 7:50 AM
            6 D
            8 Available offline
            9 Unknown
           10 TrustedInstaller
           11 Folder
           19 Unrated
           50 58.4 GB
           54 MyComputer (this PC)
          158 Windows
          162 33.0 GB
          180 No
          183 C:\
          184 C:\
          185 C:\
          187 C:\Windows
          189 File folder
          195 Unresolved
          247 ‎43%
.Link
    http://stackoverflow.com/questions/9420055/enumerate-file-properties-in-powershell
.Link
    https://dotps1.github.io
.Link
    https://www.powershellgallery.com/packages/Get-ItemExtendedAttribute
.Link
    https://grposh.github.io

#>


[CmdletBinding()]
[OutputType(
    [PSCustomObject]
)]

param (
    [Parameter(
        Mandatory = $true
    )]
    [ValidateScript({
        if (Test-Path -Path $_) {
            return $true
        } else {
            throw "Unable to find part of path: '$_'."
        }
    })]
    [String[]]
    $Path,

    [Parameter()]
    [ValidateRange(
        1, 287
    )]
    [Int]
    $Attribute
)

begin {
    $shell = New-Object -ComObject Shell.Application
}

process {
    foreach ($pathValue in $Path) {
        $item = Resolve-Path -Path $pathValue
        $parent = Split-Path -Path $item
        $leaf = Split-Path -Path $item -Leaf

        $shellParent = $shell.NameSpace(
            $parent
        )

        $shellLeaf = $shellParent.ParseName(
            $leaf
        )
        
        $output = @()
        if ($PSBoundParameters.ContainsKey("Attribute")) {
            $value = $shellParent.GetDetailsOf(
                $shellLeaf, $Attribute
            )

            $output += [PSCustomObject]@{
                Attribute = $Attribute
                Value = $value
            }
        } else {
            for ($i = 1; $i -le 287; $i++) {
                $value = $shellParent.GetDetailsOf(
                    $shellLeaf, $i
                )

                if (-not ([String]::IsNullOrEmpty($value))) {
                    $output += [PSCustomObject]@{
                        Attribute = $i
                        Value = $value
                    }
                }
            }
        }

        if ($null -ne $output) {
            Write-Output -InputObject $output
        }
    }
}

end {
    $null = [System.Runtime.InteropServices.Marshal]::ReleaseComObject(
        $shell
    )
    Remove-Variable -Name shell
}
