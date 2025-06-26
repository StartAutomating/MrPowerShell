<#
.SYNOPSIS
    The At Jetstream
.DESCRIPTION
    The At Protocol is a protocol for building decentralized social applications.
    
    One of the ways it does this effeciently is by broadcasting changes over a WebSocket.

    This is called the Jetstream, and it allows you to subscribe to changes in real-time.

    This is a pretty barebones implementation of a static page that will be dynamically updated as new posts are made.    
.LINK
    https://MrPowerShell.com/At/Jetstream
#>
param()

# Get the help for this script
$myHelp         = Get-Help $MyInvocation.MyCommand.ScriptBlock.File
$Title          = $myHelp.Synopsis
$description    = $myHelp.Description.text -join [Environment]::NewLine


"<h1>$Title</h1>"

(ConvertFrom-Markdown -InputObject $description).Html

"<details>"
"<summary>View Source</summary>"
"<pre><code class='language-powershell'>"
[Web.HttpUtility]::HtmlEncode($MyInvocation.MyCommand.ScriptBlock)
"</code></pre>"
"</details>"

function at.jetstream.js {
    param(
    $OnMessage      = "console.log(event.data)",
    $OnOpen         = "console.log('WebSocket connection established')",
    $collections    = @('app.bsky.feed.post'),
    $cursor         = $null,
    $dids           = @(),
    $socketName     = 'atJetstream',
    $filter,
    $target,
    $template
    )

    if ($filter) {
        $onMessage = @(
            "let filterValue = $filter"
            "if (! filterValue) { return }"
        ) + @($OnMessage)
    }

    if ($target -and $template) { 
        $OnMessage = @($OnMessage) + @(
"let target = document.getElementById('$target')"
"if (target) {"
"let templateOutput = ``$($template -replace '^`+' -replace '`+$')``"
"target.innerHTML += templateOutput"
"}"
)
    }

    return @"
        // Create WebSocket connection.
        let socketUri = "wss://jetstream2.us-west.bsky.network/subscribe"
        if (Math.random() > 0.5) { socketUri = "wss://jetstream2.us-east.bsky.network/subscribe" }
        if (Math.random() > 0.5) { socketUri = socketUri.replace("2","1") }
        let $socketName = new WebSocket(```${socketUri}?$(
            @(
                foreach ($collection in $collections | Select-Object -Unique) { "wantedCollections=$collection" }
                foreach ($did in $dids) { "wantedDids=$did" }
                if ($cursor) { "cursor=$cursor" }
            ) -join '&'
        )``)
        // Log the connection opening
        $socketName.addEventListener("open", (event) => {
            $($OnOpen -join ([Environment]::NewLine))
        });
        // Listen for messages
        $socketName.addEventListener("message", (event) => {
        let atEvent = JSON.parse(event.data);
        $(
            $OnMessage -join ([Environment]::NewLine)
        )
        });
"@
}

"<style>"
"</style>"
"<div id='jetstreamOutput'>"
"</div>"
"<template id='jetstreamTemplate'>"
"<div></div>"
"</template>"
"<script type='module'>"
at.jetstream.js -target 'jetstreamOutput' -template '
<blockquote class="bluesky-embed" data-bluesky-uri="at://${atEvent?.did}/${atEvent?.commit?.record?.$type}/${atEvent?.commit?.record?.rkey}" data-bluesky-cid="${atEvent?.cid}">
${atEvent?.commit?.record?.text}
</blockquote>
'
"</script>"