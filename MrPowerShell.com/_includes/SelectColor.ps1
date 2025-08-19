<#
.SYNOPSIS
    Includes a color selector
.DESCRIPTION
    Includes a color selector.  
    
    This allows selection of a color from a fixed list of named colors.
#>
param([string]$id= 'SelectColor', [string]$Selected = 'foreground')
@"
<select id='$id'>
$(
foreach (
    $colorName in 
        'foreground','red','green','blue','yellow','purple','cyan','brightBlue',
        'brightRed','brightGreen','brightYellow','brightPurple','brightCyan'
    ) {
        "<option$(if ($Selected -eq $colorName) { ' selected'}) value='--$colorName'>$colorName</option>"
    }
)
</select>
"@

