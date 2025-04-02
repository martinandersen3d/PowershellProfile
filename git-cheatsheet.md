# Git Config
git config --global grep.lineNumber true
git config --global grep.patternType perl

# Git Branch
> Use command `git fetch` before the `git branch`

| Command                   | Description                              |
|---------------------------|------------------------------------------|
| git branch --list         | Lists all local branches.                |
| git branch --remotes      | Lists all remote branches.               |
| git branch --show-current | Displays the name of the current branch. |

# Git Log
| Command                                             | Description                                                           |
|-----------------------------------------------------|-----------------------------------------------------------------------|
| git log --follow --pretty=oneline -- myFilename.cs  | Displays a simple commit message history for a file (tracks renames). |
| git log --follow -p -- myFilename.cs                | Shows detailed diffs for each commit of a file (tracks renames).      |
| git log --oneline --decorate                        | Shows a compact log with commit messages and references.              |
| git log --oneline --graph --decorate                | Displays a graphical commit history with references.                  |
| git log --pretty=format:"%h - %s" --name-only -n 10 | Shows changed files in the last 10 commits.                           |
| git log -S 'search_string' -- myFilename.cs         | Shows all commits that added or removed a specific string in a file.  |

# Git Grep
| Command                               | Description                                        |
|---------------------------------------|----------------------------------------------------|
| git grep 'TODO'                       | Searches for the string "TODO" in the repository.  |
| git grep -n 'FIXME'                   | Displays line numbers for matches.                 |
| git grep -i 'error'                   | Case-insensitive search for "error".               |
| git grep -w 'main'                    | Matches the whole word "main" only.                |
| git grep -C2 'debug'                  | Shows 2 lines of context around matches.           |
| git grep -B3 'fatal'                  | Shows 3 lines before each match.                   |
| git grep -A4 'exception'              | Shows 4 lines after each match.                    |
| git grep --perl-regexp 'log\s*\('     | Uses Perl-style regex to match log( with spaces.   |
| git grep 'Logger' -- '*.cs'           | Searches only in .cs files.                        |
| git grep -e 'error' -e 'warning'      | Searches for multiple patterns.                    |
| git grep 'async' HEAD~3               | Searches for "async" in the commit 3 versions ago. |
| git grep 'TODO' $(git rev-list --all) | Searches "TODO" in the entire history.             |

# Git Diff
| Command                                    | Description                                                         |
|--------------------------------------------|---------------------------------------------------------------------|
| git diff                                   | Shows changes in the working directory (unstaged).                  |
| git diff branch1..branch2 -- myFilename.cs | Compares changes in a specific file between two branches.           |
| git diff --staged                          | Shows changes that are staged but not committed.                    |
| git diff HEAD                              | Shows differences between working directory and latest commit.      |
| git diff HEAD~1                            | Compares the working directory with the previous commit.            |
| git diff --name-only                       | Shows only the names of modified files.                             |
| git diff --name-status                     | Shows names and status (modified, added, deleted).                  |
| git diff branch1 branch2                   | Shows differences between two branches.                             |
| git diff commit1 commit2                   | Compares two specific commits.                                      |
| git diff --color-words                     | Highlights word differences instead of lines.                       |
| git diff --stat                            | Displays summary of changes (files changed, insertions, deletions). |
| git diff --ignore-space-change             | Ignores whitespace changes.                                         |
| git diff --diff-filter=D                   | Shows only deleted files.                                           |
| git diff origin/main                       | Compares local changes with origin/main.                            |
| git diff HEAD -- file.txt                  | Shows differences for a specific file.                              |
| git diff -U5                               | Shows 5 lines of context instead of default 3.                      |
| git diff --cached                          | Same as --staged (shows staged changes).                            |

# Git Blame
Shows who last modified each line of file.txt
| Command                                | Description                                       |
|----------------------------------------|---------------------------------------------------|
| git blame -w -C --date=short file.txt  | Shows who last modified each line of file.txt.    |
| git blame -L 10,20 file.txt            | Limits output to lines 10-20 of file.txt.         |
| git blame -C file.txt                  | Detects moved/copied lines in file.txt.           |
| git blame -C -C file.txt               | Detects copied code across multiple files.        |
| git blame -e file.txt                  | Shows emails instead of usernames.                |
| git blame --date=short file.txt        | Displays short date format for each commit.       |
| git blame --since=2.weeks file.txt     | Shows blame only for changes in the last 2 weeks. |
| git blame --author='John Doe' file.txt | Filters output to changes by a specific author.   |
| git blame -w file.txt                  | Ignores whitespace changes.                       |
| git blame -s file.txt                  | Suppresses the filename in the output.            |
| git blame --reverse HEAD~5 file.txt    | Shows blame from 5 commits ago onward.            |


# Git Reflog
Records all changes to the tip of branches and allows you to view the history of reference updates, including those that are not part of the commit history.
| Command               | Description                                |
|-----------------------|--------------------------------------------|
| git reflog --date=iso | Shows the reflog with ISO-formatted dates. |


Markdown Table Prettifier
https://marketplace.visualstudio.com/items?itemName=darkriszty.markdown-table-prettify

--------------------------------------------------------------------------------------