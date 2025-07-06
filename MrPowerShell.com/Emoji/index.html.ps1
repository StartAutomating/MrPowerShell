<#
.SYNOPSIS
    My Emoji
.DESCRIPTION
    My BlueSky feed, but just the Emoji.
.NOTES
    ### Emoji are fun!
    
    **(especially out of context)**

    This is a randomized grid of emoji I use.
    
    Every emoji links to a post on BlueSky.

    You want context?  Just click!
.EXAMPLE
    ./index.html.ps1
.LINK
    https://MrPowerShell.com/Emoji
#>
param(
    $did = 'did_plc_hlchta7bwmobyum375ltycg5'
)
#region ShowHelp
$myHelp = Get-Help $MyInvocation.MyCommand.ScriptBlock.File 
$Title = $myHelp.Synopsis
$Description = $myHelp.Description.text -join [Environment]::NewLine
$notes = $myHelp.alertSet.alert.text -join [Environment]::NewLine
if ($notes) {
    ConvertFrom-Markdown -InputObject $notes |
        Select-Object -ExpandProperty Html
}
#endregion ShowHelp

if ($site.AtData) {
    Write-Host "Getting posts from cache"
    $myPosts = @($site.AtData.Tables['app.bsky.feed.post'].Select("did = '$($did -replace '_', ':')'", "createdAt DESC")).message
} else {
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
                    
}

filter toUri {
    $data = $_
    $recordType = @($data.commit.record.'$type' -split '\.')[-1]
    "https://bsky.app/profile/$($data.did)/$recordType/$($data.commit.rkey)"
}    

@"
<style>
    .emojiGrid {
        display: grid;
        align-items: center;
        text-align: center;
        font-size: 2em;
        grid-template-columns: repeat(auto-fit, minmax(100px, 2fr));
        gap: 2em; 
        margin: 2em;    
    }
</style>
"@

$emojiPattern = [Regex]::new('[\p{IsHighSurrogates}\p{IsLowSurrogates}\p{IsVariationSelectors}\p{IsCombiningHalfMarks}]+')


"<div class='emojiGrid'>"
$allMyEmoji = @(foreach ($post in $myPosts) {    
    $postText = $post.commit.record.text
    $emojiMatches = @($emojiPattern.Matches($postText))
    if (-not $emojiMatches) { continue }
    @(foreach ($match in $emojiPattern.Matches($postText)) {
        "<a href='$($post | toUri)' target='_blank'>$match</a>"
    })           
})
$allMyEmoji | Get-Random -Count $allMyEmoji.Count
"</div>"