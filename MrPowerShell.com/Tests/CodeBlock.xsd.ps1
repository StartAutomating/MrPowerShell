$codeBlockSchema = [Data.DataSet]::New('CodeBlocks')
$codeTable = $codeBlocks.Tables.Add('code')
$codeTable.Columns.AddRange(@(
    [Data.DataColumn]::new('class', [string], '', 'Attribute')
    [Data.DataColumn]::new('content', [string], '', 'SimpleContent')
))
$codeBlockSchema