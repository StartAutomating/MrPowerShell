param(
[int]
$Count = 1kb
)

$ds = [Data.DataSet]::new('Random')
$randomPointsTable = $ds.Tables.Add("RandomPoints")
$randomPointsTable.Columns.AddRange(@(
    [Data.DataColumn]::new("X", [double], '', 'Attribute'),
    [Data.DataColumn]::new("Y", [double], '', 'Attribute')
))

$null = foreach ($n in 1..$count) {
    $randomPointsTable.Rows.Add((Get-Random), (Get-Random))
}

$ds