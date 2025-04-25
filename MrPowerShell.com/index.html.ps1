"<div id='header'>"
"<h1><a href='/'>MrPowerShell</a></h1>"
"<svg width='75%' height='25%'>"
"$((Get-Content -Path .\MrPowerShell-Animated.svg -Raw) -replace '<\?xml.+>')"
"</svg>"
"</div>"
"<div id='mainContent'>"
$markdown = ConvertFrom-Markdown -Path "$psScriptRoot/Greetings.md"
$markdown.Html
"</div>"
"<div id='footer'>"
"<a href='https://bsky.app/profile/mrpowershell.com'>
Follow me on BlueSky:
<br/>
<svg width='75%' height='10%'>
$((Get-Content -Path .\BlueSkyRainbow-Animated.svg -Raw) -replace '<\?xml.+>')
</svg>
</a>
<br/>
<a href='BlueSkyRainbow-Animated.svg'>Download SVG</a>"
"</div>"
