<#PSScriptInfo

.Version
    1.0
.Guid
    9be00d5e-0fd8-4b87-be0a-28e97bdd67b7
.Author
    Thomas J. Malkewitz @dotps1
.Tags
    AppLocker, WinEvent
.ProjectUri
    https://github.com/dotps1/PSFunctions

#>

<#

.Synopsis
    Gets AppLocker related events.
.Description 
    Gets AppLocker events based on given critera from the local or remote machine(s).
.Inputs
    System.String
.Outputs
    System.Diagnostics.Eventing.Reader.EventLogRecord
.Parameter Name
    System.String
    The name of the system to get AppLocker data against.
.Parameter EventType
    System.String
    The type of AppLocker events to get, the default value is all events from the Microsoft-Windows-AppLocker log provider.
.Parameter LogName
    System.String
    The specific log to pull events from, the default value is all logs from the Microsoft-Windows-AppLocker log provider.
.Parameter Credential
    System.Management.Automation.PSCredential
    Credential object used for authentication.
.Parameter MaxEvents
    System.Int
    The maximum number of EventLogRecord objects to return.
.Parameter Oldest
    System.Management.Automation.SwitchParameter
    Returns EventLogRecord objects from oldest to newest.
.Parameter StartTime
    System.DateTime
    The starting range to get EventLogRecord objects from.
.Parameter EndTime
    System.DateTime
    The ending range to get EventLogRecord objects from.
.Example
    PS C:\> Get-AppLockerWinEvent -MaxEvents 2


        ProviderName: Microsoft-Windows-AppLocker

    TimeCreated                     Id LevelDisplayName Message
    -----------                     -- ---------------- -------
    10/5/2017 8:17:59 AM          8005 Information      %OSDRIVE%\USERS\dotps1\DOCUMENTS\GITHUB\PSFUNCTIONS\FUNCTIONS\GET-APPLOCKERWINEVENT.PS1 was allowed to run.
    10/5/2017 8:15:10 AM          8002 Information      %PROGRAMFILES%\GIT\MINGW64\BIN\GIT.EXE was allowed to run.
.Example
    PS C:\> Get-AppLockerWinEvent -MaxEvents 2 -Oldest -LogName ExeAndDll -Credential (Get-Credential) -ComputerName myremotebox


        ProviderName: Microsoft-Windows-AppLocker

    TimeCreated                     Id LevelDisplayName Message
    -----------                     -- ---------------- -------
    10/5/2017 7:33:43 AM          8002 Information      %OSDRIVE%\USERS\dotps1\APPDATA\LOCAL\MICROSOFT\ONEDRIVE\ONEDRIVESTANDALONEUPDATER.EXE was prevented from running.
    10/5/2017 7:33:43 AM          8002 Information      %PROGRAMFILES%\GIT\CMD\GIT.EXE was allowed to run.
.Notes
    When running against a remote machine, and the results are: "No events were found that match the specified selection criteria.", you may just need to authenticate.
    Run the command and use the -Credential parameter.
.Link
    https://dotps1.github.io
.Link
    https://www.powershellgallery.com/packages/Get-AppLockerWinEvent
.Link
    https://grposh.github.io

#>


[CmdletBinding()]
[OutputType(
    [System.Diagnostics.Eventing.Reader.EventLogRecord]
)]

param(
    [Parameter(
        ValueFromPipeline = $true
    )]
    [Alias(
        "ComputerName"
    )]
    [String[]]
    $Name = $env:COMPUTERNAME,

    [Parameter()]
    [ValidateSet(
        "All", "Allowed", "Audit", "Blocked"
    )]
    [String]
    $EventType = "All",

    [Parameter()]
    [ValidateSet(
        "ExeAndDll", "MsiAndScript", "PackagedAppExecution", "PackagedAppDeployment"
    )]
    [String]
    $LogName,

    [Parameter()]
    [PSCredential]
    $Credential = [PSCredential]::Empty,

    [Parameter()]
    [Int]
    $MaxEvents,

    [Parameter()]
    [Switch]
    $Oldest,

    [Parameter()]
    [DateTime]
    $StartTime = [DateTime]::MinValue,

    [Parameter()]
    [DateTime]
    $EndTime = [DateTime]::MaxValue
)

begin {
    $filterHashTable = @{
        ProviderName = "Microsoft-Windows-AppLocker"
        StartTime = $StartTime
        EndTime = $EndTime
    }

    switch ($EventType) {
        "Allowed" {
            $filterHashTable.Add(
                "Id", @(
                    8002, 8005, 8020, 8023
                )
            )
        }

        "Audit" {
            $filterHashTable.Add(
                "Id", @(
                    8003, 8006, 8021, 8024
                )
            )
        }

        "Blocked" {
            $filterHashTable.Add(
                "Id", @(
                    8004, 8007, 8022, 8025
                )
            )
        }
    }

    switch ($LogName) {
        "ExeAndDll" {
            $filterHashTable.Add(
                "LogName", "Microsoft-Windows-AppLocker/EXE and DLL"
            )
        }

        "MsiAndScript" {
            $filterHashTable.Add(
                "LogName", "Microsoft-Windows-AppLocker/MSI and Script"
            )
        }

        "PackagedAppExecution" {
            $filterHashTable.Add(
                "LogName", "Microsoft-Windows-AppLocker/Packaged app-Execution"
            )
        }

        "PackagedAppDeployment" {
            $filterHashTable.Add(
                "LogName", "Microsoft-Windows-AppLocker/Packaged app-Deployment"
            )
        }
    }
}

process {
    foreach ($nameValue in $Name) {
        $getWinEventParameters = @{
            ComputerName = $nameValue
            Credential = $Credential
            FilterHashTable = $filterHashTable
            ErrorAction = "Stop"
        }

        if ($MaxEvents -gt 0) {
            $getWinEventParameters.Add(
                "MaxEvents", $MaxEvents
            )
        }

        if ($Oldest.IsPresent) {
            $getWinEventParameters.Add(
                "Oldest", $Oldest
            )
        }

        try {
            $output = Get-WinEvent @getWinEventParameters

            Write-Output -InputObject $output
        } catch {
            $PSCmdlet.ThrowTerminatingError(
                $_
            )
        }
    }
}
