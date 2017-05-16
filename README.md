# PSFunctions

---

Repository to hold script-functions that are published to the PowerShell Gallery.
These are functions that I haven't really made into a module yet or don't really fit into any of my other custom modules.
So they are contained in single .ps1 files that can be installed with `Install-Script`.

---

### ConvertTo-ShortPath

```
PS C:\Users\dotps1\Documents\GitHub\PSFunctions\Functions> ConvertTo-ShortPath
C:\Users\dotps1\DOCUME~1\GitHub\PSFUNC~1\FUNCTI~1

PS C:\> Get-Item $env:WinDir\System32\WindowsPowerShell\v1.0\powershell.exe | .\ConvertTo-ShortPath.ps1
C:\Windows\System32\WINDOW~1\v1.0\powershell.exe
```

### Enable-WindowsStore

```
PS C:\> Enable-WindowsStore


PS C:\> Enable-WindowsStore -Credential (Get-Credential)


PS C:\> Get-Credential | Enable-WindowsStore
```

### Find-NthIndexOf

```
PS C:\> Find-NthIndexOf -Target "CN=me,OU=Users,DC=domain,DC=org" -Value "=" -Nth 2
8


PS C:\> ($dn = "CN=dotps1,OU=Users,DC=domain,DC=org").SubString((Find-NthIndexOf -Target $dn -Value "=" -Nth 2) - 2)
OU=Users,DC=domain,DC=org


PS C:\> Find-NthIndexOf -Target "Hello World." -Value "w" -IgnoreCase
6
```

### Get-ItemExtendedAttribute

```
PS C:\> Get-ItemExtendedAttribute -Path .\googlechromestandaloneenterprise.msi -Attribute 24

Attribute Value
--------- -----
24 57.0.2987.98 Copyright 2011 Google Inc.


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
```

### Get-LastLoggedOnUser

```
PS C:\> Get-LastLoggedOnUser

PSComputerName LastUseTime         UserName        Loaded
-------------- -----------         --------        ------
localhost      5/5/2017 9:06:45 AM domain\username   True


PS C:\> Get-LastLoggedOnUser -Name Server1, Server2 -Credential (Get-Credential)

PSComputerName LastUseTime         UserName        Loaded
-------------- -----------         --------        ------
Server1        5/5/2017 9:06:45 AM domain\username   True
Server1        5/5/2017 9:06:45 AM domain\username  False
```

### Get-ADComputerSiteName

```
PS C:\> Get-ADComputerSiteName

PSComputerName ADSiteName            
-------------- ----------            
MyComputer     Default-First-Site


PS C:\> Get-ADComputer -Filter { Name -like '*Computer*' } | Get-ADComputerSiteName

PSComputerName ADSiteName            
-------------- ----------            
MyComputer     Default-First-Site
```

### Get-MsiPropertyValue

```
PS C:\> Get-MsiPropertyValue -Path .\jre1.8.0_121.msi -Property ProductVersion, ProductCode
Name             ProductVersion ProductCode
----             -------------- -----------
jre1.8.0_121.msi 8.0.1210.13    {26A24AE4-039D-4CA4-87B4-2F32180121F0}


PS C:\> Get-ChildItem -Path ".\Installers" -Filter "*.msi" | Select -ExpandProperty FullName | Get-MsiPropertyValue -Property ProductVersion
    
Name             ProductVersion ProductCode
----             -------------- -----------
jre1.8.0_101.msi 8.0.1010.13    {26A24AE4-039D-4CA4-87B4-2F32180101F0}
jre1.8.0_111.msi 8.0.1110.14    {26A24AE4-039D-4CA4-87B4-2F32180111F0}
jre1.8.0_121.msi 8.0.1210.13    {26A24AE4-039D-4CA4-87B4-2F32180121F0}
```

### Get-ProgramUninstallString

```
PS C:\> Get-ProgramUninstallString -Name "Google Chrome"

Name          Version       Guid                                   UninstallString
----          -------       ----                                   ---------------
Google Chrome 57.0.2987.110 {4F711ED6-6E14-3607-A3CA-E3282AFE87B6} MsiExec.exe /X{4F711ED6-6E14-3607-A3CA-E3282AFE87B6}


PS C:\> Get-ProgramUninstallString -Filter "Google*"

Name                 Version       Guid                                   UninstallString
----                 -------       ----                                   ---------------
Google Chrome        57.0.2987.110 {4F711ED6-6E14-3607-A3CA-E3282AFE87B6} MsiExec.exe /X{4F711ED6-6E14-3607-A3CA-E3282AFE87B6}
Google Update Helper 1.3.32.7      {60EC980A-BDA2-4CB6-A427-B07A5498B4CA} MsiExec.exe /I{60EC980A-BDA2-4CB6-A427-B07A5498B4CA}
```

### New-ADUserName

```
PS C:\> New-Username -FirstName John -LastName Doe

jdoe


PS C:\> New-Username -FirstName Jane -LastName Doe -MiddleName Ala

jadoe
```

### New-NetStaticIPAddress

```
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
```

### Test-Credential

```
PS C:\> Test-Credential -Credential (Get-Credential)
True


PS C:\> $credential = (Get-Credential)
    
cmdlet Get-Credential at command pipeline position 1
Supply values for the following parameters:
Credential
PS C:\> Test-Credential -Credential $credential
True
```
### Test-WannaCryVulnerability
```
PS C:\> Test-WannaCryVulnerability

PSComputerName      : myrig
OperatingSystem     : Microsoft Windows 7 Professional
Vulnerable          : False
AppliedHotFixIds    : KB4012212|KB4015546|KB4015549
SMB1FeatureEnabled  : False
SMB1ProtocolEnabled : False


PS C:\> Get-ADComputer -Filter * -OrganizationalUnit OU=workstations,DC=domain,DC=org | Test-WannaCryVulnerability

PSComputerName      : workstation
OperatingSystem     : Microsoft Windows 7 Professional
Vulnerable          : True
AppliedHotFixIds    : 
SMB1FeatureEnabled  : False
SMB1ProtocolEnabled : True
```
