function Show-CustomArrayTable {
    param (
        [Parameter(Mandatory=$true)]
        [AllowEmptyCollection()]
        [ValidateNotNull()]
        [Object[][][]]$Arrays
    )

    foreach ($array in $Arrays) {
        # Convert the array elements to custom objects
        $tableRows = $array | ForEach-Object {
            [PSCustomObject]@{
                Column1 = $_[0]
                Column2 = $_[1]
            }
        }

        Write-Host "TABLE________________________________________________" -ForegroundColor Yellow
        $tableRows | Format-Table -AutoSize -HideTableHeaders
        # Write-Host "`n"
    }
}

$array1 = @(
    @("D", "List Directorys"),
    @("F", "List Files")
)

$array2 = @(
    @("GitCheatsheet", "GitCheatsheet"),
    @("SearchContent", "Search inside files with RipGrep")
)

Show-CustomArrayTable -Arrays @($array1, $array2)