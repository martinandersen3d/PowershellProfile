### PowerShell template profile 
### Version 1.03 - Tim Sneath <tim@sneath.org>
### From https://gist.github.com/timsneath/19867b12eee7fd5af2ba
###
### This file should be stored in $PROFILE.CurrentUserAllHosts
### If $PROFILE.CurrentUserAllHosts doesn't exist, you can make one with the following:
###    PS> New-Item $PROFILE.CurrentUserAllHosts -ItemType File -Force
### This will create the file and the containing subdirectory if it doesn't already 
###
### As a reminder, to enable unsigned script execution of local scripts on client Windows, 
### you need to run this line (or similar) from an elevated PowerShell prompt:
###   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
### This is the default policy on Windows Server 2012 R2 and above for server Windows. For 
### more information about execution policies, run Get-Help about_Execution_Policies.

# --------------------------------------------------------------------
# POWERSHELL INITALIZATION - When you start a new terminal
# --------------------------------------------------------------------

Clear-Host

# Only load Powershell version 7 and above
if ($PSVersionTable.PSVersion.Major -ge 7) {
    # Write-Host "────────────────────────────────────────────────────────────────────────────────────────"
    # Write-Host " Ctrl+Alt: | ▶ BOOKMARKS | ▼ SUBDIRS | ▲ Up | ◀ BACK | 'fn-' Tab | Type 'h' for help 🔎"
    # Write-Host "────────────────────────────────────────────────────────────────────────────────────────"
    # Write-Host ""
    $pipe = [char]0x007C  # |
    $rightArrow = [char]0x25B6   # ▶
    $downArrow = [char]0x25BC    # ▼
    $upArrow = [char]0x25B2      # ▲
    $leftArrow = [char]0x25C0    # ◀
    
Write-Host "────────────────────────────────────────────────────────────────────────────────────────
 Ctrl+Alt: $pipe $rightArrow BOOKMARKS $pipe $downArrow SUBDIRS $pipe $upArrow Up $pipe $leftArrow BACK $pipe 'fn-' Tab $pipe Type 'fn-help' for help
────────────────────────────────────────────────────────────────────────────────────────
"
}

# Only load Powershell below version 7
if ($PSVersionTable.PSVersion.Major -lt 7) {
    $pipe = [char]0x007C  # |
    $rightArrow = [char]0x25B6   # ▶
    $downArrow = [char]0x25BC    # ▼
    $upArrow = [char]0x25B2      # ▲
    $leftArrow = [char]0x25C0    # ◀
    Write-Host "--------------------------------------------------------------------------------------------"
    $ps5message =  " Ctrl+Num: $pipe $rightArrow 6:BOOKMARKS $pipe $downArrow 2:SUBDIRS $pipe $upArrow 8:Up $pipe $leftArrow 4:BACK $pipe 'fn-' Tab $pipe Type 'h' for help "
    Write-Host $ps5message
    Write-Host "--------------------------------------------------------------------------------------------"
    Write-Host ""
}

# --------------------------------------------------------------------
# CONFIGURATION & ENVIRONMENT VARIABLES
# --------------------------------------------------------------------
# BatCat: Tell batcat to use truecolors and theme
$Env:COLORTERM = 'truecolor'
$Env:BAT_THEME = 'Visual Studio Dark+'

# micro text editor
$env:MICRO_TRUECOLOR = "1"

# default fzf options for full‑color UI - VsCode-Dark inspired
$Env:FZF_DEFAULT_OPTS = @(
  '--ansi',
  '--color=fg:#d4d4d4,bg:#1e1e1e,hl:#569cd6',          # main UI
  '--color=fg+:#ffffff,bg+:#094771,hl+:#4fc1ff',        # selected entry
  '--color=prompt:#dcdcaa,pointer:#c586c0,marker:#ce9178',
  '--color=spinner:#9cdcfe,header:#808080,info:#9cdcfe'
) -join ' '

# Yazi file manager
$Env:YAZI_FILE_ONE = 'C:\Program Files\Git\usr\bin\file.exe'

# --------------------------------------------------------------------
# ALIASES
# --------------------------------------------------------------------
Set-Alias -Name d -Value fn-directory-list
Set-Alias -Name f -Value fn-file-list
Set-Alias -Name dd -Value fn-directory-list-as-table
Set-Alias -Name fn -Value fn-help-list-my-functions
Set-Alias -Name gen -Value fn-file-new-from-template
Set-Alias -Name y -Value fn-app-yasi
Set-Alias -Name snip -Value fn-snippets 
# Set UNIX-like aliases for the admin command, so sudo <command> will run the command
# with elevated rights. 
Set-Alias -Name su -Value admin
Set-Alias -Name sudo -Value admin

# --------------------------------------------------------------------
# APPS
# --------------------------------------------------------------------
function c. { code . }
function i. { code-insiders . }
function e. { explorer . }
function n { notepad $args }

# Yazi file manager ---------------------------------------------------

<#
.SYNOPSIS
    Launches Yazi and updates the shell location to the selected directory.
#>
function fn-app-yasi {
    $tmp = [System.IO.Path]::GetTempFileName()
    yazi $args --cwd-file="$tmp"
    $cwd = Get-Content -Path $tmp -Encoding UTF8
    if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path) {
        Set-Location -LiteralPath ([System.IO.Path]::GetFullPath($cwd))
    }
    Remove-Item -Path $tmp
}

# Micro: Open file  ---------------------------------------------------
# Open files with micro
<#
.SYNOPSIS
    Opens one or more files in micro, optionally using fzf to select files.
#>
function m {
    [CmdletBinding()]
    param (
        [string[]]$File
    )

    if (-not (Get-Command fzf -ErrorAction SilentlyContinue)) {
        Write-Error "fzf is not installed or not in PATH."
        return
    }
    if (-not (Get-Command micro -ErrorAction SilentlyContinue)) {
        Write-Error "micro editor is not installed or not in PATH."
        return
    }

    try {
        if ($File) {
            # Quote paths that may contain spaces
            $quoted = $File | ForEach-Object { "`"$($_)`"" }
            Invoke-Expression "micro $($quoted -join ' ')"
            return
        }

        Write-Host "Loading..."
        $files = Get-ChildItem -File -Recurse -ErrorAction SilentlyContinue |
            Where-Object {
                $_.FullName -notmatch '\\(node_modules|\.git)[\\\/]' -and
                $_.Extension -notmatch '\.(exe|dll|bin|jpg|jpeg|png|gif|bmp|zip|rar|7z|iso|mp4|mp3|avi|mov|pdf|docx?|xlsx?|pptx?)$'
            } |
            ForEach-Object {
                Resolve-Path -Relative $_.FullName
            }

        if (-not $files) {
            Write-Host "No suitable files found."
            return
        }

        $fzfArgs = @(
            '--multi'
            '--layout=reverse'
            '--header=Micro: Select files to open'
            '--preview=bat --theme="Visual Studio Dark+" --color=always {}'
        )
        $selected = $files | fzf @fzfArgs

        if ([string]::IsNullOrWhiteSpace($selected)) {
            Write-Host "No file selected."
            return
        }

        # Split into lines (even if only one), trim and verify
        $toOpen = $selected -split "`n" |
            ForEach-Object { $_.Trim('"') } |
            Where-Object { Test-Path $_ }

        if (-not $toOpen) {
            Write-Host "No valid files selected."
            return
        }

        # Quote each path and launch micro
        $quotedPaths = $toOpen | ForEach-Object { "`"$($_)`"" }
        Invoke-Expression "micro $($quotedPaths -join ' ')"
    }
    catch {
        Write-Error "An error occurred in function m: $_"
    }
}

# --------------------------------------------------------------------
# SCRIPT UPDATE
# --------------------------------------------------------------------
# Update scripts from the git repo
<#
.SYNOPSIS
    Downloads and executes the profile setup script from the repository.
#>
function fn-profile-download-script-update {
    $url = "https://github.com/martinandersen3d/PowershellProfile/raw/main/setup.ps1"
    try {
        $scriptContent = Invoke-RestMethod -Uri $url
        Invoke-Expression -Command $scriptContent
    }
    catch {
        Write-Error "An error occurred while executing the script from URL: $_"
    }
}

# --------------------------------------------------------------------
# KEYBINDINGS
# --------------------------------------------------------------------

# ================================================ CTRL+ALT+LEFT: cd back
<#
.SYNOPSIS
    Extends cd with stack navigation, fuzzy matching, and back navigation.
#>
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
        $targetPath = if ([string]::IsNullOrWhiteSpace($Path)) 
        { 
                $HOME 
        } 
        else { 
            if (Test-Path -Path $Path -PathType Container) {
                Get-Item $Path
            }
            else {
                $matchedDirs = Get-ChildItem -Path "." -Directory -ErrorAction SilentlyContinue |
                    Where-Object { $_.Name -ilike "*$Path*" }
                
                if ($matchedDirs) {
                    if ($null -eq $matchedDirs.Count -or $matchedDirs.Count -eq 1) {
                        $singleMatch = if ($null -eq $matchedDirs.Count) { $matchedDirs } else { $matchedDirs[0] }
                        Get-Item $singleMatch.FullName
                    }
                    else {
                        if (Get-Command fzf -ErrorAction SilentlyContinue) {
                            $arrow = [char]::ConvertFromUtf32(0x276F)
                            $selected = $matchedDirs | ForEach-Object { Resolve-Path -Relative $_.FullName } |
                                fzf --height 40% --layout=reverse --prompt=" Multiple Matches $arrow "
                            if ($selected) {
                                Get-Item $selected
                            }
                            else {
                                $null
                            }
                        }
                        else {
                            Get-Item $matchedDirs[0].FullName
                        }
                    }
                }
                else {
                    Write-Error "Path can not be found"
                    $null
                }
            }
        }
        $currentPath = (Get-Location).Path

        # Only push to stack if we are actually moving to a DIFFERENT directory
        if ($null -ne $targetPath -and $targetPath.Path -ne $currentPath) {
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

# ================================================ CTRL+ALT+UP: CD UP
# Push the current directory onto the stack before cd up one directory
<#
.SYNOPSIS
    Moves to the parent directory and stores the current location on the stack.
#>
function fn-cd-up {
    Push-Location (Get-Location)
    cd ..
}
# Bind Cltr+Alt+Up to function "cd .."
Set-PSReadLineKeyHandler -Chord "Ctrl+Alt+UpArrow" -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("fn-cd-up")
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

# ================================================ CTRL+ALT+LEFT: CD BACK
# Function to get Windows Explorer pinned/bookmarked paths
# NOTE: do not "Run Code" from VScode. Only run in terminal
<#
.SYNOPSIS
    Lists accessible pinned folders from Windows Explorer Quick Access.
#>
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

# ================================================
# Go to last directory by creation date
<#
.SYNOPSIS
    Navigates to the most recently created subdirectory in the current path.
#>
function cd-last {
    <#
    .SYNOPSIS
        Changes the location to the most recently created directory in the current folder.
    #>
    # Find the latest directory, ignoring files
    $lastDir = Get-ChildItem -Directory | 
               Sort-Object CreationTime -Descending | 
               Select-Object -First 1

    if ($lastDir) {
        Write-Host "Navigating to: $($lastDir.Name)" -ForegroundColor Cyan
        Set-Location -Path $lastDir.FullName
    } else {
        Write-Warning "No subdirectories found in the current folder."
    }
}

<#
.SYNOPSIS
    Selects a Quick Access bookmark with fzf and navigates to it.
#>
function fn-windows-explorer-bookmarks-fzf {
    $arrow = [char]::ConvertFromUtf32(0x276F)
    $selected = fn-windows-explorer-list-bookmarks | fzf --layout=reverse --prompt=" BOOKMARKS $arrow "
    if ($selected) {
        Push-Location (Get-Location)
        Set-Location $selected
    }
}

# Bind Cltr+Alt+Right to function "fn-windows-explorer-bookmarks-fzf"
Set-PSReadLineKeyHandler -Chord "Ctrl+Alt+RightArrow" -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("fn-windows-explorer-bookmarks-fzf")
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

# ================================================ CTRL+ALT+DOWN: CD SUBDIRS
# Interactive directory navigation tool: CD into subfolders via fzf with context-aware depth limits.
# Uses 2-level depth at root/home for speed, and 3-level depth elsewhere for project browsing,
# while filtering out noise folders (e.g., .git, node_modules) to maximize relevance.
<#
.SYNOPSIS
    Selects a subdirectory with fzf and navigates to it.
#>
function fn-subdirs-fzf {
    $exclude = "\.git|node_modules|bin|obj"
    $arrow = [char]::ConvertFromUtf32(0x276F)
    
    # Get current path to check against criteria
    $currentPath = (Get-Location).Path
    $homeDir = $HOME # C:\Users\m
    $rootDrive = [System.IO.Path]::GetPathRoot($currentPath) # C:\

    # Determine depth: Default to 5, reduce to 2 for Home or Root
    if ($currentPath -eq $homeDir -or $currentPath -eq $rootDrive) {
        $depth = 1 # 0, 1 = 2 levels
    } else {
        $depth = 3 # 0, 1, 2, 3, 4 = 5 levels
    }

    try {
        # Calculate depth beforehand for cleaner expansion
        $nextDepth = $depth + 1

        # Run Get-ChildItem with dynamic depth
        $selection = Get-ChildItem -Path "." -Recurse -Directory -Name -Depth $depth -ErrorAction SilentlyContinue |
                     Where-Object { $_ -notmatch $exclude } |
                     fzf --height 40% --layout=reverse --prompt=" SUBDIRS (Depth:$nextDepth) $arrow"
    
        if ($selection) {
            Push-Location (Get-Location)
            Set-Location "$selection"
        }
    }
    catch {
        <#Do this if a terminating exception happens#>
    }
}

# Bind Cltr+Alt+Down to function "fn-subdirs-fzf"
Set-PSReadLineKeyHandler -Chord "Ctrl+Alt+DownArrow" -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("fn-subdirs-fzf")
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

# Powershell 5 compatability: Only load Powershell below version 7
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Set-PSReadLineKeyHandler -Chord "Ctrl+NumPad4" -ScriptBlock {
        [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert("cd back")
        [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
    }
    Set-PSReadLineKeyHandler -Chord "Ctrl+NumPad8" -ScriptBlock {
        [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert("fn-cd-up")
        [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
    }
    Set-PSReadLineKeyHandler -Chord "Ctrl+NumPad6" -ScriptBlock {
        [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert("fn-windows-explorer-bookmarks-fzf")
        [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
    }
    Set-PSReadLineKeyHandler -Chord "Ctrl+NumPad2" -ScriptBlock {
        [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert("fn-subdirs-fzf")
        [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
    }
}



# --------------------------------------------------------------------
# AI
# --------------------------------------------------------------------
# Core base alias
Set-Alias -Name ai -Value copilot

<#
.SYNOPSIS
    Lists available Copilot skills from the local skills folder.
#>
function al-skills-list {
    Get-ChildItem -LiteralPath "$HOME\.copilot\skills" -Directory -Name
}

# Gemini 3.5 Flash (Medium Effort)
<#
.SYNOPSIS
    Runs Copilot CLI with the gemini-3.5-flash model.
#>
function ai-gemini-3_5-flash { copilot --model gemini-3.5-flash --effort medium @args }

# Claude Sonnet 4.6 (Medium Effort)
<#
.SYNOPSIS
    Runs Copilot CLI with the claude-sonnet-4.6 model.
#>
function ai-claude-sonnet-4_6 { copilot --model claude-sonnet-4.6 --effort medium @args }

# GPT 5.5 (Medium Effort)
<#
.SYNOPSIS
    Runs Copilot CLI with the gpt-5.5 model.
#>
function ai-gpt-5_5 { copilot --model gpt-5.5 --effort medium @args }

# GPT 5.3 Codex (Medium Effort)
<#
.SYNOPSIS
    Runs Copilot CLI with the gpt-5.3-codex model.
#>
function ai-gpt-5_3-codex { copilot --model gpt-5.3-codex --effort medium @args }

# --------------------------------------------------------------------
# CHEATSHEET / HELP 
# --------------------------------------------------------------------

<#
.SYNOPSIS
    Displays the Git cheatsheet file using bat.
#>
function fn-CheatsheetGit {
    $filePath = "$HOME\Documents\WindowsPowerShell\CheatSheet\git.md"
    if (Test-Path $filePath) {
        bat --paging=never  --style=plain $filePath
    } else {
        Write-Host "Cheatsheet not found: $filePath" -ForegroundColor Red
    }
}

<#
.SYNOPSIS
    Displays the PowerShell cheatsheet file using bat.
#>
function fn-CheatsheetPowershell {
    $filePath = "$HOME\Documents\WindowsPowerShell\CheatSheet\powershell.md"
    if (Test-Path $filePath) {
        bat --paging=never  --style=plain $filePath
    } else {
        Write-Host "Cheatsheet not found: $filePath" -ForegroundColor Red
    }
}

<#
.SYNOPSIS
    Displays the general help cheatsheet file using bat.
#>
function fn-help {
    $filePath = "$HOME\Documents\WindowsPowerShell\CheatSheet\help.md"
    if (Test-Path $filePath) {
        bat --paging=never  --style=plain $filePath
    } else {
        Write-Host "Cheatsheet not found: $filePath" -ForegroundColor Red
    }
}

# --------------------------------------------------------------------
# GIT
# --------------------------------------------------------------------
<#
.SYNOPSIS
    Stages all changes, creates a commit with a message, and pushes to the remote.
#>
function fn-gitCommitPush {
    param (
        [string]$Message
    )
    
    if (-not $Message) {
        Write-Host "Error: A commit message is required."
        return
    }
    
    # If message is passed, proceed with git add, commit, and push
    Write-Host "COMMAND: git add ."

    git add .
    Write-Host "COMMAND: git commit -m '$Message'"
    git commit -m "$Message"
    Write-Host "COMMAND: git push"
    git push
}

<#
.SYNOPSIS
    Pushes the current branch to the remote repository.
#>
function fn-gitPush {    
    Write-Host "COMMAND: git push"
    git push
}

<#
.SYNOPSIS
    Executes the auto-commit-and-push helper script from UserScripts.
#>
function fn-gitAutoCommitPush {
    $profileBasePath = Split-Path $PROFILE -Parent
    & "$profileBasePath\UserScripts\GitAutoCommitPush.ps1"
}

<#
.SYNOPSIS
    Shows changed files and previews diffs against HEAD with fzf.
#>
function fn-gitShowCurrentCommitDiffFzf {
    git status --porcelain | ForEach-Object { $_.Substring(3) } | fzf --header "[COMMIT DIFF]: CURRENT vs. HEAD" --header-first --preview "git diff HEAD -- {} | bat --color=always" --layout=reverse
}

<#
.SYNOPSIS
    Shows commit message preview using the UserScripts helper.
#>
function fn-gitShowCommitMessage {
    # Get the firectory name of the current powershell profile
    $profileBasePath = Split-Path $PROFILE -Parent
    & "$profileBasePath\UserScripts\GitShowCommitMessagePreview.ps1"
}

<#
.SYNOPSIS
    Compares current branch files to origin/dev and previews diffs with fzf.
#>
function fn-GitShowCurrentBranchVSDevFzf {
    git diff --name-only origin/dev | fzf --header "[PULLREQUEST DIFF]: HEAD vs. origin/dev" --header-first --preview "git diff origin/dev -- {} | bat --color=always" --layout=reverse
}

# --------------------------------------------------------------------
# NAVIGATION & FILE EDIT
# --------------------------------------------------------------------
# Useful shortcuts for traversing directories

function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function .... { Set-Location ..\..\.. }
function ..... { Set-Location ..\..\..\.. }
function cd.. { Set-Location .. }
function cd... { Set-Location ..\.. }
function cd.... { Set-Location ..\..\.. }
function cd..... { Set-Location ..\..\..\.. }

# --------------------------------------------------------------------
# DIRECTORYS 
# --------------------------------------------------------------------

<#
.SYNOPSIS
    Lists files and folders with type, size, and timestamp metadata.
#>
function ll {
    param (
        [string]$Path = "."
    )

    function Convert-Size {
        param ([long]$bytes)
        switch ($bytes) {
            { $_ -lt 1KB } { return "{0:N1} B" -f $bytes; break }
            { $_ -lt 1MB } { return "{0:N1} KB" -f ($bytes / 1KB); break }
            { $_ -lt 1GB } { return "{0:N1} MB" -f ($bytes / 1MB); break }
            { $_ -lt 1TB } { return "{0:N1} GB" -f ($bytes / 1GB); break }
            default        { return "{0:N1} TB" -f ($bytes / 1TB) }
        }
    }
    function Get-EmojiPrefix {
        param ($item)
    
        # Use Unicode escape sequences to represent emojis
        # $folderEmoji = [char]0x1F4C1  # 📁
        # $fileEmoji   = [char]0x1F4C4  # 📄
        $folderEmoji = "`u{1F4C1}"  # 📁
        $fileEmoji   = "`u{1F4C4}"  # 📄
    
        if ($item.PSIsContainer) {
            return $folderEmoji
        } else {
            return $fileEmoji
        }
    }
    # function Get-EmojiPrefix {
    #     param ($item)
    #     if ($item.PSIsContainer) {
    #         return "📁"
    #     } else {
    #         return "📄"
    #     }
    # }

    Get-ChildItem -Path $Path | ForEach-Object {
        $isFolder = $_.PSIsContainer
        [PSCustomObject]@{
            Name           = "$(Get-EmojiPrefix $_) $($_.Name)"
            Type           = if ($isFolder) { "Folder" } else { $_.Extension.TrimStart('.') }
            Size           = if ($isFolder) { "" } else { Convert-Size $_.Length }
            'Date Modified'= $_.LastWriteTime
            'Date Created' = $_.CreationTime
        }
    } | Format-Table -AutoSize
}


# Only load PS7-specific code if the current PowerShell version is 7 or higher
# This avoids syntax errors in PowerShell 5, which can't parse newer language features
if ($PSVersionTable.PSVersion.Major -ge 7) {

    function Is-Binary {
        param (
            [string]$filePath
        )

        # Read a portion of the file
        $byteArray = [System.IO.File]::ReadAllBytes($filePath)
        
        # Loop through each byte
        foreach ($byte in $byteArray) {
            # If any byte is outside the range of printable ASCII characters (0x20 - 0x7E), it's binary
            if ($byte -lt 0x20 -or $byte -gt 0x7E) {
                return $true
            }
        }
        
        # If all bytes are within the printable ASCII range, it's likely a text file
        return $false
    }
}


# List Dirs in current dir
<#
.SYNOPSIS
    Lists subdirectories in the current directory.
#>
function fn-directory-list { Get-ChildItem -Path . -Directory | Select-Object @{Name='SubPath';Expression={Split-Path $_.FullName -Leaf} } }

# List Dirs in current dir as table with columns
<#
.SYNOPSIS
    Shows directory contents in a multi-column table view.
#>
function fn-directory-list-as-table {
    Get-ChildItem | Format-Wide -Column 3
  }

# Navigate subdirectories with fzf
<#
.SYNOPSIS
    Selects a subdirectory with fzf and navigates to it.
#>
function s {
    if (!(Get-Command fzf -ErrorAction SilentlyContinue)) {
        Write-Host "fzf is not installed. Please install it and try again."
        Exit
    }
    
    $subdirectories = Get-ChildItem -Path . -Directory -Recurse -Depth 3 | Where-Object { (-not $_.Name.StartsWith(".git")) -and ($_.Name -ne "node_modules") } | Select-Object -ExpandProperty FullName 

    # Use fzf to select a subdirectory
    $selectedSubdirectory = $subdirectories | fzf --layout=reverse

    # Check if a directory is selected
    if ($selectedSubdirectory) {
        # Navigate to the selected subdirectory
        Set-Location $selectedSubdirectory
    } else {
        Write-Host "Nothing selected."
    }
}

# Preview Files in Dir With FZF
<#
.SYNOPSIS
    Opens fzf with file previews powered by bat.
#>
function fn-directory-preview-fzf {
    if (!(Get-Command fzf -ErrorAction SilentlyContinue)) {
        Write-Host "fzf is not installed. Please install it and try again."
        Exit
    }
    fzf --preview 'bat --theme="Visual Studio Dark+" --color=always {}' --layout=reverse
}

# It will get the sizes of the folders in the current directory, and show it as a table
<#
.SYNOPSIS
    Calculates and displays folder sizes in the current directory.
#>
function fn-directory-list-sizes {
    try {
        $folders = Get-ChildItem -Directory
        $folderInfo = @()
        
        foreach ($folder in $folders) {
            $folderSize = (Get-ChildItem $folder.FullName -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
            $folderInfo += [PSCustomObject]@{
                Name = $folder.Name
                Size_MB = [math]::Round($folderSize, 2)
            }
        }

        $folderInfo | Format-Table -AutoSize
    }
    catch {
        Write-Host "Error: $_"
    }
}
<#
.SYNOPSIS
    Searches recursively for directories by name pattern.
#>
function fn-directory-search-directory-name([string]$name = "") {
    Get-ChildItem -Directory -Recurse -Filter "*$name*" -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Output $_.FullName
    }
}

<#
.SYNOPSIS
    Lists subdirectories at a specific depth while excluding common build folders.
#>
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
# --------------------------------------------------------------------
# FILES 
# --------------------------------------------------------------------

<#
.SYNOPSIS
    Creates an empty file or overwrites an existing file with empty content.
#>
function touch([string]$file) {
    "" | Out-File $file -Encoding ASCII
}

# List files in current dir
<#
.SYNOPSIS
    Lists files in the current directory.
#>
function fn-file-list {  Get-ChildItem -Path . -File | Select-Object @{Name='SubPath';Expression={Split-Path $_.FullName -Leaf} } }

# It returns a list of paths, that matches the search pattern. Does the the rough equivalent of dir /s /b. For example, dirs *.png is dir /s /b *.png
<#
.SYNOPSIS
    Recursively lists file paths that match include patterns.
#>
function fn-file-filename-search {
    if ($args.Count -gt 0) {
        Get-ChildItem -Recurse -Include "$args" | Foreach-Object FullName
    } else {
        Get-ChildItem -Recurse | Foreach-Object FullName
    }
}

# Generate or copy a file from ~/MEGA/Templates to the current directory
# 1. Select the file
# 2. Rename to new filename
<#
.SYNOPSIS
    Copies a selected template file into the current directory and optionally renames it.
#>
function fn-file-new-from-template {
    if (!(Get-Command fzf -ErrorAction SilentlyContinue)) {
        Write-Host "fzf is not installed. Please install it and try again."
        Exit
    }
    
    $files = Get-ChildItem -Path "~/MEGA/Templates" -Recurse -File | Select-Object -ExpandProperty FullName

    # Use fzf to select a file
    $selectedFile = $files | fzf --layout=reverse --header="TEMPALTE: Copy File to Current Dir" --preview 'bat --theme="Visual Studio Dark+" --color=always {}'
    $currentDir = $PWD.Path
    # Check if a file is selected
    if ($selectedFile) {
        # Extract filename
        $fileName = Split-Path -Path $selectedFile -Leaf
        # Navigate to the selected subdirectory
        $newFileName = Read-Host -Prompt "TEMPLATE`n`nSelected: $fileName`nDir: $currentDir`n`n(Press Enter to keep the same name)`n`n`nEnter New Filename"
        
        # If no filename is given, then set it to the selected
        if ($newFileName -eq "") {
            $newFileName = $fileName 
        }

        # Check if the file already exists
        if (Test-Path -Path ".\$newFileName") {
            # Prompt user for confirmation
            $confirmation = Read-Host "File '$newFileName' already exists. Do you want to overwrite it? (Y/N)"
            
            # If user confirms, copy the file with force
            if ($confirmation -eq "Y" -or $confirmation -eq "y") {
                Copy-Item -Path "$selectedFile" -Destination ".\$newFileName" -Force -Confirm:$false
                
                Write-Host "`nCreated: $currentDir\$newFileName`n"
            }
            else {
                Write-Host "Operation aborted by user."
            }
        }
        else {
            # If file does not exist, simply copy it
            Copy-Item -Path "$selectedFile" -Destination ".\$newFileName"
            $currentDir = $PWD.Path
            Write-Host "`nCreated: $currentDir\$newFileName`n"
        }


    } else {
        Write-Host "Nothing selected."
    }
}

<#
.SYNOPSIS
    Imports a CSV file and shows it in Out-GridView.
#>
function fn-file-show-csv-in-table {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$Path,

        [Parameter(Position = 1)]
        [string]$Delimiter
    )

    if (-not $Path) {
        Write-Host ""
        Write-Host "Usage:" -ForegroundColor Yellow
        Write-Host "Show-CsvInGridView -Path '<PathToCsv>' [-Delimiter '<DelimiterCharacter>']"
        Write-Host ""
        Write-Host "Examples:"
        Write-Host "Show-CsvInGridView -Path 'C:\data.csv'"
        Write-Host "Show-CsvInGridView -Path 'C:\data.csv' -Delimiter ';'"
        Write-Host "Show-CsvInGridView -Path 'C:\data.csv' -Delimiter '`t'"

        return
    }

    if (-not (Test-Path $Path)) {
        Write-Error "Error: File '$Path' not found."
        return
    }

    try {
        if ($Delimiter) {
            # Validate: must be exactly one character
            if ($Delimiter.Length -ne 1) {
                throw "Delimiter must be exactly one character. Provided: '$Delimiter'"
            }

            Import-Csv -Path $Path -Delimiter $Delimiter | Out-GridView -Title ($Path | Split-Path -Leaf)
        }
        else {
            Import-Csv -Path $Path | Out-GridView -Title ($Path | Split-Path -Leaf)
        }
    }
    catch {
        Write-Error "Error: $_"
    }
}

# Searches all the content of files in the current diretory and subpaths for a given string
# example usage: Search-Content "TODO"
<#
.SYNOPSIS
    Searches file contents recursively while skipping common ignored folders.
#>
function fn-file-search-content {
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [string]$searchContent
    )

    # Step 1: Define an array of exclude strings
    $excludeDirs = @(
        "node_modules",
        "dist",
        "bin",
        "obj",
        "build",
        "out",
        "tmp",
        "temp",
        "coverage",
        ".cache",
        ".vs",
        ".idea"
        )

    # Step 1: Get a list of all subdirectories
    $subdirs = Get-ChildItem -Directory -Recurse

    # Step 2: Initialize an array to store the full names
    $subdirNames = @()

    # Step 3: Iterate over each subdirectory and add its full name to the array
    foreach ($subdir in $subdirs) {
        $subdirNames += $subdir.FullName
    }


    # Step 4: Initialize an array to store filtered directory names
    $subdirsFiltered = @()

    # Step 5: Iterate over each directory name and check if it should be excluded
    foreach ($dirName in $subdirNames) {
        $exclude = $false
        foreach ($excludedir in $excludeDirs) {
            if ($dirName -like "*\$excludedir*") {
                $exclude = $true
                break
            }
        }
        if (-not $exclude) {
            $subdirsFiltered += $dirName
        }
    }


    foreach ($path in $subdirsFiltered) {
        Write-Host ""
        Write-Host "$path" -ForegroundColor Yellow
        rg -i --context 1 "$searchContent" "$path"
    }
}

<#
.SYNOPSIS
    Searches recursively for files by partial filename.
#>
function fn-file-search-filename([string]$name) {
    Get-ChildItem -recurse -filter "*${name}*" -ErrorAction SilentlyContinue | ForEach-Object {
        $place_path = $_.directory
        Write-Output "${place_path}\${_}"
    }
}

<#
.SYNOPSIS
    Extracts a zip archive into the current directory.
#>
function fn-file-unzip ([string]$file) {
    Write-Output("Extracting", $file, "to", $pwd)
    $fullFile = Get-ChildItem -Path $pwd -Filter .\cove.zip | ForEach-Object { $_.FullName }
    Expand-Archive -Path $fullFile -DestinationPath $pwd
}

<#
.SYNOPSIS
    Searches text with Select-String in provided files or pipeline input.
#>
function fn-file-grep-in-file([string]$regex, [string]$dir) {
    if ( $dir ) {
        Get-ChildItem $dir | select-string $regex
        return
    }
    $input | select-string $regex
}

# --------------------------------------------------------------------
# INCLUDE SCRIPTS
# --------------------------------------------------------------------
. "$PSScriptRoot\UserScripts\G-JumpToDir.ps1"
. "$PSScriptRoot\UserScripts\fn-snippets.ps1"
. "$PSScriptRoot\UserScripts\fn-help-list-my-functions.ps1"


# Only load PS7-specific code if the current PowerShell version is 7 or higher
# This avoids syntax errors in PowerShell 5, which can't parse newer language features
if ($PSVersionTable.PSVersion.Major -ge 7) {
    . "$PSScriptRoot\UserScripts\fn-file-show-json-in-table-ps7.ps1"
}

# --------------------------------------------------------------------
# PROFILE
# --------------------------------------------------------------------
<#
.SYNOPSIS
    Displays the path to the active PowerShell profile.
#>
function fn-profile-show-path { Write-Host " Profile: $PROFILE" }
<#
.SYNOPSIS
    Reloads the active PowerShell profile.
#>
function fn-profile-reload { & $profile }
# Make it easy to edit this profile once it's installed
<#
.SYNOPSIS
    Opens the current profile for editing in ISE or Notepad.
#>
function fn-profile-edit-notepad {
    if ($host.Name -match "ise") {
        $psISE.CurrentPowerShellTab.Files.Add($profile.CurrentUserAllHosts)
    } else {
        notepad $profile.CurrentUserAllHosts
    }
}

<#
.SYNOPSIS
    Opens common PowerShell profile directories in File Explorer.
#>
function fn-profile-open-directory-in-explorer {
    # Open folder if it exists
    if (!(Test-Path -Path ($env:userprofile + "\Documents\WindowsPowerShell"))) {
        explorer ($env:userprofile + "\Documents\WindowsPowerShell")

    }
    if (!(Test-Path -Path ($env:userprofile + "\Documents\Powershell"))) {
        explorer ($env:userprofile + "\Documents\Powershell")
    }

    
}

# --------------------------------------------------------------------
# TERMINAL
# --------------------------------------------------------------------
<#
.SYNOPSIS
    Clears the screen and reloads the profile.
#>
function clr { 
    Clear-Host 
    & $profile
}
<#
.SYNOPSIS
    Clears the screen and reloads the profile.
#>
function clear { 
    Clear-Host 
    & $profile
}
<#
.SYNOPSIS
    Lists all current PSReadLine keybindings.
#>
function fn-show-all-terminal-hotkeys {
    Get-PSReadLineKeyHandler
}
# --------------------------------------------------------------------
# FUNCTIONS
# --------------------------------------------------------------------


<#
.SYNOPSIS
    Runs dotnet watch for the current project.
#>
function dotnetWatch { dotnet run watch }

# Print info about a file or dir
<#
.SYNOPSIS
    Shows metadata about a file or directory, including size details.
#>
function fn-info {
    param(
        [string]$Path
    )

    try {
        $item = Get-Item $Path -ErrorAction Stop
        Write-Host "Name: $($item.Name)"
        Write-Host "Type: $($item.GetType().Name)"
        Write-Host "Full Path: $($item.FullName)"
        
        if ($item -is [System.IO.FileInfo]) {
            $sizeMB = [math]::Round($item.Length / 1MB, 2)
            Write-Host "Size: $($sizeMB) MB"
        }
        elseif ($item -is [System.IO.DirectoryInfo]) {
            $totalSize = 0
            $childItems = Get-ChildItem $Path -Recurse
            foreach ($child in $childItems) {
                $totalSize += $child.Length
            }
            $totalSizeMB = [math]::Round($totalSize / 1MB, 2)
            Write-Host "Total Size: $($totalSizeMB) MB"
            Write-Host "Number of items inside: $($childItems.Count)"
        }
    }
    catch {
        Write-Host "Error: $_"
    }
}

<#
.SYNOPSIS
    Finds possible installation paths for a program from PATH and registry entries.
#>
function fn-locate {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProgramName
    )

    try {
        Write-Host "Searching for '$ProgramName'..." -ForegroundColor Cyan
        $pathsFound = [System.Collections.Generic.List[string]]::new()

        # 1. Check environmental PATH (Uses 'Get-Command' internally)
        $cliCheck = Get-Command $ProgramName -ErrorAction SilentlyContinue
        if ($cliCheck) {
            $pathsFound.Add($cliCheck.Source)
        }

        # 2. Check Windows Registry (Both 64-bit and 32-bit paths)
        $regPaths = @(
            "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
        )

        foreach ($regPath in $regPaths) {
            try {
                $apps = Get-ItemProperty $regPath -ErrorAction SilentlyContinue | 
                        Where-Object { $_.DisplayName -match $ProgramName -or $_.PSChildName -match $ProgramName }

                foreach ($app in $apps) {
                    if ($app.InstallLocation) {
                        $pathsFound.Add($app.InstallLocation)
                    } elseif ($app.UninstallString -match '"([^"]+)"|(\S+)') {
                        # Fallback: Extract directory from the uninstall string if InstallLocation is blank
                        $uninstallPath = $Matches[0].Trim('"')
                        if (Test-Path $uninstallPath) {
                            $pathsFound.Add((Split-Path $uninstallPath))
                        }
                    }
                }
            } catch {
                # Silently catch registry access errors for specific restricted keys
            }
        }

        # Output results
        $uniquePaths = $pathsFound | Select-Object -Unique
        if ($uniquePaths.Count -gt 0) {
            return $uniquePaths
        } else {
            Write-Warning "Could not find any installation paths matching '$ProgramName'."
        }
    }
    catch {
        Write-Error "An unexpected error occurred while locating the program: $_"
    }
}

# Simple function to start a new elevated process. If arguments are supplied then 
# a single command is started with admin rights; if not then a new admin instance
# of PowerShell is started.
<#
.SYNOPSIS
    Starts PowerShell or a command with elevated administrator privileges.
#>
function admin {
    if ($args.Count -gt 0) {   
        $argList = "& '" + $args + "'"
        Start-Process "$psHome\powershell.exe" -Verb runAs -ArgumentList $argList
    } else {
        Start-Process "$psHome\powershell.exe" -Verb runAs
    }
}

<#
.SYNOPSIS
    Checks whether a command is available in the current session.
#>
Function Test-CommandExists {
    Param ($command)
    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = 'SilentlyContinue'
    try { if (Get-Command $command) { RETURN $true } }
    Catch { Write-Host "$command does not exist"; RETURN $false }
    Finally { $ErrorActionPreference = $oldPreference }
} 

# --------------------------------------------------------------------
# HELP
# --------------------------------------------------------------------


# Call the function to list all methods in the PowerShell profile
<#
.SYNOPSIS
    Lists function definitions found in the current profile file.
#>
function fn-help-list-commands {
    try {
        $profilePath = $profile
        if (-not (Test-Path $profilePath)) {
            Write-Error "PowerShell profile not found."
            return
        }
        
        $profileContent = Get-Content $profilePath -Raw
        $profileMethods = [regex]::Matches($profileContent, 'function\s+([^({\s]+)')
        
        if ($profileMethods.Count -eq 0) {
            Write-Output "No custom methods found in the PowerShell profile."
            return
        }
        
        Write-Output "Methods in PowerShell profile:"
        $profileMethods | ForEach-Object {
            $_.Groups[1].Value
        }
    }
    catch {
        Write-Error "An error occurred: $_"
    }
}

function fn-help-alias-list-all { Get-Alias }

function fn-help-alias-list-profile-only {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$Name
    )

    try {
        # Determine whether to use 'pwsh' (PS Core) or 'powershell' (Windows PS)
        $psExe = if ($PSVersionTable.PSVersion.Major -ge 6) { "pwsh" } else { "powershell" }

        # Get aliases from a clean session without loading the profile
        $cleanAliases = & $psExe -NoProfile -Command { Get-Alias } -ErrorAction Stop

        # Compare current session aliases against the clean session
        $profileAliases = Compare-Object (Get-Alias) $cleanAliases -Property Name |
            Where-Object { $_.SideIndicator -eq '<=' } |
            ForEach-Object { Get-Alias $_.Name } |
            Select-Object Name, Definition

        # If a specific name filter was provided, filter the results
        if ($Name) {
            $profileAliases = $profileAliases | Where-Object { $_.Name -like "*$Name*" }
        }

        # Output the results
        if ($profileAliases) {
            return $profileAliases
        } else {
            Write-Warning "No custom profile aliases found."
        }
    }
    catch {
        Write-Error "Failed to retrieve profile aliases: $_"
    }
}

# JUNK SCRIPTS -------------------------------------------------------------------------------
# Compute file hashes - useful for checking successful downloads 
function md5 { Get-FileHash -Algorithm MD5 $args }
function sha1 { Get-FileHash -Algorithm SHA1 $args }
function sha256 { Get-FileHash -Algorithm SHA256 $args }
function fn-ip-get-PubIP {
    (Invoke-WebRequest http://ifconfig.me/ip ).Content
}

function which([string]$name) {
    Get-Command $name | Select-Object -ExpandProperty Definition
}

function pkill([string]$name) {
    Get-Process $name -ErrorAction SilentlyContinue | Stop-Process
}
function fn-process-grep([string]$name) {
    Get-Process $name
}

# Drive shortcuts
function HKLM: { Set-Location HKLM: }
function HKCU: { Set-Location HKCU: }
function Env: { Set-Location Env: }

# # Creates drive shortcut for Work Folders, if current user account is using it
# if (Test-Path "$env:USERPROFILE\Work Folders") {
#     New-PSDrive -Name Work -PSProvider FileSystem -Root "$env:USERPROFILE\Work Folders" -Description "Work Folders"
#     function Work: { Set-Location Work: }
# }


# --------------------------------------------------------------------
# PROMT STYLE
# --------------------------------------------------------------------
# Checks if .git exists in the current directory (indicating a Git repo).
# Runs git branch --show-current to get the active branch name.
# Displays the branch name with  (or you can replace it with another symbol).
# Uses 2>$null to suppress errors in case git is not available or the directory is not a repo.
# function prompt {

#     #  Lazy Load Autocompleters
#     if (-not $script:__completersLoaded) {
#         . "$PSScriptRoot\UserScripts\ArgumentCompleters.ps1"  # ← NOT executed at load time
#     }

#     $closedFolder = [char]::ConvertFromUtf32(0x1F4C1)  # Closed folder emoji
#     $arrow = [char]::ConvertFromUtf32(0x276F)  # Right angle arrow '❯'
#     # $adminPrefix = if ($isAdmin) { " [ADMIN]" } else { "" }
#     $path = $PWD.Path
#     $branch = if ($b = git branch --show-current 2>$null) { " [$b]" } else { "" }

#     $promptString = "$closedFolder $path$branch $arrow"
#     Write-Host -NoNewline $promptString -ForegroundColor Yellow
#     return " "
# }

# Color Theme - Set default typing colors (Wheat for both commands and arguments)
if (Get-Module PSReadLine) {
    $WheatColor = "$([char]27)[38;2;245;222;179m"
    $BrightGray = "$([char]27)[38;2;170;170;170m"
    $WhiteColor = "$([char]27)[38;2;255;255;255m"

    # History Listview inline prediction: https://ianmorozoff.com/2023/01/10/predictive-intellisense-on-by-default-in-powershell-7-3/
    # if ($PSVersionTable.PSVersion.Major -ge 7) {
    #     if ((Get-Command Set-PSReadLineOption).Parameters.ContainsKey('PredictionViewStyle')) {
    #         InlinePrediction = $BrightGray  # The predictive ghost/shadow text in bright gray
    #     }
    # }

    Set-PSReadLineOption -Colors @{
        Command          = $WheatColor  # Like 'cd', 'dir'
        Default          = $WhiteColor  # Like './Documents'
    }
}

function prompt {

    # Lazy Load Autocompleters
    if (-not $script:__completersLoaded) {
        . "$PSScriptRoot\UserScripts\ArgumentCompleters.ps1"
    }

    # ANSI Color Codes
    $Esc    = [char]27
    $Gold   = "$Esc[38;5;220m"
    $Orange = "$Esc[38;2;255;140;0m"
    $White  = "$Esc[97m"            # High-intensity crisp white for typing
    $Reset  = "$Esc[0m"

    $closedFolder = [char]::ConvertFromUtf32(0x1F4C1)  # Closed folder emoji
    $arrow = [char]::ConvertFromUtf32(0x276F)  # Right angle arrow '❯'
    $path = $PWD.Path
    
    # Get the branch (Orange), then immediately switch back to Yellow
    $branch = if ($b = git branch --show-current 2>$null) { "${Orange} [$b]${Gold}" } else { "" }

    # Construct the visual prompt string (stops right at the arrow)
    $promptString = "${Gold}$closedFolder $path$branch${Reset} $arrow"
    
    Write-Host -NoNewline $promptString
    
    # Passing White inside the return guarantees that your input stream uses it
    return " "
}


# --------------------------------------------------------------------
# Autocomplete with TAB Key
# --------------------------------------------------------------------
# Shows navigable menu of all options when hitting Tab
# https://techcommunity.microsoft.com/blog/itopstalkblog/autocomplete-in-powershell/2604524
# Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
if ($PSVersionTable.PSVersion.Major -ge 7) {
    try {
        Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
        # 1. Force predictions and completions into a single vertical list view
        Import-Module DirectoryPredictor
        Import-Module CompletionPredictor
        Set-PSReadLineOption -PredictionViewStyle ListView
        Set-PSReadLineOption -PredictionSource HistoryAndPlugin
        Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
        Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
    }
    catch {
        Write-Error "Failed to configure vertical list options: $_"
    }

}

# ----------------------------------------------------------------------------
# CD command Autocomplete with TAB Key in FZF - Install: Install-Module -Name PSFzf -Scope CurrentUser
# ----------------------------------------------------------------------------

# This replaces the standard Tab completion with fzf
# Set-PSReadLineKeyHandler -Key Tab -ScriptBlock {
#     # Check if the function exists; if not, source the script or module
#     if (-not (Get-Command Invoke-FzfTabCompletion -ErrorAction SilentlyContinue)) {
#     }
    
#     # Now that it's loaded, invoke it
#     Invoke-FzfTabCompletion
# }

# https://www.poppastring.com/blog/powershell-intellisense-completion
# https://devblogs.microsoft.com/powershell/announcing-psreadline-2-1-with-predictive-intellisense/
# https://mertsenel.tech/post/mypowershellswissknife/
# https://www.thomasmaurer.ch/2021/02/powershell-predictive-intellisense/
# https://learn.microsoft.com/en-us/powershell/scripting/dev-cross-plat/create-cmdline-predictor?view=powershell-7.4

# Bind a key to a function:
# - Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
# Argument Completer:
# - tab completion carries out either a default completion, or built-in cmdlet, or even a custom function.  
# - Register-ArgumentCompleter 
# PSReadLine 2.1+ with Predictive IntelliSense:
# - https://devblogs.microsoft.com/powershell/announcing-psreadline-2-1-with-predictive-intellisense/


