$paletteName = 'Konsolas'
$Font = 'Roboto'
$CodeFont = 'Inconsolata'

$argsAndinput = @($args) + @($input)

$style = @"
body {
    width: 100vw;
    height: 100vh;
    font-family: '$GoogleFont', sans-serif;        
}
pre, code {
    font-family: '$CodeFont', monospace;
}
@

@"
<html>
    <head>
        <title>$Title</title>
        <meta name='viewport' content='width=device-width, initial-scale=1' />
        <link rel='stylesheet' href='https://cdn.jsdelivr.net/gh/2bitdesigns/4bitcss@latest/css/$PaletteName.css' id='palette' />
        <link rel='stylesheet' href='https://fonts.googleapis.com/css?family=$Font' id='font' />
        <link rel='stylesheet' href='https://fonts.googleapis.com/css?family=$CodeFont' id='codeFont' />
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@latest/build/styles/default.min.css" id='highlight' />
        $OpenGraph
        $ImportMap
        <style>
$style        
        </style>
        $(
            @(
                '<script src="https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@latest/build/highlight.min.js"></script>'
                foreach ($language in 'powershell') {
                    "<script src='https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@latest/build/languages/$language.min.js'></script>"
                }
            ) -join [Environment]::NewLine            
        )
    </head>
    <body>
$($argsAndinput -join [Environment]::NewLine)
<script>hljs.highlightAll();</script>
    </body>
</html>
"@
