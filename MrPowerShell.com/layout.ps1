<#
.SYNOPSIS
    Layout script
.DESCRIPTION
    This script is used to layout a page with a consistent style and structure.

    If a file generates HTML but does not include an `<html>` tag, it's output should be piped to this script.

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
    $Font        = $(
        if ($Site -and $Site['FontName']) { $Site['FontName'] }
        else { 'Roboto' }
    ),

    # The Google Code Font name
    [string]
    $CodeFont   = $(
        if ($Site -and $Site['CodeFontName']) { $Site['CodeFontName'] }
        else { 'Inconsolata' }
    ),
    
    # The urls for any fav icons.
    [string[]]
    $FavIcon,

    # Any CSS keyframes to include.
    # The keyframes should be a dictionary of dictionaries.
    [Collections.IDictionary]
    [Alias('Keyframes')]
    $Keyframe = $(
        if ($Site -and $Site['Keyframe']) { $Site['Keyframe'] }
        elseif ($Site.Glow -or $page.Glow) { 
            [Ordered]@{
                'glow-link' = [Ordered]@{
                    '0%,100%' = [Ordered]@{
                        'text-shadow' = "0 0 0em"
                    }
                    '50%' = [Ordered]@{
                        'text-shadow' = "0 0 1em"
                    }
                }
            }
        }
    ),

    # The top right corner links.
    [Collections.IDictionary]
    $TopRight = $(
        if ($Site -and $site['TopRight']) {
            $site['TopRight']
        } else {
            [Ordered]@{}
        }        
    ),
    
    # The bottom right corner links.
    [Collections.IDictionary]
    $BottomRight = $(
        if ($Site -and $site['BottomRight']) {
            $site['BottomRight']
        } else {
            [Ordered]@{}
        }
    ),

    # The bottom left corner links.
    [Collections.IDictionary]
    $BottomLeft = $(
        if ($Site -and $site['BottomLeft']) {
            $site['BottomLeft']
        } else {
            [Ordered]@{}
        }
    ),

    # The top left corner links.
    [Collections.IDictionary]
    $TopLeft = $(
        if ($Site -and $site['TopLeft']) {
            $site['TopLeft']
        } else {
            [Ordered]@{}
        }
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
    $FoooterMenu = $(
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
    if ($title) {
        $title
    } elseif ($Page.title) {
        $Page.title
    } elseif ($site.title) {
        $site.title
    }

$page.MetaData['og:description'] =
    if ($description) {
        $description
    } elseif ($page.description) {
        $page.description
    } elseif ($site.description) {
        $site.description
    }

$page.MetaData['og:image'] =
    if ($image) {
        $image
    } elseif ($page.image) {
        $page.image
    } elseif ($site.image) {
        $site.image
    }

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
        {$outputItem -is 'Microsoft.PowerShell.MarkdownRender.MarkdownInfo'} {
            # Someone converted from markdown, but didn't finish.
            # If the object has HTML, use it.
            if ($OutputItem.HTML) {
                return $outputItem.HTML
            } else {
                # otherwise, extract the original markdown tokens and convert them to HTML.
                return (ConvertFrom-Markdown -InputObject "$(
                    $outputItem.Tokens.Inline.Content.Text | Select-Object -Unique
                )").HTML
            }
        }
        
        {$outputItem.HTML} {
            return $outputItem.HTML
        }
        {$outputItem.Markdown} {
            return (ConvertFrom-Markdown -InputObject $outputItem.Markdown).HTML
        }
        
        default {
            "$outputItem"
        }
    }
}

$outputHtml = @($argsAndinput | outputHtml) -join [Environment]::NewLine

#region Corners.css
$corners = @(
    foreach ($vertical in @('top','bottom')) {
        foreach ($horizontal in @('left','right')) {
            @(".$vertical-$horizontal {"
                @(
                    'position: fixed'
                    'z-index: 10'
                    'display: flex'
                    'flex-direction: row'
                    'align-content: center'
                    'margin: 2em'
                    'gap: 0.5em'
                    if ($horizontal -eq 'left') {
                        'float: left'
                        'text-align: left'
                        'left: 0'
                    }
                    elseif ($horizontal -eq 'right') {
                        'float: right'
                        'text-align: right'
                        'right: 0'
                    }
                    if ($vertical -eq 'top') {
                        'top: 0'
                    } elseif ($vertical -eq 'bottom') {
                        'bottom: 0'
                    }
                ) -join ';'
            "}") -join ' ' 
        }
    }    
) -join [Environment]::NewLine
#endregion Corners.css

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
    .logo {
        height: 7em;
    }
}

@media (orientation: portrait) {
    .logo {    
        height: 5em;
    }
}

pre, code {
    font-family: '$CodeFont', monospace;
}

a, a:visited {    
    text-decoration: none;
    $(if ($site.Glow) {
        $glowDuration = if ($site.GlowDuration) {
            $site.GlowDuration
        } else {
            '4.2s'
        }
        "animation-name: glow-link; animation-duration: $glowDuration; animation-iteration-count: infinite;"
    })
}

a:hover, a:focus {
    text-decoration: underline;
    $(if ($site.Glow) {
        $glowHoverDuration = 
            if ($site.GlowHoverDuration) {
                $site.GlowHoverDuration
            } elseif ($site.GlowDuration) {
                $site.GlowDuration
            } else {
                '2.4s'
            }
        "animation-name: glow-link; animation-duration: $glowHoverDuration; animation-iteration-count: infinite;"
    })
}

.main {
    $(
        if ($page.FontSize) {
            "font-size: $($page.FontSize);"
        } elseif ($site.FontSize) {
            "font-size: $($site.FontSize);"
        } else {
            "font-size: 1.25em;"
        }
    )
}

$corners

$(@(foreach ($keyframeName in $keyframe.Keys) {
    $keyframeKeyframes = $keyframe[$keyframeName]
    "@keyframes $keyframeName {"
    foreach ($percent in $keyframeKeyframes.Keys) {
        "  $percent {"
        $props = $keyframeKeyframes[$percent]
        foreach ($prop in $props.Keys) {
            $value = $props.$prop
            "    ${prop}: $value;"
        }
        "  }"
    }
    "}"
    ".$keyframeName { animation-name: $keyframeName; }"
}) -join [Environment]::NewLine)
"@
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
                        if ($site.Logo -match '<svg') {
                            $site.Logo -replace '<\?.+>'
                        } else {
                            "<image src='$($site.Logo)' class='logo' />"
                        }
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
    if ($TopLeft) {
        # * Our top left corner
        "<div class='top-left'>"
            if ($TopLeft) {
                foreach ($TopLeftUrl in $TopLeft.Keys) {
                    "<a href='$TopLeftUrl' class='icon-link' target='_blank'>$($TopLeft[$TopLeftUrl])</a>"
                }
            }
        "</div>"
    }
    
    if ($TopRight) {
        # * Our upper right corner
        "<div class='top-right'>"
        foreach ($TopRightUrl in $TopRight.Keys) {
            "<a href='$TopRightUrl' class='icon-link' target='_blank'>$($TopRight[$TopRightUrl])</a>"
        }
        "</div>"
    }

    if ($BottomRight) {
        # * Our bottom right corner
        "<div class='bottom-right'>"
            foreach ($BottomRightUrl in $BottomRight.Keys) {
                "<a href='$BottomRightUrl' class='icon-link' target='_blank'>$($BottomRight[$BottomRightUrl])</a>"
            }
        "</div>"
    }

    if ($BottomLeft) {
        # * Our bottom left corner
        "<div class='bottom-left'>"
            foreach ($BottomLeftUrl in $BottomLeft.Keys) {
                "<a href='$BottomLeftUrl' class='icon-link' target='_blank'>$($BottomLeft[$BottomLeftUrl])</a>"
            }
        "</div>"
    }

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
    if ($Page.Footer) {
        $page.Footer -join [Environment]::NewLine
    }
    if ($Site.Footer) {
        $site.Footer -join [Environment]::NewLine
    } 
    "</footer>"

    if ($site.HighlightJS -or $page.HighlightJS) { "<script>hljs.highlightAll();</script>" }
)

@"
<html>
    <head>
        <title>$(if ($page['Title']) { $page['Title'] } else { $Title })</title>
        $($headerElements -join [Environment]::NewLine)
    </head>
    <body>                    
        $($bodyElements -join [Environment]::NewLine)
    </body>
</html>
"@
