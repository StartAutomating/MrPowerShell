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
    "https://bsky.app/profile/$($data.did)/$recordType/$($data.commit.rkey)/"
}    

"<div style='text-align: center'>"
foreach ($post in $myPosts) {         
    $myPostUri = $post.commit.record.embed.external.uri -as [uri]
    if ($myPostUri.DnsSafeHost -eq 'media.tenor.com') {
        "<a href='$($post | toUri)'><img src='$($myPostUri)' $(if ($post.commit.record.embed.external.description) {
            "alt='$([Web.HttpUtility]::htmlAttributeEncode($post.commit.record.embed.external.description))'"
        } else {
            "alt='Tenor GIF'"
        }) /></a>
        <br/>"
    }    
}
"</div>"