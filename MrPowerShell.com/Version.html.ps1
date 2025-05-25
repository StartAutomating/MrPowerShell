$Version = [Ordered]@{} + $PSVersionTable
$Version.Modules = [ordered]@{}
"<table>"
foreach ($versionProperty in $PSVersionTable.GetEnumerator()) {
    "<tr><td>$($versionProperty.Key)</td><td>$($versionProperty.Value)</td></tr>"    
}
foreach ($loadedModule in Get-Module) {
    $Version.Modules[$loadedModule.Name] = $loadedModule.Version
}
"</table>"
$Version | ConvertTo-Json -Depth 5 > ./Version.json

