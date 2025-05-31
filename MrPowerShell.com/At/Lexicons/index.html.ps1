

# We'll be populating a subdirectory with a sparse checkout of a repository.
if (-not $psScriptRoot) { return }
Push-Location $PSScriptRoot
$greatGreatGrandParent = $PSScriptRoot | Split-Path | Split-Path | Split-Path
$atProtoPath = Join-Path $greatGreatGrandParent atproto
$lexiconCommunityPath = Join-Path $greatGreatGrandParent lexicons.community

$lexiconFiles = @(
    # Sparse clone community lexicons
    git.sparse -Repository https://github.com/lexicon-community/lexicon -Path $lexiconCommunityPath -Pattern '/community/lexicon/**/**.json'

    # Sparse clone at proto lexicons
    git.sparse -Repository https://github.com/bluesky-social/atproto/ -Path $atProtoPath -Pattern '/lexicons/**/**.json'    
)

$AllLexicons = @()
$lexiconsById = [Ordered]@{}

$lexiconFiles |
    ForEach-Object {
        $json = Get-Content -Path $_.FullName -Raw 
        $jsonObject = ConvertFrom-Json -InputObject $json
        if (-not $jsonObject.id) { return }
        
        $json > "$($jsonObject.id).json"
        $AllLexicons += $jsonObject
        $lexiconsById[$jsonObject.id] = $jsonObject
    }

"<h1>At Protocol Lexicons</h1>"

"<h2>At Protocol uses Lexicons to describe objects and operations</h2>"

"<p>This site contains all at protocol lexicons defined in the following repositories</p>"

"<ul>"
"<li><a href='https://github.com/bluesky-social/atproto/'>bluesky-social/atproto</a></li>"
"<li><a href='https://github.com/lexicon-community/lexicon'>lexicon-community/lexicon</a></li>"
"</ul>"

"<hr/>"

"<details>"
"<summary>View Source</summary>"
"<pre><code class='language-PowerShell'>$([Web.HttpUtility]::HtmlEncode($MyInvocation.MyCommand.ScriptBlock))</code></pre>"
"</details>"

"<hr/>"
$AllLexicons | 
    ForEach-Object -Begin {
        "<ul class='atLexicons'>"
    } -Process {
        "<li>"
        "<a href='$($_.id).json'>$($_.id)</a>"
        "</li>"
    } -End {
        "</ul>"
    }

($lexiconsById | ConvertTo-Json -Depth 10) > .\ById.json

Pop-Location