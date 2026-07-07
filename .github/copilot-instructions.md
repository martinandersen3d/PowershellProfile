---
layout: Reference
monikers:
- powershell-7.6
defaultMoniker: powershell-7.6
versioningType: Ranged
title: Register-ArgumentCompleter (Microsoft.PowerShell.Core) - PowerShell | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/register-argumentcompleter?view=powershell-7.6
config_moniker_range: powershell-7.6
uid: Microsoft.PowerShell.Core.Register-ArgumentCompleter
module: Microsoft.PowerShell.Core
description: 'The Register-ArgumentCompleter cmdlet registers a custom argument completer. An argument completer allows you to provide dynamic tab completion, at run time for any command that you specify. When you call this command with the CommandName parameter and without the ParameterName or Native parameters, the command runs as if you specified the Native parameter. This prevents the argument completer from working for PowerShell command parameters. Always specify the ParameterName parameter when you want to register an argument completer for PowerShell commands. '
ROBOTS: INDEX, FOLLOW
apiPlatform: powershell
archive_url: https://learn.microsoft.com/previous-versions/powershell/scripting/overview
breadcrumb_path: /powershell/scripting/bread/toc.json
feedback_product_url: https://github.com/PowerShell/PowerShell/issues/new/choose
feedback_help_link_url: https://learn.microsoft.com/powershell/scripting/community/community-support
feedback_help_link_type: ask-the-community
feedback_system: OpenSource
hideScope: false
author: sdwheeler
ms.author: sewhee
manager: jasongroce
ms.devlang: powershell
ms.service: powershell
ms.tgt_pltfr: windows, macos, linux
ms.update-cycle: 365-days
toc_preview: true
uhfHeaderId: MSDocsHeader-Powershell
ms.topic: reference
products:
- https://authoring-docs-microsoft.poolparty.biz/devrel/2bdae855-045f-4535-b365-7b2e23824328
- https://authoring-docs-microsoft.poolparty.biz/devrel/8bce367e-2e90-4b56-9ed5-5e4e9f3a2dc3
document type: cmdlet
external help file: System.Management.Automation.dll-Help.xml
HelpUri: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/register-argumentcompleter?view=powershell-7.6&WT.mc_id=ps-gethelp
Locale: en-us
Module Name: Microsoft.PowerShell.Core
ms.date: 2026-01-18T00:00:00.0000000Z
PlatyPS schema version: 2024-05-01T00:00:00.0000000Z
document_id: 62e812be-da48-a4c0-2a47-aac8e1c97018
document_version_independent_id: e471c27f-aa83-321f-541f-878442638e1b
updated_at: 2026-01-19T23:07:00.0000000Z
original_content_git_url: https://github.com/MicrosoftDocs/PowerShell-Docs/blob/live/reference/7.6/Microsoft.PowerShell.Core/Register-ArgumentCompleter.md
gitcommit: https://github.com/MicrosoftDocs/PowerShell-Docs/blob/918194e64e55e8ff165d23a3712b6c446ea5344f/reference/7.6/Microsoft.PowerShell.Core/Register-ArgumentCompleter.md
git_commit_id: 918194e64e55e8ff165d23a3712b6c446ea5344f
default_moniker: powershell-7.6
site_name: Docs
depot_name: PowerShell.PowerShell_PowerShell-docs_reference
in_right_rail: h2h3
page_type: powershell
page_kind: command
toc_rel: ../psdocs/toc.json
asset_id: module/microsoft.powershell.core/register-argumentcompleter
moniker_range_name: 9b5469a01154ce5be5ffa44dbe12b832
monikers:
- powershell-7.6
item_type: Content
source_path: reference/7.6/Microsoft.PowerShell.Core/Register-ArgumentCompleter.md
cmProducts: []
platformId: 82a00d7d-6623-9e4f-b6ad-70b62035db79
---

# Register-ArgumentCompleter

- Module:
    - [Microsoft.PowerShell.Core Module](./)

Registers a custom argument completer.

## Syntax

### NativeSet

```Syntax
Register-ArgumentCompleter
    -CommandName <string[]>
    -ScriptBlock <scriptblock>
    [-Native]
    [<CommonParameters>]
```

### PowerShellSet

```Syntax
Register-ArgumentCompleter
    -ParameterName <string>
    -ScriptBlock <scriptblock>
    [-CommandName <string[]>]
    [<CommonParameters>]
```

### NativeFallbackSet

```Syntax
Register-ArgumentCompleter
    -ScriptBlock <scriptblock>
    [-NativeFallback]
    [<CommonParameters>]
```

## Description

The `Register-ArgumentCompleter` cmdlet registers a custom argument completer. An argument completer allows you to provide dynamic tab completion, at run time for any command that you specify.

When you call this command with the **CommandName** parameter and without the **ParameterName** or **Native** parameters, the command runs as if you specified the **Native** parameter. This prevents the argument completer from working for PowerShell command parameters. Always specify the **ParameterName** parameter when you want to register an argument completer for PowerShell commands.

## Examples

### Example 1: Register a custom argument completer

The following example registers an argument completer for the **Id** parameter of the `Set-TimeZone` cmdlet.

```powershell
$s = {
    param(
        $commandName,
        $parameterName,
        $wordToComplete,
        $commandAst,
        $fakeBoundParameters
    )

    (Get-TimeZone -ListAvailable).Id | Where-Object {
        $_ -like "$wordToComplete*"
    } | ForEach-Object {
        "'$_'"
    }
}

Register-ArgumentCompleter -CommandName Set-TimeZone -ParameterName Id -ScriptBlock $s
```

The first command creates a scriptblock that takes the required parameters, which are passed in when the user presses Tab. For more information, see the **ScriptBlock** parameter description.

Within the scriptblock, the available values for **Id** are retrieved using the `Get-TimeZone` cmdlet. The **Id** property for each Time Zone is piped to the `Where-Object` cmdlet. The `Where-Object` cmdlet filters out any ids that don't start with the value provided by `$wordToComplete`, which represents the text the user typed before they pressed Tab. The filtered ids are piped to the `ForEach-Object` cmdlet, which encloses each value in quotes to handle values that contain spaces.

The second command registers the argument completer by passing the scriptblock, the **ParameterName** **Id** and the **CommandName**`Set-TimeZone`.

### Example 2: Add details to your tab completion values

The following example overwrites tab completion for the **Name** parameter of the `Stop-Service` cmdlet and only returns running services.

```powershell
$s = {
    param(
        $commandName,
        $parameterName,
        $wordToComplete,
        $commandAst,
        $fakeBoundParameters
    )

    $services = Get-Service | Where-Object {
        $_.Status -eq 'Running' -and $_.Name -like "$wordToComplete*"
    }

    $services | ForEach-Object {
        New-Object -Type System.Management.Automation.CompletionResult -ArgumentList @(
            $_.Name          # completionText
            $_.Name          # listItemText
            'ParameterValue' # resultType
            $_.Name          # toolTip
        )
    }
}

Register-ArgumentCompleter -CommandName Stop-Service -ParameterName Name -ScriptBlock $s
```

The first command creates a scriptblock that takes the required parameters, which are passed in when the user presses Tab. For more information, see the **ScriptBlock** parameter description.

Within the scriptblock, the first command retrieves all running services using the `Where-Object` cmdlet. The services are piped to the `ForEach-Object` cmdlet. The `ForEach-Object` cmdlet creates a new [System.Management.Automation.CompletionResult](/en-us/dotnet/api/system.management.automation.completionresult) object and populates it with the name of the current service (represented by the pipeline variable `$_.Name`).

The **CompletionResult** object allows you to provide additional details to each returned value:

- **completionText** (String) - The text to be used as the auto completion result. This is the value sent to the command.
- **listItemText** (String) - The text to be displayed in a list, such as when the user presses Ctrl+Space. PowerShell uses this for display only. It isn't passed to the command when selected.
- **resultType** ([CompletionResultType](/en-us/dotnet/api/system.management.automation.completionresulttype)) - The type of completion result.
- **toolTip** (String) - The text for the tooltip with details to display about the object. This is visible when the user selects an item after pressing Ctrl+Space.

### Example 3: Register a custom Native argument completer

You can use the **Native** parameter to provide tab-completion for a native command. The following example adds tab-completion for the `dotnet` Command Line Interface (CLI).

Note

The `dotnet complete` command is only available in version 2.0 and greater of the dotnet cli.

```powershell
$scriptblock = {
    param(
        $wordToComplete,
        $commandAst,
        $cursorPosition
    )

    dotnet complete --position $cursorPosition $commandAst.ToString() | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new(
            $_,               # completionText
            $_,               # listItemText
            'ParameterValue', # resultType
            $_                # toolTip
        )
    }
}

Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock $scriptblock
```

The first command creates a scriptblock that takes the required parameters, which are passed in when the user presses Tab. For more information, see the **ScriptBlock** parameter description.

Within the scriptblock, the `dotnet complete` command performs the tab completion. The results are piped to the `ForEach-Object` cmdlet, which uses the **new** static method of the [System.Management.Automation.CompletionResult](/en-us/dotnet/api/system.management.automation.completionresult) class to create a **CompletionResult** object for each value.

## Parameters

### -CommandName

Specifies the name of one or more commands to register the argument completer for. This parameter is mandatory for native commands.

When you specify this parameter without the **ParameterName** or **Native** parameters, the command behaves as if you had specified the **Native** parameter. When registering argument completers for PowerShell commands, always specify the **ParameterName** parameter.

If you don't specify this parameter, PowerShell registers the argument completer for the specified **ParameterName** across all PowerShell commands.

#### Parameter properties

| Type: | [String](/en-us/dotnet/api/system.string)[] |
| --- | --- |
| Default value: | None |
| Supports wildcards: | False |
| DontShow: | False |

#### Parameter sets

 NativeSet 

| Position: | Named |
| --- | --- |
| Mandatory: | True |
| Value from pipeline: | False |
| Value from pipeline by property name: | False |
| Value from remaining arguments: | False |

 PowerShellSet 

| Position: | Named |
| --- | --- |
| Mandatory: | False |
| Value from pipeline: | False |
| Value from pipeline by property name: | False |
| Value from remaining arguments: | False |

### -Native

Indicates that the argument completer is for a native command where PowerShell can't complete parameter names.

#### Parameter properties

| Type: | [SwitchParameter](/en-us/dotnet/api/system.management.automation.switchparameter) |
| --- | --- |
| Default value: | None |
| Supports wildcards: | False |
| DontShow: | False |

#### Parameter sets

 NativeSet 

| Position: | Named |
| --- | --- |
| Mandatory: | False |
| Value from pipeline: | False |
| Value from pipeline by property name: | False |
| Value from remaining arguments: | False |

### -NativeFallback

When you use this parameter, PowerShell registers a cover-all argument completer for native commands. When a native command doesn't have a specific completer for it, it uses the cover-all completer. A cover-all completer allows a module like Microsoft.PowerShell.UnixTabCompletion to be registered to provide tab completion for many native commands on Linux and macOS systems.

Note

You can only register one cover-all completer.

This parameter was added in PowerShell 7.6-preview.5.

#### Parameter properties

| Type: | [SwitchParameter](/en-us/dotnet/api/system.management.automation.switchparameter) |
| --- | --- |
| Default value: | None |
| Supports wildcards: | False |
| DontShow: | False |

#### Parameter sets

 NativeFallbackSet 

| Position: | Named |
| --- | --- |
| Mandatory: | False |
| Value from pipeline: | False |
| Value from pipeline by property name: | False |
| Value from remaining arguments: | False |

### -ParameterName

Specifies the name of the parameter the argument completer applies to. The type for specified parameters can't be an enumeration, such as the **ForegroundColor** parameter of the `Write-Host` cmdlet.

For more information on enums, see [about_Enum](about/about_enum).

When registering an argument completer for PowerShell commands, always specify this parameter. When you specify the **CommandName** parameter without the **ParameterName** or **Native** parameters, the command behaves as if you specified the **Native** parameter.

#### Parameter properties

| Type: | [String](/en-us/dotnet/api/system.string) |
| --- | --- |
| Default value: | None |
| Supports wildcards: | False |
| DontShow: | False |

#### Parameter sets

 PowerShellSet 

| Position: | Named |
| --- | --- |
| Mandatory: | True |
| Value from pipeline: | False |
| Value from pipeline by property name: | False |
| Value from remaining arguments: | False |

### -ScriptBlock

Specifies the commands to run to perform tab completion. The scriptblock you provide should return the values that complete the input. The scriptblock must unroll the values using the pipeline (`ForEach-Object`, `Where-Object`, etc.), or another suitable method. Returning an array of values causes PowerShell to treat the entire array as **one** tab completion value.

The scriptblock can also return [System.Management.Automation.CompletionResult](/en-us/dotnet/api/system.management.automation.completionresult) objects for each value to enhance the user experience. Returning **CompletionResult** objects enables you to define tooltips and custom list entries displayed when users press Ctrl+Space to show the list of available completions.

The scriptblock must accept the following parameters in the order specified below. The names of the parameters aren't important because PowerShell passes in the values by position.

- `$commandName` (Position 0, **String**) - This parameter is set to the name of the command for which the scriptblock is providing tab completion.
- `$parameterName` (Position 1, **String**) - This parameter is set to the parameter whose value requires tab completion.
- `$wordToComplete` (Position 2, **String**) - This parameter is set to value the user has provided before they pressed Tab. Your scriptblock should use this value to determine tab completion values.
- `$commandAst` (Position 3, **CommandAst**) - This parameter is set to the Abstract Syntax Tree (AST) for the current input line. For more information, see [CommandAst Class](/en-us/dotnet/api/system.management.automation.language.commandast).
- `$fakeBoundParameters` (Position 4 **IDictionary**) - This parameter is set to a hashtable containing the `$PSBoundParameters` for the cmdlet, before the user pressed Tab. For more information, see [about_Automatic_Variables](about/about_automatic_variables).

When you specify the **Native** parameter, the scriptblock must take the following parameters in the specified order. The names of the parameters aren't important because PowerShell passes in the values by position.

- `$wordToComplete` (Position 0, **String**) - This parameter is set to value the user has provided before they pressed Tab. Your scriptblock should use this value to determine tab completion values.
- `$commandAst` (Position 1, **CommandAst**) - This parameter is set to the Abstract Syntax Tree (AST) for the current input line. For more information, see [CommandAst Class](/en-us/dotnet/api/system.management.automation.language.commandast).
- `$cursorPosition` (Position 2, **Int32**) - This parameter is set to the position of the cursor when the user pressed Tab.

You can also provide an **ArgumentCompleter** as a parameter attribute. For more information, see [about_Functions_Advanced_Parameters](about/about_functions_advanced_parameters).

#### Parameter properties

| Type: | [ScriptBlock](/en-us/dotnet/api/system.management.automation.scriptblock) |
| --- | --- |
| Default value: | None |
| Supports wildcards: | False |
| DontShow: | False |

#### Parameter sets

 (All) 

| Position: | Named |
| --- | --- |
| Mandatory: | True |
| Value from pipeline: | False |
| Value from pipeline by property name: | False |
| Value from remaining arguments: | False |

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable, -ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## Inputs

### None

You can't pipe objects to this cmdlet.

## Outputs

### None

This cmdlet returns no output.

## Related Links

- [about_Functions_Argument_Completion](about/about_functions_argument_completion)

---

## Other Supported Versions

- [powershell-5.1](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/register-argumentcompleter?view=powershell-5.1&accept=text/markdown)
- [powershell-7.4](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/register-argumentcompleter?view=powershell-7.4&accept=text/markdown)
- [powershell-7.5](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/register-argumentcompleter?view=powershell-7.5&accept=text/markdown)
- [powershell-7.7](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/register-argumentcompleter?view=powershell-7.7&accept=text/markdown)


---
external help file: Microsoft.PowerShell.PSReadLine2.dll-Help.xml
Locale: en-US
Module Name: PSReadLine
ms.date: 03/04/2026
online version: https://learn.microsoft.com/powershell/module/psreadline/set-psreadlineoption?view=powershell-5.1&WT.mc_id=ps-gethelp
no-loc: [Windows]
schema: 2.0.0
title: Set-PSReadLineOption
---

# Set-PSReadLineOption

## SYNOPSIS
Customizes the behavior of command line editing in **PSReadLine**.

## SYNTAX

```
Set-PSReadLineOption [-EditMode <EditMode>] [-ContinuationPrompt <string>]
 [-HistoryNoDuplicates] [-AddToHistoryHandler <Func[string,Object]>]
 [-CommandValidationHandler <Action[CommandAst]>] [-HistorySearchCursorMovesToEnd]
 [-MaximumHistoryCount <int>] [-MaximumKillRingCount <int>] [-ShowToolTips]
 [-ExtraPromptLineCount <int>] [-DingTone <int>] [-DingDuration <int>]
 [-BellStyle <BellStyle>] [-CompletionQueryItems <int>] [-WordDelimiters <string>]
 [-HistorySearchCaseSensitive] [-HistorySaveStyle <HistorySaveStyle>]
 [-HistorySavePath <string>] [-AnsiEscapeTimeout <int>] [-PromptText <string[]>]
 [-ViModeIndicator <ViModeStyle>] [-ViModeChangeHandler <scriptblock>]
 [-Colors <hashtable>] [<CommonParameters>]
```

## DESCRIPTION

The `Set-PSReadLineOption` cmdlet customizes the behavior of the **PSReadLine** module when you're
editing the command line. To view the **PSReadLine** settings, use `Get-PSReadLineOption`.

The options set by this command only apply to the current session. To persist any options, add them
to a profile script. For more information, see
[about_Profiles](../Microsoft.PowerShell.Core/About/about_Profiles.md) and
[Customizing your shell environment](/powershell/scripting/learn/shell/creating-profiles).

## EXAMPLES

### Example 1: Set foreground and background colors

This example sets **PSReadLine** to display the **Comment** token with green foreground text on a
gray background. In the escape sequence used in the example, **32** represents the foreground color
and **47** represents the background color.

```powershell
Set-PSReadLineOption -Colors @{ "Comment"="$([char]0x1b)[32;47m" }
```

You can choose to set only a foreground text color. For example, a bright green foreground text
color for the **Comment** token: `"Comment"="$([char]0x1b)[92m"`.

### Example 2: Set bell style

In this example, **PSReadLine** will respond to errors or conditions that require user attention.
The **BellStyle** is set to emit an audible beep at 1221 Hz for 60 ms.

```powershell
Set-PSReadLineOption -BellStyle Audible -DingTone 1221 -DingDuration 60
```

> [!NOTE]
> This feature may not work in all hosts on platforms.

### Example 3: Set multiple options

`Set-PSReadLineOption` can set multiple options with a hash table.

```powershell
$PSReadLineOptions = @{
    EditMode = "Emacs"
    HistoryNoDuplicates = $true
    HistorySearchCursorMovesToEnd = $true
    Colors = @{
        "Command" = "#8181f7"
    }
}
Set-PSReadLineOption @PSReadLineOptions
```

The `$PSReadLineOptions` hash table sets the keys and values. `Set-PSReadLineOption` uses the keys
and values with `@PSReadLineOptions` to update the **PSReadLine** options.

You can view the keys and values entering the hash table name, `$PSReadLineOptions` on the
PowerShell command line.

### Example 4: Set multiple color options

This example shows how to set more than one color value in a single command.

```powershell
Set-PSReadLineOption -Colors @{
  Command            = 'Magenta'
  Number             = 'DarkGray'
  Member             = 'DarkGray'
  Operator           = 'DarkGray'
  Type               = 'DarkGray'
  Variable           = 'DarkGreen'
  Parameter          = 'DarkGreen'
  ContinuationPrompt = 'DarkGray'
  Default            = 'DarkGray'
}
```

### Example 5: Set color values for multiple types

This example shows three different methods for how to set the color of tokens displayed in
**PSReadLine**.

```powershell
Set-PSReadLineOption -Colors @{
 # Use a ConsoleColor enum
 "Error" = [ConsoleColor]::DarkRed

 # 24 bit color escape sequence
 "String" = "$([char]0x1b)[38;5;100m"

 # RGB value
 "Command" = "#8181f7"
}
```

### Example 6: Use ViModeChangeHandler to display Vi mode changes

This example emits a cursor change VT escape in response to a **Vi** mode change.

```powershell
function OnViModeChange {
    if ($args[0] -eq 'Command') {
        # Set the cursor to a blinking block.
        Write-Host -NoNewline "$([char]0x1b)[1 q"
    } else {
        # Set the cursor to a blinking line.
        Write-Host -NoNewline "$([char]0x1b)[5 q"
    }
}
Set-PSReadLineOption -ViModeIndicator Script -ViModeChangeHandler $Function:OnViModeChange
```

The **OnViModeChange** function sets the cursor options for the **Vi** modes: insert and command.
**ViModeChangeHandler** uses the `Function:` provider to reference **OnViModeChange** as a
scriptblock object.

For more information, see
[about_Providers](/powershell/module/microsoft.powershell.core/about/about_providers).

### Example 7: Use HistoryHandler to filter commands added to history

The following example shows how to use the `AddToHistoryHandler` to prevent saving any git commands
to history.

```powershell
$ScriptBlock = {
    param ([string]$Line)

    if ($Line -match "^git") {
        return $false
    } else {
        return $true
    }
}

Set-PSReadLineOption -AddToHistoryHandler $ScriptBlock
```

The scriptblock returns `$false` if the command started with `git`. This has the same effect as
returning the `SkipAdding` **AddToHistory** enum. If the command doesn't start with `git`, the
handler returns `$true` and PSReadLine saves the command in history.

### Example 8: Use CommandValidationHandler to validate a command before its executed

This example shows how to use the **CommandValidationHandler** parameter to run a validate a command
before it's executed. The example specifically checks for the command `git` with the sub command
`cmt` and replaces that with the full name `commit`. This way you can create shorthand aliases for
subcommands.

```powershell
# Load the namespace so you can use the [CommandAst] object type
using namespace System.Management.Automation.Language

Set-PSReadLineOption -CommandValidationHandler {
    param([CommandAst]$CommandAst)

    switch ($CommandAst.GetCommandName()) {
        'git' {
            $gitCmd = $CommandAst.CommandElements[1].Extent
            switch ($gitCmd.Text) {
                'cmt' {
                    [Microsoft.PowerShell.PSConsoleReadLine]::Replace(
                        $gitCmd.StartOffset, $gitCmd.EndOffset - $gitCmd.StartOffset, 'commit')
                }
            }
        }
    }
}
# This checks the validation script when you hit enter
Set-PSReadLineKeyHandler -Chord Enter -Function ValidateAndAcceptLine
```

### Example 9: Using the PromptText parameter

When there's a parse error, **PSReadLine** changes a part of the prompt red. The **PromptText**
parameter tells **PSReadLine** the part of the prompt string to make red.

For example, the following example creates a prompt that contains the current path followed by the
greater-than character (`>`) and a space.

```powershell
function prompt { "PS $PWD> " }`
Set-PSReadLineOption -PromptText '> ' # change the '>' character red
Set-PSReadLineOption -PromptText '> ', 'X ' # replace the '>' character with a red 'X'
```

The first string is the portion of your prompt string that you want to make red when there is a
parse error. The second string is an alternate string to use for when there is a parse error.

## PARAMETERS

### -AddToHistoryHandler

Specifies a **ScriptBlock** that controls how commands get added to **PSReadLine** history.

The **ScriptBlock** receives the command line as input.

The  **ScripBlock** should return a member of the **AddToHistoryOption** enum, the string name of
one of those members, or a boolean value. The list below describes the possible values and their
effects.

- `MemoryAndFile` - Add the command to the history file and the current session.
- `MemoryOnly` - Add the command to history for the current session only.
- `SkipAdding` - Don't add the command to the history file for current session.
- `$false` - Same as if the value was `SkipAdding`.
- `$true` - Same as if the value was `MemoryAndFile`.

```yaml
Type: System.Func`2[System.String,System.Object]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AnsiEscapeTimeout

This option is specific to Windows when input is redirected, for example, when running under `tmux`
or `screen`.

With redirected input on Windows, many keys are sent as a sequence of characters starting with the
escape character. It's impossible to distinguish between a single escape character followed by
more characters and a valid escape sequence.

The assumption is that the terminal can send the characters faster than a user types. **PSReadLine**
waits for this timeout before concluding that it has received a complete escape sequence.

If you see random or unexpected characters when you type, you can adjust this timeout.

```yaml
Type: System.Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 100
Accept pipeline input: False
Accept wildcard characters: False
```

### -BellStyle

Specifies how **PSReadLine** responds to various error and ambiguous conditions.

The valid values are as follows:

- `Audible`: A short beep.
- `Visual`: Text flashes briefly.
- `None`: No feedback.

```yaml
Type: Microsoft.PowerShell.BellStyle
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Audible
Accept pipeline input: False
Accept wildcard characters: False
```

### -Colors

The **Colors** parameter specifies various colors used by **PSReadLine**.

The argument is a hash table where the keys specify the elements and the values specify the color.
For more information, see
[about_Hash_Tables](/powershell/module/microsoft.powershell.core/about/about_hash_tables).

Colors can be either a value from **ConsoleColor**, for example `[ConsoleColor]::Red`, or a valid
ANSI escape sequence. Valid escape sequences depend on your terminal. In PowerShell 5.0, an example
escape sequence for red text is `$([char]0x1b)[91m`. In PowerShell 6 and newer, the same escape
sequence is `` `e[91m``. You can specify other escape sequences including the following types:

- 256 color
- 24-bit color
- Foreground, background, or both
- Inverse, bold

For more information about ANSI color codes, see the Wikipedia article
[ANSI escape code](https://wikipedia.org/wiki/ANSI_escape_code#Colors_).

The valid keys include:

- `ContinuationPrompt`: The color of the continuation prompt.
- `Emphasis`: The emphasis color. For example, the matching text when searching history.
- `Error`: The error color. For example, in the prompt.
- `Selection`: The color to highlight the menu selection or selected text.
- `Default`: The default token color.
- `Comment`: The comment token color.
- `Keyword`: The keyword token color.
- `String`: The string token color.
- `Operator`: The operator token color.
- `Variable`: The variable token color.
- `Command`: The command token color.
- `Parameter`: The parameter token color.
- `Type`: The type token color.
- `Number`: The number token color.
- `Member`: The member name token color.

```yaml
Type: System.Collections.Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CommandValidationHandler

Specifies a **ScriptBlock** that is called from **ValidateAndAcceptLine**. If an exception is
thrown, validation fails and the error is reported.

Before throwing an exception, the validation handler can place the cursor at the point of the error
to make it easier to fix. A validation handler can also change the command line to correct common
typographical errors.

**ValidateAndAcceptLine** is used to avoid cluttering your history with commands that can't work.

```yaml
Type: System.Action`1[System.Management.Automation.Language.CommandAst]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CompletionQueryItems

Specifies the maximum number of completion items that are shown without prompting.

If the number of items to show is greater than this value, **PSReadLine** prompts **yes/no** before
displaying the completion items.

```yaml
Type: System.Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 100
Accept pipeline input: False
Accept wildcard characters: False
```

### -ContinuationPrompt

Specifies the string displayed at the beginning of the subsequent lines when multi-line input is
entered. The default is double greater-than signs (`>>`). An empty string is valid.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: >>
Accept pipeline input: False
Accept wildcard characters: False
```

### -DingDuration

Specifies the duration of the beep when **BellStyle** is set to `Audible`.

```yaml
Type: System.Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 50ms
Accept pipeline input: False
Accept wildcard characters: False
```

### -DingTone

Specifies the tone in Hertz (Hz) of the beep when **BellStyle** is set to `Audible`

```yaml
Type: System.Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 1221
Accept pipeline input: False
Accept wildcard characters: False
```

### -EditMode

Specifies the command line editing mode. Using this parameter resets any key bindings set by
`Set-PSReadLineKeyHandler`.

The valid values are as follows:

- `Windows`: Key bindings emulate PowerShell, cmd, and Visual Studio. (default)
- `Emacs`: Key bindings emulate Bash or Emacs.
- `Vi`: Key bindings emulate Vi.

Use `Get-PSReadLineKeyHandler` to see the key bindings for the currently configured **EditMode**.

```yaml
Type: Microsoft.PowerShell.EditMode
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Windows
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExtraPromptLineCount

Specifies the number of extra lines.

If your prompt spans more than one line, specify a value for this parameter. Use this option when
you want extra lines to be available when **PSReadLine** displays the prompt after showing some
output. For example, **PSReadLine** returns a list of completions.

This option is needed less than in previous versions of **PSReadLine**, but is useful when the
`InvokePrompt` function is used.

```yaml
Type: System.Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -HistoryNoDuplicates

This option controls the recall behavior. Duplicate commands are still added to the history file.
When this option is set, only the most recent invocation appears when recalling commands. Repeated
commands are added to history to preserve ordering during recall. However, you typically don't want
to see the command multiple times when recalling or searching the history.

By default, the **HistoryNoDuplicates** property of the global **PSConsoleReadLineOptions** object
is set to `True`. To change the property value, you must specify the value of the
**SwitchParameter** as follows: `-HistoryNoDuplicates:$false`. You can set back to `True` by using
just the **SwitchParameter**, `-HistoryNoDuplicates`.

Using the following command, you can set the property value directly:

`(Get-PSReadLineOption).HistoryNoDuplicates = $false`

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -HistorySavePath

Specifies the path to the file where history is saved. Computers running Windows or non-Windows
platforms store the file in different locations. The filename is stored in a variable
`$($Host.Name)_history.txt`, for example `ConsoleHost_history.txt`.

If you don't use this parameter, the default path is:

`$Env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\$($Host.Name)_history.txt`

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: A file named $($Host.Name)_history.txt in $Env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine on Windows and $Env:XDG_DATA_HOME/powershell/PSReadLine or $HOME/.local/share/powershell/PSReadLine on non-Windows platforms
Accept pipeline input: False
Accept wildcard characters: False
```

### -HistorySaveStyle

Specifies how **PSReadLine** saves history.

Valid values are as follows:

- `SaveIncrementally`: Save history after each command is executed and share across multiple
  instances of PowerShell.
- `SaveAtExit`: Append history file when PowerShell exits.
- `SaveNothing`: Don't use a history file.

> [!NOTE]
> If you set **HistorySaveStyle** to `SaveNothing` and then set it to `SaveIncrementally` later in
> the same session, PSReadLine saves all the commands previously run in the session.

```yaml
Type: Microsoft.PowerShell.HistorySaveStyle
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: SaveIncrementally
Accept pipeline input: False
Accept wildcard characters: False
```

### -HistorySearchCaseSensitive

Specifies that history searching is case-sensitive in functions like **ReverseSearchHistory** or
**HistorySearchBackward**.

By default, the **HistorySearchCaseSensitive** property of the global **PSConsoleReadLineOptions**
object is set to `False`. Using this **SwitchParameter** sets the property value to `True`. To
change the property value back, you must specify the value of the **SwitchParameter** as follows:
`-HistorySearchCaseSensitive:$false`.

Using the following command, you can set the property value directly:

`(Get-PSReadLineOption).HistorySearchCaseSensitive = $false`

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -HistorySearchCursorMovesToEnd

Indicates that the cursor moves to the end of commands that you load from history by using a search.
When this parameter is set to `$false`, the cursor remains at the position it was when you pressed
the up or down arrows.

By default, the **HistorySearchCursorMovesToEnd** property of the global
**PSConsoleReadLineOptions** object is set to `False`. Using this **SwitchParameter** set the
property value to `True`. To change the property value back, you must specify the value of the
**SwitchParameter** as follows: `-HistorySearchCursorMovesToEnd:$false`.

Using the following command, you can set the property value directly:

`(Get-PSReadLineOption).HistorySearchCursorMovesToEnd = $false`

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -MaximumHistoryCount

Specifies the maximum number of commands to save in **PSReadLine** history.

**PSReadLine** history is separate from PowerShell history.

```yaml
Type: System.Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MaximumKillRingCount

Specifies the maximum number of items stored in the kill ring.

```yaml
Type: System.Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 10
Accept pipeline input: False
Accept wildcard characters: False
```

### -PromptText

This parameter sets the value of the **PromptText** property. The default value is `"> "`.

**PSReadLine** analyzes your prompt function to determine how to change only the color of part of
your prompt. This analysis isn't 100% reliable. Use this option if **PSReadLine** is changing your
prompt in unexpected ways. Include any trailing whitespace.

The value of this parameter can be a single string or an array of two strings. The first string is
the portion of your prompt string that you want to be changed to red when there is a parse error.
The second string is an alternate string to use for when there is a parse error.

```yaml
Type: System.String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: >
Accept pipeline input: False
Accept wildcard characters: False
```

### -ShowToolTips

When displaying possible completions, tooltips are shown in the list of completions.

This option is enabled by default. This option wasn't enabled by default in prior versions of
**PSReadLine**. To disable, set this option to `$false`.

By default, the **ShowToolTips** property of the global **PSConsoleReadLineOptions** object is set
to `True`. Using this **SwitchParameter** sets the property value to `True`. To change the property
value, you must specify the value of the **SwitchParameter** as follows: `-ShowToolTips:$false`.

Using the following command, you can set the property value directly:

`(Get-PSReadLineOption).ShowToolTips = $false`

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: True
Accept pipeline input: False
Accept wildcard characters: False
```

### -ViModeChangeHandler

When the **ViModeIndicator** is set to `Script`, the scriptblock provided will be invoked every time
the mode changes. The scriptblock is provided one argument of type `ViMode`.

This parameter was introduced in PowerShell 7.

```yaml
Type: System.Management.Automation.ScriptBlock
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ViModeIndicator

This option sets the visual indicator for the current `Vi` mode. Either insert mode or command
mode.

The valid values are as follows:

- `None`: There's no indicator.
- `Prompt`: The prompt changes color.
- `Cursor`: The cursor changes size.
- `Script`: User-specified text is printed.

```yaml
Type: Microsoft.PowerShell.ViModeStyle
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WordDelimiters

Specifies the characters that delimit words for functions like **ForwardWord** or **KillWord**.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: ;:,.[]{}()/\|^&*-=+'"---
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose,
-WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

You can't pipe objects to this cmdlet.

## OUTPUTS

### None

This cmdlet returns no output.

## NOTES

## RELATED LINKS

[about_PSReadLine](./About/about_PSReadLine.md)

[Get-PSReadLineKeyHandler](Get-PSReadLineKeyHandler.md)

[Get-PSReadLineOption](Get-PSReadLineOption.md)

[Remove-PSReadLineKeyHandler](Remove-PSReadLineKeyHandler.md)

[Set-PSReadLineKeyHandler](Set-PSReadLineKeyHandler.md)


# Powershell Method parameters 

