# Dotnet command Autocomplete with TAB Key -----------------------------------------------------------------
# https://learn.microsoft.com/en-us/dotnet/core/tools/enable-tab-autocomplete?WT.mc_id=modinfra-35653-salean#powershell
# PowerShell parameter completion shim for the dotnet CLI
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
        dotnet complete --position $cursorPosition "$commandAst" | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}

# ----------------------------------------------------------------------------
# GIT command Autocomplete with TAB Key
# ----------------------------------------------------------------------------

# Look here for inspiration: https://github.com/kzrnm/git-completion-pwsh/tree/main
Register-ArgumentCompleter -Native -CommandName git -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)

    $inputLine = $commandAst.ToString()
    $args = $inputLine.Split()

    $gitCommands = @(
        'add -A; git commit -m "ADDED: "; git push --set-upstream ',
        'add -A; git commit -m "CHANGED: "; git push --set-upstream ',
        'add -A; git commit -m "DELETED: "; git push --set-upstream',
        'add -A; git commit -m "FIXED: "; git push --set-upstream',    
        'checkout dev; git pull origin dev',    
        'checkout -b <new-branch-name>',    
        'branch --all',    
        'diff dev',    
        'log --oneline --decorate',    
        'log --oneline --graph --decorate --all ',    
        'add', 'bisect', 'branch', 'checkout', 'clone', 'commit', 'diff',
        'fetch', 'grep', 'init', 'log', 'merge', 'mv', 'pull', 'push',
        'rebase', 'reset', 'restore', 'rm', 'show', 'status', 'switch', 'tag', 'whatchanged'
    )

    $commonGitOptions = @(
        '--help', '--version', '--exec-path', '--html-path', '--man-path', '--info-path'
    )
    $branchOptions = @(
        '--all',
        '--color',
        '--column',
        '--contains',
        '--copy',
        '--create-reflog',
        '--delete',
        '--edit-description',
        '--format=',
        '--force',
        '--ignore-case',
        '--list',
        '--merged',
        '--move',
        '--no-color',
        '--no-column',
        '--no-merged',
        '--points-at',
        '--quiet',
        '--remotes',
        '--show-current',
        '--sort=',
        '--track',
        '--unset-upstream',
        '--verbose'
    )

    $commitOptions = @(
        '-am "ADDED: "',
        '-am "CHANGED: "',
        '-am "FIXED: "',
        '-am "DELETED: "',
        '--amend',
        '--no-edit',
        '--only',
        '--quiet',
        '--signoff',
        '--dry-run',
        '--verbose',
        '--no-verify',
        '--all',
        '--reset-author',
        '--date',
        '--author',
        '--message',
        '--file',
        '--template',
        '--status',
        '--pathspec-from-file',
        '--pathspec-file-nul',
        '--mainline'
    )

    $diffOptions = @(
        '--abbrev-commit',
        '--abbrev=',
        '--anchored=',
        '--break-rewrites',
        '--break-rewrites=',
        '--cached',
        '--check',
        '--color-moved-ws',
        '--color-moved',
        '--color',
        '--compact-summary',
        '--cumulative',
        '--diff-algorithm=',
        '--diff-filter=',
        '--dirstat',
        '--dirstat=',
        '--dst-prefix=',
        '--exit-code',
        '--ext-diff',
        '--find-copies-harder',
        '--find-copies',
        '--find-copies=',
        '--find-renames',
        '--find-renames=',
        '--full-index',
        '--function-context',
        '--histogram',
        '--ignore-all-space',
        '--ignore-blank-lines',
        '--ignore-space-at-eol',
        '--ignore-space-change',
        '--indent-heuristic',
        '--inter-hunk-context=',
        '--irreversible-delete',
        '--minimal',
        '--name-only',
        '--name-status',
        '--no-color',
        '--no-ext-diff',
        '--no-indent-heuristic',
        '--no-patch',
        '--no-prefix',
        '--no-renames',
        '--numstat',
        '--output-indicator-context=',
        '--output-indicator-new=',
        '--output-indicator-old=',
        '--output=',
        '--patch-with-raw',
        '--patch',
        '--patience',
        '--quiet',
        '--raw',
        '--relative',
        '--relative=',
        '--rename-empty',
        '--shortstat',
        '--src-prefix=',
        '--staged',
        '--stat-graph-width=',
        '--stat-name-width=',
        '--stat-width=',
        '--stat',
        '--summary',
        '--text',
        '--unified=',
        '--word-diff-regex=',
        '--word-diff'
    )

    $logOptions = @(
        '--root',
         '--abbrev-commit',
         '--abbrev=',
         '--all',
         '--cherry-mark',
         '--cherry-pick',
         '--children',
         '--clear-decorations',
         '--date-order',
         '--date=',
         '--decorate-refs-exclude=',
         '--decorate-refs=',
         '--decorate',
         '--decorate=',
         '--do-walk',
         '--expand-tabs',
         '--expand-tabs=',
         '--follow',
         '--format=',
         '--full-diff',
         '--graph',
         '--name-status',
         '--no-abbrev-commit',
         '--no-decorate',
         '--no-expand-tabs',
         '--no-walk',
         '--no-walk=',
         '--oneline',
         '--oneline --decorate',
         '--oneline --graph --decorate --all',
         '--parents',
         '--patch',
         '--pretty=',
         '--relative-date',
         '--reverse',
         '--show-signature',
         '--since=',
         '--stat',
         '--topo-order',
         '--until=',
         '--walk-reflogs'
    )

    if ($args.Count -eq 1 -or ($args.Count -eq 2 -and $args[1] -like "$wordToComplete*")) {
        $gitCommands + $commonGitOptions |
        Where-Object { $_ -like "$wordToComplete*" } |
        ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
    elseif ($args.Count -ge 2) {
        $subcommand = $args[1]

        switch ($subcommand) {
            'branch' {
                $branchOptions |
                Where-Object { $_ -like "$wordToComplete*" } |
                ForEach-Object {
                    [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterName', $_)
                }
            }
            'checkout' {
                git branch --format='%(refname:short)' |
                Where-Object { $_ -like "$wordToComplete*" } |
                ForEach-Object {
                    [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
                }
            }
            'commit' {
                $commitOptions |
                Where-Object { $_ -like "$wordToComplete*" } |
                ForEach-Object {
                    [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterName', $_)
                }
            }
            'diff' {
                $diffOptions |
                Where-Object { $_ -like "$wordToComplete*" } |
                ForEach-Object {
                    [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterName', $_)
                }
            }
            'log' {
                $logOptions |
                Where-Object { $_ -like "$wordToComplete*" } |
                ForEach-Object {
                    [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterName', $_)
                }
            }
            default {
                # Optional: fallback to common options
                $commonGitOptions |
                Where-Object { $_ -like "$wordToComplete*" } |
                ForEach-Object {
                    [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterName', $_)
                }
            }
        }
    }
}

# ----------------------------------------------------------------------------
# CHOCO command Autocomplete with TAB Key
# ----------------------------------------------------------------------------

# Register-ArgumentCompleter -Native -CommandName choco -ScriptBlock {
#     param($wordToComplete, $commandAst, $cursorPosition)

#     $inputLine = $commandAst.ToString()
#     $args = $inputLine.Split()

#     $chocoCommands = @(
#         'find',
#         'help',
#         'info',
#         'install -y ',
#         'list',
#         'outdated',
#         'pin',
#         'search',
#         'uninstall',
#         'upgrade'
#     )

#     if ($args.Count -eq 1 -or ($args.Count -eq 2 -and $args[1] -like "$wordToComplete*")) {
#         $chocoCommands |
#         Where-Object { $_ -like "$wordToComplete*" } |
#         ForEach-Object {
#             [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
#         }
#     }
# }

# ----------------------------------------------------------------------------
# WINGET command Autocomplete with TAB Key
# ----------------------------------------------------------------------------

Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)

    $inputLine = $commandAst.ToString()
    $args = $inputLine.Split()

    $wingetCommands = @(
        # 'configure',
        # 'download',
        # 'export',
        # 'features',
        # 'hash',
        # 'import',
        'install',
        'list',
        'pin',
        'repair',
        'search',
        # 'settings',
        'show',
        # 'source',
        'uninstall',
        'upgrade'
        # 'validate'
    )

    if ($args.Count -eq 1 -or ($args.Count -eq 2 -and $args[1] -like "$wordToComplete*")) {
        $wingetCommands |
        Where-Object { $_ -like "$wordToComplete*" } |
        ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}

# ----------------------------------------------------------------------------
# NPM command Autocomplete with TAB Key
# ----------------------------------------------------------------------------

Register-ArgumentCompleter -Native -CommandName npm -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)

    $inputLine = $commandAst.ToString()
    $args = $inputLine.Split()

    $npmCommands = @(
        'access',
        'adduser',
        'audit',
        'bugs',
        'cache',
        'ci',
        'completion',
        'config',
        'dedupe',
        'deprecate',
        'diff',
        'dist-tag',
        'docs',
        'doctor',
        'edit',
        'exec',
        'explore',
        'find-dupes',
        'fund',
        'help',
        'help-search',
        'hook',
        'init',
        'install',
        # 'install-test',
        'link',
        'logout',
        'ls',
        'outdated',
        'owner',
        'pack',
        'ping',
        'pkg',
        'prefix',
        'profile',
        'prune',
        'publish',
        'rebuild',
        'repo',
        'restart',
        'root',
        'run',
        # 'run-script',
        'search',
        'set-script',
        'shrinkwrap',
        'star',
        'stars',
        'start',
        'stop',
        'team',
        'test',
        'token',
        'uninstall',
        # 'unpublish',
        # 'unstar',
        'update',
        'version',
        'view',
        'whoami'
    )

    if ($args.Count -eq 1 -or ($args.Count -eq 2 -and $args[1] -like "$wordToComplete*")) {
        $npmCommands |
        Where-Object { $_ -like "$wordToComplete*" } |
        ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}

# ----------------------------------------------------------------------------
# PIP command Autocomplete with TAB Key
# ----------------------------------------------------------------------------

Register-ArgumentCompleter -Native -CommandName pip -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)

    $inputLine = $commandAst.ToString()
    $args = $inputLine.Split()

    $pipCommands = @(
        # 'cache',
        # 'check',
        # 'completion',
        # 'config',
        # 'debug',
        # 'download',
        'freeze',
        # 'hash',
        # 'help',
        # 'index',
        # 'inspect',
        'install',
        'list',
        'search',
        'show',
        'uninstall',
        'wheel'
    )

    if ($args.Count -eq 1 -or ($args.Count -eq 2 -and $args[1] -like "$wordToComplete*")) {
        $pipCommands |
        Where-Object { $_ -like "$wordToComplete*" } |
        ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}

# ----------------------------------------------------------------------------
# NODE command Autocomplete with TAB Key
# ----------------------------------------------------------------------------
Register-ArgumentCompleter -Native -CommandName node -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)

    $nodeOptions = @(
        '--version',
        '--help',
        '--eval',
        '--print',
        '--check',
        '--interactive',
        '--require',
        '--input-type',
        '--inspect',
        '--inspect-brk',
        '--no-deprecation',
        '--trace-deprecation',
        '--trace-warnings',
        '--trace-sync-io',
        '--zero-fill-buffers',
        '--abort-on-uncaught-exception',
        '--unhandled-rejections',
        '--watch',
        '--watch-path=',
        '--loader=',
        '--enable-source-maps',
        '--experimental-specifier-resolution=node',
        '--experimental-repl-await',
        '--experimental-vm-modules',
        '--experimental-json-modules',
        '--experimental-import-meta-resolve'
    )

    $nodeOptions |
    Where-Object { $_ -like "$wordToComplete*" } |
    ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterName', $_)
    }
}

# ----------------------------------------------------------------------------
# TYPESCRIPT (tsc) command Autocomplete with TAB Key
# ----------------------------------------------------------------------------
# Register-ArgumentCompleter -Native -CommandName tsc -ScriptBlock {
#     param($wordToComplete, $commandAst, $cursorPosition)

#     $tscOptions = @(
#         '--help',
#         '--version',
#         '--watch',
#         '--project',
#         '--module',
#         '--target',
#         '--outFile',
#         '--outDir',
#         '--rootDir',
#         '--declaration',
#         '--sourceMap',
#         '--inlineSourceMap',
#         '--inlineSources',
#         '--noImplicitAny',
#         '--strictNullChecks',
#         '--esModuleInterop',
#         '--skipLibCheck',
#         '--noEmit',
#         '--removeComments',
#         '--jsx',
#         '--noImplicitThis',
#         '--allowJs',
#         '--checkJs',
#         '--noUnusedLocals',
#         '--noUnusedParameters',
#         '--moduleResolution',
#         '--resolveJsonModule',
#         '--isolatedModules',
#         '--allowSyntheticDefaultImports',
#         '--lib',
#         '--types',
#         '--typeRoots',
#         '--noEmitOnError',
#         '--skipDefaultLibCheck',
#         '--incremental',
#         '--tsBuildInfoFile',
#         '--allowUmdGlobalAccess',
#         '--resolveJsonModule',
#         '--downlevelIteration'
#     )

#     $tscOptions |
#     Where-Object { $_ -like "$wordToComplete*" } |
#     ForEach-Object {
#         [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterName', $_)
#     }
# }


# ----------------------------------------------------------------------------
# CD, Set-Location, Push-Location complete only folders with FZF
# ----------------------------------------------------------------------------
# if ($PSVersionTable.PSVersion.Major -ge 7.3) {
#     $cdCompleter = {
#         param($commandName, $parameterName, $wordToComplete, $commandAst, $cursorPosition)

#         $word = $wordToComplete
#         if ($null -eq $word) { $word = "" }

#         # Handle trailing backslashes or slashes
#         if ($word -match '^(.*)[\\/]$') {
#             $parent = $word
#             $leaf = ""
#         } else {
#             $parent = Split-Path -Path $word -Parent -ErrorAction SilentlyContinue
#             $leaf = Split-Path -Path $word -Leaf -ErrorAction SilentlyContinue
#             if ([string]::IsNullOrEmpty($parent)) {
#                 $parent = "."
#             }
#         }

#         if (Test-Path -Path $parent -ErrorAction SilentlyContinue) {
#             $filter = "$leaf*"
#             Get-ChildItem -Path $parent -Directory -ErrorAction SilentlyContinue |
#                 Where-Object { $_.Name -like $filter } |
#                 ForEach-Object {
#                     $fullPath = Join-Path -Path $parent -ChildPath $_.Name
#                     # Normalize separator to match the input style (slash vs backslash)
#                     if ($word -match '/') {
#                         $fullPath = $fullPath -replace '\\', '/'
#                     }
                    
#                     [System.Management.Automation.CompletionResult]::new(
#                         $fullPath,                    # Completion text
#                         $_.Name,                      # List item text
#                         'ProviderContainer',          # Result type
#                         $_.FullName                   # Tooltip
#                     )
#                 }
#         }
#     }

#     Register-ArgumentCompleter -CommandName @('cd', 'custom-cd', 'Set-Location', 'Push-Location', 'sl', 'chdir') -ParameterName 'Path' -ScriptBlock $cdCompleter
#     Register-ArgumentCompleter -CommandName @('cd', 'custom-cd', 'Set-Location', 'Push-Location', 'sl', 'chdir') -ParameterName 'LiteralPath' -ScriptBlock $cdCompleter    
# }

