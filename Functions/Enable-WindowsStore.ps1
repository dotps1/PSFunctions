<#PSScriptInfo

.Version
    1.0
.Guid
    f359f57b-4e50-42f1-8999-5eaf3da1bb24
.Author
    Thomas Malkewitz @dotps1
.Tags
    WindowsStore, Registry
.ProjectUri
    https://github.com/dotps1/PSFunctions
.ReleaseNotes 
    Initial Release.
    
#>

<#

.Synopsis
    Enables the Windows Store that maybe disabled with Group Policy.
.Description
    Sets the registry that disables the Windows Store to "0", which will temporarily allow access to the Windows Store.
.Inputs
    System.Management.Automation.Credential
    System.Management.Automation.PSCredential
.Outputs
    None
.Parameter Credential
    System.Management.Automation.PSCredential
    A Credential object with permissions to modify the SOFTWARE Registry Hive.
.Example
    PS C:\> Enable-WindowsStore
.Example
    PS C:\> Enable-WindowsStore -Credential (Get-Credential)
.Example
    PS C:\> Get-Credential | Enable-WindowsStore
.Notes
    This change will only last until Group Policy refreshes.
.Link
    https://dotps1.github.io
.link
    https://grposh.github.io

#>


[CmdletBinding()]
[OutputType(
    [Void]
)]

param (
    [Parameter(
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true
    )]
    [ValidateNotNull()]
    [System.Management.Automation.PSCredential]
    [System.Management.Automation.Credential()]
    $Credential
)

process {
    $icmGetItemPropertyValueParams = @{
        ComputerName = $env:COMPUTERNAME
        ScriptBlock = { Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore" -Name "RemoveWindowsStore" }
        ErrorAction = "Stop"
    }

    if ($null -ne $Credential) {
        $icmGetItemPropertyValueParams.Add(
            "Credential", $Credential
        )
    }

    try {
        if ((Invoke-Command @icmGetItemPropertyValueParams) -eq 1) {
            $icmSetItemPropertyValueParams = @{
                ComputerName = $env:COMPUTERNAME
                ScriptBlock = { Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore" -Name "RemoveWindowsStore" -Value 0 }
                ErrorAction = "Stop"
            }

            if ($null -ne $Credential) {
                $icmSetItemPropertyValueParams.Add(
                    "Credential", $Credential
                )
            }

            try {
                Invoke-Command @icmSetItemPropertyValueParams

                Write-Information -MessageData "Windows store enabled successfully."
            } catch {
                Write-Error $_
                break
            }
        } else {
            Write-Information -MessageData "Windows Store is already enabled."
        }
    } catch {
        Write-Error $_
        break
    }
}
