param(
    [string]$GitHubUser = 'StartAutomating'
)

if (-not $script:myGists) {
    $script:myGists = Invoke-RestMethod -Uri "https://api.github.com/users/$GitHubUser/gists"    
}

"<ul>"
$script:myGists | 
    Sort-Object updated_at -Descending |
    ForEach-Object {
        "<li>"
            "<a href='$($_.html_url)' target='_blank' class='gist'>$([Web.HttpUtility]::HtmlEncode($_.description))</a>"
        "</li>"
    }
"</ul>"