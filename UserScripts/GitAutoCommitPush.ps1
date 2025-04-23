function Log-Commit {
    param(
        [string]$Message
    )

    Write-Host -ForegroundColor Green "[Commit] $Message"
}

function Log-Error {
    param(
        [string]$Message
    )

    Write-Host -ForegroundColor Red "[Error] $Message"
}

# Check if git is installed
# Returns a boolean
function Test-GitInstalled {
    $gitVersion = git version 2>&1
    return $gitVersion -match "^git version"
}

# Checks if the current directory is a git repository
# Returns a boolean
function Test-IsGitRepository {
    $statusOutput = git rev-parse --is-inside-work-tree 2>&1
    if ($statusOutput -match "true") {
        return $true
    } else {
        return $false
    }
}


# Checks if there are any conflicts in the current Git repository
# Returns a boolean
function Test-HasGitConflicts {
    $gitStatus = git status --porcelain
    return [bool]($gitStatus -match '^UU |^AA |^DD |^UD |^DU |^AA|^DD|^UU')
}


function RepeatForever {
    Clear-Host
    # if (Test-GitInstalled) {
    #     Log-Error "Git not installed"
    #     exit
    # }
    if (!(Test-IsGitRepository)) {
        Log-Error "Not in a Git Repository`n"
        exit
    }
    if (Test-HasGitConflicts) {
        Log-Error "Git Conflict`n"
        # Write-Host " `n "
        git diff --name-only --diff-filter=U
        exit
    }

    # ADDED, CHANGED, DELETED ========================================= 
    $gitStatus = git status --porcelain
    $text1 = @()
    # Trim each line and replace "??" with "A"
    $gitStatus | ForEach-Object {
        $line = $_.Trim() 

        # Skip the line if it contains "??"
        if ($line -notmatch "^\?\?") {
            $line = $line -replace "A  ", "A "              # Replace "A  " with "A "
            # $line = $line -replace ".*/", ""                # Remove everything before and including the last "/" (or backslash)
            if ($line.Contains("/")) {
                # Extract the first two characters (prefix) and everything after the last slash
                $line = $line.Substring(0, 2) + $line.Substring($line.LastIndexOf("/") + 1)
            }
            # $line = $line -replace "\.\w{2,4}$", ""         # Remove file extensions
            # Add the modified line to $text array
            $text1 += $line
        }
    }

    # UNTRACKED ========================================= 

    $untracked = git ls-files --others --exclude-standard

    $untracked | ForEach-Object {
        $line = $_.Trim() 
        $line = "A " + $line
        # $line = $line -replace ".*/", ""                # Remove everything before and including the last "/" (or backslash)
        if ($line.Contains("/")) {
            # Extract the first two characters (prefix) and everything after the last slash
            $line = $line.Substring(0, 2) + $line.Substring($line.LastIndexOf("/") + 1)
        }
        # $line = $line -replace "\.\w{2,4}$", ""         # Remove file extensions
        # Add the modified line to $text array
        $text1 += $line
    }

    $description = @()

    $text1 | ForEach-Object {
        $line = $_.Trim() 
        # Replace the first two characters with the corresponding status
        $line = $line -replace "^A ", "ADDED: "
        $line = $line -replace "^M ", "CHANGED: "
        $line = $line -replace "^D ", "DELETED: "

        # Only add to $description if the line is not empty or whitespace
        if (-not [string]::IsNullOrWhiteSpace($line)) {
            $description += $line
        }
    }
    # SORT ============================================
    # Sort the description and remove duplicate lines
    $description = $description | Sort-Object | Select-Object -Unique

    # 3 Variables: ADDED, CHANGED, DELETED ===========

    # Initialize variables for each status
    $added = @()
    $changed = @()
    $deleted = @()

    # Filter lines into corresponding variables based on the prefix
    $description | ForEach-Object {
        if ($_ -like "ADDED:*") {
            $added += $_ -replace "ADDED: ", ""
        }
        elseif ($_ -like "CHANGED:*") {
            $changed += $_ -replace "CHANGED: ", ""
        }
        elseif ($_ -like "DELETED:*") {
            $deleted += $_ -replace "DELETED: ", ""
        }
    }
    # JOIN LINES =======================================

    $addedJoined = ""
    $changedJoined = ""
    $deletedJoined = ""
    # Join the lines
    # Handle $added
    if ($added.Count -gt 0) {
        if ($added.Count -eq 1) {
            $addedJoined = $added[0]  # Set to the single line if there's only one
        } else {
            $addedJoined = $added -join " "  # Join with comma if there are multiple lines
        }
    }

    # Handle $changed
    if ($changed.Count -gt 0) {
        if ($changed.Count -eq 1) {
            $changedJoined = $changed[0]  # Set to the single line if there's only one
        } else {
            $changedJoined = $changed -join " "  # Join with comma if there are multiple lines
        }
    }

    # Handle $deleted
    if ($deleted.Count -gt 0) {
        if ($deleted.Count -eq 1) {
            $deletedJoined = $deleted[0]  # Set to the single line if there's only one
        } else {
            $deletedJoined = $deleted -join " "  # Join with comma if there are multiple lines
        }
    }

    # Write-Host "=== 3 ======================================"
    # Output the variables for verification
    # Write-Host "=== Added ======================================"
    # Write-Output $addedJoined
    # Write-Host "=== Changed ======================================"
    # Write-Output $changedJoined
    # Write-Host "=== Deleted ======================================"
    # Write-Output $deletedJoined

    # Main Message =======================================

    $message= ""

    if ($addedJoined.Length -gt 0) {
        $message = "ADDED: " + $addedJoined + " "
    }
    if ($changedJoined.Length -gt 0) {
        $message += "CHANGED: " + $changedJoined + " "
    }
    if ($deletedJoined.Length -gt 0) {
        $message += "DELETED: " + $deletedJoined
    }

    # Check if the message is longer than 50 characters
    if ($message.Length -gt 76) {
        # Truncate to 48 characters and add ".." suffix
        $message = $message.Substring(0, 74) + ".."
    }

    # Print a formatted message
    # Write-Host "`n"
    # Write-Output $message

    # Write-Host ""
    # Write-Output $description
    $description = $description -join "`n"
    return "$message`n`n$description"


}

function CommitPush {
    param (
        [string]$Message
    )
    git pull
    git add --all
    git commit -m "$Message"
    git push
}

while ($true) {
    try {

        # Replace this with your method call
        Write-Output "-----------------------------------------"
        $message = RepeatForever
        Write-Output "$message"
        Write-Output "-----------------------------------------"
        CommitPush "$message"
        Write-Output ""
        Write-Host "[ OK ] Commitet message, pull and push" -ForegroundColor Green
        Write-Host ""
        Write-Host "Press ANY key to commit+push again" -ForegroundColor Yellow
        [void][System.Console]::ReadKey($true)
    } catch {
        Write-Error "An error occurred: $_"
    }
}