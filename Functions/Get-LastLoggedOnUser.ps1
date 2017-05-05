<#PSScriptInfo

.Version
    1.0
.Guid
    255f22ba-2bfb-42ca-b584-d9cbdb28e0b2
.Author 
    Thomas J. Malkewitz @dotps1
.Tags 
    Wmi, WmiObject, Cim, CimInstance, User
.ProjectUri
    https://github.com/dotps1/PSFunctions
.ReleaseNotes
    Initial Release.

#>

<#

.Synopsis
    Gets the last logged on user of a system.
.Description
    Gets the last not special user to have a loaded profile on a given system.
.Inputs
    System.String
    System.Object.CimSession
.Outputs
    System.Management.Automation.PSCustomObject
.Parameter Name
    System.String
    The The Computer Name.
.Parameter Credential
    System.Management.Automation.PSCredential
    Credential object to used for authentication.
.Parameter CimSession
    System.Object.CimSession
    Cim Session to run against.
.Example
    PS C:\> Get-LastLoggedOnUser

    PSComputerName LastUseTime         UserName        Loaded
    -------------- -----------         --------        ------
    localhost      5/5/2017 9:06:45 AM domain\username   True
.Example
    PS C:\> Get-LastLoggedOnUser -Name Server1, Server2 -Credential (Get-Credential)

    PSComputerName LastUseTime         UserName        Loaded
    -------------- -----------         --------        ------
    Server1        5/5/2017 9:06:45 AM domain\username   True
    Server1        5/5/2017 9:06:45 AM domain\username  False
.Notes
    Using the ByComputerName parameter set uses WinRM.
.Link
    https://dotps1.github.io
.Link
    https://www.powershellgallery.com/packages/Get-LastLoggedOnUser
.Link
    https://grposh.github.io

#>


[CmdletBinding(
    DefaultParameterSetName = "ByComputerName"
)]
[OutputType(
    [PSCustomObject]
)]

param (
    [Parameter(
        ParameterSetName = "ByComputerName",
        ValueFromPipeline = $true
    )]
    [ValidateScript({
        try {
            Test-Connection -ComputerName $_ -Quiet -Count 1 -ErrorAction Stop
            return $true
        } catch {
            $_
            return $false
        }
    })]
    [Alias(
        "ComputerName"
    )]
    [String[]]
    $Name = $env:COMPUTERNAME,

    [Parameter(
        ParameterSetName = "ByComputerName"
    )]
    [PSCredential]
    $Credential = $null,

    [Parameter(
        ParameterSetName = "ByCimSession",
        ValueFromPipeline = $true
    )]
    [CimSession[]]
    $CimSession
)

begin {
    function Format-Object ($Object) {
        if ($Object.GetType().Name -eq "ManagementObject") {
            $lastUseTime = $Object.ConvertToDateTime(
                $Object.LastUseTime
            )
        } else {
            $lastUseTime = $Object.LastUseTime
        }

        $userName = ([System.Security.Principal.SecurityIdentifier]$Object.SID).Translate(
            [System.Security.Principal.NTAccount]
        ).Value  

        $output = [PSCustomObject]@{
            PSComputerName = $Object.PSComputerName
            LastUseTime = $lastUseTime
            UserName = $userName
            Loaded = $Object.Loaded
        }

        Write-Output -InputObject $output
    }
}

process {
    switch ($PSCmdlet.ParameterSetName) {
        "ByComputerName" {
            foreach ($nameValue in $Name) {
                try {
                    $userProfile = Get-WmiObject -ComputerName $nameValue -Class "Win32_UserProfile" -Namespace root\CimV2 -Filter "Special = 'False' and LastUseTime != NULL" -Credential $Credential -ErrorAction Stop |
                        Sort-Object -Property LastUseTime |
                            Select-Object -Last 1
                } catch {
                    Write-Error -Message $_.ToString()
                    continue
                }

                $output = Format-Object -Object $userProfile

                Write-Output -InputObject $output
            }
        }

        "ByCimSession" {
            foreach ($cimSessionValue in $CimSession) {
                try {
                    $userProfile = Get-CimInstance -CimSession $cimSessionValue -ClassName "Win32_UserProfile" -Namespace root\CimV2 -Filter "Special = 'False' and LastUseTime != NULL" -ErrorAction Stop |
                        Sort-Object -Property LastUseTime |
                            Select-Object -Last 1
                } catch {
                    Write-Error -Message $_.ToString()
                    continue
                }

                $output = Format-Object -Object $userProfile

                Write-Output -InputObject $output
            }
        }
    }
}
