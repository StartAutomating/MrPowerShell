param(
    [uri]
    $ShowUri = 'https://mrpowershell.com/'
)

"<p> We can run chromium in headless mode inside of a GitHub action </p>"
"<pre><code class='language-powershell'>"
{
    #region Find Chromium
    if (-not $script:chromium) {
        # Find the chromium executable or alias, pick the first one
        $chromium = Get-Command -Name chromium -CommandType Application, Alias -ErrorAction Ignore | 
            Select-Object -First 1
        # If we don't have a chromium alias, we'll try to find the chrome or edge executable.
        if ($chromium) {
            $script:chromium = $chromium
        } else {
            # If there's no running instance of chrome, we'll try to find it.
            $chromePath = 
                Get-Process chrome, msedge -ErrorAction Ignore |
                    Select-Object -ExpandProperty Path -First 1        
            if ($chromePath) {
                $script:chromium   = $chromePath
            }
            else {                        
                Write-Error 'Chromium not found. Please `Set-Alias chromium $ChromiumPath` (after you set $ChromiumPath)'
            }
        }
    }
    # $script:chromium
    #endregion Find Chromium
    $headlessArguments = @(
        '--headless', # run in headless mode
        '--dump-dom', # dump the DOM to stdout
        '--disable-gpu', # disable GPU acceleration
        '--no-sandbox' # disable the sandbox if running in CI/CD    
        $ShowUri       # the URL to show
    )
    $chromiumOutput = & $script:chromium @headlessArguments | Out-String
    "<pre><code class='language-html'>$([Web.HttpUtility]::HtmlEncode("$chromiumOutput"))</code></pre>"
}
"</code></pre>"