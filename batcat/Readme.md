I maybe not need this:

How to use this:

Save the content above into a file named something like vscode_dark_plus.tmTheme.
Place this file in your bat themes directory. You can find the location by running bat --config-dir. It's usually in ~/.config/bat/themes/ on Linux/macOS or %APPDATA%\bat\themes\ on Windows. Create the themes directory if it doesn't exist.
Rebuild the bat cache by running bat cache --build.
List available themes with bat --list-themes. You should see "VS Code Dark+" listed.
You can now use the theme, for example: bat --theme="VS Code Dark+" your_file.js or set it as your default in the bat config file (bat --config-file).