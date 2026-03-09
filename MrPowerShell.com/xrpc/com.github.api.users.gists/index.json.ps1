<#
.SYNOPSIS
    Gets GitHub Gists
.DESCRIPTION
    Gets gists from GitHub, and makes them available at an xrpc endpoint
.LINK
    https://MrPowerShell.com/xrpc/com.github.api.users.gists
#>
param(
    [string]$GitHubUser = 'StartAutomating',
    [uri]$GistFallbackUrl = "https://MrPowerShell.com/Gists/MyGists.json"
)

if (-not $script:Cache) {
    $script:Cache = [Ordered]@{}
}

$gistsUrl = "https://api.github.com/users/$GitHubUser/gists?per_page=100"
if (-not $script:Cache[$gistsUrl]) {
    $script:Cache[$gistsUrl] = 
        try { Invoke-RestMethod -Uri $gistsUrl -ErrorAction Ignore }
        catch { $null }
        
}

$script:myGists = $script:Cache[$gistsUrl]

# If we could not get gists, try getting previous gists
if (-not $script:myGists) {
    $script:myGists = Invoke-RestMethod $GistFallbackUrl
}

$script:MyGists |
    Add-Member NoteProperty '$type' 'com.github.api.gist' -Force -PassThru