# ----------------------------------------------
# INSTALL SCRIIPTS
# ----------------------------------------------

#If the file does not exist, create it.
if (!(Test-Path -Path $PROFILE -PathType Leaf)) {
    try {
        # Detect Version of Powershell & Create Profile directories if they do not exist.
        # For Powershell 7 and above
        if ($PSVersionTable.PSEdition -eq "Core" ) { 
            if (!(Test-Path -Path ($env:userprofile + "\Documents\PowerShell"))) {
                New-Item -Path ($env:userprofile + "\Documents\PowerShell") -ItemType "directory"
            }
        }
        # For windows powershell 5
        elseif ($PSVersionTable.PSEdition -eq "Desktop") {
            if (!(Test-Path -Path ($env:userprofile + "\Documents\WindowsPowerShell"))) {
                New-Item -Path ($env:userprofile + "\Documents\WindowsPowerShell") -ItemType "directory"
            }
        }

        Invoke-RestMethod https://github.com/martinandersen3d/PowershellProfile/raw/main/Microsoft.PowerShell_profile.ps1 -OutFile $PROFILE
        Invoke-WebRequest -Uri "https://github.com/martinandersen3d/PowershellProfile/raw/main/git-cheatsheet.md" -OutFile "$env:USERPROFILE\Documents\WindowsPowerShell\git-cheatsheet.md"
        Invoke-WebRequest -Uri "https://github.com/martinandersen3d/PowershellProfile/raw/main/git-cheatsheet.md" -OutFile "$env:USERPROFILE\Documents\PowerShell\git-cheatsheet.md"

        Write-Host "The profile @ [$PROFILE] has been created."
    }
    catch {
        throw $_.Exception.Message
    }
}
# If the file already exists, show the message and do nothing.
 else {
		 Get-Item -Path $PROFILE | Move-Item -Destination oldprofile.ps1 -Force
		 Invoke-RestMethod https://github.com/martinandersen3d/PowershellProfile/raw/main/Microsoft.PowerShell_profile.ps1 -OutFile $PROFILE
         Invoke-WebRequest -Uri "https://github.com/martinandersen3d/PowershellProfile/raw/main/git-cheatsheet.md" -OutFile "$env:USERPROFILE\Documents\WindowsPowerShell\git-cheatsheet.md"
         Invoke-WebRequest -Uri "https://github.com/martinandersen3d/PowershellProfile/raw/main/git-cheatsheet.md" -OutFile "$env:USERPROFILE\Documents\PowerShell\git-cheatsheet.md"

		 Write-Host "The profile @ [$PROFILE] has been created and old profile removed."
 }


 if (Get-Command git -ErrorAction SilentlyContinue) {
    git config --global alias.gg "log --oneline --graph --decorate --all"
    git config --global alias.lol "log --oneline --decorate"
}

# Choco install
#
# Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# ----------------------------------------------
# INSTALL PROGRAMS VIA WINGET
# ----------------------------------------------

# Function to check if winget exists
function Is-WingetAvailable {
    try {
        winget --version > $null 2>&1
        return $true
    } catch {
        return $false
    }
}

# Try to install winget if not found
if (-not (Is-WingetAvailable)) {
    Write-Host "winget not found. Attempting to register App Installer..."
    try {
        Get-AppxPackage Microsoft.DesktopAppInstaller -AllUsers | ForEach-Object {
            Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"
        }
    } catch {
        Write-Warning "Failed to register App Installer. You may need to install winget manually."
    }
}

# Re-check if winget is now available
if (-not (Is-WingetAvailable)) {
    Write-Error "winget is still not available. Winget only works in Powershell 7+ and above. Maybe install winget manually, install 'App Installer' from Microsoft Store and be sure to run this script from Powershell version 7+"
    # exit 1
}

# List of packages to check and install if needed
$packages = @(
    "junegunn.fzf",
    "sharkdp.bat",
    "git.git",
    "Microsoft.PowerShell",
    "BurntSushi.ripgrep.GNU"
)

foreach ($pkg in $packages) {
    $isInstalled = winget list --id "$pkg" | Select-String "$pkg"
    if (-not $isInstalled) {
        Write-Host "Installing $pkg..."
        winget install --id "$pkg" --exact --accept-source-agreements --accept-package-agreements
    } else {
        Write-Host "$pkg is already installed."
    }
}

# ----------------------------------------------
# RELOAD PROFILE
# ----------------------------------------------
& $profile