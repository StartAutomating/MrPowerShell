
<#
.SYNOPSIS
    Includes a palette selector
.DESCRIPTION
    Includes a palette selector in a page.  This allows the page to use multiple color palettes. 
#>
param(
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
function GetRandomPalette() {
    var SelectPalette = document.getElementById('$SelectPaletteId')
    if (SelectPalette) {
        var randomNumber = Math.floor(Math.random() * SelectPalette.length);
        SelectPalette.selectedIndex = randomNumber
        SetPalette()
    }    
}
"@

$HTML = @"
<script>
$JavaScript
</script>
<button onclick='GetRandomPalette()'>Random Palette</button>
"@

$HTML

