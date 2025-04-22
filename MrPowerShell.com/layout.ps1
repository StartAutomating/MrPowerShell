$paletteName = 'Konsolas'

$argsAndinput = @($args) + @($input)

@"
<html>
    <head>
        <title>$Title</title>
        <meta name='viewport' content='width=device-width, initial-scale=1' />
        <link rel='stylesheet' href='https://cdn.jsdelivr.net/gh/2bitdesigns/4bitcss@latest/css/$PaletteName.css'>
        $OpenGraph
        $ImportMap
        <style>
        body {
            width: 100vw;
            height: 100vh;
        }
        </style>
    </head>
    <body>
$($argsAndinput -join [Environment]::NewLine)
    </body>
<html>
"@
