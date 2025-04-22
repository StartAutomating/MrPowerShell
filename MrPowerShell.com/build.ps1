Set-Alias BuildFile ./buildFile.ps1

$lastBuildTime = [DateTime]::Now

Push-Location $PSScriptRoot
$CNAME = if (Test-Path 'CNAME') { Get-Content -Path 'CNAME' -Raw } else { $null }

$buildStart = [DateTime]::Now
Get-ChildItem -Recurse -File | . buildFile
$buildEnd = [DateTime]::Now

$newLastBuild = [Ordered]@{
    LastBuildTime = $lastBuildTime
    BuildDuration = $buildEnd - $buildStart
}
   
$lastBuild = Invoke-RestMethod -Uri "https://$CNAME/lastBuild.json" -ErrorAction Ignore
if ($lastBuild) {
    $newLastBuild.TimeSinceLastBuild = $lastBuildTime - $lastBuild.LastBuildTime            
}


$newLastBuild | ConvertTo-Json -Depth 3 > lastBuild.json
$newLastBuild

Pop-Location