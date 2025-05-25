$Version = [Ordered]@{} + $PSVersionTable
$Version.Modules = [ordered]@{}
"<h3>PSVersionTable</h3>"
"<table>"
foreach ($versionProperty in $PSVersionTable.GetEnumerator()) {
    "<tr><td>$($versionProperty.Key)</td><td>$($versionProperty.Value)</td></tr>"    
}

"</table>"
"<table>"
"<thead><tr><th>Module</th><th>Version</th></tr></thead>"
foreach ($loadedModule in Get-Module) {
    $Version.Modules[$loadedModule.Name] = $loadedModule.Version
    "<tr><td>$($loadedModule.Name)</td><td>$($loadedModule.Version)</td></tr>"    
}
"</table>"
$Version | ConvertTo-Json -Depth 5 > ./Version.json

