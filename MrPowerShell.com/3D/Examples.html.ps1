
$greatGreatGrandParent = $PSScriptRoot | Split-Path | Split-Path | Split-Path
$threeJsPath = $greatGreatGrandParent | Join-Path -ChildPath 'three.js'

$3jsFiles = 
    git.sparse -Repository https://github.com/mrdoob/three.js/ -Pattern "/examples/**/**.html" -Path $threeJsPath

$htmlFiles = $3jsFiles | 
    Where-Object Extension -eq '.html'
    
$pageDepth = 0
$inSegments = @()
$root = "$pwd"

"<h2>Three.js Examples</h2>"

"<p>This page clones the <a href='https://github.com/mrdoob/three.js'>three.js</a> examples</p>"

"<details>"
"<summary>View Source</summary>"
"<pre><code class='language-PowerShell'>$([Web.HttpUtility]::HtmlEncode($MyInvocation.MyCommand.ScriptBlock))</code></pre>"
"</details>"
"<hr/>"
foreach ($file in $htmlFiles) {
    if ($file.Name -eq 'index.html') { continue }
    $fileSegments = @($file.Name -split '[/_]')
    $parentSegments = $fileSegments[0..($fileSegments.Count - 2)]
           
    if ("$parentSegments" -ne "$inSegments") {
        if ($inSegments) {
            "</ul>"
            "</details>"
        }
        $inSegments = $parentSegments
        "<details open>"
        "<summary>$($parentSegments -join ' / ')</summary>"
        "<ul>"
    }
    "<li>"
    $exampleFileName = $file.Name -replace '\.html$'
    "<a href='https://threejs.org/examples/#$exampleFileName)'>$($exampleFileName)</a>"
    "</li>"
}
