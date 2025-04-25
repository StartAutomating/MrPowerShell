$style = @"
<style type='text/css'>
.header {
    text-align: center;
    margin: 2em;
    height: 20%;    
}

.content {        
    margin: 3em;
    height: 33%
}

.corner {    
    position: absolute;
    right: 0;
    top: 0;
    height: 10%;
    text-align: right;
}
</style>
"@

$header = @"
<div class='header'>
<h2>MrPowerShell</h2>
<a href='/'>
<svg height='200%' y='0%' style='margin-top: -7%'>
$((Get-Content -Path .\MrPowerShell-Animated.svg -Raw) -replace '<\?xml.+>')
</svg>
</a>
</div>
"@

$content = @"
<div class='content'>
$($markdown = ConvertFrom-Markdown -Path "$psScriptRoot/Greetings.md"
$markdown.Html)
</div>
"@

$footer = @"
<div class='corner'>
<svg x='0%' height='66%'>
<a href='https://bsky.app/profile/mrpowershell.com'>
<title>Follow me on BlueSky</title>
$((Get-Content -Path .\BlueSkyRainbow-Animated.svg -Raw) -replace '<\?xml.+>')
</a>
</svg>
</div>
"@

$style,
    $header,    
    $content,
    $footer -join [Environment]::NewLine
