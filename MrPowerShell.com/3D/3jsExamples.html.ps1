$3jsFiles = 
    git.sparse -Repository https://github.com/mrdoob/three.js/ -Pattern "/build/**.js", "/examples/**/**.js", "/examples/**/**.html"

$htmlFiles = $3jsFiles | Where-Object Extension -eq '.html' | Sort-Object { $_.FullName.Length }
$pageDepth = 0
$root = "$pwd"

foreach ($file in $htmlFiles) {
    $fileSegments = @($file.Name -split '/')
    if ($fileSegments.Length -gt $pageDepth) {
        $pageDepth = $fileSegments.Count
        "<ul>"
    }

    if ($fileSegments.Length -lt $pageDepth) {
        "</ul>"
    }
    "<li>"
    "<a href='$($file.FullName.Substring($root.Length))'>$($file.Name)</a>"
    "</li>"
}
