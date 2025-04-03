#If the file does not exist, create it.
if (!(Test-Path -Path $PROFILE -PathType Leaf)) {
    try {
        # Detect Version of Powershell & Create Profile directories if they do not exist.
        if ($PSVersionTable.PSEdition -eq "Core" ) { 
            if (!(Test-Path -Path ($env:userprofile + "\Documents\Powershell"))) {
                New-Item -Path ($env:userprofile + "\Documents\Powershell") -ItemType "directory"
            }
        }
        elseif ($PSVersionTable.PSEdition -eq "Desktop") {
            if (!(Test-Path -Path ($env:userprofile + "\Documents\WindowsPowerShell"))) {
                New-Item -Path ($env:userprofile + "\Documents\WindowsPowerShell") -ItemType "directory"
            }
        }

        Invoke-RestMethod https://github.com/martinandersen3d/PowershellProfile/raw/main/Microsoft.PowerShell_profile.ps1 -OutFile $PROFILE
        Invoke-WebRequest -Uri "https://github.com/martinandersen3d/PowershellProfile/raw/main/git-cheatsheet.md" -OutFile "$env:USERPROFILE\Documents\WindowsPowerShell\git-cheatsheet.md"

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

		 Write-Host "The profile @ [$PROFILE] has been created and old profile removed."
 }


 if (Get-Command git -ErrorAction SilentlyContinue) {
    git config --global alias.gg "log --oneline --graph --decorate --all"
    git config --global alias.lol "log --oneline --decorate"
}


& $profile

# Choco install
#
# Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
