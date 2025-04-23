#requires -Module PSDevOps
if (-not $script:CachedRepoList) {
    $script:CachedRepoList = [Ordered]@{}    
    $connectedToGitHub = Connect-GitHub
    $startAutomatingRepos = api.github.com/users/<username>/repos -username StartAutomating
    $psWebRepos = api.github.com/users/<username>/repos -username PowerShellWeb
    $script:CachedRepoList['StartAutomating'] = $startAutomatingRepos
    $script:CachedRepoList['PowerShellWeb'] = $psWebRepos
}

$myRepos = @($script:CachedRepoList.Values) | . { process { $_ } }
$myReposByPopularity = $myRepos | Sort-Object stargazers_count -Descending 
$markdown = @(
"# Most of My Repos"

"(I write a lot of code)"

"## By Popularity:"
foreach ($repoInfo in $myReposByPopularity) {
"  * [$($repoInfo.owner.login)/$($repoInfo.Name)]($($repoInfo.html_url))"
}

"## By Recency:"
foreach ($repoInfo in $myRepos | Sort-Object updated_at -Descending) {
"  * [$($repoInfo.owner.login)/$($repoInfo.Name)]($($repoInfo.html_url))"
}
) -join [Environment]::NewLine

(ConvertFrom-Markdown -InputObject $markdown).Html
