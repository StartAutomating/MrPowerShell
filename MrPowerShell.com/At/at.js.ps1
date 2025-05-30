if (-not $Site.AtData) {
    return
}
@"

export default function AtData() {
    $(
    @(foreach ($tableName in $site.AtData.Tables.TableName) {
        "this['$tableName'] = $($site.AtData.Tables[$TableName].message | ConvertTo-Json)"
    }) -join ";$([Environment]::NewLine)$(' ' * 4)"
    )
    return this
}
"@
