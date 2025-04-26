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

# If we have a CNAME, read it and trim it.
$CNAME = 
    if (Test-Path 'CNAME') {
        (Get-Content -Path 'CNAME' -Raw).Trim()
    }

# Start the clock on the build process
$buildStart = [DateTime]::Now
# pipe every file we find to buildFile
Get-ChildItem -Recurse -File | . buildFile
# and stop the clock
$buildEnd = [DateTime]::Now

#region lastBuild.json

# We create a new object each time, so we can use it to compare to the last build.
$newLastBuild = [Ordered]@{
    LastBuildTime = $lastBuildTime
    BuildDuration = $buildEnd - $buildStart
    Message = 
        if ($gitHubEvent.commits) { 
            $gitHubEvent.commits[-1].Message
        } elseif ($gitHubEvent.schedule) {
            $gitHubEvent.schedule
        } else {
            'On Demand'
        }
}

# If we have a CNAME, we can use it to get the last build time from the server.
$lastBuild =
    try {
        Invoke-RestMethod -Uri "https://$CNAME/lastBuild.json" -ErrorAction Ignore
    } catch {
        Write-Warning ($_ | Out-String)
    }

# If we could get the last build time, we can use it to calculate the time since the last build.
if ($lastBuild) {
    $newLastBuild.TimeSinceLastBuild = $lastBuildTime - $lastBuild.LastBuildTime
}

# Save the build time to a file.
$newLastBuild | ConvertTo-Json -Depth 2 > lastBuild.json
#endregion lastBuild.json

# Create an archive of the current deployment.
Compress-Archive -Path $pwd -DestinationPath "archive.zip" -CompressionLevel Optimal -Force

Pop-Location