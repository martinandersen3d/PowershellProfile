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

# Quick shortcut
function c. { code . }
function e. { explorer . }
function m { notepad $args }
function n { notepad $args }
function dotnetWatch { dotnet run watch }
function clr { Clear-Host }
function clear { Clear-Host }

# Update scripts from the git repo
function u {
    $url = "https://github.com/martinandersen3d/PowershellProfile/raw/main/setup.ps1"
    try {
        $scriptContent = Invoke-RestMethod -Uri $url
        Invoke-Expression -Command $scriptContent
    }
    catch {
        Write-Error "An error occurred while executing the script from URL: $_"
    }
}

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

# Navigate directorys:
# g: Will output a number before each dir
# g [number]: will jump to directory
# g [search-string] will jump to first matching directory
# g [directory] will jump to directory in current directory
function g {
    $userDir = [System.Environment]::ExpandEnvironmentVariables($env:UserProfile)
    $dirs = @(
        "C:\",
        "C:\MartinPrivat",
        "C:\Github",
        "C:\temp",
        "$userDir",
        "$userDir\source\repos",
        "$userDir\source\repos\EmplyInddateringV2",
        "$userDir\source\repos\Esas-Dmjx-Metadir-Inddatering",
        "$userDir\Documents",
        "$userDir\Downloads",
        "$userDir\Desktop",
        "$userDir\Videos",
        "$userDir\.vscode",
        "$userDir\AppData\Local\Microsoft\VisualStudio",
        "$userDir\Obsidian2",
        "$userDir\Desktop\SCREENSHOTS",
        "$userDir\Documents\WindowsPowerShell"
        "C:\Program Files",
        "C:\Program Files (x86)",
        "C:\ProgramData",
        "C:\ProgramData\chocolatey\lib"
    )

    # $args is an automatic variable that contains any method arguments
    if ($args) {
        # Check if the first argument is a number
        if ($args[0] -is [int]) {
            # g [number]: will jump to directory
            # Method parameter is a number
            $index = $args[0]

            # Check if the index is valid
            if ($index -ge 1 -and $index -le $dirs.Length) {
                # Get array item by index
                $arrayItem = $dirs[$index-1]

                # Use the Set-Location cmdlet (or its alias cd) to navigate to the directory
                Set-Location $arrayItem
            } else {
                Write-Host "Invalid directory index."
            }
        } else {
            # g [search-string] will jump to first matching directory
            # Method parameter is a string (search string)
            $searchString = $args[0].ToLower()

            # Loop through directories
            foreach ($dir in $dirs) {
                if ($dir.ToLower() -like "*$searchString*") {
                    # Use the Set-Location cmdlet (or its alias cd) to navigate to the directory
                    Set-Location $dir
                    return
                }
            }

            # g [directory] will jump to directory in current directory
            # Example: In you user folder, you write: g .\Documents, then it will cd into that
            $path = $args[0]

            # Check if the path exists *before* trying to resolve it
            if (Test-Path -Path $path) {
                try {
                    $absolutePath = Resolve-Path -Path $path
                    if (Test-Path -Path $absolutePath -PathType Container) { # Double-check if it's a directory
                        Set-Location -Path $absolutePath
                        return  # Return from the script/function
                    } else {
                        Write-Host "Path exists, but is not a directory: $absolutePath"
                    }
                } catch {
                    Write-Host "An error occurred during resolution: $_.Exception.Message"
                }
            }
            
            # g [directory-partial-match] will jump to directory in current directory
            # Example: In you user folder, you write: "g one", then it will cd into "C:\Users\m\OneDrive". case-incensive

            # If the initial Test-Path failed OR Resolve-Path failed, check for partial matches
            $partialMatches = Get-ChildItem -Directory -Path . | Where-Object {$_.Name -match "(?i)^$path"}
            
            if ($partialMatches) {
                # Write-Host "Possible matches in the current directory:" # Uncomment for detailed output
                # foreach ($match in $partialMatches) {
                #     Write-Host "  $match"
                # }
            
                if ($partialMatches.Count -gt 0) {
                    Set-Location -Path $partialMatches[0].FullName
                    Write-Host "Navigated to: $($partialMatches[0].FullName)"
                    return # Return after setting location to partial match
                }
            } else {
                Write-Host "No full or partial matches found for '$path' in the current directory."
            }

            # If no matching directory is found
            Write-Host "No directory matching '$searchString' found."
        }
    }
    else {
        # No method parameters send, will print a list of directories
        Write-Host "Write 'g number or string'"
        Write-Host ""
        for ($i = 0; $i -lt $dirs.Length; $i++) {
            Write-Host "$($i + 1) $($dirs[$i])"
        }
        Write-Host ""
    }
}

# Preview Files in Dir With FZF
function p {
    if (!(Get-Command fzf -ErrorAction SilentlyContinue)) {
        Write-Host "fzf is not installed. Please install it and try again."
        Exit
    }
    fzf --preview "bat --theme=Nord --color=always {}" --layout=reverse
}

# Generate or copy a file from ~/Templates to the current directory
# 1. Select the file
# 2. Rename to new filename
function t {
    if (!(Get-Command fzf -ErrorAction SilentlyContinue)) {
        Write-Host "fzf is not installed. Please install it and try again."
        Exit
    }
    
    $files = Get-ChildItem -Path "~/Templates" -Recurse -File | Select-Object -ExpandProperty FullName

    # Use fzf to select a file
    $selectedFile = $files | fzf --layout=reverse --header="TEMPALTE: Copy File to Current Dir" --preview 'bat --color=always  {}'
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

# If so and the current host is a command line, then change to red color 
# as warning to user that they are operating in an elevated context
# Useful shortcuts for traversing directories

function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function .... { Set-Location ..\..\.. }
function cd.. { Set-Location .. }
function cd... { Set-Location ..\.. }
function cd.... { Set-Location ..\..\.. }
function cd..... { Set-Location ..\..\..\.. }

# Drive shortcuts
function HKLM: { Set-Location HKLM: }
function HKCU: { Set-Location HKCU: }
function Env: { Set-Location Env: }

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

# Does the the rough equivalent of dir /s /b. For example, dirs *.png is dir /s /b *.png
function dirs {
    if ($args.Count -gt 0) {
        Get-ChildItem -Recurse -Include "$args" | Foreach-Object FullName
    } else {
        Get-ChildItem -Recurse | Foreach-Object FullName
    }
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

# Set UNIX-like aliases for the admin command, so sudo <command> will run the command
# with elevated rights. 
Set-Alias -Name su -Value admin
Set-Alias -Name sudo -Value admin


# Make it easy to edit this profile once it's installed
function Edit-Profile {
    if ($host.Name -match "ise") {
        $psISE.CurrentPowerShellTab.Files.Add($profile.CurrentUserAllHosts)
    } else {
        notepad $profile.CurrentUserAllHosts
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

function ll { Get-ChildItem -Path $pwd -File }

# function GitCommit {
#     git add .
#     git commit -m "wip"
# }
# function GitCommitPush {
#     git add .
#     git commit -m "wip"
#     git push
# }

function GitCheatsheet {
    $filePath = "$HOME\Documents\WindowsPowerShell\git-cheatsheet.md"
    if (Test-Path $filePath) {
        bat $filePath
    } else {
        Write-Host "Cheatsheet not found: $filePath" -ForegroundColor Red
    }
}

function GitCommitAutoMessage {
    # Get the firectory name of the current powershell profile
    $profileBasePath = Split-Path $PROFILE -Parent
    & "$profileBasePath\UserScripts\GitAutoCommit.ps1"
}

function GitCommitPreviewFzf {
    git status --porcelain | ForEach-Object { $_.Substring(3) } | fzf --header "[COMMIT DIFF]: CURRENT vs. HEAD" --header-first --preview "git diff HEAD -- {} | bat --theme=OneHalfLight --color=always" --layout=reverse
}
function GitCommitMessagePreview {
    # Get the firectory name of the current powershell profile
    $profileBasePath = Split-Path $PROFILE -Parent
    & "$profileBasePath\UserScripts\GitCommitMessagePreview.ps1"
}
function GitPullRequestPreviewFzf {
    git diff --name-only origin/dev | fzf --header "[PULLREQUEST DIFF]: HEAD vs. origin/dev" --header-first --preview "git diff origin/dev -- {} | bat --theme=OneHalfLight --color=always" --layout=reverse
}

function reload-profile {
    & $profile
}
function find-file($name) {
    Get-ChildItem -recurse -filter "*${name}*" -ErrorAction SilentlyContinue | ForEach-Object {
        $place_path = $_.directory
        Write-Output "${place_path}\${_}"
    }
}
function unzip ($file) {
    Write-Output("Extracting", $file, "to", $pwd)
    $fullFile = Get-ChildItem -Path $pwd -Filter .\cove.zip | ForEach-Object { $_.FullName }
    Expand-Archive -Path $fullFile -DestinationPath $pwd
}

function grep($regex, $dir) {
    if ( $dir ) {
        Get-ChildItem $dir | select-string $regex
        return
    }
    $input | select-string $regex
}
function touch($file) {
    "" | Out-File $file -Encoding ASCII
}

# Print info about a file or dir
function info {
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
function Get-FolderSizes {
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

# Start firefox with json file file
function json {
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

# Searches all the content of files in the current diretory and subpaths for a given string
# example usage: Search-Content "TODO"
function Search-Content {
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

# Call the function to list all methods in the PowerShell profile
function ListCommands {
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
function l { ListCommands }

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


# First Lines when started -----------------------------------------------------------------------------

Clear-Host
# Print Profile Location
Write-Host "Profile: $PROFILE"

# Mulitline varaible
# $multiLineString = @"
# "@
# Write-Output $multiLineString


# Help Promt when is starts up - Array table ------------------------
# Define the array
$array = @(
    @("D", "List Directorys"),
    @("DD", "List Directorys as table"),
    @("F", "List Files"),
    @("G", "Go To Favorites"),
    @("L", "List Commands"),
    @("P", "Preview Files in Dir With FZF"),
    @("S", "Sub-dirs Fzf (Depth 3) "),
    @("T", "Generate file from Template"),
    @("X", "Execute Script"),
    @("U", "Update Scripts"),
    @("GitCheatsheet", "GitCheatsheet")
)

# Convert the array elements to custom objects
$tableRows = $array | ForEach-Object {
    [PSCustomObject]@{
        Column1 = $_[0]
        Column2 = $_[1]
    }
}

# Output the table without headers
$tableRows | Format-Table -AutoSize -HideTableHeaders
# Write-Host "________"


# Prompt Style  -----------------------------------------------------------------------------


function prompt {
    # $rocket = [char]::ConvertFromUtf32(0x1F680)  # This is the Unicode for the "rocket" emoji
    $closedFolder = [char]::ConvertFromUtf32(0x1F4C1)  # This is the Unicode for the "closed folder" emoji
    $promptString = "$closedFolder $($PWD.Path) :"
    Write-Host -NoNewline $promptString -ForegroundColor Yellow
    return " "
}


# Autocomplete with TAB Key -----------------------------------------------------------------
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

# WinGet command Autocomplete with TAB Key -----------------------------------------------------------------
# https://github.com/microsoft/winget-cli/blob/1fbfacc13950de8a17875d40a8beb99fc6ada6c2/doc/Completion.md
# Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
#     param($wordToComplete, $commandAst, $cursorPosition)
#         [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
#         $Local:word = $wordToComplete.Replace('"', '""')
#         $Local:ast = $commandAst.ToString().Replace('"', '""')
#         winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
#             [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
#         }
# }