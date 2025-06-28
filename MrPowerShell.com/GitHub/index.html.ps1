#requires -Module PSDevOps
param(
    [string]
    $did = 'did:plc:hlchta7bwmobyum375ltycg5',

    [string]
    $GitHubUserName = 'StartAutomating',

    [Alias('GitHubOrgs','GitHubOrg')]
    [string[]]
    $GitHubOrganizations = @('StartAutomating', 'PowerShellWeb')
)

$Title = "My GitHub Repos"

if (-not $script:CachedRepoList) {
    $script:CachedRepoList = [Ordered]@{}    
    $connectedToGitHub = Connect-GitHub
    $myGitHubInfo = api.github.com/users/<username> -username $GitHubUserName
    $startAutomatingRepos = api.github.com/users/<username>/repos -username StartAutomating
    $psWebRepos = api.github.com/users/<username>/repos -username PowerShellWeb
    $script:CachedRepoList['StartAutomating'] = $startAutomatingRepos
    $script:CachedRepoList['PowerShellWeb'] = $psWebRepos
}

$myRepos = @($script:CachedRepoList.Values) | . { process { $_ } }
$myRepos | ConvertTo-Json -Depth 10 | Set-Content -Path $PSScriptRoot/Repos.json
$myReposByPopularity = $myRepos | Where-Object -Not Fork | Sort-Object stargazers_count -Descending 
$totalStars = ($myRepos | Measure-Object -Property stargazers_count -Sum).Sum

if (-not $atProtocolData -and $at.AtData) {
    $atProtocolData = $at.AtData
}

$postsAboutRepos =
    if ($atProtocolData) {
        foreach ($message in @($atProtocolData.Tables['app.bsky.feed.post'].Select("did = '$($did -replace '_', ':')'", "createdAt DESC")).message) {
            $messageLink = $message.commit.record.embed.external.uri -as [uri]
            if (-not $messageLink) { continue }
            if ($messageLink.DnsSafeHost -match 'github\.com$') {
                $message
            }
        }
    }

$markdown = @(
"# Most of My Repos"

"(I write a lot of code)"

"## Some Stats:"

"  * $totalStars ★"
"  * [$($myGitHubInfo.followers) followers](https://github.com/$GitHubUserName?tab=followers)"
"  * [$($myRepos.Count) public repos](https://github.com/$GitHubUserName?tab=repositories)"
"  * $($($myRepos | Where-Object -Not Fork | Measure-Object).Count) of my repos are original"
"  * $($($myRepos | Where-Object Fork | Measure-Object).Count) of my repos are forks"
"  * $($($myRepos | Measure-Object -Property forks_count -Sum).Sum) forks of my repos"
"  * $($($myRepos | Measure-Object -Property watchers_count -Sum).Sum) watchers of my repos"
"  * $($($myRepos | Measure-Object -Property open_issues_count -Sum).Sum) open issues in my repos"

"## By Popularity:"
foreach ($repoInfo in $myReposByPopularity) {
"  * [$($repoInfo.owner.login)/$($repoInfo.Name)]($($repoInfo.html_url))"
}

"## By Recency:"
foreach ($repoInfo in $myRepos | Where-Object Fork -Not | Sort-Object updated_at -Descending) {
"  * [$($repoInfo.owner.login)/$($repoInfo.Name)]($($repoInfo.html_url))"
}
) -join [Environment]::NewLine

(ConvertFrom-Markdown -InputObject $markdown).Html