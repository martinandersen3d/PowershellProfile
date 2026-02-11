Import-Module PSFzf

Set-PSReadLineKeyHandler -Key Tab -ScriptBlock {
    # Check if the function exists; if not, source the script or module
    if (-not (Get-Command Invoke-FzfTabCompletion -ErrorAction SilentlyContinue)) {
        # Replace the path below with your actual fzf-powershell script/module path
        # . "$HOME\.config\powershell\scripts\fzf-completion.ps1"
    }
    
    # Now that it's loaded, invoke it
    Invoke-FzfTabCompletion
}