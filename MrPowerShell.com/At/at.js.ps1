if (-not $Site.AtData) {
    return
}
@"

const atData = {}
$(
@(foreach ($tableName in $site.AtData.Tables.TableName) {
    "atData['$tableName'] = $($site.AtData.Tables[$TableName].message | ConvertTo-Json)"
}) -join ";$([Environment]::NewLine)$(' ' * 4)"
)
export default atData
"@
