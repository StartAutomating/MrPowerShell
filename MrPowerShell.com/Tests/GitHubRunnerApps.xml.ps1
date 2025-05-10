$dataSet = [Data.DataSet]::new('GitHubRunnerApps') 
$appTable = $dataSet.Tables.Add('App')
$appTable.Columns.AddRange(@(
    [Data.DataColumn]::new('Name', [string], '', 'Attribute'),
    [Data.DataColumn]::new('Path', [string], '', 'Attribute')
))
$null = foreach ($app in Get-Command -CommandType Application) {
    $appTable.Rows.Add($app.Name, $app.Source)
}
$dataSet