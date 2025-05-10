"<p> We can run chromium in headless mode inside of a GitHub action.</p>"

#region Set up chromium alias
$chromium = Get-Command -Name chromium -CommandType Application, Alias -ErrorAction Ignore
if (-not $chromium) {
    $chromePath = Get-Process chrome -ErrorAction Ignore | Select-Object -ExpandProperty Path
    if ($chromePath) {
        Set-Alias -Name chromium -Value $chromePath -Force
    }
    else {
        $edgePath = Get-Process msedge -ErrorAction Ignore | 
            Select-Object -ExpandProperty Path
        if ($edgePath) {
            Set-Alias -Name chromium -Value $edgePath -Force
        }
        else {
            Write-Warning "No chromium or edge found in the path."
            return
        }
    }
}
#endregion Set up chromium alias

$chromiumOutput = chromium --headless --dump-dom --disable-gpu ("$pwd/index.html" -as [uri]) | Out-String
"<pre><code class='language-html'>$([Web.HttpUtility]::Encode($chromiumOutput))</code></pre>"