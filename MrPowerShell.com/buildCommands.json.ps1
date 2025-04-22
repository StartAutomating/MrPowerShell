[Ordered]@{
    Applications = Get-Command -CommandType Application | select -ExpandProperty Name
    Functions = Get-Command -CommandType Function | select -ExpandProperty Name
    Cmdlets = Get-Command -CommandType Cmdlet | select -ExpandProperty Name
    Aliases = Get-Command -CommandType Alias | select -ExpandProperty Name
} | ConvertTo-Json -Depth 3

