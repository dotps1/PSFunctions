<#PSScriptInfo

.Version
    1.0
.Guid
    a56f96f1-27d1-4d1d-85aa-ca206cee7fe5
.Author
    Thomas Malkewitz @dotps1
.Tags
    Google, Chrome, Msi
.ProjectUri
    https://github.com/dotps1/PSFunctions
.ReleaseNotes 
    Initial Release.

#>

<#

.SYNOPSIS
    Gets the Google Chrome for Enterprise msi.
.DESCRIPTION
    Gets the Latest version of the Google Chrome for Enterprise msi.
.INPUTS
    System.String
.OUTPUTS
    System.IO.FileInfo
.PARAMETER Path
    System.String
    The path to save the msi installer.
.PARAMETER Architecture
    System.String
    The specified OS Architecture of the installer to get.  Defaults to "All" (x64 and x86).
.EXAMPLE
    PS C:\> Get-GoogleChromeMsiInstaller
    

        Directory: C:\Users\dotps1\Downloads


    Mode                LastWriteTime         Length Name
    ----                -------------         ------ ----
    -a----       12/12/2018   4:11 PM       55500800 googlechromestandaloneenterprise.msi
    -a----       12/12/2018   4:11 PM       56463360 googlechromestandaloneenterprise64.msi
.EXAMPLE
    PS C:\> Get-GoogleChromeMsiInstaller -Path C:\Temp -Architecture x86
        

        Directory: C:\Users\dotps1\Downloads


    Mode                LastWriteTime         Length Name
    ----                -------------         ------ ----
    -a----       12/12/2018   4:11 PM       55500800 googlechromestandaloneenterprise.msi
.NOTES
    The installer download links are renedered on the google page with javascript,
    these links are fetched with an Internet Explorer COM object to cause that javascript to run and expose the links.
.LINK
    https://dotps1.github.io

#>


[CmdletBinding(
    ConfirmImpact = "High",
    SupportsShouldProcess = $true
)]
[OutputType(
    [System.IO.FileInfo]
)]

param (
    [Parameter(
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true
    )]
    [String]
    $Path = "${env:USERPROFILE}\Downloads",
    
    [Parameter()]
    [ValidateSet(
        "All", "X86", "X64"
    )]
    [String]
    $Architecture = "All"
)

begin {
    if (-not (Test-Path -Path $Path)) {
        try {
            Out-Null -InputObject (
                New-Item -Path $Path -ItemType Directory -ErrorAction Stop
            )
        } catch {
            $PSCmdlet.ThrowTerminatingError(
                $_
            )
            
            break
        }
    }

    $downloader = New-Object -TypeName System.Net.WebClient
}

process {
    if ($Architecture -in @("All", "X86")) {
        $downloadUriX86 = 'https://dl.google.com/edgedl/chrome/install/GoogleChromeStandaloneEnterprise.msi'
        $msiX86 = Join-path -Path $Path -ChildPath "googlechromestandaloneenterprise.msi"

        if (Test-Path -Path $msiX86) {
            $shouldProcess = $PSCmdlet.ShouldProcess(
                $msiX86, "Overwrite"
            )
        } else {
            $shouldProcess = $true
        }

        if ($shouldProcess) {
            $downloader.DownloadFile(
                $downloadUriX86, $msiX86
            )

            Write-Output -InputObject ( Get-Item -Path $msiX86 )
        }
    }

    if ($Architecture -in @("All", "X64")) {
        $downloadUriX64 = 'https://dl.google.com/edgedl/chrome/install/GoogleChromeStandaloneEnterprise64.msi'
        $msiX64 = Join-path -Path $Path -ChildPath "googlechromestandaloneenterprise64.msi"

        if (Test-Path -Path $msiX64) {
            $shouldProcess = $PSCmdlet.ShouldProcess(
                $msiX64, "Overwrite"
            )
        } else {
            $shouldProcess = $true
        }

        if ($shouldProcess) {
            $downloader.DownloadFile(
                $downloadUriX64, $msiX64
            )

            Write-Output -InputObject ( Get-Item -Path $msiX64 )
        }
    }
}

end {
    $downloader.Dispose()
}
