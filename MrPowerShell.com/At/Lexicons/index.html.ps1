

# We'll be populating a subdirectory with a sparse checkout of a repository.
if (-not $psScriptRoot) { return }

$greatGreatGrandParent = $PSScriptRoot | Split-Path | Split-Path | Split-Path

$atProtoPath = Join-Path $greatGreatGrandParent atproto
$lexiconCommunityPath = Join-Path $greatGreatGrandParent lexicons.community

# If we don't have the content, get it.
if (-not (Test-Path $lexiconCommunityPath)) {
    $gitOutput = @(
        # use ugit to clone -Nothing
        # git clone https://github.com/bluesky-social/atproto/ -Nothing
        git clone --depth 1 --no-checkout --sparse --filter=tree:0 https://github.com/lexicon-community/lexicon $lexiconCommunityPath
        Push-Location $lexiconCommunityPath
        # and then use a sparse-checkout to get only the CSS-related content.
        git sparse-checkout set --no-cone /community/lexicon/**/**.json
        # checkout the content, and we're set.
        git checkout
        
        Pop-Location
    )
}

# If we don't have the content, get it.
if (-not (Test-Path $atProtoPath)) {
    $gitOutput = @(
        # use ugit to clone -Nothing
        # git clone https://github.com/bluesky-social/atproto/ -Nothing
        git clone --depth 1 --no-checkout --sparse --filter=tree:0 https://github.com/bluesky-social/atproto/ $atProtoPath
        Push-Location $atProtoPath
        # and then use a sparse-checkout to get only the CSS-related content.        
        git sparse-checkout set --no-cone /lexicons/**/**.json
        # checkout the content, and we're set.
        git checkout
        
        Pop-Location
    )
}

$AllLexicons = @()

Get-ChildItem -Path $atProtoPath, $lexiconCommunityPath -Recurse -Filter *.json |
    ForEach-Object {
        $json = Get-Content -Path $_.FullName -Raw 
        $jsonObject = ConvertFrom-Json -InputObject $json
        if (-not $jsonObject.id) { return }
        
        $json > "$($jsonObject.id).json"
        $AllLexicons += $jsonObject
    }


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


Pop-Location