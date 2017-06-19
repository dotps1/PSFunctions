# PSFunctions

---

Repository to hold script-functions that are published to the [PowerShell Gallery](https://powershellgallery.com).
These are functions that I haven't really made into a module yet or don't really fit into any of my other custom modules.
So they are contained in single .ps1 files that can be installed using `Install-Script -Repository PSGallery -Name <Function-Name>`, and used like native PowerShell cmdlets.

---

### ConvertTo-ShortPath
Converts each element of a file object path to the 8.3 path and return the short path string. 

```
PS C:\Users\dotps1\Documents\GitHub\PSFunctions\Functions> ConvertTo-ShortPath
C:\Users\dotps1\DOCUME~1\GitHub\PSFUNC~1\FUNCTI~1

PS C:\> Get-Item $env:WinDir\System32\WindowsPowerShell\v1.0\powershell.exe | .\ConvertTo-ShortPath.ps1
C:\Windows\System32\WINDOW~1\v1.0\powershell.exe
```

---

### Enable-WindowsStore
Sets the registry that disables the Windows Store to "0", which will temporarily allow access to the Windows Store.

```
PS C:\> Enable-WindowsStore


PS C:\> Enable-WindowsStore -Credential (Get-Credential)


PS C:\> Get-Credential | Enable-WindowsStore
```

---

### Find-NthIndexOf
Finds the nth index of a char in a string, returns -1 if the char does not exist, or if nth is out of range.

```
PS C:\> Find-NthIndexOf -Target "CN=me,OU=Users,DC=domain,DC=org" -Value "=" -Nth 2
8


PS C:\> ($dn = "CN=dotps1,OU=Users,DC=domain,DC=org").SubString((Find-NthIndexOf -Target $dn -Value "=" -Nth 2) - 2)
OU=Users,DC=domain,DC=org


PS C:\> Find-NthIndexOf -Target "Hello World." -Value "w" -IgnoreCase -Nth 1
6
```

---

### Get-ADComputerSiteName
Queries DNS to get the computers IPAddress then, returns the ADSiteName base on AD Sites and Services.

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

---

### Get-EternalBlueVulnerabilityStatistics
Test for applicable patches to prevent the WannaCry/WannaCrypt malware.  Tests for the SMB1 protocol and component.

```
PS C:\> Get-EternalBlueVulnerabilityStatistics

PSComputerName         : my-win7-rig
OperatingSystemCaption : Microsoft Windows 7 Professional
OperatingSystemVersion : 6.1.7601
LastBootUpTime         : 5/14/2017 3:38:38 PM
AppliedHotFixID        : KB4012212;KB4015546;KB4015549
SMB1FeatureEnabled     : False
SMB1ProtocolEnabled    : False
Port139Enabled         : True
Port445Enabled         : True


PS C:\> Get-ADComputer -Identity domain-win7-rig | Get-EternalBlueVulnerabilityStatistics

PSComputerName         : domain-win7-rig
OperatingSystemCaption : Microsoft Windows 7 Professional
OperatingSystemVersion : 6.1.7601
LastBootUpTime         : 3/14/2017 3:38:38 PM
AppliedHotFixID        : 
SMB1FeatureEnabled     : False
SMB1ProtocolEnabled    : True
Port139Enabled         : True
Port445Enabled         : True
```

### Get-ItemExtendedAttribute
Get extended item metadeta attribute value from an item using COM and referenced by attribute number.

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

---

### Get-LastLoggedOnUser
Gets the last not special user to have a loaded profile on a given system.

```
PS C:\> Get-LastLoggedOnUser

PSComputerName LastUseTime         UserName        Loaded
-------------- -----------         --------        ------
localhost      5/5/2017 9:06:45 AM domain\username   True


PS C:\> Get-LastLoggedOnUser -Name Server1, Server2 -Credential (Get-Credential)

PSComputerName LastUseTime         UserName        Loaded
-------------- -----------         --------        ------
Server1        5/5/2017 9:06:45 AM domain\username   True
Server2        5/5/2017 9:06:45 AM domain\username  False
```

---

### Get-MsiPropertyValue
Opens a Windows Installer Database (.msi) and queries for the specified property value.

```
PS C:\> Get-MsiPropertyValue -Path .\jre1.8.0_121.msi -Property ProductVersion, ProductCode
Name             ProductVersion ProductCode
----             -------------- -----------
jre1.8.0_121.msi 8.0.1210.13    {26A24AE4-039D-4CA4-87B4-2F32180121F0}


PS C:\> Get-ChildItem -Path ".\Installers" -Filter "*.msi" | Select -ExpandProperty FullName | Get-MsiPropertyValue -Property ProductVersion, ProductCode
    
Name             ProductVersion ProductCode
----             -------------- -----------
jre1.8.0_101.msi 8.0.1010.13    {26A24AE4-039D-4CA4-87B4-2F32180101F0}
jre1.8.0_111.msi 8.0.1110.14    {26A24AE4-039D-4CA4-87B4-2F32180111F0}
jre1.8.0_121.msi 8.0.1210.13    {26A24AE4-039D-4CA4-87B4-2F32180121F0}
```

---

### Get-ProgramUninstallString
Gets the uninstall string for a program, can be filtered to a key word of the programs display name.

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

---

### New-ADUserName
Create a new username with the following order until a unique Username is found.
1. First Initial Last Name.
2. First Initial First Middle Initial Last Name.
3. Iterates First Name adding each Char until a unique Username is found.

```
PS C:\> New-Username -FirstName John -LastName Doe

jdoe


PS C:\> New-Username -FirstName Jane -LastName Doe -MiddleName Ala

jadoe
```

---

### New-NetStaticIPAddress
Removes the current NetIPAddress and NetRoute on a given NetAdapter.  Sets a new Static NetIPAddress and adds DNS Server values if provided.

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

---

### Set-CsvValue
Sets a value or multiple values in the same row in a comma separated value.

```
PS C:\> Set-CsvValue -Path .\my.csv -Key "ComputerName" -Value "MyComputer" -Hashtable @{ Owner = "dotps1" }


PS C:\> Set-CsvValue -Path .\my.csv -Key "ComputerName" -Value "MyComputer" -Hashtable @{ Owner = "dotps1"; Make = "Dell"; Model = "XPS 15" }
```

---

### Test-Credential
Simulates an Authentication Request in a Domain environment using a PSCredential Object. Returns $true if both Username and Password pair are valid. 

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
