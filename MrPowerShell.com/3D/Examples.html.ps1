$3jsFiles = 
    git.sparse -Repository https://github.com/mrdoob/three.js/ -Pattern "/build/**.js", "/examples/**/**.**"

$htmlFiles = $3jsFiles | 
    Where-Object Extension -eq '.html' | 
    Sort-Object { $_.FullName.Length } -Descending
    
$pageDepth = 0
$root = "$pwd"

"<h2>Three.js Examples</h2>"

"<p>This page clones the [three.js](https://github.com/mrdoob/three.js) examples</p>"

"<details>"
"<summary>View Source</summary>"
"<pre><code class='language-PowerShell'>$([Web.HttpUtility]::HtmlEncode($MyInvocation.MyCommand.ScriptBlock))</code></pre>"
"</details>"

foreach ($file in $htmlFiles) {
    $fileSegments = @($file.Name -split '/')
    if ($fileSegments.Length -gt $pageDepth) {
        $pageDepth = $fileSegments.Count
        "<ul>"
    }

    if ($fileSegments.Length -lt $pageDepth) {        
        "</ul>"
        $pageDepth = $fileSegments.Count
    }
    "<li>"
    "<a href='$($file.FullName.Substring($root.Length))'>$($file.Name -replace '\.html$')</a>"
    "</li>"
}
