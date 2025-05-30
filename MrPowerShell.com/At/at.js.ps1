if (-not $Site.AtData) {
    return
}
@"

const at = {}
at['data'] = {}
$(
@(foreach ($tableName in $site.AtData.Tables.TableName) {
    "at.data['$tableName'] = $($site.AtData.Tables[$TableName].message | ConvertTo-Json)"
}) -join ";$([Environment]::NewLine)$(' ' * 4)"
)
export default at
"@
