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
