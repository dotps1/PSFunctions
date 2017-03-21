
<#PSScriptInfo

.Version
    1.0
.Guid
    0ae30495-bfc9-4f9e-8d05-6730895e755f
.Author 
    Thomas J. Malkewitz @dotps1
.Tags 
    AD, UserName, UserProvisioning
.ProjectUri
    https://github.com/dotps1/PSFunctions
.ExternalModuleDependencies 
    ActiveDirectory
.ReleaseNotes
    Renamed to fit AD Module Naming.  Added ProjectUri.

#>

<#

.Synopsis
    Creates a new username with AD DS Validation.
.Description
    Create a new username with the following order until a unique Username is found.
    1. First Initial Last Name.
    2. First Initial First Middle Initial Last Name.
    3. Iterates First Name adding each Char until a unique Username is found.
.Inputs
    None.
.Outputs
    System.String
.Parameter FirstName
    The first name of the user to be created.
.Parameter LastName
    The last name of the user to be created.
.Parameter OtherName
    The middle name of the user to be created.
.Example
    PS C:\> New-Username -FirstName John -LastName Doe

    jdoe
.Example
    PS C:\> New-Username -FirstName Jane -LastName Doe -MiddleName Ala

    jadoe
.Notes 
    Requires ActiveDirectory PowerShell Module available with Remote Server Administration Tools.
    RSAT 7SP1: http://www.microsoft.com/en-us/download/details.aspx?id=7887
    RSAT 8:    http://www.microsoft.com/en-us/download/details.aspx?id=28972
    RSAT 8.1:  http://www.microsoft.com/en-us/download/details.aspx?id=39296
    RSAT 10:   http://www.microsoft.com/en-us/download/details.aspx?id=45520
.Link
    http://dotps1.github.io
.Link
    https://grposh.github.io

#>

#requires -Modules ActiveDirectory

[CmdletBinding()]
[OutputType(
    [String]
)]
    
param (
    [Parameter(
        Mandatory = $true
    )]
    [Alias(
        'GivenName'
    )]
    [String]
    $FirstName,

    [Parameter(
        Mandatory = $true
    )]
    [Alias(
        'Surname'
    )]
    [String]
    $LastName,

    [Parameter()]
    [AllowNull()]
    [String]
    $OtherName
)

[RegEx]$pattern = "\s|-|'"

$primaryUserName = ($FirstName.Substring(0,1) + $LastName) -replace $pattern,""
if ((Get-ADUser -Filter { SamAccountName -eq $primaryUserName } | Measure-Object).Count -eq 0) {
    return $primaryUsername.ToLower()
}
    
if (-not ([String]::IsNullOrEmpty($OtherName))) {
    $secondaryUserName = ($FirstName.Substring(0,1) + $OtherName.Substring(0,1) + $LastName) -replace $pattern,""
    if ((Get-ADUser -Filter { SamAccountName -eq $secondaryUserName } | Measure-Object).Count -eq 0) {
        return $secondaryUserName.ToLower()
    }
}

foreach ($char in $FirstName.ToCharArray()) {
    $prefix += $char
    $tertiaryUserName = ($prefix + $LastName) -replace $pattern,""

    if (-not ($tertiaryUserName -eq $primaryUserName)) {
        if ((Get-ADUser -Filter { SamAccountName -eq $tertiaryUserName } | Measure-Object).Count -eq 0) {
            return $tertiaryUserName.ToLower()
        }
    }
}
