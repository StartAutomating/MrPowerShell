#requires -Module WebSocket
param(        
[uri]
$jetstreamUrl = "wss://jetstream$(1,2 | Get-Random).us-$('east','west' | Get-Random).bsky.network/subscribe",

[string[]]
$Collections,

[string[]]
$Dids = @(),

[Collections.IDictionary]
$WellKnownDid = @{
    'MrPowershell.com' = 'did:plc:hlchta7bwmobyum375ltycg5'
},

[TimeSpan]
$Since = [TimeSpan]::FromDays(.5),

[TimeSpan]
$TimeOut = [TimeSpan]::FromMinutes(15),

[string]
$Root = $PSScriptRoot,

[ValidateSet("png","jpeg")]
[string]
$ImageFormat = 'png'
)

if ($WellKnownDid.Count) {
    $Dids += $WellKnownDid.Values
}

$jetstreamUrl = @(
    "$jetstreamUrl"
    '?'
    @(
        foreach ($collection in $Collections) {
            "wantedCollections=$collection"
        }
        foreach ($did in $Dids) {
            "wantedDids=$did"
        }
        "cursor=$(([DateTimeOffset]::Now - $Since).ToUnixTimeMilliseconds())" 
    ) -join '&'
) -join ''

Write-Host "Listening to $($jetstreamUrl)"

$Jetstream = WebSocket -SocketUrl $jetstreamUrl -TimeOut $TimeOut

filter toAtUri {
    $in = $_
    $did = $in.did    
    $rkey = $in.commit.rkey
    $recordType = $in.commit.record.'$type'
    "at://$did/$recordType/$rkey"
}

filter saveImage {
    param($to)
    $in = $_
    foreach ($img in $in.commit.record.embed.images) {
        $imageRef = $img.image.ref.'$link'
        $imageLink =
            "https://cdn.bsky.app/img/feed_thumbnail/plain/$($in.did)/$imageRef@$($ImageFormat.ToLower())"
        
        $outFilePath = "$($to -replace '/$')/$imageRef.$ImageFormat"
        Invoke-WebRequest $imageLink -OutFile $outFilePath
        if ($?) {
            Get-Item -Path $outFilePath
        }
    }
    
}

filter savePost {
    param($to)
    $in = $_
    $inAtUri = $in | toAtUri
    $inFilePath = $inAtUri -replace ':','_' -replace '^at_//', $to -replace '$', '.json'
    if (-not (Test-Path $inFilePath)) {
        New-Item -Path $inFilePath -Force -Value (ConvertTo-Json -InputObject $in -Depth 10)
        $in | saveImage "$($inFilePath | Split-Path)"
    } else {
        Get-Item -Path $inFilePath
    }
}

do {
    $Jetstream | 
        Receive-Job -ErrorAction SilentlyContinue | 
        savePost "$root/"
} while ($Jetstream.JobStateInfo.State -in 'NotStarted','Running') 

$Jetstream | 
    Receive-Job -ErrorAction SilentlyContinue | 
    savePost "$root/"