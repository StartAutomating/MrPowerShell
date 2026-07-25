<#
.SYNOPSIS
    Layout script
.DESCRIPTION
    This script is used to layout a page with a consistent style and structure.

    If a file generates HTML but does not include a `<html>` tag, it's output should be piped to this script.

    Any directories without a layout should use the nearest `layout.ps1` file in a parent directory.

    Layout parameters can be provided by the site or page.
#>
param(
    # The name of the palette to use.
    [Alias('Palette')]
    [string]
    $PaletteName = 'Konsolas',

    # The Google Font name
    [Alias('FontName')]
    [string]
    $Font = 'Roboto',

    # The Google Code Font name
    [string]
    $CodeFont = 'Inconsolata',
    
    # The urls for any fav icons.
    [string[]]
    $FavIcon,
    
    # The taskbar icons.
    # The key should be the icon name or content, and the value should be the URL.
    # SVG icons should be included inline so they may be stylized.
    [Collections.IDictionary]
    $Taskbar = [Ordered]@{},

    # The header menu.
    [Collections.IDictionary]
    $HeaderMenu = [Ordered]@{},

    # The footer menu.
    [Collections.IDictionary]
    $FooterMenu = [Ordered]@{}
)

# The literal first thing we do is to capture the arguments and input.
# This is important beecause `$input` can only be read once.
$allInput = @($input)

$allArguments = @($args)
$argsAndinput = @($args) + @($allInput)

#region Initialize Site and Page

# Site and Page are generally expected to be an ordered dictionary
# If they already existed, we don't have to default the values
# (and we can use whatever they provided)
if (-not $Site) { $Site = [Ordered]@{} }
if (-not $page) { $page = [Ordered]@{} }
if (-not $page.MetaData) { $page.MetaData = [Ordered]@{} }
#endregion Initialize Site and Page

#region Bind Site and Page Data

# If the `$page` or the `$site` defines a layout parameter
# we want to use that.
$psVariable = $ExecutionContext.SessionState.PSVariable
:nextParameter foreach ($parameterName in $MyInvocation.MyCommand.Parameters.Keys) {
    $parameter = $MyInvocation.MyCommand.Parameters[$parameterName]        
    if ($page.($Parameter.Name)) {
        try {
            $psVariable.Set($Parameter.Name, $page.($ParameterName))
            continue nextParameter
        } catch {
            Write-Warning "Could not bind $($page.($parameterName)) to `$$($parameterName): $_"
        }
    }
    elseif ($site.($Parameter.Name)) {
        try {
            $psVariable.Set($Parameter.Name, $site.($ParameterName))
            continue nextParameter
        } catch {
            Write-Warning "Could not bind $($site.($parameterName)) to `$$($parameterName): $_"
        }
    }

    foreach ($alias in $parameter.Aliases) {
        if ($page.$alias) {
            try {
                $psVariable.Set($Parameter.Name, $page.$alias)
                continue nextParameter
            } catch {
                Write-Warning "Could not bind $($page.$alias) to `$$($parameterName): $_"
            }
        }
        elseif ($site.$alias) {
            try {
                $psVariable.Set($Parameter.Name, $site.$alias)
                continue nextParameter
            } catch {
                Write-Warning "Could not bind $($site.$alias) to `$$($parameterName): $_"
            }            
        }   
    }
}
#endregion Initialize Parameters
        
#region Initialize Metadata

$page.MetaData['og:title'] = $title
$page.MetaData['og:description'] = $description

$page.MetaData['og:image'] =
    if ($image) { $image } 
    elseif ($page.image) { $page.image } 
    elseif ($site.image) { $site.image }

if ($page.Date -is [DateTime]) {
    $page.MetaData['article:published_time'] = $page.Date.ToString('o')
}

if ($page.MetaData['og:image']) {
    $page.MetaData['og:image'] = $page.MetaData['og:image'] -replace '^/', '' -replace '^[^h]', '/'
}
#endregion Initialize Metadata

filter outputHtml {
    $outputItem = $_
    switch ($outputItem) {
        {$outputItem -is [string]} { return $outputItem }
        {$outputItem -is [xml]} { return $outputItem.OuterXml }
        {$outputItem.HTML} { return $outputItem.HTML }
        {$outputItem.Markdown} { return (ConvertFrom-Markdown -InputObject $outputItem.Markdown).HTML }
        default { "$outputItem" }
    }
}

$outputHtml = @($argsAndinput | outputHtml) -join [Environment]::NewLine

#region Declare global styles
$style = @"
body {
    max-width: 100vw;
    height: 100vh;
    font-family: '$Font', sans-serif;
    margin: 1em;    
}

header, footer {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr;
    grid-template-areas:
        "grid-left grid-center grid-right";
    text-align: center;
    
}

.grid-left { grid-area: grid-left; place-items: left; }
.grid-center { grid-area: grid-center; place-items: center;  }
.grid-right { grid-area: grid-right; place-items: right  }

article {
    background-color: var(--background);
    margin: 1rem;
    padding: 1rem;
    max-width: 100%;    
}

header svg {    
    text-align: center;
}
header h1 {
    display: inline-block;
}

$(
    if ($HeaderMenu) {
        # If the device is in landscape mode, use larger padding and gaps
        "@media (orientation: landscape) {"
            ".header-menu { display: grid; grid-template-columns: repeat(auto-fit, minmax(100px, 1fr)); gap: 0.25rem }"
            ".header-menu-item { text-align: center; padding: 0.5em; }"
        "}"

        # If the device is in portrait mode, use smaller padding and gaps
        "@media (orientation: portrait) {"
            ".header-menu { display: grid; grid-template-columns: repeat(auto-fit, minmax(66px, 1fr)); gap: 0.25rem }"
            ".header-menu-item { text-align: center; padding: 0.25em; }"
        "}"
    }
)

$(
    if ($FooterMenu) {
        "@media (orientation: landscape) {"
            ".footer-menu { display: grid; grid-template-columns: repeat(auto-fit, minmax(100px, 1fr)); gap: 0.5em }"
            ".footer-menu-item { text-align: center; padding: 0.5em; }"
        "}"

        "@media (orientation: portrait) {"
            ".footer-menu { display: grid; grid-template-columns: repeat(auto-fit, minmax(100px, 1fr)); gap: 0.25em }"
            ".footer-menu-item { text-align: center; padding: 0.25em; }"
        "}"
    }
)

.logo { 
    display: inline-block;
    height: 4.2rem;
}

.logo-site-title {
    display: flex;
    place-items: center;    
    flex-direction: row;    
}

.logo-site-title svg { height: 4rem }

.logo svg {
    
}

.expandInline { display: flex; flex-direction: row; }

@media (orientation: landscape) {    
    .site-title, .page-title {
        font-size: 1.23rem;
        line-height: .75rem
    }
}

@media (orientation: portrait) {    
    .site-title, .page-title {
        font-size: 0.84em;
        line-height: .66rem
    }
    .expandInline { display: flex; flex-direction: column; }
}

pre, code { font-family: '$CodeFont', monospace; }

a, a:visited {
    text-decoration: none;
}

a:hover, a:focus {
    text-decoration: underline;    
}

.main {
    $(if ($page.FontSize) {
        "font-size: $($page.FontSize);"
    } elseif ($site.FontSize) {
        "font-size: $($site.FontSize);"
    } else {
        "font-size: 1.23em;"
    })
}

.taskbar {
    position: fixed;
    top: 0; right: 0; z-index: 10;    
    text-align: right;
    display: flex; flex-direction: row-reverse; 
    align-content: right; align-items: center;
    margin: 1em; gap: 0.5em;
}

.taskbar * {
    vertical-align: middle;    
}

.logo {
    display: inline-block;
}

.background {
    position: fixed;
    top: 0; left: 0;
    min-width: 100%; height:100%;
}

.backdrop-svg {
    z-index: -100;
}

.backdrop-canvas {
    z-index: -99;
}
"@

# $style = @($StyleTable | outputCss) -join [Environment]::NewLine
#endregion Declare global styles



#region Page Header

# Set up all of the header elements
$headerElements = @(
    # * Google Analytics
    if ($site.analyticsID) {
        "<!-- Google tag (gtag.js) -->
        <script async src='https://www.googletagmanager.com/gtag/js?id=$($site.AnalyticsID)'></script>
        <script>
            window.dataLayer = window.dataLayer || [];
            function gtag(){dataLayer.push(arguments);}
            gtag('js', new Date());
            gtag('config', '$($site.AnalyticsID)');
        </script>"
    }
    # * Viewport metadata
    "<meta name='viewport' content='width=device-width, initial-scale=1, minimum-scale=1.0' />"
    # * Open Graph metadata
    if ($Page.MetaData -is [Collections.IDictionary] -and $Page.MetaData.Count) {
        foreach ($og in $Page.MetaData.GetEnumerator()) {
            "<meta name='$([Web.HttpUtility]::HtmlAttributeEncode($og.Key))' content='$([Web.HttpUtility]::HtmlAttributeEncode($og.Value))' />"
        }
    }
    # * RSS autodiscovery
    if (-not $site.NoRss) { "<link rel='alternate' type='application/rss+xml' title='$($site.Title)' href='/RSS/index.rss' />" }
    # * Color palette
    if ($PaletteName) { "<link rel='stylesheet' href='https://cdn.jsdelivr.net/gh/2bitdesigns/4bitcss@latest/css/$PaletteName.css' id='palette' />" }
    # * Google Font
    if ($Font) { "<link rel='stylesheet' href='https://fonts.googleapis.com/css?family=$Font' id='font' />" }
    # * Code font
    if ($CodeFont) { "<link rel='stylesheet' href='https://fonts.googleapis.com/css?family=$CodeFont' id='codeFont' />" }
    # * highlightjs css ( if using highlight )
    if ($Site.HighlightJS -or $page.HighlightJS) {
        "<link rel='stylesheet' href='https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@latest/build/styles/default.min.css' id='highlight' />"
        '<script src="https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@latest/build/highlight.min.js"></script>'
        foreach ($language in $Site.HighlightJS.Languages) {
            "<script src='https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@latest/build/languages/$language.min.js'></script>"
        }
    }
    # * favicons 
    if ($FavIcon) {
        switch -regex ($FavIcon) {
            '\.(?>svg|png)$' {
                $contentType = $matches.0 -replace 'svg', 'svg+xml' -replace '^', 'image'
                # (try to match the size,
                if ($_ -match '\d+x\d+') {
                    "<link rel='icon' href='$_' type='$contentType' sizes='$($matches.0)' />"
                } else {
                    # otherwise, use 'any' size)
                    "<link rel='icon' href='$_' type='$contentType' sizes='any' />"
                }
            }
        }
    }    
    # * HTMX
    if (-not $Site.NoHtmx -or $page.NoHtmx) {
        "<script src='https://unpkg.com/htmx.org@latest'></script>"
    }
    $ImportMap
    # * Our styles
    "<style>$style</style>"
)

# Now we declare the body elements
$bodyElements = @(
    # * The background layers

    
    
    "<svg class='background backdrop-svg' id='background-svg' width='100%' height='100%'>"
    if ($page.Background -is [xml]) {
        $page.Background.OuterXml
    }
    elseif ($site.Background -is [xml]) {
        $site.Background.OuterXml
    }
    "</svg>"    
    "<canvas id='background backdrop-canvas' width='0' height='0'></canvas>"


    # * The header
    "<header>"
        if ($page.Header) {
            $page.Header -join [Environment]::NewLine
        } elseif ($site.Header) {
            $site.Header -join [Environment]::NewLine
        } else {
            "<section class='grid-left'>"
                "<a href='/'>"         
                "<h2 class='logo-site-title'>"
                    
                    # "<svg xmlns='http://www.w3.org/2000/svg' class='logo'>"
                    if ($site.Logo) {
                        if ($site.Logo -match '<svg') { $site.Logo -replace '<\?.+>' }
                        else { "<image src='$($site.Logo)' class='logoImage' />" }
                    }                    
                    # "</svg>" 
                    if ($site.Title) {
                        "$([Web.HttpUtility]::HtmlEncode($site.Title))"
                    }
                    elseif ($site.CNAME) {                    
                        "$([Web.HttpUtility]::HtmlEncode($site.CNAME))"
                    }                
                "</h2>"
                "</a>" 
                "</section>"
            "</section>"
            "<section class='grid-center'>"
            if ($page.Title -and $page.Title -ne $site.Title) {
                "<h1 class='page-title'>$([Web.HttpUtility]::HtmlEncode($page.Title))</h1>"
            }
            "</section>"
        }
        
        "<section class='grid-right'>"
        if ($headerMenu) {            
            "<nav class='header-menu'>"
            foreach ($menuItem in $headerMenu.GetEnumerator()) {
                "<a href='$($menuItem.Value)' class='header-menu-item'>$(
                    [Web.HttpUtility]::HtmlEncode($menuItem.Key)
                )</a>"
            }
            foreach ($taskbarItem in $taskbar.GetEnumerator()) {
                "<a href='$($taskbarItem.Value)' class='icon-link' target='_blank'>"
                if ($page -and $page.Icon."$($taskbarItem.Key)") {                     
                    $page.Icon[$taskbarItem.Key]
                    if ($site.ShowTaskbarIconText -or $page.ShowTaskbarIconText) {
                        $taskbarItem.Key
                    }                    
                }
                elseif ($site -and $site.Icon."$($taskbarItem.Key)") { 
                    $site.Icon[$taskbarItem.Key]
                    if ($site.ShowTaskbarIconText -or $page.ShowTaskbarIconText) {
                        $taskbarItem.Key
                    }                
                }
                else { $taskbarItem.Key }
                "</a>"
            }
            "</nav>"
        }
        "</section>"
    "</header>"

    # * The main content
    "<div class='main'>$outputHtml</div>"

    if ($taskbar) {
        # * Our taskbar
        <#"<div class='taskbar'>"
            foreach ($taskbarItem in $taskbar.GetEnumerator()) {
                "<a href='$($taskbarItem.Value)' class='icon-link' target='_blank'>"
                if ($page -and $page.Icon."$($taskbarItem.Key)") {                     
                    $page.Icon[$taskbarItem.Key]
                    if ($site.ShowTaskbarIconText -or $page.ShowTaskbarIconText) {
                        $taskbarItem.Key
                    }                    
                }
                elseif ($site -and $site.Icon."$($taskbarItem.Key)") { 
                    $site.Icon[$taskbarItem.Key]
                    if ($site.ShowTaskbarIconText -or $page.ShowTaskbarIconText) {
                        $taskbarItem.Key
                    }                
                }
                else { $taskbarItem.Key }
                "</a>"
            }
        "</div>"#>
    }

    # * The footer
    "<footer>"
    if ($FooterMenu) {        
        "<nav class='footer-menu'>"            
        foreach ($menuItem in $FooterMenu.GetEnumerator()) {
            "<a href='$($menuItem.Value)' class='footer-menu-item'>$([Web.HttpUtility]::HtmlEncode($menuItem.Key))</a>"
        }
        "</nav>"
    }
    if ($Page.Footer) { $page.Footer -join [Environment]::NewLine }
    if ($Site.Footer) { $site.Footer -join [Environment]::NewLine } 
    "</footer>"
    if ($site.HighlightJS -or $page.HighlightJS) { "<script>hljs.highlightAll();</script>" }
)

"<html>
    <head>
        <title>$(if ($page['Title']) { $page['Title'] } else { $Title })</title>
        $($headerElements -join [Environment]::NewLine)
    </head>
    <body>$($bodyElements -join [Environment]::NewLine)</body>
</html>"