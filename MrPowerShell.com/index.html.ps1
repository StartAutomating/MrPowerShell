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
    position: fixed;
    display: grid;
    margin-right: 0.5%;
    margin-top: 0%; 
    right: 0.5%;   
    text-align: right;
    grid-template-columns: 1fr 1fr;
}

.corner div {
    padding: 0.5em;
}
</style>
"@

$header = @"
<div class='header'>
<a href='/'>
<h2>MrPowerShell</h2>
<svg height='200%' y='0%' style='margin-top: -7%'>
$((Get-Content -Path .\MrPowerShell-Animated.svg -Raw) -replace '<\?xml.+>')
</svg>
</a>
</div>
"@

$content = @"
<div class='content'>
$(Get-Item "$psScriptRoot/Greetings.md" | from_markdown)
</div>
"@

$corner = @"
<div class='corner'>
<div>
<a href='https://github.com/StartAutomating/MrPowerShell'>
$(Get-Content -Path ./Assets/GitHub.svg -Raw)
</a>
</div>
<div>
<a href='https://bsky.app/profile/mrpowershell.com'>
$(Get-Content -Path ./Assets/BlueSky.svg -Raw)
</a>
</div>
</div>
"@

$style,
    $corner,
        $header,    
            $content -join [Environment]::NewLine
