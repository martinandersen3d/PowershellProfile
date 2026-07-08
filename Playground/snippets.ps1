function Get-Snippet {
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
                            Display = $DisplayStr
                            Code    = $CleanCode
                            Preview = "$SingleLineDesc`r`n`r`n$CleanCode"
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

    $SelectedLine = $Choices | fzf `
        --delimiter '\t' `
        --with-nth 2 `
        --preview $PreviewCommand `
        --preview-window 'top:55%:wrap' `
        --header="Select a snippet (Copies to clipboard)" `
        --height=90% `
        --reverse

    if ($SelectedLine) {
        # Split cleanly by the tab character to get the array index
        $SelectedIndex = [int]($SelectedLine -split "`t")[0]
        $SelectedSnippet = $AllSnippets[$SelectedIndex]
        
        if ($SelectedSnippet) {
            if (Get-Command Set-Clipboard -ErrorAction SilentlyContinue) {
                $SelectedSnippet.Code | Set-Clipboard
            }
            else {
                $SelectedSnippet.Code | clip.exe
            }

            Write-Host "Copied to clipboard!" -ForegroundColor Green
        }
    }
}
Get-Snippet