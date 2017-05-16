
<#PSScriptInfo

.Version
    1.3
.Guid
    d03a0e2b-361d-4994-af70-ae2afc40d661
.Author
    Thomas J. Malkewitz @dotps1
.Tags
    TCPIP IP NIC
.ProjectUri
    https://github.com/dotps1/PSFunctions
.ExternalModuleDependencies
    NetTCPIP
.ReleaseNotes
    Fixed a typo in "ThrottleLimit" parameter.
    Added missing "ValidLifeTime" parameter.
    Added Comment Based Help.

#>

<# 

.Synopsis
    Sets a static IP Address on a Network Adapter. 
.Description
    Removes the current NetIPAddress and NetRoute on a given NetAdapter.  Sets a new Static NetIPAddress and adds DNS Server values if provided.
.Inputs
    Microsoft.Management.Infrastructure.CimSession
    Microsoft.PowerShell.Cmdletization.GeneratedTypes.NetIPAddress.AddressFamily
    Microsoft.PowerShell.Cmdletization.GeneratedTypes.NetIPAddress.Store
    Microsoft.PowerShell.Cmdletization.GeneratedTypes.NetIPAddress.Type
    System.Boolean
    System.Byte
    System.Int
    System.String
    System.TimeSpan
.Outputs
    Microsoft.Management.Infrastructure.CimInstance
.Parameter InterfaceIndex
    System.Int
    The index of the NetAdapter to set a NetIPAddress on.
.Parameter InterfaceAlias
    System.String
    The display name of the NetAdapter to set a NetIPAddress on.
.Parameter IPAddress
    System.String
    The new IP Address value for the NetAdapter.
.Parameter DefaultGateway
    System.String
    The IP Address value to set for the Default Gateway of the NetAdapter.
.Parameter PrefixLength
    System.Int
    The subnet mask for the new NetIPAddress.
.Parameter AddressFamily
    Microsoft.PowerShell.Cmdletization.GeneratedTypes.NetIPAddress.AddressFamily
    Specifies IPv4 or IPv6 NetIPAddress.
.Parameter PolicyStore
    Microsoft.PowerShell.Cmdletization.GeneratedTypes.NetIPAddress.Store
    Specifies if the NetIPAddress should be applied immediately or after the next reboot.
.Parameter PreferredLifetime
    System.TimeSpan
    Specifies a preferred lifetime, as a TimeSpan object, for an NetIPAddress.
.Parameter ValidLifetime
    System.TimeSpan
    Specifies a valid lifetime value, as a TimeSpan object, for an NetIPAddress.
.Parameter SkipAsSource
    System.Boolean
    If used, the new NetIPAddress will not register with DNS.
.Parameter Type
    Microsoft.PowerShell.Cmdletization.GeneratedTypes.NetIPAddress.Type
    Specifies an NetIPAddress type.
.Parameter DnsServerAddress
    System.String
    The IP Address of a server running Domain Name Services.
.Parameter CimSession
    Microsoft.Management.Infrastructure.CimSession
    Runs the cmdlet in a remote session or on a remote computer.
.Parameter ThrottleLimit
    System.Int
    Specifies the maximum number of concurrent operations that can be established to run the cmdlet.
.Example
    PS C:\> New-NetStaticIPAddress -InterfaceIndex 3 -IPAddress 192.168.1.1 -DefaultGateway 192.168.1.0 -PrefixLength 24 -DnsServerAddress 192.168.1.0 -Confirm:$false


    IPAddress         : 192.168.1.1
    InterfaceIndex    : 3
    InterfaceAlias    : Ethernet
    AddressFamily     : IPv4
    Type              : Unicast
    PrefixLength      : 24
    PrefixOrigin      : Manual
    SuffixOrigin      : Manual
    AddressState      : Tentative
    ValidLifetime     : Infinite ([TimeSpan]::MaxValue)
    PreferredLifetime : Infinite ([TimeSpan]::MaxValue)
    SkipAsSource      : False
    PolicyStore       : ActiveStore
.Notes
    This will reset the NetAdapter, which means it will break the connection to a system if running remotely.
.Link
    https://dotps1.github.io
.Link
    https://www.powershellgallery.com/packages/New-NetStaticIPAddress
.Link
    https://grposh.github.io
    
#> 


#requires -Modules NetTCPIP

[CmdletBinding(
    ConfirmImpact = "High",
    SupportsShouldProcess = $true
)]
[OutputType(
    [Microsoft.Management.Infrastructure.CimInstance]
)]

param (
    [Parameter(
        ParameterSetName = "ByInterfaceIndex",
        ValueFromPipelineByPropertyName = $true
    )]
    [Alias(
        "ifIndex"
    )]
    [Int]
    $InterfaceIndex,

    [Parameter(
        ParameterSetName = "ByInterfaceAlias",
        ValueFromPipelineByPropertyName = $true
    )]
    [Alias(
        "ifAlias"
    )]
    [String]
    $InterfaceAlias,

    [Parameter(
        Mandatory = $true
    )]
    [String]
    $IPAddress,

    [Parameter(
        Mandatory = $true
    )]
    [String]
    $DefaultGateway,

    [Parameter(
        Mandatory = $true
    )]
    [ValidateRange(
        8, 32
    )]
    [Alias(
        "SubnetMask"
    )]
    [Byte]
    $PrefixLength,

    [Parameter()]
    [Microsoft.PowerShell.Cmdletization.GeneratedTypes.NetIPAddress.AddressFamily]
    $AddressFamily = "IPv4",

    [Parameter()]
    [Microsoft.PowerShell.Cmdletization.GeneratedTypes.NetIPAddress.Store]
    $PolicyStore = "ActiveStore",

    [Parameter()]
    [TimeSpan]
    $PreferredLifetime = [TimeSpan]::MaxValue,

    [Parameter()]
    [TimeSpan]
    $ValidLifetime = [TimeSpan]::MaxValue,

    [Parameter()]
    [Bool]
    $SkipAsSource = $false,

    [Parameter()]
    [Microsoft.PowerShell.Cmdletization.GeneratedTypes.NetIPAddress.Type]
    $Type = "Unicast",

    [Parameter()]
    [ValidateCount(
        1, 3
    )]
    [String[]]
    $DnsServerAddress = $null,

    [Parameter()]
    [CimSession[]]
    $CimSession = $null,

    [Parameter()]
    [Int]
    $ThrottleLimit = 0
)

begin {
    if ($PSBoundParameters.ContainsKey("CimSession")) {
        $Local:PSDefaultParameterValues = @{
            "*:CimSession" = $CimSession
            "*:ThrottleLimit" = $ThrottleLimit
        }
    }
}

process {
    switch ($PSCmdlet.ParameterSetName) {
        "ByInterfaceIndex" {
            try {
                $interface = Get-NetAdapter -InterfaceIndex $InterfaceIndex -ErrorAction Stop
            } catch {
                Write-Error $_
                return
            }
        }

        "ByInterfaceAlias" {
            try {
                $interface = Get-NetAdapter -Name $InterfaceAlias -ErrorAction Stop
            } catch {
                Write-Error $_
                return
            }
        }
    }

    if ($PSCmdlet.ShouldProcess($interface)) {
        if ($null -ne (Get-NetIPAddress -InterfaceIndex $interface.InterfaceIndex)) {
            Remove-NetIPAddress -InterfaceIndex $interface.InterfaceIndex -AddressFamily $AddressFamily -Confirm:${ConfirmPreference}
        }

        if ($null -ne (Get-NetRoute -InterfaceIndex $interface.InterfaceIndex)) {
            Remove-NetRoute -InterfaceIndex $interface.InterfaceIndex -AddressFamily $AddressFamily -Confirm:${ConfirmPreference}
        }

        New-NetIPAddress -AddressFamily $AddressFamily -DefaultGateway $DefaultGateway -InterfaceIndex $interface.InterfaceIndex -IPAddress $IPAddress -PolicyStore $PolicyStore -PreferredLifetime $PreferredLifetime -ValidLifetime $ValidLifetime -PrefixLength $PrefixLength -SkipAsSource $SkipAsSource -Type $Type

        if ($null -ne $DnsServerAddress) {
            Set-DnsClientServerAddress -InterfaceIndex $interface.InterfaceIndex -ServerAddresses $DnsServerAddress
        }
    }
}

end {
    if ($null -ne $Local:PSDefaultParameterValues) {
        $Local:PSDefaultParameterValues.Clear()
    }
}
