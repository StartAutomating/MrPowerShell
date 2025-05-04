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
"@

@"
<html>
    <head>
        $(
            if ($site.analyticsID) {
@"
<!-- Google tag (gtag.js) -->
<script async src="https://www.googletagmanager.com/gtag/js?id=$($site.AnalyticsID)"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', '$($site.AnalyticsID)');
</script>
"@
            }
        )
        <title>$(if ($page['Title']) { $page['Title'] } else { $Title})</title>
        <meta name='viewport' content='width=device-width, initial-scale=1' />
        <link rel='stylesheet' href='https://cdn.jsdelivr.net/gh/2bitdesigns/4bitcss@latest/css/$PaletteName.css' id='palette' />
        <link rel='stylesheet' href='https://fonts.googleapis.com/css?family=$Font' id='font' />
        <link rel='stylesheet' href='https://fonts.googleapis.com/css?family=$CodeFont' id='codeFont' />
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@latest/build/styles/default.min.css" id='highlight' />
        <script src='https://unpkg.com/htmx.org@latest'></script>
        $(
            if ($MetaData -is [Collections.IDictionary] -and $metadata.Count) {
                foreach ($og in $MetaData.GetEnumerator()) {
                    "<meta name='$([Web.HttpUtility]::HtmlAttributeEncode($keyValue.Key))' content='$([Web.HttpUtility]::HtmlAttributeEncode($keyValue.Value))' />"
                }
            }
        )        
        
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
