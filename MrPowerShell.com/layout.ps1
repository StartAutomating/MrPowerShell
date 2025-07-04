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
        else { @{} }
    ),

    [Collections.IDictionary]
    $TopRight = $(
        if ($Site -and $site['TopRight']) {
            $site['TopRight']
        } else {
            [Ordered]@{}
        }        
    ),
    
    [Collections.IDictionary]
    $BottomRight = $(
        if ($Site -and $site['BottomRight']) {
            $site['BottomRight']
        } else {
            [Ordered]@{}
        }
    ),

    [Collections.IDictionary]
    $BottomLeft = $(
        if ($Site -and $site['BottomLeft']) {
            $site['BottomLeft']
        } else {
            [Ordered]@{}
        }
    ),

    [Collections.IDictionary]
    $TopLeft = $(
        if ($Site -and $site['TopLeft']) {
            $site['TopLeft']
        } else {
            [Ordered]@{}
        }
    )
)

$argsAndinput = @($args) + @($input)

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
    width: 100vw;
    height: 100vh;
    font-family: '$Font', sans-serif;
    margin: 3em;
}
pre, code {
    font-family: '$CodeFont', monospace;
}
a, a:visited {    
    text-decoration: none;
}
a:hover, a:focus {
    text-decoration: underline;
}
.main {
    
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
        "
        <!-- Google tag (gtag.js) -->
        <script async src='https://www.googletagmanager.com/gtag/js?id=$($site.AnalyticsID)'></script>
        <script>
            window.dataLayer = window.dataLayer || [];
            function gtag(){dataLayer.push(arguments);}
            gtag('js', new Date());
            gtag('config', '$($site.AnalyticsID)');
        </script>
        "
    }
    # * Viewport metadata
    "<meta name='viewport' content='width=device-width, initial-scale=1, minimum-scale=1.0' />"

    # * Open Graph metadata
    if (
        $Page.MetaData -is [Collections.IDictionary] -and 
        $Page.MetaData.Count
    ) {
        foreach ($og in $Page.MetaData.GetEnumerator()) {
            "<meta name='$([Web.HttpUtility]::HtmlAttributeEncode($og.Key))' content='$([Web.HttpUtility]::HtmlAttributeEncode($og.Value))' />"
        }
    }

    # * RSS autodiscovery
    if (-not $site.NoRss) {
        "<link rel='alternate' type='application/rss+xml' title='$($site.Title)' href='/RSS/index.rss' />"
    }
    
    # * Color palette
    if ($PaletteName) {
        "<link rel='stylesheet' href='https://cdn.jsdelivr.net/gh/2bitdesigns/4bitcss@latest/css/$PaletteName.css' id='palette' />"
    }

    # * Google Font
    if ($Font) {
        "<link rel='stylesheet' href='https://fonts.googleapis.com/css?family=$Font' id='font' />"
    }

    # * Code font
    if ($CodeFont) {
        "<link rel='stylesheet' href='https://fonts.googleapis.com/css?family=$CodeFont' id='codeFont' />"
    }

    # * highlightjs css ( if using highlight )
    if ($Site.HighlightJS -or $page.HighlightJS) {
        "<link rel='stylesheet' href='https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@latest/build/styles/default.min.css' id='highlight' />"     
        '<script async src="https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@latest/build/highlight.min.js"></script>'
        foreach ($language in $Site.HighlightJS.Languages) {
            "<script async src='https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@latest/build/languages/$language.min.js'></script>"
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
    if ($Site.IsHtmx -or $Site.Htmx -or $site.UseHtmx) {
        "<script src='https://unpkg.com/htmx.org@latest'></script>"
    }
    $ImportMap
    # * Our styles
    "<style>"
    $style
    "</style>"    
)

# Now we declare the body elements
$bodyElements = @(
    # * The main content 
    "<div class='main'>$($argsAndinput -join [Environment]::NewLine)</div>"

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

    "<div class='bottom-right'>"
    "<nav id='breadcrumbBar' class='breadcrumBar'>
        <details>
        <summary>/</summary>
        <span id='breadcrumbs'><a href='/' class='breadcrumb'><button>/</button></a></span>
        </details>
    </nav>"
        @'
<script>
    var urlSegments = window.location.pathname.split('/')
    var breadcrumbs = document.getElementById('breadcrumbs');
    for (var i = 1; i < (urlSegments.length - 1); i++) {
        breadcrumbs.innerHTML += 
            `<a href='${urlSegments.slice(0, i + 1).join('/')}' id='breadcrumb-${i}' class='breadcrumb'><button>${urlSegments[i]}</button></a>`
    }
</script>
'@
     "</div>"   

    # Then we add the breadcrumb bar
    $breadcrumbBar = @(
'<style>'
@'
.breadcrumb { margin: 0 0.3em 0 0; }
.breadcrumb > button {padding: 0.25em; }
'@
"</style>"
"
<nav id='breadcrumbBar' class='breadcrumBar'>
    <details>
    <summary>/</summary>
    <span id='breadcrumbs'><a href='/' class='breadcrumb'><button>/</button></a></span>
    </details>
</nav>
"
)
    
    if ($site.HighlightJS -or $page.HighlightJS) {
        "<script>hljs.highlightAll();</script>"
    }
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
