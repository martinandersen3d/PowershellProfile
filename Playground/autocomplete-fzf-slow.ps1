# Import-Module PSFzf

# # This replaces the standard Tab completion with fzf
# Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }

# # Commands that change the location
# Register-ArgumentCompleter -CommandName cd -ScriptBlock {
#     param($commandName, $parameterName, $wordToComplete, $commandAst, $cursorPosition)

#     try {
#         # Using 'dir /ad /b /s' to get only directories (bare format, recursive)
#         # Then piping to fzf with your typed word as a query
#         $selectedDir = cmd /c "dir /ad /b /s 2>null" | fzf --query="$wordToComplete" --select-1 --exit-0

#         if ($selectedDir) {
#             # Ensure the path is relative or formatted correctly for the shell
#             $quotedPath = if ($selectedDir.Contains(' ')) { "'$selectedDir'" } else { $selectedDir }
            
#             [System.Management.Automation.CompletionResult]::new(
#                 $quotedPath, 
#                 $quotedPath, 
#                 'ProviderContainer', 
#                 $quotedPath
#             )
#         }
#     }
#     catch {
#         Write-Error "Fzf directory-only completion failed: $_"
#     }
# }