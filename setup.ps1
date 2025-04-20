# ---------------------------------------------------------------------------
# LOG FUNCTIONS
# ---------------------------------------------------------------------------

function LogGreen {
    param([string]$Message)
    Write-Host "[ OK ] $Message" -ForegroundColor Green
}

function LogRed {
    param([string]$Message)
    Write-Host "[ ERROR ] $Message" -ForegroundColor Red
}
function LogInfo {
    param([string]$Message)
    Write-Host "$Message"
}
function LogTitle {
    param([string]$Message)
    Write-Host "" -ForegroundColor Yellow
    Write-Host "=====================================================================" -ForegroundColor Yellow
    Write-Host "$Message" -ForegroundColor Yellow
    Write-Host "=====================================================================" -ForegroundColor Yellow
}

# ---------------------------------------------------------------------------
LogTitle "Requirements:"
# ---------------------------------------------------------------------------

LogInfo "- Run as Admin"
LogInfo "- Git Installed"
LogInfo "- PowerShell 7+"
LogInfo "- WinGet"
LogInfo "- 'App Installer' from Microsoft Store has WinGet"

# ---------------------------------------------------------------------------
LogTitle "Preflight Checks"
# ---------------------------------------------------------------------------

function CheckCommand {
    param([string]$CommandName)

    if (Get-Command $CommandName -ErrorAction SilentlyContinue) {
        LogGreen "'$CommandName' is available."
        return $true
    } else {
        LogRed "'$CommandName' is NOT available."
        return $false
    }
}

function CheckElevation {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal $identity
    $isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    if ($isAdmin) {
        LogGreen "Script is running with elevated privileges."
    } else {
        LogRed "Script is NOT running as Administrator."
    }

    return $isAdmin
}

$allOk = $true

if (-not (CheckElevation)) { $allOk = $false }
if (-not (CheckCommand "git")) { $allOk = $false }
if (-not (CheckCommand "winget")) { $allOk = $false }
if (-not (CheckCommand "powershell")) { $allOk = $false }
if (-not (CheckCommand "pwsh")) { $allOk = $false }

# If Git is missing, check if winget is installed and offer to install git
if (-not (CheckCommand "git")) {
        LogRed "Git is not installed. Aborting."
        exit 1
}

if (-not (CheckCommand "pwsh")){
    LogRed "Powershell 7+ is not Installed. You can install it later. Continue..."
}

if (-not (CheckCommand "winget")){
    LogRed "WinGet is required for this script to continue. Maybe install winget manually, install 'App Installer' from Microsoft Store or install it from https://learn.microsoft.com/en-us/windows/msix/app-installer/install-update-app-installer. Aborting."
    exit 1
}

# ---------------------------------------------------------------------------
LogTitle "Install Suggestions"
# ---------------------------------------------------------------------------
function CheckAndSuggestCommand {
    param(
        [string]$CommandName,
        [string]$WingetInstallCommand,
        [string]$ChocoInstallCommand
    )

    # Check if the command is available
    if (Get-Command $CommandName -ErrorAction SilentlyContinue) {
        LogGreen "'$CommandName' is already available."
        # return $true
    } else {
        LogRed "'$CommandName' is NOT available."
        
        # Suggest installation methods
        if ($WingetInstallCommand) {
            LogRed "You can install '$CommandName' using winget: $WingetInstallCommand"
        }
        if ($ChocoInstallCommand) {
            LogRed "You can install '$CommandName' using choco: $ChocoInstallCommand"
        }
        
        # return $false
    }
}
CheckAndSuggestCommand "git" "winget install --id Git.Git" "choco install git"
CheckAndSuggestCommand "fzf" "winget install junegunn.fzf" "choco install fzf"
CheckAndSuggestCommand "bat" "winget install sharkdp.bat" "choco install bat"
CheckAndSuggestCommand "git" "winget install git.git" "choco install git"
CheckAndSuggestCommand "pwsh" "winget install Microsoft.PowerShell" "choco install powershell-core"
CheckAndSuggestCommand "rg" "winget install BurntSushi.ripgrep.GNU" "choco install ripgrep"


# ---------------------------------------------------------------------------
LogTitle "Clone Git Repo to: $home\AppData\Local\Temp\PowerShellProfile"
# ---------------------------------------------------------------------------

$target = "$env:TEMP\PowerShellProfile"
if (Test-Path $target) {
    Remove-Item -Recurse -Force $target -ErrorAction SilentlyContinue
    LogGreen "Removing path: $target"
}

git clone https://github.com/martinandersen3d/PowershellProfile.git "$target" | Write-Host

# ---------------------------------------------------------------------------
LogTitle "Copy Files"
# ---------------------------------------------------------------------------

function TryCopyFile {
    param(
        [string]$SourcePath,
        [string]$DestinationPath
    )

    try {
        # Ensure destination folder exists
        $destFolder = Split-Path -Path $DestinationPath -Parent
        if (-not (Test-Path $destFolder)) {
            New-Item -ItemType Directory -Path $destFolder -Force | Out-Null
            LogGreen "Created folder: '$destFolder'"
        }

        # Copy file
        Copy-Item -Path $SourcePath -Destination $DestinationPath -Force -ErrorAction Stop
        LogGreen "Copied file '$SourcePath' to '$DestinationPath'."
        # return $true
    }
    catch {
        LogRed "Failed to copy file from '$SourcePath' to '$DestinationPath': $_"
        # return $false
    }
}

function TryCopyFolder {
    param(
        [string]$SourceFolder,
        [string]$DestinationFolder
    )

    try {
        # Ensure destination folder exists
        if (-not (Test-Path $DestinationFolder)) {
            New-Item -ItemType Directory -Path $DestinationFolder -Force | Out-Null
            LogGreen "Created folder: '$DestinationFolder'"
        }

        # Copy contents recursively
        Copy-Item -Path $SourceFolder\* -Destination $DestinationFolder -Recurse -Force -ErrorAction Stop
        LogGreen "Copied folder '$SourceFolder' to '$DestinationFolder'."
        # return $true
    }
    catch {
        LogRed "Failed to copy folder from '$SourceFolder' to '$DestinationFolder': $_"
        # return $false
    }
}

# Variables
$GitDir = "$home\AppData\Local\Temp\PowerShellProfile"
# User Documents Folder - Example: C:\Users\<user>\Documents
$documentsPath = [Environment]::GetFolderPath('MyDocuments')

# Start Copy Files
TryCopyFile "$GitDir\Microsoft.WindowsTerminal\settings.json" "$home\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

TryCopyFile "$GitDir\Microsoft.PowerShell_profile.ps1" "$documentsPath\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
TryCopyFile "$GitDir\Microsoft.PowerShell_profile.ps1" "$documentsPath\PowerShell\Microsoft.PowerShell_profile.ps1"

TryCopyFile "$GitDir\git-cheatsheet.md" "$documentsPath\WindowsPowerShell\git-cheatsheet.md"
TryCopyFile "$GitDir\git-cheatsheet.md" "$documentsPath\PowerShell\git-cheatsheet.md"

# Start Copy Folders

# TryCopyFolder "C:\SourceStuff" "D:\BackupStuff"
TryCopyFolder "$GitDir\UserScripts" "$documentsPath\WindowsPowerShell\UserScripts"
TryCopyFolder "$GitDir\UserScripts" "$documentsPath\PowerShell\UserScripts"


# ----------------------------------------------
# RELOAD PROFILE
# ----------------------------------------------
Start-Sleep -Seconds 1

LogTitle "Complete - Press any key to reload profile"
Write-Host "Press any key to continue..."
[void][System.Console]::ReadKey($true)
Clear-Host
& $profile