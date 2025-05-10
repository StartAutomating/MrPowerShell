$codeBlockSchema = [Data.DataSet]::New('CodeBlocks')
$codeTable = $codeBlockSchema.Tables.Add('code')
$codeTable.Columns.AddRange(@(
    [Data.DataColumn]::new('class', [string], '', 'Attribute')
    [Data.DataColumn]::new('content', [string], '', 'SimpleContent')
))
$codeBlockSchema