param(
    $did = 'did_plc_hlchta7bwmobyum375ltycg5',
    
    [double]
    $MinimumMentionPopularity = 0.01,

    [double]
    $BaseEmphasis = 1.5,

    [double]
    $ExtraWeight = 5.0 
)

# Set a title and description, so that it shows up in metadata
$Title = "Mentions"
$Description = "People I talk about on BlueSky"

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
"<h1>$title</h1>"
"<h3>$Description</h3>"
"<h4>Top $("{0:P0}" -f $popularEnoughTags)</h4>"
"</div>"

"<div class='hashtagGrid'>"
$postsByMention = [Ordered]@{}
$didMap = [Ordered]@{}
foreach ($post in $myPosts) {
    foreach ($facet in $post.commit.record.facets) {
        foreach ($feature in $facet.features) {
            if ($feature.'$type' -eq 'app.bsky.richtext.facet#mention') {
                $resolvedMention = $post.commit.record.text.Substring($facet.index.byteStart, $facet.index.byteEnd - $facet.index.byteStart)
                $didMap[$resolvedMention] = $feature.did
                if (-not $postsByMention[$resolvedMention]) {
                    $postsByMention[$resolvedMention] = @()
                }
                $postsByMention[$resolvedMention] += $post
            }
        }
    }
}
$taggedPostTotal = @($postsByMention.Values).Count

$postsByPopularity = [Ordered]@{}
foreach ($mention in $postsByMention.GetEnumerator() | Sort-Object { $_.Value.Count } -Descending) {
    $postsByPopularity[$mention.Key] = @($postsByMention[$mention.Key]).Count / $taggedPostTotal
}

"<style>"
'
.wordCloud {
    list-style: none;
    margin: 10%;
    display: flex;
    text-align: center;
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
    Where-Object { $_.Value -gt $MinimumMentionPopularity }

foreach ($popularTag in ($popularEnoughTags | Get-Random -Count $popularEnoughTags.Count)) {
    "<li>"
    "<a href='https://bsky.app/profile/$($didMap[$popularTag.Key])' style='font-size: $([Math]::Round($BaseEmphasis + ($popularTag.Value * $ExtraWeight), 4))rem'>"
    $popularTag.Key
    "</a>"
    "</li>"
}
"</div>"