param(
    $did = 'did_plc_hlchta7bwmobyum375ltycg5',
    
    [double]
    $MinimumTagPopularity = 0.02,

    [double]
    $BaseEmphasis = 2.0,

    [double]
    $ExtraWeight = 5.0 
)

# Set a title and description, so that it shows up in metadata
$Title = "Tags"
$Description = "My BlueSky feed, but just the tags"

# If we have already cached the AtProto data, use it
if ($site.AtData) {
    Write-Host "Getting posts from cache"
    $myPosts = @($site.AtData.Tables['app.bsky.feed.post'].Select("did = '$($did -replace '_', ':')'", "createdAt DESC")).message
} else {
    $myPostFiles = $PSScriptRoot | Split-Path | Split-Path | 
        Get-ChildItem -Filter $did |
        Get-ChildItem -Filter app.bsky.feed.post |
        Get-ChildItem -Filter *.json

    $myPosts = $myPostFiles |
        Foreach-Object {
            Get-content -Raw $_.FullName | ConvertFrom-Json
        } |
        Sort-Object { $_.commit.record.createdAt } -Descending
                    
}

filter toUri {
    $data = $_
    $recordType = @($data.commit.record.'$type' -split '\.')[-1]
    "https://bsky.app/profile/$($data.did)/$recordType/$($data.commit.rkey)"
}

@"
<style>
a {
    text-decoration: none;    
}

.hashtagGrid {
    display: grid;    
    text-align: center;    
}

.header {
    font-size: 1.5em;
    text-align: center;    
}
</style>
"@
"<div class='header'>"
"<h1>Hashtags</h1>"
"<p>My BlueSky feed, but just the tags</p>"
"</div>"

"<div class='hashtagGrid'>"
$postsByTag = [Ordered]@{}
foreach ($post in $myPosts) {
    foreach ($facet in $post.commit.record.facets) {
        foreach ($feature in $facet.features) {
            if ($feature.'$type' -eq 'app.bsky.richtext.facet#tag') {
                if (-not $postsByTag[$feature.tag]) {
                    $postsByTag[$feature.tag] = @()
                }
                $postsByTag[$feature.tag] += $post
            }
        }
    }
}
$taggedPostTotal = @($postsByTag.Values).Count

$postsByPopularity = [Ordered]@{}
foreach ($tag in $postsByTag.GetEnumerator() | Sort-Object { $_.Value.Count } -Descending) {
    $postsByPopularity[$tag.Key] = @($postsByTag[$tag.Key]).Count / $taggedPostTotal
}

"<style>"
'
.wordCloud {
    list-style: none;
    padding: 5%;
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    justify-content: center;
    line-height: 3rem;    
}

.wordCloud a {
    display: block;  
    padding: .8rem .8rem;
    text-decoration: none;  
}
'

"</style>"
"<ul class='wordCloud'>"
$popularEnoughTags = $postsByPopularity.GetEnumerator() |
    Where-Object { $_.Value -gt $MinimumTagPopularity }

foreach ($popularTag in ($popularEnoughTags | Get-Random -Count $popularEnoughTags.Count)) {
    "<li>"
    "<a href='https://bsky.app/hashtag/$($popularTag.Key)' style='font-size: $([Math]::Round($BaseEmphasis + ($popularTag.Value * $ExtraWeight), 4))em'>"
    '#' + $popularTag.Key
    "</a>"
    "</li>"
}
"</div>"