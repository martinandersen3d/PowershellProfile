function DemoOne {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ArgumentCompletions("Server01", "Server02", "Localhost")]
        [string]$First,

        [Parameter(Mandatory = $true, Position = 1)]
        [string]$Second,

        [Parameter(Mandatory = $false, Position = 2)]
        [string]$Third
    )
    # ... rest of your code with try-catch
}

function DemoTwo {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateSet("Apple", "Banana", "Orange")]
        [string]$First,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateSet("Red", "Blue", "Green")]
        [string]$Second,

        [Parameter(Mandatory = $false, Position = 2)]
        [string]$Third
    )

    try {
        Write-Host "First: $First"
        Write-Host "Second: $Second"

        if ($PSBoundParameters.ContainsKey('Third')) {
            Write-Host "Third: $Third"
        }
    }
    catch {
        Write-Error "An unexpected error occurred: $_"
    }
}

<#
.SYNOPSIS
    A brief description of what Show-ThreeArgs does.
.DESCRIPTION
    A detailed explanation of the function's behavior and argument handling.
.PARAMETER First
    Specifies the primary identification string or server name.
.PARAMETER Second
    Specifies the backup configuration or secondary string.
.PARAMETER Third
    An optional parameter to provide additional contextual metadata.
.EXAMPLE
    Show-ThreeArgs -First "Server01" -Second "ConfigA"
#>
function DemoThree {
    param(
        [Parameter(Mandatory = $true, Position = 0, HelpMessage = "Please enter the first string (e.g., a server name or ID).")]
        [string]$First,

        [Parameter(Mandatory = $true, Position = 1, HelpMessage = "Please enter the second string (e.g., a configuration profile).")]
        [string]$Second,

        [Parameter(Mandatory = $false, Position = 2)]
        [string]$Third
    )

    try {
        Write-Host "First: $First"
        Write-Host "Second: $Second"

        if ($PSBoundParameters.ContainsKey('Third')) {
            Write-Host "Third: $Third"
        }
    }
    catch {
        Write-Error "An unexpected error occurred: $_"
    }
}