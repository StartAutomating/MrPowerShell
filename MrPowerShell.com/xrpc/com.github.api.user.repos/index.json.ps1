<#
.SYNOPSIS
    User Repos
.DESCRIPTION
    Gets the repos for a user
#>
param(
# The GitHub organization.
# This should default to the repository owner.
[string]$Organization = $(
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


$page = 1
$reposUrl = "https://api.github.com/$UserName/repos?per_page=100&page=$page"

if (-not $script:Cache[$reposUrl]) {
    $script:Cache[$reposUrl] = @(Invoke-RestMethod -Uri $reposUrl)
        
    while ($script:Cache[$reposUrl].Count -eq 100) {
        $page++
        $reposUrl = "https://api.github.com/$UserName/repos?per_page=100&page=$page"
        $script:Cache[$reposUrl] = @(Invoke-RestMethod -Uri $reposUrl)
    }    
}

$script:Cache[$reposUrl] |
    Add-Member NoteProperty '$type' 'com.github.api.user.repo' -Force -PassThru
