[OutputType('{
    "type": "object",
    "required": ["atUri", "url", "domain"],
    "properties": {
        "id": {
            "type": "string",
            "format": "atUri",
            "description": "The at uri"
        },
        "url": {
            "type": "string",
            "format": "url",
            "description": "The url"
        },
        "domain": {
            "type": "string",            
            "description": "The domain name"
        },
        "createdAt": {
            "type": "string",
            "format": "date",
            "description": "The link creation time"
        }        
    }
}')]
param()

if ($atProtocolData -isnot [Data.DataSet]) { return }

if (-not $script:Cache) {
    $script:Cache = [Ordered]@{}
}

if (-not $script:Cache['com.mrpowershell.at.links']) {
    $script:Cache['com.mrpowershell.at.links'] = @(
        foreach ($row in $atProtocolData.Tables['app.bsky.feed.post'].Select(
            "", "createdAt DESC"
        )) {
            $message = $row.Message
            $messageLink = $message.commit.record.embed.external.uri -as [uri]
            if (-not $messageLink) { continue }    
            
            $atUri = @(
                "at:/"
                $message.did
                $message.commit.collection
                $message.commit.rkey
            ) -join '/'

            [PSCustomObject]@{
                PSTypeName = 'com.mrpowershell.at.link'
                '$type' = 'com.mrpowershell.at.link'
                atUri = $atUri
                url = $messageLink
                domain = $messageLink.DnsSafeHost
                createdAt = $row.createdAt
            }            
        }
    )
}

$script:Cache['com.mrpowershell.at.links']


