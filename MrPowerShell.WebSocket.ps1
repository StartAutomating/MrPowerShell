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

Write-Host "Listening to $($jetstreamUrl) for $Timeout"

$Jetstream = WebSocket -SocketUrl $jetstreamUrl -TimeOut $TimeOut
$JetStreamStart = [DateTime]::Now

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

filter saveMatchingMessages {
    $message = $_
    $message | savePost "$root/$($patternName)/"
}

do {

    $batch = $Jetstream |
        Receive-Job -ErrorAction Ignore

    $batchStart = [DateTime]::Now 
    
    $newFiles = $batch |
        savePost "$root/" |
        Add-Member NoteProperty CommitMessage "Syncing from at protocol [skip ci]" -Force -PassThru
    
    if ($batch) {
        Write-Host "Processed batch of $($batch.Length) in $([DateTime]::Now - $batchStart) - Last Post @ $($batch[-1].commit.record.createdAt)" -ForegroundColor Green
        if ($newFiles) {
            Write-Host "Found $(@($newFiles).Length) new posts or images!" -ForegroundColor Green
            $filesFound += $newFiles
            $newFiles
        }
    }

    # Break out if we're past the time
    # (the job should automatically complete,
    # but better safe than hanging the action )
    if (([DateTime]::Now - $JetStreamStart) -gt $TimeOut) {
        Write-Host "Timeout $timeout hit: breaking loop."
        break
    }
} while ($Jetstream.JobStateInfo.State -in 'NotStarted','Running') 


$batch = $Jetstream |
    Receive-Job -ErrorAction Ignore

$newFiles = $batch |
    saveMatchingMessages |
    Add-Member NoteProperty CommitMessage "Syncing from at protocol [skip ci]" -Force -PassThru

$newFiles

$Jetstream | 
    Stop-Job