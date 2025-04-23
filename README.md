# 🎨 PowerShell Profile (Pretty PowerShell)

A stylish and functional PowerShell profile that looks and feels almost as good as a Linux terminal.

## ⚡ One Line Install (Elevated PowerShell Recommended)

Execute the following command in an elevated PowerShell window to install the PowerShell profile:

```
irm "https://github.com/martinandersen3d/PowershellProfile/raw/main/setup.ps1" | iex
```

# Requirements
- Run as Admin
- PowerShell 7+, required to use WinGet
- WinGet
- 'App Installer' from Microsoft Store has WinGet
- Git Installed (but if WinGet is working, it will ask to install it)

# Troubleshouting Installation:
1. Install Powershell 7.5+ 
2. Install WinGet
3. WinGet only works in PowerShell version 7+


# Dependencies
```
choco install -y fzf ripgrep batcat micro
```
# Todo
- https://github.com/dandavison/delta?tab=readme-ov-file

Miller:
- https://github.com/johnkerl/miller
- https://miller.readthedocs.io/en/latest/10min/
- Miller.Miller

GiTui
- https://github.com/gitui-org/gitui?tab=readme-ov-file#installation

Broot?
- https://dystroy.org/broot/

https://ilya-sher.org/2018/04/10/list-of-json-tools-for-command-line/

JID - Json Incremental Digger
- https://github.com/simeji/jid
YQ:
- https://github.com/mikefarah/yq

https://github.com/kellyjonbrazil/jtbl

Hurl:
- https://github.com/Orange-OpenSource/hurl?tab=readme-ov-file

Fselect:
- https://github.com/jhspetersson/fselect/

Presenterm:
- https://github.com/mfontanini/presenterm

Moniker: mediainfo
Publisher Url: https://mediaarea.net/
Description: A convenient unified display of the most relevant technical and tag data for video and audio files from command line.

# Inspiration
https://christitus.com/pretty-powershell/


----

# More utilities

🧭 CLI Navigation & System Tools

Tool	Description	Install Command
fzf	Fuzzy finder for navigating output	winget install fzf
bat	cat clone with syntax highlighting	winget install sharkdp.bat
lsd	ls replacement with icons	winget install lsd
eza	Modern replacement for ls (alt to lsd)	winget install eza-community.eza
ripgrep	Recursive fast search (like grep)	winget install BurntSushi.ripgrep
tldr	Community cheatsheets for commands	winget install tldr-pages.tldr
📂 Viewing & Modifying JSON, CSV, and Structured Data

Tool	Description	Install Command
jq	Lightweight JSON processor	winget install stedolan.jq
yq	Like jq, but for YAML	winget install mikefarah.yq
xsv	Fast CSV toolkit	winget install BurntSushi.xsv
visidata	Terminal spreadsheet for CSV/TSV/JSON	winget install saulpw.visidata
glow	Render Markdown in the terminal	winget install charmbracelet.glow
🔄 File Conversion

Tool	Description	Install Command
pandoc	Universal document converter	winget install pandoc
imagemagick	Convert/edit images from CLI	winget install ImageMagick.ImageMagick
ffmpeg	Convert audio/video files	winget install Gyan.FFmpeg
💻 Developer Tools
Git & Git-related

Tool	Description	Install Command
git	Version control system	winget install Git.Git
gh	GitHub CLI	winget install GitHub.cli
lazygit	TUI for Git	winget install jesseduffield.lazygit
tig	Text-mode interface for Git	winget install jonas.tig
delta	Syntax-highlighted Git diff viewer	winget install dandavison.delta
✨ Extras & Helpers

Tool	Description	Install Command
hyperfine	Benchmark command-line tools	winget install sharkdp.hyperfine
fd	Simplified find command	winget install sharkdp.fd
duf	Disk usage viewer	winget install muesli.duf
bottom	htop alternative with more metrics	winget install Clement.bottom
📦 Quick Bulk Install Script
powershell
Copy
Edit
winget install fzf; winget install sharkdp.bat; winget install lsd; winget install eza-community.eza; winget install BurntSushi.ripgrep; winget install tldr-pages.tldr; winget install stedolan.jq; winget install mikefarah.yq; winget install BurntSushi.xsv; winget install saulpw.visidata; winget install charmbracelet.glow; winget install pandoc; winget install ImageMagick.ImageMagick; winget install Gyan.FFmpeg; winget install Git.Git; winget install GitHub.cli; winget install jesseduffield.lazygit; winget install jonas.tig; winget install dandavison.delta; winget install sharkdp.hyperfine; winget install sharkdp.fd; winget install muesli.duf; winget install Clement.bottom
Let me know if you want a printable PDF, categorized Markdown version, or even a PowerShell script to automate checking/installing only what's missing.
