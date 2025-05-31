param(
    [Collections.IDictionary]    
    $LexiconRepository = [Ordered]@{
        'At Protocol' = 'https://github.com/bluesky-social/atproto/'
        'Community Lexicons' = 'https://github.com/lexicon-community/lexicon'
        'FujoWebDev.LexiconGuestbook' = 'https://github.com/FujoWebDev/lexicon-guestbook/'
    },

    [Collections.IDictionary]
    $LexiconPatterns = [Ordered]@{
        'At Protocol' = '/lexicons/**/**.json'
        'Community Lexicons' = '/community/lexicon/**/**.json'
        'FujoWebDev.LexiconGuestbook' = '/lexicons/com/fujocoded/'
    },

    [Collections.IDictionary]
    $LexiconPath
)

# We'll be populating a subdirectory with a sparse checkout of a repository.
if (-not $psScriptRoot) { return }

Push-Location $PSScriptRoot

$greatGreatGrandParent = $PSScriptRoot | Split-Path | Split-Path | Split-Path

if (-not $lexiconPath) {
    $lexiconPath = [Ordered]@{}
}

foreach ($key in $LexiconRepository.Keys) {
    if (-not $lexiconPath[$key]) {
        $lexiconPath[$key] = Join-Path $greatGreatGrandParent ($key -replace '[\s\p{P}]+', '.')
    }        
}

$title = 'At Protocol Lexicons'
$Description = 'List of all At Protocol Lexicons defined in the lexicon-community and atproto repositories.'

$lexiconFiles = @(
    # Sparse clone each lexicon
    foreach ($key in $LexiconRepository.Keys) {
        git.sparse -Repository $LexiconRepository[$key] -Path $lexiconPath[$key] -Pattern $LexiconPatterns[$key] |
            Add-Member NoteProperty -Name 'Repository' -Value $LexiconRepository[$key] -Force -PassThru |
            Add-Member NoteProperty -Name 'Pattern' -Value $LexiconPatterns[$key] -Force -PassThru
    }
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
$(
    foreach ($value in $LexiconRepository.Values) {
        "<li><a href='$value'>$value</a></li>"
    }
)
"</ul>"

"<hr/>"
$treeDepth = 0
$currentTreeBranch = ''
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

"<hr/>"
"<details>"
"<summary>View Source</summary>"
"<pre><code class='language-PowerShell'>$([Web.HttpUtility]::HtmlEncode($MyInvocation.MyCommand.ScriptBlock))</code></pre>"
"</details>"

ConvertTo-Json -Depth 10 $AllLexicons > .\All.json
($lexiconsById | ConvertTo-Json -Depth 10) > .\ById.json

Pop-Location