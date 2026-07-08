<#
.SYNOPSIS
Lists all loaded functions named fn-* and prints each function's SYNTAX and SYNOPSIS.
#>
function fn-help-list-my-functions {
	function Get-HelpSectionText {
		param(
			[string]$HelpText,
			[string]$SectionName
		)

		$pattern = "(?ms)^\s*$SectionName\s*\r?\n(?<content>.*?)(?=^\s*[A-Z][A-Z0-9 _-]*\s*$|\z)"
		$match = [regex]::Match($HelpText, $pattern)
		if (-not $match.Success) {
			return $null
		}

		$match.Groups['content'].Value.TrimEnd()
	}

	$functionNames = Get-Command -CommandType Function -Name 'fn-*' |
		Select-Object -ExpandProperty Name |
		Sort-Object -Unique

	foreach ($functionName in $functionNames) {
		$helpText = Get-Help $functionName -Full | Out-String
		$syntax = Get-HelpSectionText -HelpText $helpText -SectionName 'SYNTAX'
		$synopsis = Get-HelpSectionText -HelpText $helpText -SectionName 'SYNOPSIS'

		if (-not [string]::IsNullOrWhiteSpace($syntax)) {
			Write-Host $syntax.Trim() -ForegroundColor Yellow
		}

		if (-not [string]::IsNullOrWhiteSpace($synopsis)) {
			Write-Host $synopsis.Trim()
		}

		Write-Host ''
	}
}
