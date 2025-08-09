$JavaScript = @'
function SetPalette() {
    var palette = document.getElementById('palette')
    if (! palette) {
        palette = document.createElement('link')
        palette.rel = 'stylesheet'
        palette.id = 'palette'
        document.head.appendChild(palette)
    }
    var selectedPalette = document.getElementById('SelectPalette').value
    palette.href = 'https://cdn.jsdelivr.net/gh/2bitdesigns/4bitcss@latest/css/' + selectedPalette + '.css'        
}
function SetRandomPalette() {
    var SelectPalette = document.getElementById('SelectPalette')
    var randomNumber = Math.floor(Math.random() * SelectPalette.length);
    SelectPalette.selectedIndex = randomNumber
    SetPalette()
}
'@

$paletteSelector = @"
<select id='SelectPalette' onchange='SetPalette()'>
$(
    if (-not $script:PaletteList) {
        $script:PaletteList = Invoke-RestMethod https://4bitcss.com/Palette-List.json
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

