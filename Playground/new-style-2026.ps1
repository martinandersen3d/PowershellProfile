Write-Host "────────────────────────────────────────────────────────────────────────────────────────"
Write-Host " Ctrl+Alt: | ▶ BOOKMARKS | ▼ SUBDIRS | ▲ Up | ◀ BACK | 'fn-' Tab | Type 'h' for help 🔎"
Write-Host "────────────────────────────────────────────────────────────────────────────────────────"



# Bind Cltr+Alt+Down to function s
Set-PSReadLineKeyHandler -Chord "Ctrl+Alt+DownArrow" -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("s")
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

# Function to get Windows Explorer pinned/bookmarked paths
# NOTE: do not "Run Code" from VScode. Only run in terminal
function fn-windows-explorer-list-bookmarks {
    <#
    .SYNOPSIS
        Gets all pinned paths from Windows Explorer (Quick Access)
    .DESCRIPTION
        Retrieves pinned folders from Windows Explorer's Quick Access section
        and returns only the accessible folder paths for use with fzf
    #>
    
    $allPaths = @()
    
    try {
        $shell = New-Object -ComObject Shell.Application
        $quickAccess = $shell.Namespace("shell:::{679f85cb-0220-4080-b29b-5540cc05aab6}")
        
        if ($quickAccess) {
            foreach ($item in $quickAccess.Items()) {
                if ($item.Path -and (Test-Path $item.Path -ErrorAction SilentlyContinue)) {
                    $allPaths += $item.Path
                }
            }
        }
    }
    catch {
        # Silently continue if Quick Access is not accessible
    }
    
    # Return unique paths
    $allPaths | Select-Object -Unique
}

function fn-windows-explorer-bookmarks-fzf {
    $selected = fn-windows-explorer-list-bookmarks | fzf
    if ($selected) {
        Set-Location $selected
    }
}

# Bind Cltr+Alt+Down to function s
Set-PSReadLineKeyHandler -Chord "Ctrl+Alt+RightArrow" -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("fn-windows-explorer-bookmarks-fzf")
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}