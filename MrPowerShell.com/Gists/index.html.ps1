param(
    [string]$GitHubUser = 'StartAutomating'
)

if (-not $script:myGists) {
    $script:myGists = Invoke-RestMethod -Uri "https://api.github.com/users/$GitHubUser/gists"    
}


$script:myGists | 
    Sort-Object updated_at -Descending |
    ForEach-Object {
        "<a href='$($_.html_url)' target='_blank' class='gist'>$([Web.HttpUtility]::HtmlEncode($_.description))</a>"
    }