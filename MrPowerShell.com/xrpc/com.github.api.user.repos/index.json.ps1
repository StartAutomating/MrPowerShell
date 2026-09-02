<#
.SYNOPSIS
    User Repos
.DESCRIPTION
    Gets the repos for a user
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


$page = 1
$reposUrl = "https://api.github.com/users/$UserName/repos?per_page=100&page=$page"

$repoPages = @($reposUrl)

if (-not $script:Cache[$reposUrl]) {
    $script:Cache[$reposUrl] = @(Invoke-RestMethod -Uri $reposUrl)
        
    while ($script:Cache[$reposUrl].Count -eq 100) {
        $page++
        $reposUrl = "https://api.github.com/users/$UserName/repos?per_page=100&page=$page"
        $script:Cache[$reposUrl] = @(Invoke-RestMethod -Uri $reposUrl)
        $repoPages += $reposUrl        
    }    
}

foreach ($repoUrl in $repoPages) {
    $script:Cache[$repoUrl] |
        Add-Member NoteProperty '$type' 'com.github.api.user.repo' -Force -PassThru
}


