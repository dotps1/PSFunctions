<#PSScriptInfo

.Version
    1.0
.Guid
    dc64634e-86a9-4ed5-bc7f-f2a55fa3bb0a
.Author 
    Thomas Malkewitz @dotps1 
.Tags 
    MSI, PSCustomObject
.ProjectUri
    https://github.com/dotps1/PSFunctions
.ReleaseNotes
    Initial Release.

#>

<#

.Synopsis
    Gets a property value from a Windows Installer Database.
.Description
    Opens a Windows Installer Database (.msi) and queries for the specified property value.
.Inputs
    System.String
.Outputs
    System.String
.Parameter Path
    System.String
    The location of the Windows Installer Database.
.Parameter Property
    System.String
    The Property to get the value of.
.Example
    PS C:\> Get-MsiPropertyValue -Path .\jre1.8.0_121.msi -Property ProductVersion, ProductCode

    Name             ProductVersion ProductCode
    ----             -------------- -----------
    jre1.8.0_121.msi 8.0.1210.13    {26A24AE4-039D-4CA4-87B4-2F32180121F0}
.Example
    PS C:\> Get-ChildItem -Path ".\Installers" -Filter "*.msi" | Select -ExpandProperty FullName | Get-MsiPropertyValue -Property ProductVersion
    
    Name             ProductVersion ProductCode
    ----             -------------- -----------
    jre1.8.0_101.msi 8.0.1010.13    {26A24AE4-039D-4CA4-87B4-2F32180101F0}
    jre1.8.0_111.msi 8.0.1110.14    {26A24AE4-039D-4CA4-87B4-2F32180111F0}
    jre1.8.0_121.msi 8.0.1210.13    {26A24AE4-039D-4CA4-87B4-2F32180121F0}
.Link
    https://dotps1.github.io
.Link
    https://www.powershellgallery.com/packages/Get-MsiPropertyValue
.Link
    https://grposh.github.io

#>

    
[CmdletBinding()]
[OutputType(
    [PSCustomObject]
)]

param (
    [Parameter(
        Mandatory = $true,
        ValueFromPipeLine = $true,
        ValueFromPipelineByPropertyName = $true
    )]
    [ValidateScript({
        if (([System.IO.FileInfo]$_).Extension -eq ".msi") {
            $true
        } else {
            throw "Path must be a Windows Installer Database (*.msi) file."
        }
    })]
    [String[]]
    $Path,

    [Parameter(
        Mandatory = $true,
        ValueFromPipelineByPropertyName = $true
    )]
    [String[]]
    $Property
)

begin {
    $windowsInstaller = New-Object -ComObject WindowsInstaller.Installer
}

process {
    foreach ($pathValue in $Path) {
        try {
            $item = Get-Item -Path $pathValue -ErrorAction Stop
                
            $database = $windowsInstaller.GetType().InvokeMember(
                "OpenDatabase", "InvokeMethod", $null, $windowsInstaller, ($item.FullName, 0)
            )

            $output = [PSCustomObject]@{
                Name = $item.Name
            }

            foreach ($propertyValue in $Property) {
                $view = $database.GetType().InvokeMember(
                    "OpenView", "InvokeMethod", $null, $database, "SELECT Value FROM Property WHERE Property = '$propertyValue'"
                )

                $view.GetType().InvokeMember(
                    "Execute", "InvokeMethod", $null, $view, $null
                ) | Out-Null

                $record = $view.GetType().InvokeMember(
                    "Fetch", "InvokeMethod", $null, $view, $null
                )

                $value = $record.GetType().InvokeMember(
                    "StringData", "GetProperty", $null, $record, 1
                )

                Add-Member -InputObject $output -Name $propertyValue -Value $value -MemberType NoteProperty
            }

            # Close the database, else it will be locked.
            $database.GetType().InvokeMember(
                "Close", "InvokeMethod", $null, $view, $null
            ) | Out-Null

            Write-Output -InputObject $output
        } catch {
            Write-Error $_
            continue
        }
    }
}

end {
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject(
        $windowsInstaller
    ) | Out-Null
}
