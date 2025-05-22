$style = @"
<style type='text/css'>
@media (min-width: 30em) {
}
@media (min-width: 60em) {
}

.grid9x9 {
  display: grid;
  height: 100vh;
  grid:
    "$( @('header') * 9)" minmax(100px, auto)
    "$( @('navigation') * 9)" minmax(100px, auto)
    "$( @('main') * 9)" minmax(100px, auto)
    "$( @('footer') * 9)" minmax(100px, auto)
    / $( @('1fr') * 9);
  align-content: center;
  grid-auto-rows: auto
}


.header {
    text-align: center;
    margin: 2em;
    height: 20%;
    grid-area: header;    
}

.navigation {
    text-align: center;
    margin: 1em;
    height: 5%;
    grid-area: navigation;
}

.content {        
    margin: 3em;
    height: 33%;
    grid-area: main;
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
<svg>
$((Get-Content -Path .\MrPowerShell-Animated.svg -Raw) -replace '<\?.+>')
</svg>
<h1>
MrPowerShell
</h1>
</a>
</div>
"@

$content = @"
<div class='content'>
<h1>
Hey PowerShell People!
</h1>
<h2>
Welcome to my website!
</h2>
<h3>
Who am I?
</h3>
<p>
I'm James Brundage, and I've been using PowerShell since it's early days.
</p>

<p>
I was lucky enough to help test and build PowerShell V2 and V3 at Microsoft, 
and I've continued to do amazing things with the language ever since.
</p>

<p>
I enjoy making hard things easy to do, and I love to share my knowledge with others.
</p>

<p>
I'm always interested in interesting projects.
</p>

<p>
If you need the help of a Jack of all trades and master of PowerShell, reach out.
</p>
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

$TopLevelLinks = 'GitHub','Gist', 'Memes'

$navigation = @($TopLevelLinks |
    ForEach-Object -Begin {
        "<nav class='navigation'>"    
    } -Process {
        "<a href='$($_)'><button>$($_)</button></a>"
    } -End {
        "</nav>"
    }) -join [Environment]::NewLine
    
"<div class='grid9x9'>"

$style,
    $corner,
        $header,    
            $navigation,
                $content -join [Environment]::NewLine

"</div>"
