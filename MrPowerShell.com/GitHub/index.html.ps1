<#
.SYNOPSIS
    Gets my GitHub repositories
.DESCRIPTION
    Gets my GitHub repositories and displays them as HTML.
.EXAMPLE
    ./index.html.ps1
.LINK
    https://MrPowerShell.com/GitHub
#>
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
"  * [$($myGitHubInfo.followers) followers](https://github.com/$GitHubUserName/?tab=followers)"
"  * [$($myRepos.Count) public repos](https://github.com/$GitHubUserName/?tab=repositories)"
"  * $($($myRepos | Where-Object -Not Fork | Measure-Object).Count) of my repos are original"
"  * $($($myRepos | Where-Object Fork | Measure-Object).Count) of my repos are forks"
"  * $($($myRepos | Measure-Object -Property forks_count -Sum).Sum) forks of my repos"
"  * $($($myRepos | Measure-Object -Property watchers_count -Sum).Sum) watchers of my repos"
"  * $($($myRepos | Measure-Object -Property open_issues_count -Sum).Sum) open issues in my repos"

) -join [Environment]::NewLine

(ConvertFrom-Markdown -InputObject $markdown).Html
"<style>"
".github-repos { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 2.5em; margin: 2.5em}"
".github-repo-sorter { font-size: 1.5em; text-align: center;}"
".repo-thumbnail { max-width: 100%; height: auto; }"
"</style>"

"<div class='github-repo-sorter'>"
"Sort by:"
"<select id='sort-repos'>"
"<option value='repoRandom'>Random</option>"
"<option value='repoStars' selected>Stars</option>"
"<option value='repoUpdatedAt'>Updated At</option>"
"<option value='repoCreatedAt'>Created At</option>"
"<option value='repoOpenIssues'>Open Issues</option>"
"<option value='repoForks'>Forks</option>"
"<option value='repoName'>Name</option>"
"<option value='repoWatchers'>Watchers</option>"

"</select>"
"<script>"
"document.getElementById('sort-repos').addEventListener('change', function(event) {"
"    const sortBy = event.target.value;"
"    const container = document.querySelector('.github-repos');"
"    const repos = Array.from(container.children);"
"    repos.sort((a, b) => {"
"        if (sortBy === 'repoStars') {"
"            return parseInt(b.dataset.repoStars) - parseInt(a.dataset.repoStars);"
"        } else if (sortBy === 'repoForks') {"
"            return parseInt(b.dataset.repoForks) - parseInt(a.dataset.repoForks);"
"        } else if (sortBy === 'repoOpenIssues') {"
"            return parseInt(b.dataset.repoOpenIssues) - parseInt(a.dataset.repoOpenIssues);"
"        } else if (sortBy === 'repoName') {"
"            return a.dataset.repoName.localeCompare(b.dataset.repoName);"
"        } else if (sortBy === 'repoWatchers') {"
"            return parseInt(b.dataset.repoWatchers) - parseInt(a.dataset.repoWatchers);"
"        } else if (sortBy === 'repoCreatedAt') {"
"            return new Date(b.dataset.repoCreatedAt) - new Date(a.dataset.repoCreatedAt);"
"        } else if (sortBy === 'repoUpdatedAt') {"
"            return new Date(b.dataset.repoUpdatedAt) - new Date(a.dataset.repoUpdatedAt);"
"        } else if (sortBy === 'repoRandom') {"
"            return Math.random() - 0.5;"
"        }"
"        return 0;"
"    });"
"    for (let i = 0; i < repos.length; i++) {"
"        repos[i].style.order = i + 1;"
"    }"
"});"
"</script>"
"</div>"
"<div class='github-repos'>"
foreach ($repoInfo in $myRepos | Where-Object Fork -Not | Sort-Object stargazers_count -Descending) {
    $attributes = [Ordered]@{
        'class' = 'github-repo'
        'data-repo-name' = $repoInfo.Name
        'data-repo-url' = $repoInfo.html_url
        'data-repo-stars' = $repoInfo.stargazers_count
        'data-repo-forks' = $repoInfo.forks_count
        'data-repo-watchers' = $repoInfo.watchers_count
        'data-repo-open-issues' = $repoInfo.open_issues_count
        'data-repo-created-at' = $repoInfo.created_at.ToString('o')
        'data-repo-updated-at' = $repoInfo.updated_at.ToString('o')
    }
    $attributeString = @(
        foreach ($attributeName in $attributes.Keys) {
            "$attributeName='$($attributes[$attributeName])'"
        }
    ) -join ' '
    "<div $attributeString>"
        "<h2><a href='$($repoInfo.html_url)'>$($repoInfo.Name)</a></h2>"
        "<p>$([Web.HttpUtility]::HtmlEncode($repoInfo.Description))</p>"
        "<p>★ $($repoInfo.stargazers_count) | Forks: $($repoInfo.forks_count) | Watchers: $($repoInfo.watchers_count) | Open Issues: $($repoInfo.open_issues_count)</p>"
        "<p>Created: $($repoInfo.created_at.ToString('yyyy-MM-dd')) | Updated: $($repoInfo.updated_at.ToString('yyyy-MM-dd'))</p>"
        if ($postsAboutRepos) {
            $post = $postsAboutRepos | Where-Object { $_.commit.record.embed.external.uri -match "^$([Regex]::Escape($repoInfo.html_url))" } | Get-Random
            if ($post) {
                $thumbRef = $post.commit.record.embed.external.thumb.ref.'$link'
                $imageTag =  if ($thumbRef) {
                    "<img class='repo-thumbnail' src='https://cdn.bsky.app/img/feed_thumbnail/plain/$($post.did)/$thumbRef@png' alt='Thumbnail' />"
                } else { '' }
                    
                "<blockquote>$imageTag - $($post.commit.record.text) <br/>— <a href='https://bsky.app/profile/$($post.did)/post/$($post.commit.rkey)'>@$($post.author.handle)</a></blockquote>"
            }
        }
    "</div>"
}

"</div>"
