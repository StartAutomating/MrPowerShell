if ($PSScriptRoot) { Push-Location $PSScriptRoot }
$navData = foreach ($file in Get-ChildItem | Where-Object Name -match '\.html\.ps1$') {
    $file.Name -replace '\.html\.ps1$'
}
"<nav>"
"<label for='filePicker'>File:</label>"
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
