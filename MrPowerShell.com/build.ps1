Set-Alias BuildFile ./buildFile.ps1

$lastBuildTime = [DateTime]::Now

Push-Location $PSScriptRoot
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

$newLastBuild | ConvertTo-Json -Depth 3 > lastBuild.json
$newLastBuild

Pop-Location