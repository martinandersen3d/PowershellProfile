
# Interactive directory navigation tool: CD into subfolders via fzf with context-aware depth limits.
# Uses 2-level depth at root/home for speed, and 5-level depth elsewhere for project browsing,
# while filtering out noise folders (e.g., .git, node_modules) to maximize relevance.
function fn-subdirs-fzf {
    $exclude = "\.git|node_modules|bin|obj"
    $arrow = [char]::ConvertFromUtf32(0x276F)
    
    # Get current path to check against criteria
    $currentPath = (Get-Location).Path
    $homeDir = $HOME # C:\Users\m
    $rootDrive = [System.IO.Path]::GetPathRoot($currentPath) # C:\

    # Determine depth: Default to 5, reduce to 2 for Home or Root
    if ($currentPath -eq $homeDir -or $currentPath -eq $rootDrive) {
        $depth = 1 # 0, 1 = 2 levels
    } else {
        $depth = 4 # 0, 1, 2, 3, 4 = 5 levels
    }

    # Run Get-ChildItem with dynamic depth
    $selection = Get-ChildItem -Path "." -Recurse -Directory -Name -Depth $depth -ErrorAction SilentlyContinue |
                 Where-Object { $_ -notmatch $exclude } |
                 fzf --height 40% --layout=reverse --prompt="SUBDIRS (Depth:$( $depth + 1 )) $arrow "

    if ($selection) {
        Set-Location $selection
    }
}