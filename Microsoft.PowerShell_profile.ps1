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


# Fzf Subdirs 3 leves down, that does not start with  ".git" or is "node_modules"
# function s { Get-ChildItem -Path . -Directory -Recurse -Depth 3 | Where-Object { (-not $_.Name.StartsWith(".git")) -and ($_.Name -ne "node_modules") } | Select-Object -ExpandProperty FullName | fzf --layout=reverse | Set-Location }

# List Dirs in current dir
function d { Get-ChildItem -Path . -Directory | Select-Object @{Name='SubPath';Expression={Split-Path $_.FullName -Leaf} } }

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
function g {
    $userDir = [System.Environment]::ExpandEnvironmentVariables($env:UserProfile)
    $dirs = @(
        "C:\",
        "C:\MartinPrivat",
        "C:\temp",
        "$userDir",
        "$userDir\source\repos",
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
        "C:\ProgramData"
    )

    # $args is an automatic variable that contains any method arguments
    if ($args) {
        # Check if the first argument is a number
        if ($args[0] -is [int]) {
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

            # If no matching directory is found
            Write-Host "No directory matching '$searchString' found."
        }
    }
    else {
        # No method parameters send, will print a list of directories
        Write-Host ""
        for ($i = 0; $i -lt $dirs.Length; $i++) {
            Write-Host "$($i + 1) $($dirs[$i])"
        }
        Write-Host ""
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
function GitAddCommit {
    git add .
    git commit -m "wip"
}
function GitAddCommitPush {
    git add .
    git commit -m "wip"
    git push
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
    @("S", "Sub-dirs Fzf (Depth 3) "),
    @("D", "List Directorys"),
    @("F", "List Files"),
    @("G", "Go To Favorites FZF"),
    @("X", "Execute Script")
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
Write-Host "________"