#requires -module VirtualMachineManager

<#PSScriptInfo

.Version
    1.1
.Guid
    1badb9c5-8b26-4184-ab23-9e2de92306e7
.Author
    Thomas Malkewitz @dotps1
.Tags
    VirtualMachineManager, VMM, SCVMM, HardDisk
.ProjectUri
    https://github.com/dotps1/PSFunctions
.ReleaseNotes 
    Fix tag metadata values.
.ExternalModuleDependencies
    VirtualMachineManager

#>

<#

.SYNOPSIS
    Expands the OS Drive of a Virtual Machine.
.DESCRIPTION
    Using information from Virtual Machine Manager and CIM, this cmdlet adds space to the virtual machines vhdx file and expands the partion.
.INPUTS
    System.String
    System.Int
.OUTPUTS
    System.Management.Automation.PSCustomObject
.PARAMETER Name
    System.String
    The name of the Virtual Machine to perform the expansion against.
.PARAMETER AmmountToAddGB
    System.Int
    The ammount of disk space to add in GB.
    Default Value: 10
.PARAMETER MinimumFreeSpaceGB
    System.Int
    The ammount of minimum free space on the disk required before the operation is performed.
    Default Value: 10
.NOTES
    If the system recovery partion is located on the disk after the OS partition, it will be removed.
.EXAMPLE
    PS C:\> Expand-SCVirtualMachineOSDisk -Name MyVirtualMachine

    Name: MyVirtualMachine
    OSDriveLetter: C
    OSPartitionPreviousSizeGB: 40
    OSPartitionNewSizeGB: 50
.EXAMPLE
    PS C:\> "MyVirtualMachine" | Expand-SCVirtualMachineOSDisk -AmmountToAddGB 25

    Name: MyVirtualMachine
    OSDriveLetter: C:
    OSPartitionPreviousSizeGB: 25
    OSPartitionNewSizeGB: 50
.LINK
    https://dotps1.github.io

#>


[CmdletBinding(
    ConfirmImpact = "High"
)]
[OutputType(
    [System.Management.Automation.PSCustomObject]
)]

param (
    [Parameter(
        Mandatory = $true,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true
    )]
    [Alias(
        'ComputerName'
    )]
    [String[]]
    $Name,

    [Parameter()]
    [Int]
    $AmountToAddGB = 10,

    [Parameter()]
    [Int]
    $MinumumFreeSpaceGB = 10
)

process {
    foreach ($nameValue in $Name) {
        $vm = $null
        $vm = Get-SCVirtualMachine -Name $nameValue
        if ($null -eq $vm) {
            Write-Warning -Message "Virtual Machine '$($vm.Name)' does not exist in VMM, please ensure the host and the guest are in the VMM database."
        } else {
            $osHardDisk = Get-SCVirtualHardDisk -VM $vm | Where-Object { $_.ID -eq $vm.OSDiskID }
            $osDiskDrive = Get-SCVirtualDiskDrive -VM $vm | Where-Object { $_.VirtualHardDiskId -eq $vm.OSDiskID }
            if ($null -ne $osHardDisk -and $null -ne $osDiskDrive) {
                $osHardDiskFreeSpace = [Math]::Round( ($osHardDisk.MaximumSize - $osHardDisk.Size) / 1GB )

                # If the freespace is less then the minimum free space specified, add space to existing OSDrive.
                if ($osHardDiskFreeSpace -lt $MinumumFreeSpaceGB) {
                    try {
                        Expand-SCVirtualDiskDrive -VirtualDiskDrive $osDiskDrive -VirtualHardDiskSizeGB ( [Math]::Round( ($osHardDisk.MaximumSize / 1GB) ) + $AmountToAddGB ) -ErrorAction Stop | Out-Null
                    } catch {
                        $PSCmdlet.ThrowTerminatingError(
                            $_
                        )

                        continue
                    }
                } else {
                    Write-Warning "Virtual Machine '$($vm.Name)' has $osHardDiskFreeSpace avaiable."

                    continue
                }

                if ($vm.Generation -ne 2) {
                    Write-Warning -Message "Virtual Machine '$($vm.Name)' is not generation 2, and the volume will need to be manually expanded."
                } else {
                    # Expand the partition via CIM.
                    try {
                        $cimSession = New-CimSession -ComputerName $vm
                    } catch {
                        $PSCmdlet.ThrowTerminatingError(
                            $_
                        )

                        continue
                    }

                    $osDriveLetter = (Get-CimInstance -CimSession $cimSession -ClassName Win32_OperatingSystem).SystemDirectory.SubString( 0,1 )
                    $osPartition = Get-Partition -CimSession $cimSession -DriveLetter $osDriveLetter
                    $recoveryPartition = Get-Partition -CimSession $cimSession | Where-Object { $_.Type -eq 'Recovery' }
                    if ($null -ne $recoveryPartition -and $recoveryPartition.PartitionNumber -gt $osPartition.PartitionNumber) {
                        if ($recoveryPartition.Size -lt 1GB) {
                            Write-Warning "Removing Recovery partition from '$($vm.Name)' to allow for the partition expansion."
                            Remove-Partition -CimSession $cimSession -InputObject $recoveryPartition -Confirm:$false
                        }
                    }

                    $partitionSizeMax = (Get-PartitionSupportedSize -CimSession $cimSession -DriveLetter $osDriveLetter).SizeMax
                    Resize-Partition -CimSession $cimSession -DriveLetter $osDriveLetter -Size $partitionSizeMax
                    $osPartitionNewSize = Get-Partition -CimSession $cimSession -DriveLetter $osDriveLetter | Select-Object -ExpandProperty Size

                    Remove-CimSession -CimSession $cimSession

                    [PSCustomObject]@{
                        Name = $vm.Name
                        OSDriveLetter = $osDriveLetter
                        OSPartiontType = $osPartition.Type
                        OSPartitionPreviousSizeGB = ( [Math]::Round(( $osPartition.Size / 1GB )))
                        OSPartitionNewSizeGB = ( [Math]::Round(( $osPartitionNewSize / 1GB )))
                    } | Write-Output
                }
            }
        }
    }
}
