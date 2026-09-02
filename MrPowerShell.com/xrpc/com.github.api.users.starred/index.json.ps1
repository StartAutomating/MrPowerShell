<#
.SYNOPSIS
    User Stars
.DESCRIPTION
    Gets the starred repositories for a user
#>
param(
# The GitHub user name.
# This should default to the repository owner.
[string]$UserName = $(
    if ($env:GITHUB_REPOSITORY_OWNER) {
        $env:GITHUB_REPOSITORY_OWNER
    } else {
        'StartAutomating'
    }
)
)

if (-not $script:Cache) {
    $script:Cache = [Ordered]@{}
}


$pageNumber = 1
$starredUrl = "https://api.github.com/users/$UserName/starred?per_page=100&page=$pageNumber"

$starsUrls = @($starredUrl)

if (-not $script:Cache[$starredUrl]) {
    $script:Cache[$starredUrl] = @(Invoke-RestMethod -Uri $starredUrl)
        
    while ($script:Cache[$starredUrl].Count -eq 100) {
        $pageNumber++
        $starredUrl = "https://api.github.com/users/$UserName/starred?per_page=100&page=$pageNumber"
        $script:Cache[$starredUrl] = @(Invoke-RestMethod -Uri $starredUrl)
        $starsUrls += $starredUrl
    }    
}

foreach ($starredUrl in $starsUrls) {
    $script:Cache[$starredUrl] |
        Add-Member NoteProperty '$type' 'com.github.api.users.starred' -Force -PassThru
}


