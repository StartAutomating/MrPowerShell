function com.atproto.repo.listRecords {
    [CmdletBinding(SupportsPaging)]
    [Alias('at.records')]
    param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $did = "did:plc:hlchta7bwmobyum375ltycg5",
        
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('$type')]
        [string]
        $Collection = "app.bsky.feed.post",
        
        [string]
        $Cursor,
    
        [int]
        $Limit = 100
    )

    process {
        $total = [long]0
        $skipped = [long]0
        :AtSync do {
            $xrpcUrl = "https://bsky.social/xrpc/com.atproto.repo.listRecords?repo=$did&collection=$collection&cursor=$Cursor&limit=$Limit"
            $results = Invoke-RestMethod $xrpcUrl
            if ($results -and $results.cursor) {
                $Cursor = $results.cursor
            }
            foreach ($record in $results.records) {
                if ($PSCmdlet.PagingParameters.Skip -and 
                    $skipped -lt $PSCmdlet.PagingParameters.Skip
                ) {
                    $skipped++
                    continue
                }                                        
                
                $record.pstypenames.insert(0, $collection)
                $record
                $total++
                
                if ($PSCmdlet.PagingParameters.First -and 
                    $total -ge $PSCmdlet.PagingParameters.First) {
                    break AtSync
                }
            }    
        } while ($results -and $results.cursor)
    }
    
    
}

