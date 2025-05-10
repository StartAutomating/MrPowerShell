"<p> We can run chromium in headless mode inside of a GitHub action.</p>"

#region Set up chromium alias
$chromium = Get-Command -Name chromium -CommandType Application, Alias -ErrorAction Ignore | 
    Select-Object -First 1
if (-not $chromium) {
    $chromePath = Get-Process chrome -ErrorAction Ignore |
        Select-Object -ExpandProperty Path -First 1            
    if ($chromePath) {
        $chromium = Set-Alias -Name chromium -Value $chromePath -Force -PassThru        
    }
    else {
        $edgePath = Get-Process msedge -ErrorAction Ignore |
            Select-Object -ExpandProperty Path -First 1            
        if ($edgePath) {
            $chromium = Set-Alias -Name chromium -Value $edgePath -Force -PassThru
        }
        else {
            Write-Warning "No chromium or edge found in the path."
            return
        }
    }
}
#endregion Set up chromium alias

$chromiumOutput = & $chromium --headless --dump-dom --no-sandbox --disable-gpu ("$psScriptRoot/index.html" -as [uri]) | Out-String
"<pre><code class='language-html'>$([Web.HttpUtility]::HtmlEncode("$chromiumOutput"))</code></pre>"