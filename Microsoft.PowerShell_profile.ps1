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

# Find out if the current user identity is elevated (has admin rights)
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal $identity
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# --------------------------------------------------------------------
# POWERSHELL INITALIZATION - When you start a new terminal
# --------------------------------------------------------------------

Clear-Host

Write-Host "────────────────────────────────────────────────────────────────────────────────────────"
Write-Host " Ctrl+Alt: | ▶ BOOKMARKS | ▼ SUBDIRS | ▲ Up | ◀ BACK | 'fn-' Tab | Type 'h' for help 🔎"
Write-Host "────────────────────────────────────────────────────────────────────────────────────────"
Write-Host ""

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

# Yazi file manager
function y {
    $tmp = [System.IO.Path]::GetTempFileName()
    yazi $args --cwd-file="$tmp"
    $cwd = Get-Content -Path $tmp -Encoding UTF8
    if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path) {
        Set-Location -LiteralPath ([System.IO.Path]::GetFullPath($cwd))
    }
    Remove-Item -Path $tmp
}

# Set UNIX-like aliases for the admin command, so sudo <command> will run the command
# with elevated rights. 
Set-Alias -Name su -Value admin
Set-Alias -Name sudo -Value admin

# Set-Alias WinGetInstall winget install
# Set-Alias WinGetSearch winget search
# Set-Alias WinGetShow winget show
# Set-Alias WinGetUninstall winget uninstall

# --------------------------------------------------------------------
# SCRIPT UPDATE
# --------------------------------------------------------------------
# Update scripts from the git repo
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

# ================================================ CTRL+ALT+UP: CD UP
# Push the current directory onto the stack before cd up one directory
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
    $arrow = [char]::ConvertFromUtf32(0x276F)
    $selected = fn-windows-explorer-list-bookmarks | fzf --layout=reverse --prompt=" BOOKMARKS $arrow "
    if ($selected) {
        Push-Location $selected
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
# Uses 2-level depth at root/home for speed, and 5-level depth elsewhere for project browsing,
# while filtering out noise folders (e.g., .git, node_modules) to maximize relevance.
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
        $depth = 4 # 0, 1, 2, 3, 4 = 5 levels
    }

    # Run Get-ChildItem with dynamic depth
    $selection = Get-ChildItem -Path "." -Recurse -Directory -Name -Depth $depth -ErrorAction SilentlyContinue |
                 Where-Object { $_ -notmatch $exclude } |
                 fzf --height 40% --layout=reverse --prompt=" SUBDIRS (Depth:$( $depth + 1 )) $arrow "

    if ($selection) {
        Push-Location $selection
        Set-Location $selection
    }
}

# Bind Cltr+Alt+Down to function "fn-subdirs-fzf"
Set-PSReadLineKeyHandler -Chord "Ctrl+Alt+DownArrow" -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("fn-subdirs-fzf")
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

# --------------------------------------------------------------------
# CHEATSHEET / HELP 
# --------------------------------------------------------------------

function fn-CheatsheetGit {
    $filePath = "$HOME\Documents\WindowsPowerShell\CheatSheet\git.md"
    if (Test-Path $filePath) {
        bat --paging=never  --style=plain $filePath
    } else {
        Write-Host "Cheatsheet not found: $filePath" -ForegroundColor Red
    }
}

function fn-CheatsheetPowershell {
    $filePath = "$HOME\Documents\WindowsPowerShell\CheatSheet\powershell.md"
    if (Test-Path $filePath) {
        bat --paging=never  --style=plain $filePath
    } else {
        Write-Host "Cheatsheet not found: $filePath" -ForegroundColor Red
    }
}

# --------------------------------------------------------------------
# GIT
# --------------------------------------------------------------------
function fn-GitCommitPush {
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

function fn-GitPush {    
    Write-Host "COMMAND: git push"
    git push
}

function fn-GitAutoCommitPush {
    # Get the firectory name of the current powershell profile
    $profileBasePath = Split-Path $PROFILE -Parent
    & "$profileBasePath\UserScripts\GitAutoCommitPush.ps1"
}

function fn-GitShowCurrentCommitDiffFzf {
    git status --porcelain | ForEach-Object { $_.Substring(3) } | fzf --header "[COMMIT DIFF]: CURRENT vs. HEAD" --header-first --preview "git diff HEAD -- {} | bat --color=always" --layout=reverse
}
function fn-GitShowCommitMessage {
    # Get the firectory name of the current powershell profile
    $profileBasePath = Split-Path $PROFILE -Parent
    & "$profileBasePath\UserScripts\GitShowCommitMessagePreview.ps1"
}
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

# Fzf Subdirs 3 leves down, that does not start with  ".git" or is "node_modules"
# function s { Get-ChildItem -Path . -Directory -Recurse -Depth 3 | Where-Object { (-not $_.Name.StartsWith(".git")) -and ($_.Name -ne "node_modules") } | Select-Object -ExpandProperty FullName | fzf --layout=reverse | Set-Location }

# List Dirs in current dir
function d { Get-ChildItem -Path . -Directory | Select-Object @{Name='SubPath';Expression={Split-Path $_.FullName -Leaf} } }

# List Dirs in current dir as table with columns
function dd {
    Get-ChildItem | Format-Wide -Column 3
  }
 

# List files in current dir
function f {  Get-ChildItem -Path . -File | Select-Object @{Name='SubPath';Expression={Split-Path $_.FullName -Leaf} } }

# Navigate subdirectories with fzf
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

. "$PSScriptRoot\UserScripts\G-JumpToDir.ps1"

# Drive shortcuts
function HKLM: { Set-Location HKLM: }
function HKCU: { Set-Location HKCU: }
function Env: { Set-Location Env: }

# Does the the rough equivalent of dir /s /b. For example, dirs *.png is dir /s /b *.png
function dirs {
    if ($args.Count -gt 0) {
        Get-ChildItem -Recurse -Include "$args" | Foreach-Object FullName
    } else {
        Get-ChildItem -Recurse | Foreach-Object FullName
    }
}

# Preview Files in Dir With FZF
function fn-preview-directory {
    if (!(Get-Command fzf -ErrorAction SilentlyContinue)) {
        Write-Host "fzf is not installed. Please install it and try again."
        Exit
    }
    fzf --preview 'bat --theme="Visual Studio Dark+" --color=always {}' --layout=reverse
}

# Generate or copy a file from ~/Templates to the current directory
# 1. Select the file
# 2. Rename to new filename
function fn-file-new-from-template {
    if (!(Get-Command fzf -ErrorAction SilentlyContinue)) {
        Write-Host "fzf is not installed. Please install it and try again."
        Exit
    }
    
    $files = Get-ChildItem -Path "~/Templates" -Recurse -File | Select-Object -ExpandProperty FullName

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

function fn-ShowCsvInGridView {
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

# Only load PS7-specific code if the current PowerShell version is 7 or higher
# This avoids syntax errors in PowerShell 5, which can't parse newer language features
if ($PSVersionTable.PSVersion.Major -ge 7) {
    . "$PSScriptRoot\UserScripts\ShowJsonInGridView-Powershell-7.ps1"
}


# Print info about a file or dir
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

# It will get the sizes of the folders in the current directory, and show it as a table
function fn-get-folderSizes {
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

# Searches all the content of files in the current diretory and subpaths for a given string
# example usage: Search-Content "TODO"
function fn-SearchContent {
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

function fn-SearchFileName($name) {
    Get-ChildItem -recurse -filter "*${name}*" -ErrorAction SilentlyContinue | ForEach-Object {
        $place_path = $_.directory
        Write-Output "${place_path}\${_}"
    }
}

function fn-SearchFolderName([string]$name = "") {
    Get-ChildItem -Directory -Recurse -Filter "*$name*" -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Output $_.FullName
    }
}


# --------------------------------------------------------------------
# PROFILE
# --------------------------------------------------------------------
function fn-profile-show-path { Write-Host " Profile: $PROFILE" }
function fn-profile-reload { & $profile }
# Make it easy to edit this profile once it's installed
function fn-profile-edit-notepad {
    if ($host.Name -match "ise") {
        $psISE.CurrentPowerShellTab.Files.Add($profile.CurrentUserAllHosts)
    } else {
        notepad $profile.CurrentUserAllHosts
    }
}

# Call the function to list all methods in the PowerShell profile
function fn-list-commands {
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
# PACKAGE MANAGER
# --------------------------------------------------------------------
function choco-search {
    param (
        [string]$Query
    )

    choco search $Query
}

function choco-install {
    param (
        [string]$PackageName
    )

    choco install $PackageName
}

# takes multiple names as argument
function choco-info {
    param(
        [string[]]$packages
    )

    foreach ($package in $packages) {
        Write-Host "=== $package ======================================================="
        choco info $package
        Write-Host ""
    }
}

# --------------------------------------------------------------------
# TERMINAL
# --------------------------------------------------------------------
function clr { 
    Clear-Host 
    & $profile
}
function clear { 
    Clear-Host 
    & $profile
}

# --------------------------------------------------------------------
# FUNCTIONS
# --------------------------------------------------------------------
function c. { code . }
function e. { explorer . }
function n { notepad $args }


function dotnetWatch { dotnet run watch }


# Open files with micro
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


# If so and the current host is a command line, then change to red color 
# as warning to user that they are operating in an elevated context

# Set up command prompt and window title. Use UNIX-style convention for identifying 
# whether user is elevated (root) or not. Window title shows current version of PowerShell
# and appends [ADMIN] if appropriate for easy taskbar identification
function prompt { 
    if ($isAdmin) {
        "[" + (Get-Location) + "] # " 
    } else {
        "[" + (Get-Location) + "] $ "
    }
}

$Host.UI.RawUI.WindowTitle = "PowerShell {0}" -f $PSVersionTable.PSVersion.ToString()
if ($isAdmin) {
    $Host.UI.RawUI.WindowTitle += " [ADMIN]"
}



# Simple function to start a new elevated process. If arguments are supplied then 
# a single command is started with admin rights; if not then a new admin instance
# of PowerShell is started.
function admin {
    if ($args.Count -gt 0) {   
        $argList = "& '" + $args + "'"
        Start-Process "$psHome\powershell.exe" -Verb runAs -ArgumentList $argList
    } else {
        Start-Process "$psHome\powershell.exe" -Verb runAs
    }
}

# We don't need these any more; they were just temporary variables to get to $isAdmin. 
# Delete them to prevent cluttering up the user profile. 
Remove-Variable identity
Remove-Variable principal

Function Test-CommandExists {
    Param ($command)
    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = 'SilentlyContinue'
    try { if (Get-Command $command) { RETURN $true } }
    Catch { Write-Host "$command does not exist"; RETURN $false }
    Finally { $ErrorActionPreference = $oldPreference }
} 

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



function fn-unzip ($file) {
    Write-Output("Extracting", $file, "to", $pwd)
    $fullFile = Get-ChildItem -Path $pwd -Filter .\cove.zip | ForEach-Object { $_.FullName }
    Expand-Archive -Path $fullFile -DestinationPath $pwd
}

function fn-grep($regex, $dir) {
    if ( $dir ) {
        Get-ChildItem $dir | select-string $regex
        return
    }
    $input | select-string $regex
}
function touch($file) {
    "" | Out-File $file -Encoding ASCII
}

# Start firefox with json file file
function fn-json {
    param (
        [string]$FilePath
    )

    Start-Process -FilePath 'C:\Program Files\Mozilla Firefox\firefox.exe' -ArgumentList '-new-tab', $FilePath
}

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

# JUNK SCRIPTS -------------------------------------------------------------------------------
# Compute file hashes - useful for checking successful downloads 
function md5 { Get-FileHash -Algorithm MD5 $args }
function sha1 { Get-FileHash -Algorithm SHA1 $args }
function sha256 { Get-FileHash -Algorithm SHA256 $args }
function Get-PubIP {
    (Invoke-WebRequest http://ifconfig.me/ip ).Content
}
function uptime {
    #Windows Powershell only
	If ($PSVersionTable.PSVersion.Major -eq 5 ) {
		Get-WmiObject win32_operatingsystem |
        Select-Object @{EXPRESSION={ $_.ConverttoDateTime($_.lastbootuptime)}} | Format-Table -HideTableHeaders
	} Else {
        net statistics workstation | Select-String "since" | foreach-object {$_.ToString().Replace('Statistics since ', '')}
    }
}
# function df {
#     get-volume
# }
# function sed($file, $find, $replace) {
#     (Get-Content $file).replace("$find", $replace) | Set-Content $file
# }
function which($name) {
    Get-Command $name | Select-Object -ExpandProperty Definition
}
# function export($name, $value) {
#     set-item -force -path "env:$name" -value $value;
# }
function pkill($name) {
    Get-Process $name -ErrorAction SilentlyContinue | Stop-Process
}
function pgrep($name) {
    Get-Process $name
}


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
function prompt {
    $closedFolder = [char]::ConvertFromUtf32(0x1F4C1)  # Closed folder emoji
    $arrow = [char]::ConvertFromUtf32(0x276F)  # Right angle arrow '❯'
    $adminPrefix = if ($isAdmin) { " [ADMIN]" } else { "" }
    $path = $PWD.Path
    $branch = ""

    # Check if inside a Git repository (even in subdirectories)
    if (git rev-parse --is-inside-work-tree 2>$null) {
        $branch = git branch --show-current 2>$null
        if ($branch) {
            $branch = " <$branch>"  # Git branch symbol
        }
    }

    $promptString = "$closedFolder$adminPrefix $path$branch $arrow"
    Write-Host -NoNewline $promptString -ForegroundColor Yellow
    return " "
}



# --------------------------------------------------------------------
# Autocomplete with TAB Key
# --------------------------------------------------------------------
# Shows navigable menu of all options when hitting Tab
# https://techcommunity.microsoft.com/blog/itopstalkblog/autocomplete-in-powershell/2604524
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete

# Dotnet command Autocomplete with TAB Key -----------------------------------------------------------------
# https://learn.microsoft.com/en-us/dotnet/core/tools/enable-tab-autocomplete?WT.mc_id=modinfra-35653-salean#powershell
# PowerShell parameter completion shim for the dotnet CLI
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
        dotnet complete --position $cursorPosition "$commandAst" | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}

# ----------------------------------------------------------------------------
# GIT command Autocomplete with TAB Key
# ----------------------------------------------------------------------------

# Look here for inspiration: https://github.com/kzrnm/git-completion-pwsh/tree/main
Register-ArgumentCompleter -Native -CommandName git -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)

    $inputLine = $commandAst.ToString()
    $args = $inputLine.Split()

    $gitCommands = @(
        'add -A; git commit -m "ADDED: "; git push --set-upstream ',
        'add -A; git commit -m "CHANGED: "; git push --set-upstream ',
        'add -A; git commit -m "DELETED: "; git push --set-upstream',
        'add -A; git commit -m "FIXED: "; git push --set-upstream',    
        'checkout dev; git pull origin dev',    
        'checkout -b <new-branch-name>',    
        'branch --all',    
        'log --oneline --decorate',    
        'log --oneline --graph --decorate --all ',    
        'add', 'bisect', 'branch', 'checkout', 'clone', 'commit', 'diff',
        'fetch', 'grep', 'init', 'log', 'merge', 'mv', 'pull', 'push',
        'rebase', 'reset', 'restore', 'rm', 'show', 'status', 'switch', 'tag', 'whatchanged'
    )

    $commonGitOptions = @(
        '--help', '--version', '--exec-path', '--html-path', '--man-path', '--info-path'
    )
    $branchOptions = @(
        '--all',
        '--color',
        '--column',
        '--contains',
        '--copy',
        '--create-reflog',
        '--delete',
        '--edit-description',
        '--format=',
        '--force',
        '--ignore-case',
        '--list',
        '--merged',
        '--move',
        '--no-color',
        '--no-column',
        '--no-merged',
        '--points-at',
        '--quiet',
        '--remotes',
        '--show-current',
        '--sort=',
        '--track',
        '--unset-upstream',
        '--verbose'
    )

    $commitOptions = @(
        '-am "ADDED: "',
        '-am "CHANGED: "',
        '-am "FIXED: "',
        '-am "DELETED: "',
        '--amend',
        '--no-edit',
        '--only',
        '--quiet',
        '--signoff',
        '--dry-run',
        '--verbose',
        '--no-verify',
        '--all',
        '--reset-author',
        '--date',
        '--author',
        '--message',
        '--file',
        '--template',
        '--status',
        '--pathspec-from-file',
        '--pathspec-file-nul',
        '--mainline'
    )

    $diffOptions = @(
        '--abbrev-commit',
        '--abbrev=',
        '--anchored=',
        '--break-rewrites',
        '--break-rewrites=',
        '--cached',
        '--check',
        '--color-moved-ws',
        '--color-moved',
        '--color',
        '--compact-summary',
        '--cumulative',
        '--diff-algorithm=',
        '--diff-filter=',
        '--dirstat',
        '--dirstat=',
        '--dst-prefix=',
        '--exit-code',
        '--ext-diff',
        '--find-copies-harder',
        '--find-copies',
        '--find-copies=',
        '--find-renames',
        '--find-renames=',
        '--full-index',
        '--function-context',
        '--histogram',
        '--ignore-all-space',
        '--ignore-blank-lines',
        '--ignore-space-at-eol',
        '--ignore-space-change',
        '--indent-heuristic',
        '--inter-hunk-context=',
        '--irreversible-delete',
        '--minimal',
        '--name-only',
        '--name-status',
        '--no-color',
        '--no-ext-diff',
        '--no-indent-heuristic',
        '--no-patch',
        '--no-prefix',
        '--no-renames',
        '--numstat',
        '--output-indicator-context=',
        '--output-indicator-new=',
        '--output-indicator-old=',
        '--output=',
        '--patch-with-raw',
        '--patch',
        '--patience',
        '--quiet',
        '--raw',
        '--relative',
        '--relative=',
        '--rename-empty',
        '--shortstat',
        '--src-prefix=',
        '--staged',
        '--stat-graph-width=',
        '--stat-name-width=',
        '--stat-width=',
        '--stat',
        '--summary',
        '--text',
        '--unified=',
        '--word-diff-regex=',
        '--word-diff'
    )

    $logOptions = @(
        '--root',
         '--abbrev-commit',
         '--abbrev=',
         '--all',
         '--cherry-mark',
         '--cherry-pick',
         '--children',
         '--clear-decorations',
         '--date-order',
         '--date=',
         '--decorate-refs-exclude=',
         '--decorate-refs=',
         '--decorate',
         '--decorate=',
         '--do-walk',
         '--expand-tabs',
         '--expand-tabs=',
         '--follow',
         '--format=',
         '--full-diff',
         '--graph',
         '--name-status',
         '--no-abbrev-commit',
         '--no-decorate',
         '--no-expand-tabs',
         '--no-walk',
         '--no-walk=',
         '--oneline',
         '--oneline --decorate',
         '--oneline --graph --decorate --all',
         '--parents',
         '--patch',
         '--pretty=',
         '--relative-date',
         '--reverse',
         '--show-signature',
         '--since=',
         '--stat',
         '--topo-order',
         '--until=',
         '--walk-reflogs'
    )

    if ($args.Count -eq 1 -or ($args.Count -eq 2 -and $args[1] -like "$wordToComplete*")) {
        $gitCommands + $commonGitOptions |
        Where-Object { $_ -like "$wordToComplete*" } |
        ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
    elseif ($args.Count -ge 2) {
        $subcommand = $args[1]

        switch ($subcommand) {
            'branch' {
                $branchOptions |
                Where-Object { $_ -like "$wordToComplete*" } |
                ForEach-Object {
                    [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterName', $_)
                }
            }
            'checkout' {
                git branch --format='%(refname:short)' |
                Where-Object { $_ -like "$wordToComplete*" } |
                ForEach-Object {
                    [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
                }
            }
            'commit' {
                $commitOptions |
                Where-Object { $_ -like "$wordToComplete*" } |
                ForEach-Object {
                    [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterName', $_)
                }
            }
            'diff' {
                $diffOptions |
                Where-Object { $_ -like "$wordToComplete*" } |
                ForEach-Object {
                    [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterName', $_)
                }
            }
            'log' {
                $logOptions |
                Where-Object { $_ -like "$wordToComplete*" } |
                ForEach-Object {
                    [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterName', $_)
                }
            }
            default {
                # Optional: fallback to common options
                $commonGitOptions |
                Where-Object { $_ -like "$wordToComplete*" } |
                ForEach-Object {
                    [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterName', $_)
                }
            }
        }
    }
}

# ----------------------------------------------------------------------------
# CHOCO command Autocomplete with TAB Key
# ----------------------------------------------------------------------------

Register-ArgumentCompleter -Native -CommandName choco -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)

    $inputLine = $commandAst.ToString()
    $args = $inputLine.Split()

    $chocoCommands = @(
        'find',
        'help',
        'info',
        'install -y ',
        'list',
        'outdated',
        'pin',
        'search',
        'uninstall',
        'upgrade'
    )

    if ($args.Count -eq 1 -or ($args.Count -eq 2 -and $args[1] -like "$wordToComplete*")) {
        $chocoCommands |
        Where-Object { $_ -like "$wordToComplete*" } |
        ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}

# ----------------------------------------------------------------------------
# WINGET command Autocomplete with TAB Key
# ----------------------------------------------------------------------------

Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)

    $inputLine = $commandAst.ToString()
    $args = $inputLine.Split()

    $wingetCommands = @(
        'configure',
        'download',
        'export',
        'features',
        'hash',
        # 'import',
        'install',
        'list',
        'pin',
        'repair',
        'search',
        # 'settings',
        'show',
        # 'source',
        'uninstall',
        'upgrade',
        'validate'
    )

    if ($args.Count -eq 1 -or ($args.Count -eq 2 -and $args[1] -like "$wordToComplete*")) {
        $wingetCommands |
        Where-Object { $_ -like "$wordToComplete*" } |
        ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}

# ----------------------------------------------------------------------------
# NPM command Autocomplete with TAB Key
# ----------------------------------------------------------------------------

Register-ArgumentCompleter -Native -CommandName npm -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)

    $inputLine = $commandAst.ToString()
    $args = $inputLine.Split()

    $npmCommands = @(
        'access',
        'adduser',
        'audit',
        'bugs',
        'cache',
        'ci',
        'completion',
        'config',
        'dedupe',
        'deprecate',
        'diff',
        'dist-tag',
        'docs',
        'doctor',
        'edit',
        'exec',
        'explore',
        'find-dupes',
        'fund',
        'help',
        'help-search',
        'hook',
        'init',
        'install',
        # 'install-test',
        'link',
        'logout',
        'ls',
        'outdated',
        'owner',
        'pack',
        'ping',
        'pkg',
        'prefix',
        'profile',
        'prune',
        'publish',
        'rebuild',
        'repo',
        'restart',
        'root',
        'run',
        # 'run-script',
        'search',
        'set-script',
        'shrinkwrap',
        'star',
        'stars',
        'start',
        'stop',
        'team',
        'test',
        'token',
        'uninstall',
        # 'unpublish',
        # 'unstar',
        'update',
        'version',
        'view',
        'whoami'
    )

    if ($args.Count -eq 1 -or ($args.Count -eq 2 -and $args[1] -like "$wordToComplete*")) {
        $npmCommands |
        Where-Object { $_ -like "$wordToComplete*" } |
        ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}

# ----------------------------------------------------------------------------
# PIP command Autocomplete with TAB Key
# ----------------------------------------------------------------------------

Register-ArgumentCompleter -Native -CommandName pip -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)

    $inputLine = $commandAst.ToString()
    $args = $inputLine.Split()

    $pipCommands = @(
        'cache',
        'check',
        'completion',
        'config',
        'debug',
        'download',
        'freeze',
        'hash',
        'help',
        # 'index',
        # 'inspect',
        'install',
        'list',
        'search',
        'show',
        'uninstall',
        'wheel'
    )

    if ($args.Count -eq 1 -or ($args.Count -eq 2 -and $args[1] -like "$wordToComplete*")) {
        $pipCommands |
        Where-Object { $_ -like "$wordToComplete*" } |
        ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}

# ----------------------------------------------------------------------------
# NODE command Autocomplete with TAB Key
# ----------------------------------------------------------------------------
Register-ArgumentCompleter -Native -CommandName node -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)

    $nodeOptions = @(
        '--version',
        '--help',
        '--eval',
        '--print',
        '--check',
        '--interactive',
        '--require',
        '--input-type',
        '--inspect',
        '--inspect-brk',
        '--no-deprecation',
        '--trace-deprecation',
        '--trace-warnings',
        '--trace-sync-io',
        '--zero-fill-buffers',
        '--abort-on-uncaught-exception',
        '--unhandled-rejections',
        '--watch',
        '--watch-path=',
        '--loader=',
        '--enable-source-maps',
        '--experimental-specifier-resolution=node',
        '--experimental-repl-await',
        '--experimental-vm-modules',
        '--experimental-json-modules',
        '--experimental-import-meta-resolve'
    )

    $nodeOptions |
    Where-Object { $_ -like "$wordToComplete*" } |
    ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterName', $_)
    }
}

# ----------------------------------------------------------------------------
# TYPESCRIPT (tsc) command Autocomplete with TAB Key
# ----------------------------------------------------------------------------
Register-ArgumentCompleter -Native -CommandName tsc -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)

    $tscOptions = @(
        '--help',
        '--version',
        '--watch',
        '--project',
        '--module',
        '--target',
        '--outFile',
        '--outDir',
        '--rootDir',
        '--declaration',
        '--sourceMap',
        '--inlineSourceMap',
        '--inlineSources',
        '--noImplicitAny',
        '--strictNullChecks',
        '--esModuleInterop',
        '--skipLibCheck',
        '--noEmit',
        '--removeComments',
        '--jsx',
        '--noImplicitThis',
        '--allowJs',
        '--checkJs',
        '--noUnusedLocals',
        '--noUnusedParameters',
        '--moduleResolution',
        '--resolveJsonModule',
        '--isolatedModules',
        '--allowSyntheticDefaultImports',
        '--lib',
        '--types',
        '--typeRoots',
        '--noEmitOnError',
        '--skipDefaultLibCheck',
        '--incremental',
        '--tsBuildInfoFile',
        '--allowUmdGlobalAccess',
        '--resolveJsonModule',
        '--downlevelIteration'
    )

    $tscOptions |
    Where-Object { $_ -like "$wordToComplete*" } |
    ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterName', $_)
    }
}

# ----------------------------------------------------------------------------
# CD command Autocomplete with TAB Key in FZF - Install: Install-Module -Name PSFzf -Scope CurrentUser
# ----------------------------------------------------------------------------

# This replaces the standard Tab completion with fzf
Set-PSReadLineKeyHandler -Key Tab -ScriptBlock {
    # Check if the function exists; if not, source the script or module
    if (-not (Get-Command Invoke-FzfTabCompletion -ErrorAction SilentlyContinue)) {
    }
    
    # Now that it's loaded, invoke it
    Invoke-FzfTabCompletion
}