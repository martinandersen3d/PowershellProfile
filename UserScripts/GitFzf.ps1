# Define the array of Git commands
$gitCommands = @(
    "git add .",
    "git branch --list",
    "git branch --remotes",
    "git branch --show-current",
    "git checkout",
    "git checkout -b dev # Create Branch",
    "git checkout -b new_branch_name",
    "git clone",
    "git commit --all # Commit All",
    "git commit --all ; git push # Commit All, without a Commit Message, and Push",
    "git init",
    # "git merge # Select a list to merge from",
    "git pull",
    "git push",
    "git status"
)

# Pipe the array of commands to fzf for interactive selection
$selectedCommand = $gitCommands | Out-String | fzf.exe

# Output the selected command
Write-Output $selectedCommand
