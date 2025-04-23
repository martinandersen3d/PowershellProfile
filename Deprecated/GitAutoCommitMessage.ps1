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

# When using git status --porcelain, it makes funny formatting. This is the fix for that
# Return String
function GitPorselainFixed() {
    $lines = git status --porcelain
    $lines = $lines  -split '\r?\n'
    $formatted_lines = @()

    foreach ($line in $lines) {
        if ($line.StartsWith(' ')) {
            $line = $line.Substring(1)
        }
        if ($line.StartsWith('?? ')) {
            $line = $line -replace '\?\?', 'U'
        }
        if ($line.StartsWith('MM ')) {
            $line = $line.Substring(1)
        }
        if ($line.StartsWith('A  ')) {
            $line = "A " + $line.Substring(3)
        }
        $line = $line -replace '"', ''
        $line = $line.Trim()
        $formatted_lines += $line + "`n"  # Add newline character after each line
    }

    $result = $formatted_lines -join ''
    return $result
}

# Return String
function GetCommitString {
    param ($str)

    $lines = $str  -split '\r?\n'
    $countAdded = 0
    $countModified = 0
    $countDeleted = 0
    $countUntracked = 0
    $countTotal = 0
    $commitString = ""
    foreach ($line in $lines) {
        if ($line.StartsWith('A ')) {
            $countAdded += 1
        }
        if ($line.StartsWith('M ')) {
            $countModified += 1
        }
        if ($line.StartsWith('D ')) {
            $countDeleted += 1
        }
        if ($line.StartsWith('U ')) {
            $countAdded += 1
            $countUntracked += 1
        }
        $countTotal += 1
    }

    $commitString += "A:$countAdded "
    $commitString += "M:$countModified "
    $commitString += "D:$countDeleted "
    $commitString += "| "

    $filesArr=@()
    foreach ($line in $lines) {
        if ($line.Length -gt 3) {
            $line = $line.Substring(2)
            # Get only the filename and not the subpath
            if ($line -match "/") {
                $lastSlashIndex = $line.LastIndexOf("/")
                $line = $line.Substring($lastSlashIndex + 1)
            }
            if ($line -match "." -and $line[0] -ne '.') {
                $lastDotIndex = $line.LastIndexOf(".")
                $line = $line.Substring(0, $lastDotIndex )
            }
            if ($line.Length -gt 1) {
                $filesArr += $line
            }
        }
    }

    $commitString += $filesArr -join ', '
    if ($commitString.Length -gt 72) {
        $commitString = ($commitString.Substring(0, 70)) + ".."
    }

    # $result = $formatted_lines -join ''
    return $commitString
}

function Commit-Action {

    # if (Test-GitInstalled) {
    #     Log-Error "Git not installed"
    #     exit
    # }
    if (!(Test-IsGitRepository)) {
        Log-Error "Not in a Git Repository"
        exit
    }
    if (Test-HasGitConflicts) {
        Log-Error "Git Conflict`n"
        # Write-Host " `n "
        git diff --name-only --diff-filter=U
        exit
    }

    # Get the list of changed files in a Git repository
    $changedFiles = git status --porcelain

    # Check the number of changed files
    if ($changedFiles.Count -eq 0) {
        Log-Error "NO FILES have changed in the Git repository."
        exit
    }

    # Join the file names into a single line, separated by spaces

    $gitPors = GitPorselainFixed
    $commitString = GetCommitString "$gitPors"
    Log-Commit "$commitString"
    Write-Host " `n "

    git add --all
    git commit -m "$commitString"

}


Commit-Action
