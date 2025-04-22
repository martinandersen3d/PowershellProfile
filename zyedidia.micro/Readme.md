# Settings dir
\.config\micro

# Plugins
https://micro-editor.github.io/plugins.html

# Filemanager
# https://github.com/NicolaiSoeborg/filemanager-plugin
# Hotkey: F4 (custom in bindings.json)
```
micro -plugin install filemanager
```
 - Cltr+E write "tree" to toggle the filemanager
 - Press "Tab" to open a file

# micro -plugin install fzf
# adds support to opening files via fzf
# Hotkey: Ctrl+O (custom in bindings.json)
```
micro -plugin install fzf
```

# Quotes around selection
```
micro -plugin install quoter
```

# Theme
In Powershell profile, set the following variable:
```
$env:MICRO_TRUECOLOR = "1"
```

File:
\.config\micro\colorschemes\vscode-dark.micro

```
# VSCode Dark+ true-color theme for Micro
# ~/.config/micro/colorschemes/vscode-dark.micro

# Base
color-link default            "#BBBBBB,#1E1E1E"

# Syntax
color-link comment            "#6A9955,#1E1E1E"
color-link identifier         "#9CDCFE,#1E1E1E"
color-link constant           "#4FC1FF,#1E1E1E"
color-link constant.string    "#CE9178,#1E1E1E"
color-link statement          "#569CD6,#1E1E1E"
color-link symbol             "#D4D4D4,#1E1E1E"
color-link preproc            "#C586C0,#1E1E1E"
color-link type               "#4EC9B0,#1E1E1E"
color-link special            "#DCDCAA,#1E1E1E"
color-link underlined         "#3794FF,#1E1E1E"

# UI & Highlights
color-link error              "bold #F48771,#1E1E1E"
color-link todo               "bold #FFCC00,#1E1E1E"
color-link hlsearch           "#000000,#ADD6FF"
color-link statusline         "#007ACC,#FFFFFF"
color-link tabbar             "#252526,#CCCCCC"
color-link indent-char        "#404040,#1E1E1E"
color-link line-number        "#858585,#1E1E1E"
color-link current-line-number "#C6C6C6,#1E1E1E"
color-link diff-added         "#587C0C"
color-link diff-modified      "#007ACC"
color-link diff-deleted       "#A1260D"
color-link gutter-error       "#F48771,#1E1E1E"
color-link gutter-warning     "#CCA700,#1E1E1E"
color-link cursor-line        "#264F78"
color-link color-column       "#2A2D2E"
color-link match-brace        "#1E1E1E,#D16969"
color-link tab-error          "#FF0000"
color-link trailingws         "#FF0000"
```