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

$gitCommandsAsString = $gitCommands -join "`n"
$selectedCommand = $gitCommandsAsString | Out-String | Out-GridView -PassThru

Write-Output $selectedCommand