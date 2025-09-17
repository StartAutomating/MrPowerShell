<#
.SYNOPSIS
    Includes a palette selector
.DESCRIPTION
    Includes a palette selector in a page. 
#>
param(
[uri]
$PaletteListSource = 'https://4bitcss.com/Palette-List.json',

# The Palette CDN.  This is the root URL of all palettes.
[uri]
$PaletteCDN = 'https://cdn.jsdelivr.net/gh/2bitdesigns/4bitcss@latest/css/',

# The identifier for the palette `<select>`.
[string]
$SelectPaletteId = 'SelectPalette',

# The identifier for the stylesheet.  By default, palette.
[string]
$PaletteId = 'palette'
)


$JavaScript = @"
function SetPalette() {
    var palette = document.getElementById('$PaletteId')
    if (! palette) {
        palette = document.createElement('link')
        palette.rel = 'stylesheet'
        palette.id = 'palette'
        document.head.appendChild(palette)
    }
    var selectedPalette = document.getElementById('$SelectPaletteId').value
    palette.href = '$PaletteCDN' + selectedPalette + '.css'        
}
    
function SetRandomPalette() {
    var SelectPalette = document.getElementById('$SelectPaletteId')
    var randomNumber = Math.floor(Math.random() * SelectPalette.length);
    SelectPalette.selectedIndex = randomNumber
    SetPalette()
}
"@

$paletteSelector = @"
<select id='$SelectPaletteId' onchange='SetPalette()'>
$(
    if (-not $script:PaletteList) {
        $script:PaletteList = Invoke-RestMethod $PaletteListSource
    }
    foreach ($paletteName in $script:PaletteList) {
        "<option value='$([Web.HttpUtility]::HtmlAttributeEncode($paletteName))'>$([Web.HttpUtility]::HtmlEncode($paletteName))</option>"
    }
)
</select>
"@


$HTML = @"
<script>
$JavaScript
</script>
$PaletteSelector
"@

$HTML

