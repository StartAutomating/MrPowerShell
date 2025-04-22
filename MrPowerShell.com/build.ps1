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
$buildEnd = [DateTime]::Now

$newLastBuild = [Ordered]@{
    LastBuildTime = $lastBuildTime
    BuildDuration = $buildEnd - $buildStart
    Message = if ($gitHubEvent.commits) { $gitHubEvent.commits[-1].Message } else { 'On Demand' }
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

Compress-Archive -Path $pwd -DestinationPath "archive.zip" -CompressionLevel Optimal

Pop-Location