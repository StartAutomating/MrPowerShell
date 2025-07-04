$TopLevelLinks = 'GitHub', 'Gists', 'Memes', 'Mentions', 'Tags'

$navigation = @($TopLevelLinks |
    ForEach-Object -Begin {
        "<nav class='navigation'>"
    } -Process {
        "<a href='$($_)'><button>$($_)</button></a>"
    } -End {
        "</nav>"
    }) -join [Environment]::NewLine

$style = @"
<style type='text/css'>
.grid9x9 {
  display: grid;
  height: 100vh;
  grid:
    "$( @('header') * 9)" minmax(100px, auto)
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
$navigation
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

<h3>
Things To Know:
</h3>

<ul>
<li>I do a lot of meta-programming.</li>
<li>I love to make hard things easy to do.</li>
<li>I enjoy sharing my knowledge with others.</li>
<li>I'm always interested in interesting projects.</li>
</ul>

<h3>
What is this site?
</h3>
<p>
This site is a living experiment in PowerShell Web development.
</p>
<p>
It's both a personal page and a proving ground for new ideas.
</p>
</div>
"@

   
"<div class='grid9x9'>"

$style,
    $header,
        $content -join [Environment]::NewLine

"</div>"
