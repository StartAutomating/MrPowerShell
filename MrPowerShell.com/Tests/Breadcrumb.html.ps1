if ($PSScriptRoot) { Push-Location $PSScriptRoot }
$navData = foreach ($file in Get-ChildItem | Where-Object Name -match '\.html\.ps1$') {
    $file.Name -replace '\.html\.ps1$'
}
"<nav>"

@'
<span id='breadcrumbs'><button onclick='window.location.href="/"'>/</button></span>
'@

@'

<script>
var urlSegments = window.location.pathname.split('/')
var breadcrumbs = document.getElementById('breadcrumbs');
for (var i = 1; i < (urlSegments.length - 1); i++) {
    breadcrumbs.innerHTML += `<button onclick="window.location.href='${urlSegments.slice(0, i + 1).join('/')}';">${urlSegments[i]}</button>`;
    if (i < (urlSegments.length - 2)) {
        breadcrumbs.innerHTML += ' / ';
    }
}
</script>
'@

"<label for='filePicker'>/</label>"
"<input list='fileList' id='filePicker' name='filePicker' />"
"<datalist id='fileList'>"
foreach ($file in $navData) {
    "<option value='$file' />"
}
"</datalist>"
"<script>"
"function navigateToFile() {"
"    const filePicker = document.getElementById('filePicker');"
"    const fileName = filePicker.value;"
"    if (fileName) {"
"        window.location.href = fileName;"
"    }"
"}"
"</script>"
"<button onclick='navigateToFile()'>Go</button>"
"</nav>"
if ($PSScriptRoot) { Pop-Location}
