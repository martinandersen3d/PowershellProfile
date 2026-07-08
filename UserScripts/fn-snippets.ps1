# Folder has markdown documents.
# They are formattet:
# 1. Description
# 2. Codeblock ``` ... ```
# 3. Horizontal line "---"
#
# - There can be many in a single markdown file
# - The codeblock can be multiline
# 
# Example (Git.md):
# Git Log: Show compact decorated history.
# ```bash
# git log --oneline --decorate
# ```
# ---

function Resolve-SnippetTemplate {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Code
    )

    $PlaceholderPattern = '<(?<name>[^<>\r\n]+)>'
    $Matches = [regex]::Matches($Code, $PlaceholderPattern)
    if ($Matches.Count -eq 0) {
        return $Code
    }

    $Values = @{}
    foreach ($Match in $Matches) {
        $Name = $Match.Groups['name'].Value.Trim()
        if (-not $Name) { continue }

        if (-not $Values.ContainsKey($Name)) {
            $Values[$Name] = Read-Host "Enter value for <$Name>"
        }
    }

    return [regex]::Replace($Code, $PlaceholderPattern, {
        param($Match)

        $Name = $Match.Groups['name'].Value.Trim()
        if ($Values.ContainsKey($Name)) {
            return $Values[$Name]
        }

        return $Match.Value
    })
}

function fn-snippets {
    $SnippetDir = "$HOME/MEGA/CLI"
    
    if (-not (Test-Path $SnippetDir)) {
        Write-Error "Snippet directory not found at $SnippetDir. Please create it."
        return
    }

    if (-not (Get-Command fzf -ErrorAction SilentlyContinue)) {
        Write-Error "fzf is not installed or not in PATH."
        return
    }

    $Files = @(Get-ChildItem -Path $SnippetDir -Filter *.md -File)
    if ($Files.Count -eq 0) {
        Write-Warning "No markdown files found in $SnippetDir"
        return
    }

    $AllSnippets = New-Object 'System.Collections.Generic.List[object]'
    $CodeBlockPattern = '(?ms)^\s*(?<description>.*?)(?:(?<fence>\x60{3,})[^\r\n\x60]*\r?\n(?<fencedCode>.*?)\r?\n^\k<fence>[ \t]*(?:\r?\n)?\s*$|\x60(?<inlineCode>[^\x60]*)\x60)'
    $CodeBlockRegex = New-Object System.Text.RegularExpressions.Regex($CodeBlockPattern)

    foreach ($File in $Files) {
        try {
            $Category = $File.BaseName
            $Content = Get-Content -Raw -Path $File.FullName
            $Blocks = $Content -split '(?m)^\s*-{3,}\s*$'

            foreach ($Block in $Blocks) {
                if ([string]::IsNullOrWhiteSpace($Block)) { continue }

                $CodeMatch = $CodeBlockRegex.Match($Block)
                if ($CodeMatch.Success) {
                    $Desc = $CodeMatch.Groups['description'].Value.Trim()
                    $CleanCode = if ($CodeMatch.Groups['fencedCode'].Success) {
                        $CodeMatch.Groups['fencedCode'].Value
                    }
                    else {
                        $CodeMatch.Groups['inlineCode'].Value
                    }

                    if ($Desc -and $CleanCode) {
                        $SingleLineDesc = ($Desc -replace '\s*\r?\n\s*', ' ').Trim()
                        $DisplayStr = "[$Category] $SingleLineDesc"

                        [void]$AllSnippets.Add([PSCustomObject]@{
                            Display     = $DisplayStr
                            Description = $SingleLineDesc
                            Code        = $CleanCode
                            Preview     = "$SingleLineDesc`r`n`r`n$CleanCode"
                        })
                    }
                }
            }
        }
        catch {
            Write-Error "Failed to process file $($File.Name): $_"
        }
    }

    if ($AllSnippets.Count -eq 0) {
        Write-Warning "No valid snippets parsed from markdown files."
        return
    }

    # Use a standard Tab character (`t) to split columns. 
    # It is universally supported and won't corrupt across character encodings.
    $Choices = New-Object 'System.Collections.Generic.List[string]'
    for ($i = 0; $i -lt $AllSnippets.Count; $i++) {
        [void]$Choices.Add("$i`t$($AllSnippets[$i].Display)")
        
        # Keep environment variable assignments in process memory
        [System.Environment]::SetEnvironmentVariable("SNIP_$i", $AllSnippets[$i].Code, [System.EnvironmentVariableTarget]::Process)
        [System.Environment]::SetEnvironmentVariable("SNIP_PREVIEW_$i", $AllSnippets[$i].Preview, [System.EnvironmentVariableTarget]::Process)
    }

    # Force fzf to use powershell to run the preview command.
    # Pass the selected row as an argument so PowerShell can resolve SNIP_PREVIEW_INDEX safely.
    $PowerShellCommand = (Get-Command powershell.exe -ErrorAction SilentlyContinue).Source
    if (-not $PowerShellCommand) {
        $PowerShellCommand = 'powershell.exe'
    }

    $PreviewScript = '& { param([string]$Line) $Index = ($Line -split [char]9, 2)[0]; [System.Environment]::GetEnvironmentVariable((''SNIP_PREVIEW_'' + $Index), ''Process'') }'
    $PreviewCommand = '"{0}" -NoProfile -ExecutionPolicy Bypass -Command "{1}" {{}}' -f $PowerShellCommand, $PreviewScript

    $FzfResult = @($Choices | fzf `
        --expect=ctrl-space `
        --delimiter '\t' `
        --with-nth 2 `
        --preview $PreviewCommand `
        --preview-window 'top:15%:wrap' `
        --header="Enter: copy | Ctrl-Space: fill <params> and copy" `
        --height=90% `
        --reverse)

    if ($FzfResult.Count -eq 0) {
        return
    }

    $PressedKey = $null
    $SelectedLine = $FzfResult[0]
    if ([string]::IsNullOrEmpty($SelectedLine) -and $FzfResult.Count -ge 2) {
        $SelectedLine = $FzfResult[1]
    }
    elseif ($FzfResult[0] -eq 'ctrl-space') {
        $PressedKey = $FzfResult[0]
        if ($FzfResult.Count -lt 2) {
            return
        }

        $SelectedLine = $FzfResult[1]
    }

    if ($SelectedLine) {
        # Split cleanly by the tab character to get the array index
        $SelectedIndex = [int]($SelectedLine -split "`t")[0]
        $SelectedSnippet = $AllSnippets[$SelectedIndex]
        
        if ($SelectedSnippet) {
            $OutputCode = $SelectedSnippet.Code
            $OutputPreview = "$($SelectedSnippet.Description)`r`n`r`n$OutputCode"
            $Divider = [string]([char]0x2500) * $Host.UI.RawUI.WindowSize.Width

            Write-Host $Divider -ForegroundColor DarkGray
            Write-Output $OutputPreview
            Write-Host $Divider -ForegroundColor DarkGray

            if ($PressedKey -eq 'ctrl-space') {
                Write-Host ""
                $OutputCode = Resolve-SnippetTemplate $SelectedSnippet.Code
                $OutputPreview = "$($SelectedSnippet.Description)`r`n`r`n$OutputCode"

                Write-Host ""
                Write-Host $Divider -ForegroundColor DarkGray
                Write-Output $OutputPreview
                Write-Host $Divider -ForegroundColor DarkGray
            }

            if (Get-Command Set-Clipboard -ErrorAction SilentlyContinue) {
                $OutputCode | Set-Clipboard
            }
            else {
                $OutputCode | clip.exe
            }

            Write-Host ""
            Write-Host " ✅ Copied to clipboard!" -ForegroundColor Green
            Write-Host ""

        }
    }
}
