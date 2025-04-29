# Only Works in PowerShell Version 7+

# (Get-Content -Raw -Path "example.json" | ConvertFrom-Json) | Out-GridView -Title "Json Data"
# (Get-Content -Raw -Path "example.json" | ConvertFrom-Json).People | Out-GridView -Title "Json Data"
function ShowJsonInGridView {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$Path,

        [Parameter(Position = 1)]
        [string]$Key
    )

    if (-not $Path) {
        Write-Host ""
        Write-Host "Usage:" -ForegroundColor Yellow
        Write-Host "Show-JsonArrayInGridView -Path '<PathToJson>' [-Key '<ArrayPropertyName>']"
        Write-Host ""
        Write-Host "Examples:"
        Write-Host "Show-JsonArrayInGridView -Path 'C:\data.json' -Key 'People'"
        Write-Host "Show-JsonArrayInGridView -Path 'C:\arrayonly.json'"
        return
    }

    if (-not (Test-Path $Path)) {
        Write-Error "Error: File '$Path' not found."
        return
    }

    try {
        $json = Get-Content -Raw -Path $Path | ConvertFrom-Json

        if ($Key) {
            if ($json.PSObject.Properties.Name -notcontains $Key) {
                throw "Key '$Key' not found in JSON."
            }
            $data = $json.$Key
        }
        else {
            # No key provided: Assume the object itself is an array OR find the first array property
            if ($json -is [System.Collections.IEnumerable] -and -not ($json -is [string])) {
                $data = $json
            }
            else {
                # Try to find a property that is an array
                $arrayProp = $json.PSObject.Properties | Where-Object {
                    $_.Value -is [System.Collections.IEnumerable] -and -not ($_.Value -is [string])
                } | Select-Object -First 1

                if ($arrayProp) {
                    Write-Host "Info: No key provided. Automatically using key '$($arrayProp.Name)'." -ForegroundColor Yellow
                    $data = $arrayProp.Value
                }
                else {
                    throw "No array found at the root level or inside properties."
                }
            }
        }

        if (-not ($data -is [System.Collections.IEnumerable])) {
            throw "The selected data is not an array."
        }

        $data | Out-GridView -Title ($Key ? $Key : "JSON Data")
    }
    catch {
        Write-Error "Error: $_"
    }
}
