
# Navigate directorys:
# g: Will output a number before each dir
# g [number]: will jump to directory
# g [search-string] will jump to first matching directory
# g [directory] will jump to directory in current directory
# g ..... will go up to the parent dirs
# g [search-string] will recursive find matching dirs 4 levels down
# g [search-string] will jump to a previous visited folder

# param(
#     [string]$inputValue
# )

# TODO
#  g .....

# Done
#  1 level of c:\ folders 
#  1 level of home folder


# METHOD ---------------------------------------------------------------

# It will set the location and save the path to g-bookmarks.txt in users Temp folder
function Set-LocationIfExists {
    param (
        [string]$Path
    )
    Write-Host "$Path"
    # Check if the path exists
    if (Test-Path -Path $Path) {
        try {
            # Resolve the path to ensure it's valid
            $absolutePath = Resolve-Path -Path $Path
            if (Test-Path -Path $absolutePath -PathType Container) { # Check if it's a directory
                Set-Location -Path $absolutePath
                # Write-Host "Location set to: $absolutePath"

                # Write the full path to a file in the user's temp folder
                $tempFile = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "g-bookmarks.txt")
                Add-Content -Path $tempFile -Value $absolutePath
                # Write-Host "Path saved to: $tempFile"
            } else {
                Write-Host "Path exists, but is not a directory: $absolutePath"
            }
        } catch {
            Write-Host "An error occurred while resolving the path: $_.Exception.Message"
        }
    } else {
        Write-Host "The path '$Path' does not exist."
    }
}

# Returns array
function Get-DirectoriesFromPath {
    param (
        [string]$Path
    )

    try {
        # Check if the path exists and is a directory
        if (Test-Path -Path $Path -PathType Container) {
            # Get all directories from the specified path and return their full paths
            $directories = Get-ChildItem -Path $Path -Directory -ErrorAction Stop | ForEach-Object { $_.FullName }
            return $directories
        } else {
            # Write-Host "The path '$Path' does not exist or is not a directory."
            return @() # Return an empty array if the path is invalid
        }
    } catch {
        Write-Host "An error occurred while retrieving directories: $_.Exception.Message"
        return @() # Return an empty array in case of an error
    }
}

# function Save-CurrentDirectory {
#     # Define the path to the bookmarks file
#     $tempFile = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "g-bookmarks.txt")

#     # Get the current directory
#     $currentDir = (Get-Location).Path

#     # Check if the file exists
#     if (-not (Test-Path -Path $tempFile)) {
#         # Create the file if it doesn't exist
#         New-Item -Path $tempFile -ItemType File -Force | Out-Null
#     }

#     # Read the existing lines in the file
#     $existingLines = Get-Content -Path $tempFile -ErrorAction SilentlyContinue

#     # Check if the current directory is already in the file
#     if ($existingLines -notcontains $currentDir) {
#         # Append the current directory to the file
#         Add-Content -Path $tempFile -Value $currentDir
#         Write-Host "Current directory saved to: $tempFile"
#     } else {
#         Write-Host "Current directory is already saved in: $tempFile"
#     }
# }

function g {
    param(
        [string]$searchStr
    )

    $result = New-Object System.Collections.ArrayList

    $userDir = [System.Environment]::ExpandEnvironmentVariables($env:UserProfile)

    # PRESETS ---------------------------------------------------------------

    $presetDirs = @(
        "C:\",
        # "C:\MartinPrivat",
        # "C:\Github",
        # "C:\temp",
        "$userDir",
        "$userDir\source\repos",
        "$userDir\source\repos\EmplyInddateringV2",
        "$userDir\source\repos\Esas-Dmjx-Metadir-Inddatering",
        # "$userDir\Documents",
        # "$userDir\Downloads",
        # "$userDir\Desktop",
        # "$userDir\Videos",
        # "$userDir\.vscode",
        # "$userDir\AppData",
        "$userDir\AppData\Local\Microsoft\VisualStudio",
        # "$userDir\Obsidian2",
        "$userDir\Desktop\SCREENSHOTS",
        "$userDir\Documents\WindowsPowerShell",
        "$userDir\Documents\PowerShell",
        # "C:\Program Files",
        # "C:\Program Files (x86)",
        # "C:\ProgramData",
        "C:\ProgramData\chocolatey\lib"
    )

    if (-not $searchStr) {
            # No method parameters send, will print a list of directories
            Write-Host "Write 'g number or string'"
            Write-Host ""
            for ($i = 0; $i -lt $presetDirs.Length; $i++) {
                Write-Host "$($i + 1) $($presetDirs[$i])"
            }
            Write-Host ""
        return
    }

    # CD special case commands "-" "--" "~" ----------------------------------------

    # Handle special cases for "-", "--", and "~"
    try {
        switch ($searchStr) {
            # Handle special cases for "-", "--", and "~"
            "..." { 
                Set-Location -Path ..\..
                return 
            }
            "...." { 
                Set-Location -Path ..\..\.. 
                return 
            }
            "....." { 
                Set-Location -Path ..\..\..\..
                return 
            }
            "......" { 
                Set-Location -Path ..\..\..\..
                return 
            }
            "-" { 
                Set-Location -Path -
                return 
            }
            "~" { 
                Set-Location -Path ~
                return 
            }
        }
    } catch {
        Write-Host "An error occurred while navigating to '$searchStr': $_.Exception.Message"
        return
    }

    # CD to number of parent folders, depending on the amount of dots -----------

    # Number Jump ---------------------------------------------------------------
    #  g <number> 
    # Example: g 3

    # Check if it is a number
    if ($searchStr -match '^\d+$') {
        # Write-Host "'$searchStr' is a number."

        # g [number]: will jump to directory
        $index = [int]$searchStr

        # Check if the index is valid
        if ($index -ge 1 -and $index -le $presetDirs.Length) {
            # Get array item by index
            $arrayItem = $presetDirs[$index-1]

            # Check if the path exists
            if (Test-Path $arrayItem) {
                # Use the Set-Location cmdlet (or its alias cd) to navigate to the directory
                Set-Location $arrayItem
            } else {
                Write-Host "The directory '$arrayItem' does not exist."
            }
        } else {
            Write-Host "Invalid directory index."
        }
    } 

    # Current Directory Jump ---------------------------------------------------------------

    # g [directory] will jump to directory in current directory
    # Example: In you user folder, you write: g .\Documents, then it will cd into that
    $path = $searchStr

    # Check if the path exists *before* trying to resolve it
    if (Test-Path -Path $path) {
        try {
            $absolutePath = Resolve-Path -Path $path
            if (Test-Path -Path $absolutePath -PathType Container) { # Double-check if it's a directory
                Set-LocationIfExists -Path $absolutePath
                return  # Return from the script/function
            } else {
                Write-Host "Path exists, but is not a directory: $absolutePath"
            }
        } catch {
            Write-Host "An error occurred during resolution: $_.Exception.Message"
        }
    } else {
        # Write-Host "The directory '$path' does not exist."
    }

    # Parents match: If any of the parents dirs matches the searchStr, then add it to $result ----------------------------------------------
    # Get the current location and convert it to a DirectoryInfo object
    $currentDir = $null
    try {
        $currentDir = Get-Item -Path (Get-Location).Path
    }
    catch {
        <#Do this if a terminating exception happens#>
    }

    # Initialize an array to store parent directories
    $parentDirectories = @()

    # Walk up all parent directories to the root of the drive
    $parentDir = $currentDir

    while ($parentDir -ne $null) {
        # Add the current parent directory to the array
        $parentDirectories += $parentDir.FullName

        # Check if the current parent directory matches the search string
        if ($parentDir.Name -match "(?i)$searchStr") {
            # Write-Host "Match found: $($parentDir.FullName)"
            $result.Add($parentDir.FullName) | Out-Null
        }

        # Move to the parent directory
        $parentDir = $parentDir.Parent
    }

    # Recursive search from current directory with depth 4 -----------------------------------------------------
    
    $currentDir = Get-Location
    $searchDepth = 4
    if ($currentDir.Path -eq "C:\") {
        $searchDepth = 2
    }
    try {
        # The recursive search will exclude folders that starts with a dot "."
        $deepMatch = Get-ChildItem -Path $currentDir -Directory -Recurse -Depth $searchDepth -ErrorAction SilentlyContinue |
            Where-Object {$_.FullName -notmatch "\\\." -and $_.Name -like "*$searchStr*"  } | ForEach-Object { $_.FullName } 

        if ($deepMatch) {
            foreach ($match in $deepMatch) {
                $result.Add($match) | Out-Null
            }
        }
    } catch {
        Write-Host "Error while searching from current directory: $_"
    }
  
    # Add Presets to $result ---------------------------------------------------------------

    foreach ($dir in $presetDirs) {
        $result.Add($dir) | Out-Null
    }

    # Partial dir match in current dir -----------------------------------------------------
    # It will navigate to a directory in current directory if there is a match
    # If the initial Test-Path failed OR Resolve-Path failed, check for partial matches
    $partialDirName = $searchStr
    $partialMatches = Get-ChildItem -Directory -Path . | Where-Object {$_.Name -match "(?i)^$partialDirName"} | ForEach-Object { $_.FullName } 

    if ($partialMatches) {
        # Write-Host "Possible matches in the current directory:" # Uncomment for detailed output
        foreach ($match in $partialMatches) {
            $result.Add($match) | Out-Null
        }
        # if ($partialMatches.Count -gt 0) {
        #     Set-Location -Path $partialMatches[0].FullName
        #     Write-Host "Navigated to: $($partialMatches[0].FullName)"
        #     return # Return after setting location to partial match
        # }
    } else {
        # Write-Host "No full or partial matches found for '$path' in the current directory."
    }

    # Load g-bookmarks.txt from user Temp and add paths to the array  ----------------------------------------------

    # Define the path to the bookmarks file
    $tempFile = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "g-bookmarks.txt")

    # Check if the file exists
    if (Test-Path -Path $tempFile) {
        # Read the file line by line
        $fileLines = Get-Content -Path $tempFile -ErrorAction SilentlyContinue

        # Add non-empty lines to the $result array
        foreach ($line in $fileLines) {
            if (-not [string]::IsNullOrWhiteSpace($line)) {
                $result.Add($line) | Out-Null
            }
        }
    } else {
        # Write-Host "The bookmarks file does not exist: $tempFile"
    }


    # Add folders from C:\  ----------------------------------------------
    $cDriveDirs = Get-DirectoriesFromPath -Path "C:\"

    foreach ($dir in $cDriveDirs) {
        if (-not [string]::IsNullOrWhiteSpace($dir)) {
            $result.Add($dir) | Out-Null
        }
    }

    # Add folders from C:\Users\<user>\ home dir  ----------------------------------------------
    $userDirs = Get-DirectoriesFromPath -Path "$env:USERPROFILE"

    foreach ($dir in $userDirs) {
        if (-not [string]::IsNullOrWhiteSpace($dir)) {
            $result.Add($dir) | Out-Null
        }
    }

    # Set the location  ----------------------------------------------

    # Filter the paths in $result to only include those paths that exist
    $realPaths = $result | Where-Object { Test-Path $_ }

    # Perform a case-insensitive search in $presetDirs
    $filteredResult = $realPaths | Where-Object { $_ -match "(?i)$searchStr" } | Select-Object -Unique

    if ($filteredResult.Count -eq 0) {
        Write-Host "No results found."
    } elseif ($filteredResult.Count -eq 1) {
        # If there is only one item in the array, then we dont need to extract it.. powershell is wierd
        $fullPath = Resolve-Path -Path $filteredResult

        Set-LocationIfExists "$fullPath"
    } else {

        $selectedPath = $filteredResult | fzf --height 20% --reverse
        if (-not $selectedPath) {
            Write-Host "No selection made."
            return
        }
        $fullPath = Resolve-Path -Path $selectedPath
        Set-LocationIfExists "$fullPath"
 
    }
    # $result.Add("one") | Out-Null

    # $selected = $presetDirs | fzf --height 20% --reverse
    # Write-Host "You selected: $selected"
}




# g "$inputValue"