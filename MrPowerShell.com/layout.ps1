$paletteName = 'Konsolas'

$argsAndinput = @($args) + @($input)

$style = @'
body {
    width: 100vw;
    height: 100vh;
    font-family: 'Roboto', sans-serif;    
}
'@

@"
<html>
    <head>
        <title>$Title</title>
        <meta name='viewport' content='width=device-width, initial-scale=1' />
        <link rel='stylesheet' href='https://cdn.jsdelivr.net/gh/2bitdesigns/4bitcss@latest/css/$PaletteName.css' id='palette' />
        <link rel='stylesheet' href='https://fonts.googleapis.com/css?family=Roboto' id='font' />
        
        $OpenGraph
        $ImportMap
        <style>
$style        
        </style>
        $(
            @(
                '<script src="https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@latest/build/highlight.min.js"></script>'
                foreach ($language in 'PowerShell') {
                    "<script src='https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@latest/build/languages/$language.min.js'></script>"
                }
            ) -join [Environment]::NewLine            
        )
    </head>
    <body>
$($argsAndinput -join [Environment]::NewLine)
    </body>
</html>
"@
