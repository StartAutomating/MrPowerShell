function git.sparse
{
    param(
        [string]
        $Repository="https://github.com/bluesky-social/atproto/",
        [string]
        $Path="atproto",
        [string[]]
        $Pattern=@('lexicons/**/**.json')
    )

    process {
        if (Test-Path $path) { return }
        git clone --depth 1 --no-checkout --sparse --filter=tree:0 $Repository $Path
        Push-Location "./$Path"
        git sparse-checkout set --no-cone @Pattern
        git checkout
        Pop-Location
    }
}


<#

git clone --depth 1 --no-checkout --sparse --filter=tree:0 https://github.com/bluesky-social/atproto/
Push-Location ./atproto
git sparse-checkout set --no-cone lexicons/**/**.json
git checkout
Pop-Location

#>


