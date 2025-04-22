# Set an alias to buildFile.ps1
Set-Alias BuildFile ./buildFile.ps1

# Start the clock
$lastBuildTime = [DateTime]::Now

Push-Location $PSScriptRoot

# If we have an event path,
$gitHubEvent = if ($env:GITHUB_EVENT_PATH) {
    # all we need to do to serve it is copy it.
    Copy-Item $env:GITHUB_EVENT_PATH .\gitHubEvent.json
    Get-Content -Path .\gitHubEvent.json -Raw | ConvertFrom-Json
}

$CNAME = 
    if (Test-Path 'CNAME') {
        (Get-Content -Path 'CNAME' -Raw).Trim()
    }

$buildStart = [DateTime]::Now
Get-ChildItem -Recurse -File | . buildFile
Compress-Archive -Path $pwd -DestinationPath archive.zip
$buildEnd = [DateTime]::Now

$newLastBuild = [Ordered]@{
    LastBuildTime = $lastBuildTime
    BuildDuration = $buildEnd - $buildStart
    Message = $gitHubEvent.commits[-1].Message
}
   
$lastBuild = 
    try {
        Invoke-RestMethod -Uri "https://$CNAME/lastBuild.json" -ErrorAction Ignore
    } catch {
        Write-Warning ($_ | Out-String)
    }

if ($lastBuild) {
    $newLastBuild.TimeSinceLastBuild = $lastBuildTime - $lastBuild.LastBuildTime            
}

$newLastBuild | ConvertTo-Json -Depth 2 > lastBuild.json
$newLastBuild


Pop-Location