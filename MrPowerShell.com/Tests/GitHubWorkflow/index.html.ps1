if ($PSScriptRoot) { Push-Location $PSScriptRoot }
if ($env:GITHUB_EVENT_PATH) {
    $workflowPathFiles = $env:GITHUB_EVENT_PATH | 
        Split-Path | 
        Get-ChildItem 
    foreach ($file in $workflowPathFiles) {
        Copy-Item -Path $file.FullName -Destination .\ -Force
        "<a href='$($file.Name)'>$($file.Name)</a>"
        "<br/>"
    }
}
if ($PSScriptRoot) { Pop-Location }