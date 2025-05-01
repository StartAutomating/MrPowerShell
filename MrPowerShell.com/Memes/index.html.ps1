param(
    $did = 'did_plc_hlchta7bwmobyum375ltycg5'
)

$myPostFiles = $PSScriptRoot | 
    Split-Path | 
        Split-Path | 
            Get-ChildItem -Filter $did |
                Get-ChildItem -Filter app.bsky.feed.post | 
                    Get-ChildItem -Filter *.json

$myPosts = $myPostFiles | 
    Foreach-Object {
        Get-content -Raw $_.FullName | ConvertFrom-Json
    } | 
    Sort-Object { $_.commit.record.createdAt } -Descending

filter toUri {
    $data = $_
    $recordType = @($data.commit.record.'$type' -split '\.')[-1]
    "https://bsky.app/profile/$($data.did)/$recordType/$($data.commit.rkey)"
}    

@"
<style>
.imageGrid {
    display: grid;    
    text-align: center;    
}
</style>
"@

"<div class='imageGrid'>"
foreach ($post in $myPosts) {    
    $myPostUri = $post.commit.record.embed.external.uri -as [uri]
    $description = $post.commit.record.embed.external.description -replace '^alt:\s{0,}'    
    if ($myPostUri.DnsSafeHost -eq 'media.tenor.com') {
        "<div>"
        "<a href='$($post | toUri)' aria-label='$([Web.HttpUtility]::HtmlAttributeEncode($description))'><img src='$($myPostUri)' $(if ($description) {
            "alt='$([Web.HttpUtility]::htmlAttributeEncode($description))'"
        } else {
            "alt='Tenor GIF'"
        }) /></a>"
        "<br/>"
        "<p>"
        "<a href='$($post | toUri)'>"
        [Web.HttpUtility]::HtmlEncode($description)
        "</a>"
        "</p>"
        "</div>"
    }    
}
"</div>"