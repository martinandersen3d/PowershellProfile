function global:custom-cd {
    param(
        [Parameter(Position=0)]
        [string]$Path
    )

    try {
        if ($Path -eq "back") {
            $stack = Get-Location -Stack
            if ($null -eq $stack -or ($stack.Count -eq 0)) {
                Write-Host "Directory stack empty." -ForegroundColor Yellow
                return
            }
            Pop-Location
            return
        }

        if ($Path -eq "-") {
            Set-Location -Path -
            return
        }

        # Resolve the target path first
        $targetPath = if ([string]::IsNullOrWhiteSpace($Path)) { $HOME } else { Get-Item $Path }
        $currentPath = (Get-Location).Path

        # Only push to stack if we are actually moving to a DIFFERENT directory
        if ($targetPath.Path -ne $currentPath) {
            Push-Location $currentPath
            Set-Location $targetPath
        }
    }
    catch {
        Write-Error "cd: Cannot find path because it does not exist."
    }
}

Set-Alias -Name cd -Value custom-cd -Option AllScope -Force

# CTRL+Alt+LEFT = cd back
Set-PSReadLineKeyHandler -Chord "Ctrl+Alt+LeftArrow" -ScriptBlock {
    # Send the command to the current line and execute it
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("cd back")
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}