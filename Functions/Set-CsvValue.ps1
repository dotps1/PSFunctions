<#PSScriptInfo

.Version
    1.1
.Guid
    96c125d3-1a20-4282-b569-0da33be2d8c3
.Author
    Thomas J. Malkewitz @dotps1
.Tags
    Csv
.ProjectUri
    https://github.com/dotps1/PSFunctions
.ReleaseNotes
    Initial Release.

#>

<#

.Synopsis
    Sets a value in a row in a csv file.
.Description
    Sets a value or multiple values in the same row in a comma separated value.
.Inputs
    System.String
    System.Collections.Hashtable
.Outputs
    None
.Parameter Path
    System.String
    The path to the csv file to modify.
.Parameter Key
    System.String
    The csv header value to search in.
.Parameter Value
    System.String
    The value of the cell matching the Key.
.Parameter Hashtable
    System.Collections.HashTable
    A Hashtable containing the Key (Header) Value pairs to set in the row.
.Example
    PS C:\> Set-CsvValue -Path .\my.csv -Key "ComputerName" -Value "MyComputer" -Hashtable @{ Owner = "dotps1" }
.Example
    PS C:\> Set-CsvValue -Path .\my.csv -Key "ComputerName" -Value "MyComputer" -Hashtable @{ Owner = "dotps1"; Make = "Dell"; Model = "XPS 15" }
.Notes
    If there are multiple values in the column used to key off, each row will be updated.  Use a unique column value.
    Shout out to Miles Gratz (http://www.serveradventures.com/) for initial example for how to complete this.
.Link
    https://dotps1.github.io
.Link
    https://www.powershellgallery.com/packages/Set-CsvValue
.Link
    https://grposh.github.io

#>


[CmdletBinding()]
[OutputType(
    [Void]
)]

param (
    [Parameter(
        Mandatory = $true
    )]
    [ValidateScript({
        if (([System.IO.FileInfo]$_).Extension -eq ".csv") {
            return $true
        } else {
            throw "File must be a comma seperated value (*.csv)."
        }
    })]
    [String]
    $Path,

    [Parameter(
        Mandatory = $true
    )]
    [String]
    $Key,

    [Parameter(
        Mandatory = $true,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true
    )]
    [String[]]
    $Value,

    [Parameter(
        Mandatory = $true
    )]
    [Hashtable]
    $Hashtable
)

begin {
    $csv = Import-Csv -Path $Path
    $content = Get-Content -Path $Path

    if ($content.Count -ne ($csv.Count + 1)) {
        Write-Error -Message "Unsupported index."
        break
    }

    if ($Key -notin $csv[0].PSObject.Properties.Name) {
        Write-Error -Message "Column headers do not contain value: '$Key'."
        break
    }
}

process {
    foreach ($v in $Value) {
        $index = 1
        $csv.ForEach({
            if ($_.${Key} -eq $v) {
                foreach ($enum in $Hashtable.GetEnumerator()) {
                    $_.($enum.Name) = $enum.Value
                }

                $content[$index] = $_ | 
                    ConvertTo-Csv -NoTypeInformation |
                        Select-Object -Skip 1
            }

            $index++
        })
    }
}

end {
    Set-Content -Value $content -Path $Path -ErrorAction Stop
}
