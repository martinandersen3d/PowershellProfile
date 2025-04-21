# Define first array with Key1 and Description1
$keyGroup1 = @(
    @{ Key = "Ctrl+C"; Description = "Copy" },
    @{ Key = "Ctrl+V"; Description = "Paste" },
    @{ Key = "Ctrl+Z"; Description = "Undo" }
)

# Define second array with Key2 and Description2
$keyGroup2 = @(
    @{ Key = "Ctrl+X"; Description = "Cut" },
    @{ Key = "Ctrl+Y"; Description = "Redo" },
    @{ Key = "Ctrl+A"; Description = "Select All" }
)

# Create table combining the two arrays
$table = for ($i = 0; $i -lt [Math]::Max($keyGroup1.Count, $keyGroup2.Count); $i++) {
    [PSCustomObject]@{
        Key1         = $keyGroup1[$i].Key
        Description1 = $keyGroup1[$i].Description
        Key2         = $keyGroup2[$i].Key
        Description2 = $keyGroup2[$i].Description
    }
}

# Display the table
$table | Format-Table -AutoSize
