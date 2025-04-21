# # Define first array with Key1 and Description1
# $keyGroup1 = @(
#     @{ Key = "Ctrl+C"; Description = "Copy La LA la aa a a sdsd x xxxxxxxxxxxxxxxx a" },
#     @{ Key = "Ctrl+V"; Description = "Paste" },
#     @{ Key = "Ctrl+Z"; Description = "Undo" }
# )

# # Define second array with Key2 and Description2
# $keyGroup2 = @(
#     @{ Key = "Ctrl+X"; Description = "Cut" },
#     @{ Key = "Ctrl+Y"; Description = "Redo" },
#     @{ Key = "Ctrl+A"; Description = "Select All" }
# )

# # Create table combining the two arrays
# $table = for ($i = 0; $i -lt [Math]::Max($keyGroup1.Count, $keyGroup2.Count); $i++) {
#     [PSCustomObject]@{
#         Key1         = $keyGroup1[$i].Key
#         Description1 = "  " + $keyGroup1[$i].Description
#         Key2         = "  | " + $keyGroup2[$i].Key
#         Description2 = " " + $keyGroup2[$i].Description
#     }
# }

# # Display the table
# $table | Format-Table -AutoSize -HideTableHeaders


# Define first array with Key1 and Description1
$keyGroup1 = @(
    @{ Key = "`e[4;33mNAVIGATION`e[0m"; Description = "" },
    @{ Key = "LL"; Description = "List Folders and Files" },
    @{ Key = "G <text>"; Description = "Go To Favorites" },
    @{ Key = "S"; Description = "Go To Sub-dirs Fzf (Depth 3)" },
    @{ Key = "D"; Description = "List Directorys" },
    @{ Key = "DD"; Description = "List Directorys as table" },
    @{ Key = "F"; Description = "List Files" },
    @{ Key = ""; Description = "" },

    @{ Key = "`e[4;33mSCRIPTS`e[0m"; Description = "" },
    @{ Key = "L"; Description = "List Commands" },
    @{ Key = "P"; Description = "Preview Files in Dir With FZF" },
    @{ Key = "T"; Description = "Generate file from Template" },
    @{ Key = "X"; Description = "Execute Script" },
    @{ Key = "U"; Description = "Update Scripts" }
)

# Define second array with Key2 and Description2
$keyGroup2 = @(
    @{ Key = "`e[4;33mGIT`e[0m"; Description = "" },
    @{ Key = "GitCommitPush `e[90m`"`Message`"` `e[0m"; Description = "Add, Commit with message and PUSH" },
    @{ Key = "GitCheatsheet"; Description = "Git Cheatsheet Overview" },
    @{ Key = "GitCommitPush <string>"; Description = "Add, Commit with message and PUSH" },
    @{ Key = "GitAutoCommitMessage"; Description = "Add, Commit auto generated message" },
    @{ Key = "GitPush"; Description = "Git Push" },
    @{ Key = "GitShowCurrentCommitDiffFzf"; Description = "Show current commit diff in FZF" },
    @{ Key = "GitShowCommitMessage"; Description = "Preview auto generated Commit Message" },
    @{ Key = "GitShowCurrentBranchVSDevFzf"; Description = "In FZF Diff current branch vs dev" },
    @{ Key = "Git<TAB>"; Description = "Git Tools" },
    @{ Key = "git <TAB>"; Description = "Git Auto suggestions" },

    @{ Key = ""; Description = "" },
    @{ Key = "`e[4;33mSEARCH`e[0m"; Description = "" },
    @{ Key = "SearchFileName <string>"; Description = "Sarch for part of filename" },
    @{ Key = "SearchFolderName <string>"; Description = "Sarch for part of foldername" },
    @{ Key = "SearchContent <string>"; Description = "Search inside files with RipGrep" }
)

# Create table combining the two arrays
$table = for ($i = 0; $i -lt [Math]::Max($keyGroup1.Count, $keyGroup2.Count); $i++) {
    [PSCustomObject]@{
        Key1         = $keyGroup1[$i].Key
        Description1 = "  " + $keyGroup1[$i].Description
        Key2         = "  | " + $keyGroup2[$i].Key
        Description2 = " " + $keyGroup2[$i].Description
    }
}

# Display the table
$table | Format-Table -AutoSize -HideTableHeaders
