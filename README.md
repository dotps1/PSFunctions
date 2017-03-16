# PSFunctions

---

Repository to hold script-functions that are published to the PowerShell Gallery.
These are functions that I havent really made into a module yet.
So they are contained in single .ps1 files that can be installed with `Install-Script`.

---

### Current Functions:

* Get-MsiPropertyValue

```PowerShell
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
