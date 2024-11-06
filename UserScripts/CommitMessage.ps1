# # Kør dette script i et git repo, så vil den kopier navnene på alle de filer der er ændret

# # Get the list of changed files in a Git repository
# $changedFiles = git status --porcelain | ForEach-Object { $_.Trim().Split(' ')[1] | Split-Path -Leaf }

# Write-Host "\n"


# # Check if no files have changed
# if ($changedFiles -eq $null) {
#     Write-Host "No files have changed in the Git repository."
#     exit
# }

# # Join the file names into a single line, separated by spaces
# $changedFilesLine = $changedFiles -join ' '

# # Copy the result to the clipboard
# $changedFilesLine | Set-Clipboard

# # Print the result
# Write-Host "COPIED TO CLIPBOARD: $changedFilesLine"

# exit

# 0 changed files: Exit
# 1 changed file: full relative path
# 1+ changed file: only filenames


# Write-Host " `n "
# Write-Host "=== COPY FILENAMES TO CLIPBOARD ======================================"


# # Get the list of changed files in a Git repository
# $changedFiles = git status --porcelain | ForEach-Object { $_.Trim().Split(' ')[1] }

# # Check the number of changed files
# if ($changedFiles.Count -eq 0) {
#     Write-Host "No files have changed in the Git repository."
#     Write-Host " `n "
#     exit
# }
# # is less than 4
# elseif ($changedFiles.Count -lt 4) {
#     $changedFilesLine = $changedFiles
# }
# else {
#     $changedFilesLine = $changedFiles | ForEach-Object { $_.Trim().Split(' ')[0] } | Split-Path -Leaf
# }

# # Join the file names into a single line, separated by spaces
# $changedFilesLine = $changedFilesLine -join '   '

# # Copy the result to the clipboard
# $changedFilesLine | Set-Clipboard

# # Print the result
# Write-Host "Copied to clipboard: $changedFilesLine"

# Write-Host " `n "


# Write-Host " `n "
# git status --porcelain
# Write-Host " `n "

# Write-Host "=== Message ======================================"

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
Write-Host ""
Write-Host "___ MESSAGE __________________________________________"
Write-Host ""
Write-Output $message
Write-Host ""
Write-Host "___ DESCRIPTION ______________________________________"
Write-Host ""
Write-Output $description
Write-Host ""
Write-Host "___ DONE _____________________________________________"
