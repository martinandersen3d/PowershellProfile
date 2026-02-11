# Bind Cltr+Alt+Down to function s
Set-PSReadLineKeyHandler -Chord "Ctrl+Alt+UpArrow" -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("cd ..")
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}