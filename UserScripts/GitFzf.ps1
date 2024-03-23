# Define the array of Git commands
$gitCommands = @(
    "git clone",
    "git init",
    "git add",
    "git commit",
    "git push",
    "git pull",
    "git checkout",
    "git branch",
    "git merge",
    "git status"
)

# Convert the array into a single string with newline characters
$commandsAsString = $gitCommands -join "`n"

# Use fzf to interactively select a command
$selectedCommand = & fzf.exe --reverse --preview-window=down:70% --preview='echo {}' <<< $commandsAsString

# Output the selected command
Write-Output $selectedCommand
