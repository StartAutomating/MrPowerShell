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
    $PaletteName = $(
        if ($Site -and $Site['PaletteName']) { $Site['PaletteName'] }
        else { 'Konsolas' }    
    ),

    # The Google Font name
    [Alias('FontName')]
    [string]
    $Font = $(
        if ($Site -and $Site['FontName']) { $Site['FontName'] }
        else { 'Roboto' }
    ),

    # The Google Code Font name
    [string]
    $CodeFont = $(
        if ($Site -and $Site['CodeFontName']) { $Site['CodeFontName'] }
        else { 'Inconsolata' }
    ),
    
    # The urls for any fav icons.
    [string[]]
    $FavIcon,
    
    # The taskbar icons.
    # The key should be the icon name or content, and the value should be the URL.
    # SVG icons should be included inline so they may be stylized.
    [Collections.IDictionary]
    $Taskbar = $(
        if ($page -and $page['Taskbar']) { $page.Taskbar }
        elseif ($Site -and $site['Taskbar']) { $site['Taskbar'] }
        else { [Ordered]@{} }
    ),

    # The header menu.
    [Collections.IDictionary]
    $HeaderMenu = $(
        if ($page -and $page.'HeaderMenu' -is [Collections.IDictionary]) {
            $page.'HeaderMenu'
        } elseif ($Site -and $site.'HeaderMenu' -is [Collections.IDictionary]) {
            $site.'HeaderMenu'
        } else {
            [Ordered]@{}
        }
    ),

    # The footer menu.
    [Collections.IDictionary]
    $FooterMenu = $(
        if ($page -and $page.'FooterMenu' -is [Collections.IDictionary]) {
            $page.'FooterMenu'
        } elseif ($Site -and $site.'FooterMenu' -is [Collections.IDictionary]) {
            $site.'FooterMenu'
        } else {
            [Ordered]@{}
        }
    )
)

# The literal first thing we do is to capture the arguments and input.
# This is important beecause `$input` can only be read once.
$allInput = @($input)
$allArguments = @($args)
$argsAndinput = @($args) + @($allInput)

#region Initialize Site and Page
if (-not $Site) { $Site = [Ordered]@{} }
if (-not $page) { $page = [Ordered]@{} }
if (-not $page.MetaData) { $page.MetaData = [Ordered]@{} }
#endregion Initialize Site and Page

#region Initialize Metadata
$page.MetaData['og:title'] =
    if ($title) { $title }
    elseif ($Page.title) { $Page.title } 
    elseif ($site.title) { $site.title }

$page.MetaData['og:description'] =
    if ($description) { $description }
    elseif ($page.description) { $page.description }
    elseif ($site.description) { $site.description }

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
    margin: 3em;
}
header, footer {
    text-align: center;
    margin: 2em;
}

@media (orientation: landscape) {
    .logo { height: 7em; }
}

@media (orientation: portrait) {
    .logo { height: 5em; }
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
        "font-size: 1.25em;"
    })
}

.taskbar {
    position: fixed;
    top: 0; right: 0; z-index: 10;
    display: flex; flex-direction: row; 
    align-content: center; align-items: center;
    margin: 1em; gap: 0.5em;
}

.taskbar * {
    vertical-align: middle;    
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
    # * The header
    "<header>"
        if ($page.Header) {
            $page.Header -join [Environment]::NewLine
        } elseif ($site.Header) {
            $site.Header -join [Environment]::NewLine
        } else {
            "<a href='/'>"
            @(
                "<svg xmlns='http://www.w3.org/2000/svg' class='logo'>" + $(
                    if ($site.Logo) {
                        if ($site.Logo -match '<svg') { $site.Logo -replace '<\?.+>' }
                        else { "<image src='$($site.Logo)' class='logoImage' />" }
                    }
                ) + "</svg>"
                if ($site.Title) {
                    "<h1>$([Web.HttpUtility]::HtmlEncode($site.Title))</h1>"
                }
                elseif ($site.CNAME) {                    
                    "<h1>$([Web.HttpUtility]::HtmlEncode($site.CNAME))</h1>"
                }
            ) -join (
                [Environment]::NewLine + "<br/>" + [Environment]::NewLine
            )
            "</a>"
            if ($page.Title -and $page.Title -ne $site.Title) {
                "<h2>$([Web.HttpUtility]::HtmlEncode($page.Title))</h2>"
            }            
        }
        
        if ($headerMenu) {
            "<style>"            
                # If the device is in landscape mode, use larger padding and gaps
                "@media (orientation: landscape) {"
                    ".header-menu { display: grid; grid-template-columns: repeat(auto-fit, minmax(100px, 1fr)); gap: 1em }"
                    ".header-menu-item { text-align: center; padding: 1em; }"
                "}"

                # If the device is in portrait mode, use smaller padding and gaps
                "@media (orientation: portrait) {"
                    ".header-menu { display: grid; grid-template-columns: repeat(auto-fit, minmax(100px, 1fr)); gap: 0.5em }"
                    ".header-menu-item { text-align: center; padding: 0.5em; }"
                "}"
            "</style>"
            "<nav class='header-menu'>"
            foreach ($menuItem in $headerMenu.GetEnumerator()) {
                "<a href='$($menuItem.Value)' class='header-menu-item'>$([Web.HttpUtility]::HtmlEncode($menuItem.Key))</a>"
            }
            "</nav>"
        }
    "</header>"

    # * The main content
    "<div class='main'>$outputHtml</div>"

    if ($taskbar) {
        # * Our taskbar
        "<div class='taskbar'>"
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
        "</div>"
    }

    # * The footer
    "<footer>"
    if ($FooterMenu) {
        "<style>"
        "@media (orientation: landscape) {"
            ".footer-menu { display: grid; grid-template-columns: repeat(auto-fit, minmax(100px, 1fr)); gap: 1em }"
            ".footer-menu-item { text-align: center; padding: 1em; }"
        "}"
        "@media (orientation: portrait) {"
            ".footer-menu { display: grid; grid-template-columns: repeat(auto-fit, minmax(100px, 1fr)); gap: 0.5em }"
            ".footer-menu-item { text-align: center; padding: 0.5em; }"
        "}"
        "</style>"
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