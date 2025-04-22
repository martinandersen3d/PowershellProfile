# PowerShell Cheatsheet

## Navigation
| Section                                            | Description                                 |
|----------------------------------------------------|---------------------------------------------|
| [Files](#files)                                    | File creation, renaming, moving, deleting   |
| [Folders](#folders)                                | Folder creation, renaming, moving, deleting |
| [Variables & Environment](#variables--environment) | Working with variables and env vars         |
| [Processes & Services](#processes--services)       | Managing processes and services             |
| [Networking](#networking)                          | Network diagnostics                         |
| [Help & Discovery](#help--discovery)               | Exploring cmdlets and help                  |
| [Scripting Basics](#scripting-basics)              | Loops, conditionals, functions              |
| [Package Management](#package-management)          | Installing and updating modules             |
| [Aliases](#aliases)                                | Common PowerShell shortcuts                 |

## Files
| Command                                          | Description           |
|--------------------------------------------------|-----------------------|
| New-Item -Path . -Name "file.txt" -ItemType File | Create a new file     |
| Copy-Item "file.txt" "copy.txt"                  | Copy a file           |
| Move-Item "file.txt" "../newfolder/"             | Move or rename a file |
| Rename-Item "old.txt" "new.txt"                  | Rename a file         |
| Remove-Item "file.txt"                           | Delete a file         |
| Get-ChildItem -Filter "*.log"                    | List specific files   |

## Folders
| Command                                           | Description                |
|---------------------------------------------------|----------------------------|
| New-Item -Path . -Name "Logs" -ItemType Directory | Create a folder            |
| Copy-Item ".\Logs" "..\Backup" -Recurse           | Copy folder recursively    |
| Move-Item ".\Logs" "..\Archive"                   | Move or rename folder      |
| Rename-Item "OldFolder" "NewFolder"               | Rename folder              |
| Remove-Item ".\Logs" -Recurse                     | Delete folder and contents |
| Get-ChildItem -Directory                          | List only directories      |

## Variables & Environment
| Command                    | Description                    |
|----------------------------|--------------------------------|
| $name = "World"            | Define variable                |
| Write-Output "Hello $name" | Print variable                 |
| $env:PATH                  | Access environment variable    |
| Get-ChildItem Env:         | List all environment variables |

## Processes & Services
| Command                    | Description    |
|----------------------------|----------------|
| Get-Process                | List processes |
| Stop-Process -Name notepad | Kill process   |
| Start-Process notepad.exe  | Start process  |
| Get-Service                | List services  |
| Start-Service wuauserv     | Start service  |
| Stop-Service wuauserv      | Stop service   |

## Networking
| Command                               | Description       |
|---------------------------------------|-------------------|
| Test-Connection google.com            | Ping command      |
| Resolve-DnsName example.com           | DNS lookup        |
| Invoke-WebRequest https://example.com | HTTP request      |
| Get-NetIPAddress                      | Show IP addresses |

## Help & Discovery
| Command               | Description             |
|-----------------------|-------------------------|
| Get-Help Get-Process  | Show cmdlet help        |
| Get-Command *Service* | Find cmdlets by name    |
| Get-Member            | Show object members     |
| help about_If         | Show concept help topic |

## Scripting Basics
| Command                                        | Description     |
|------------------------------------------------|-----------------|
| if ($a -gt $b) { ... }                         | If condition    |
| for ($i=0; $i -lt 5; $i++) { ... }             | For loop        |
| foreach ($item in $list) { ... }               | Foreach loop    |
| while ($true) { ... }                          | While loop      |
| function Greet { param($name); "Hello $name" } | Define function |

## Package Management
| Command             | Description    |
|---------------------|----------------|
| Find-Module Az      | Search modules |
| Install-Module Az   | Install module |
| Update-Module Az    | Update module  |
| Uninstall-Module Az | Remove module  |

## Aliases
| Alias | Cmdlet        |
|-------|---------------|
| ls    | Get-ChildItem |
| cp    | Copy-Item     |
| mv    | Move-Item     |
| rm    | Remove-Item   |
| gci   | Get-ChildItem |
| gps   | Get-Process   |
| sls   | Select-String |
| ni    | New-Item      |
| ii    | Invoke-Item   |
| cat   | Get-Content   |

