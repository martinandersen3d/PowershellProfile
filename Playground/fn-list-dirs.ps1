function fn-list-subdirs-levels {
	param(
		[Parameter(Mandatory=$false, Position=0)]
		[ValidateRange(1, 1000)]
		[int]$Depth = 0,

		[Parameter(Mandatory=$false, Position=1)]
		[string]$Path = '.'
	)

	if ($Depth -eq 0) {
		Write-Host ""
		Write-Host "fn-list-dirs.ps1 - List subdirectories at a specific depth level" -ForegroundColor Cyan
		Write-Host ""
		Write-Host "USAGE:" -ForegroundColor Yellow
		Write-Host "  .\fn-list-dirs.ps1 <Depth> [Path]"
		return
	}

	try {
		$baseFull = (Get-Item -LiteralPath $Path).FullName
	} catch {
		Write-Error "Base path '$Path' not found."
		return
	}

	# Normalize separator and ensure trailing separator for reliable trimming
	$sep = [IO.Path]::DirectorySeparatorChar
	if (-not $baseFull.EndsWith($sep)) { $baseFull = $baseFull + $sep }

	# Folders to exclude
	$excludeFolders = @('.git', 'node_modules', 'bin', 'obj', '.vs', '.vscode', 'packages', 'dist', 'build', 'out')

	Get-ChildItem -LiteralPath $baseFull -Directory -Recurse -ErrorAction SilentlyContinue |
		Where-Object {
			# Check if any parent folder should be excluded
			$pathParts = $_.FullName.Substring($baseFull.Length).TrimStart($sep).Split($sep)
			$excluded = $false
			foreach ($part in $pathParts) {
				if ($excludeFolders -contains $part) {
					$excluded = $true
					break
				}
			}
			if ($excluded) { return $false }
			
			$relative = $_.FullName.Substring($baseFull.Length).TrimStart($sep)
			if ([string]::IsNullOrEmpty($relative)) { return $false }
			$levels = $relative.Split($sep) | Where-Object { $_ -ne '' } | Measure-Object | Select-Object -ExpandProperty Count
			return $levels -eq $Depth
		} |
		Sort-Object FullName |
		ForEach-Object { 
			$relativePath = $_.FullName.Substring($baseFull.Length).TrimStart($sep)
			Write-Output "- .$sep$relativePath$sep"    
		}
}
