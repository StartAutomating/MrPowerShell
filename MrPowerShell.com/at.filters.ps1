function at.listRecords {
    <#
    .LINK
        https://github.com/bluesky-social/atproto/blob/main/lexicons/com/atproto/repo/listRecords.json
    #>
    [CmdletBinding(SupportsPaging)]
    [Alias('at.records','com.atproto.repo.listRecords')]
    param(
        # The decentralized identifier (DID) of the user.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $did = "did:plc:hlchta7bwmobyum375ltycg5",
        
        # The collection of records to retrieve.
        # This can be any object
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('$type')]
        [string]
        $Collection = "app.bsky.feed.post",
        
        # The cursor.
        # This should be empty.
        # A cursor can be provided to start from a specific point in the list.
        # Each response will include a cursor to the next page of results.
        # Once the cursor is empty, there are no more results.        
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $Cursor,
    
        # The number of records to return.
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('Limit')]
        [int]
        $BatchSize = 100
    )

    process {
        $total = [long]0
        $skipped = [long]0
        :AtSync do {
            $xrpcUrl = "https://bsky.social/xrpc/com.atproto.repo.listRecords?repo=$did&collection=$collection&cursor=$Cursor&limit=$BatchSize"
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

filter at.record {    
    param(        
        [string]$AtUri,
        [string]$did = "did:plc:hlchta7bwmobyum375ltycg5",
        [string]$collection = "app.bsky.feed.post",
        [string]$rkey = "3k4hf5dy6nf2g"        
    )

    $xrpcUrl = "https://bsky.social/xrpc/com.atproto.repo.getRecord?repo=$did&collection=$collection&rkey=$rkey"
    
    Invoke-RestMethod -Uri $xrpcUrl
}

filter at.web.uri {
    [Alias('at.web.url')]
    param(
        [string]$pdc="bsky.app"
    )
    $data = $_    
    switch ($data.commit.record.'$type') {    
        'app.bsky.feed.post' {
            $recordType = @($data.commit.record.'$type' -split '\.')[-1]
            "https://$($pdc)/profile/$($data.did)/$recordType/$($data.commit.rkey)"
        }
        default {
            "https://bsky.social/xrpc/com.atproto.repo.getRecord?repo=$($data.did)&collection=$($data.commit.record.'$type')&rkey=$($data.commit.rkey)"
        }
    }
}

function at.jetstream.javascript {
    [Alias('at.jetstream.js')]
    param(
    $OnMessage      = "console.log(event.data)",
    $OnOpen         = "console.log('WebSocket connection established')",
    $collections    = @('app.bsky.feed.post'),
    $cursor         = $null,
    $dids           = @(),
    $socketName     = 'atJetstream',
    $filter,
    $target,
    $template
    )

    if ($filter) {
        $onMessage = @(
            "let filterValue = $filter"
            "if (! filterValue) { return }"
        ) + @($OnMessage)
    }

    if ($target -and $template) { 
        $OnMessage = @($OnMessage) + @(
"let target = document.getElementById('$target')"
"if (target) {"
"let templateOutput = ``$($template -replace '^`+' -replace '`+$')``"
"target.innerHTML += templateOutput"
"}"
)
    }

    return @"
// Create WebSocket connection.
let socketUri = "wss://jetstream2.us-west.bsky.network/subscribe"
if (Math.random() > 0.5) { socketUri = "wss://jetstream2.us-east.bsky.network/subscribe" }
if (Math.random() > 0.5) { socketUri = socketUri.replace("2","1") }
let $socketName = new WebSocket(```${socketUri}?$(
    @(
        foreach ($collection in $collections | Select-Object -Unique) { "wantedCollections=$collection" }
        foreach ($did in $dids) { "wantedDids=$did" }
        if ($cursor -as [double]) { "cursor=$cursor" }
        elseif($cursor) { "cursor=`${$cursor}" }
    ) -join '&'
)``)
// Log the connection opening
$socketName.addEventListener("open", (event) => {
    $($OnOpen -join ([Environment]::NewLine))
});
// Listen for messages
$socketName.addEventListener("message", (event) => {
let atEvent = JSON.parse(event.data);
$(
    $OnMessage -join ([Environment]::NewLine)
)
});
"@
}

function Invoke-At
{
    <#
    .SYNOPSIS
        Invokes the AT Protocol
    .DESCRIPTION
        Invokes the RESTful methods of the At Protocol.
    .LINK
        Connect-AtProto
    #>
    [Alias(
        'Invoke-AtMethod',    # Because Invoke-RestMethod is familiar
        'Invoke-AtProtocol',  # Because some people prefer longnames
        'iap',                # Because some people prefer shortnames
        'at.protocol',
        'at.proto'        
    )]
    [CmdletBinding(SupportsShouldProcess)]
    param(
    # The URI being invoked.  If this is empty, a -NamespaceID is required.
    [Parameter(ValueFromPipelineByPropertyName)]
    [Alias('Url')]
    [uri]
    $Uri,

    # The HTTP Method.
    [Parameter(ValueFromPipelineByPropertyName)]    
    [ValidateSet('GET','DELETE','HEAD','MERGE','OPTIONS','PATCH','POST', 'PUT', 'TRACE')]
    [string]
    $Method = "GET",

    # The Namespace ID.  
    # In the AT Protocol, every request has a NamespaceID.
    [Parameter(ValueFromPipelineByPropertyName)]    
    [string]
    $NamespaceID,

    # Any parameters to the request.
    # If the HTTP Method is get, these will become QueryParameters
    # Otherwise, they will become -BodyParameters.
    [Parameter(ValueFromPipelineByPropertyName)]
    [Alias('Parameters')]
    [PSObject]
    $Parameter,
    
    # One or more query parameters.
    [Parameter(ValueFromPipelineByPropertyName)]
    [Alias('QueryParameters','Query')]
    [PSObject]
    $QueryParameter,

    # One or more body parameters.
    [Parameter(ValueFromPipelineByPropertyName)]
    [Alias('BodyParameters','Body')]
    [PSObject]
    $BodyParameter,

    # The authorization.
    # This can be a JWT that accesses the at protocol.
    # It can also be a credential.
    # The username is a handle or email.
    # The password is the app password.
    [Parameter(ValueFromPipelineByPropertyName)]    
    [Alias('Authentication','AppPassword','Credential','PSCredential')]
    [PSObject]
    $Authorization,

    # The content type of the request.  
    # If not provided, this will be assumed to be application/json.
    [Parameter(ValueFromPipelineByPropertyName)]
    [string]
    $ContentType = 'application/json',

    # Aliases for parameters.
    # If these parameters are found, they will be called using their alias instead.
    [Parameter(ValueFromPipelineByPropertyName)]
    [PSObject]
    $ParameterAlias,

    # The typename of the results.
    [Parameter(ValueFromPipelineByPropertyName)]
    [Alias('Decorate','Decoration','TypeName')]
    [string[]]
    $PSTypeName,
    
    # A set of additional properties to add to an object
    [Parameter(ValueFromPipelineByPropertyName)]
    [Collections.IDictionary]
    $Property,

    # A list of property names to remove from an object.
    [Parameter(ValueFromPipelineByPropertyName)]
    [string[]]
    $RemoveProperty = @("Password"),

    # If provided, will expand a given property returned from the REST api.
    [Parameter(ValueFromPipelineByPropertyName)]
    [string]
    $ExpandProperty,

    # If provided, will decorate the values within a property in the return object.
    # This allows nested REST properties to work with the PowerShell Extended Type System.
    [Parameter(ValueFromPipelineByPropertyName)]
    [Collections.IDictionary]
    [Alias('TypeNameOfProperty')]
    $DecorateProperty,

    # If set, will receive results as a byte array.
    [Parameter(ValueFromPipelineByPropertyName)]
    [switch]
    $AsByte,

    # If set, will cache results from a request.  Only HTTP GET results will be cached.
    [Parameter(ValueFromPipelineByPropertyName)]
    [switch]
    $Cache,

    # If set, will return raw results.
    # This will ignore -Property, -DecorateProperty, -ExpandProperty, and -PSTypeName.
    [Parameter(ValueFromPipelineByPropertyName)]
    [switch]
    $Raw
    )

    begin {
        if (-not $script:AtServerSessions) {
            $script:AtServerSessions = [Ordered]@{}
        }

        if (-not $script:AtResponseCache) {
            $script:AtResponseCache = [Ordered]@{}
        }

        $InvokeQueue = [Collections.Queue]::new()
        $defaultHost = "bsky.social"        
    }
    
    process {
        $myParameters = [Ordered]@{} + $PSBoundParameters
        if ($myParameters.Contains('Authorization')) {
            if ($Authorization -is [PSCredential]) {
                # If the authorization was a credential, let it be a username/app-password

                $authUri = "https://$(if ($uri.Host) { $uri.host } else {$defaultHost})/xrpx/com.atproto.server.createSession"
                $authenticationResponse = 
                    Invoke-AtProtocol -Uri $authUri -Authorization '' -BodyParameter ([Ordered]@{
                        identifier = $Authorization.username
                        password = $Authorization.GetNetworkCredential().Password
                    })
                if (-not $authenticationResponse) {
                    return
                }
                $script:AtServerSessions[$authenticationResponse.handle] = $authenticationResponse                

                $script:AtProtocolAccessJWT  = $Authorization = $authenticationResponse.accessJWT
                $script:AtProtocolRefreshJWT = $Authorization = $authenticationResponse.refreshJWT
            }
            elseif ($Authorization -is [SecureString]) {
                $Authorization = [PSCredential]::new("AnyUserNameWillDo", $Authorization).GetNetworkCredential().Password
            }
            
            if ($Authorization -is [string] -and $Authorization) {            
                if ($Authorization -match '[\.]') {
                    $script:AtProtocolAccessJWT = $Authorization
                }
                else {
                    # We only have an app password, error out.
                    Write-Error "Authorization appears to be an app password.  Provide a credential with your username as well"
                    return
                }            
            }
        }

        $InvokeSplat     = [Ordered]@{}
        $queryParameters = [Ordered]@{}
        $BodyParameters  = [Ordered]@{}
    
        if ($Parameter) {
            $parameterDictionary = 
                if ($Method -eq 'GET') {
                    $queryParameters            
                } else {
                    $BodyParameters
                }
            if ($Parameter -is [Collections.IDictionary]) {
                $parameter = [PSCustomObject]$Parameter
            }
            foreach ($prop in $parameter.psobject.properties) {
                if ($ParameterAlias.($prop.Name)) {
                    $parameterDictionary[$ParameterAlias.($prop.Name)] = $prop.value
                } else {
                    $parameterDictionary[$prop.Name] = $prop.value
                }                    
            }
        }

        $uri = $myParameters["uri"]

        if (-not $uri.Host) {            
            $uri = "https://$defaultHost/"
        }

        if ($myParameters["NamespaceID"] -and $uri -notmatch '\/xprc\/.+$') {
            $uri = ("$uri" -replace "/$") +
                ("/xrpc/$NamespaceID")
        }

        $InvokeSplat["Uri"] = 
            if ($Method -eq 'GET' -and $queryParameters.Count) {
                "${uri}?$(
                    @(foreach ($qp in $queryParameters.GetEnumerator()) {
                        "$($qp.Key)=$($qp.Value)"
                    }) -join '&'
                )"
            } else {
                $uri 
            }

        $InvokeSplat["Method"] = $Method
        if ($PSBoundParameters["ContentType"]) {
            $InvokeSplat["ContentType"] = $PSBoundParameters["ContentType"]
        }

        if ($BodyParameters.Count -and $method -notin 'get','options') {
            if ($BodyParameters["."] -as [byte[]]) {
                $InvokeSplat["Body"] = $BodyParameters["."] -as [byte[]]
            } else {
                $InvokeSplat["Body"] = $BodyParameters | ConvertTo-Json -Depth 100                 
            }            
        }

        if ($script:AtProtocolAccessJWT -and 
            (-not ($PSBoundParameters["Authorization"] -and -not $Authorization))) {
            $InvokeSplat.Headers = [Ordered]@{"Authorization"="Bearer $($script:AtProtocolAccessJWT)"}
        }
        
        if (-not $InvokeSplat["ContentType"]) {
            $InvokeSplat["ContentType"] = "application/json"
        }


        $InvokeQueue.Enqueue($InvokeSplat)
    }
    
    end {
        # Get Invoke-RestMethod
        $invokeRestMethod = $ExecutionContext.SessionState.InvokeCommand.GetCommand('Invoke-RestMethod', 'Cmdlet')
        # and all of it's parameters
        $invokeRestMethodParameters = @($invokeRestMethod.Parameters.Keys | Sort-Object)
        # and turn that list into one regex.
        $invokeRestMethodRegex = [Regex]::new("(?>$($invokeRestMethodParameters -join '|'))")
        $psProperties = @()
        if ($Property) {
            $psProperties = @(
                if ($property -is [Collections.IDictionary]) {
                    foreach ($propKeyValue in $Property.GetEnumerator()) {
                        if ($propKeyValue.Value -as [ScriptBlock[]]) {
                            [PSScriptProperty]::new.Invoke(@($propKeyValue.Key) + $propKeyValue.Value)
                        } 
                        elseif ($propKeyValue.Value -isnot [byte[]]) {
                            [PSNoteProperty]::new($propKeyValue.Key, $propKeyValue.Value)
                        }                        
                    }
                } else {
                    $property.psobject.properties
                }                
            )
        }
        $OutputToCache = $null
        if ($cache -and -not $script:InvokeAtProtoCache) {
            $script:InvokeAtProtoCache = [Ordered]@{}
        }

        # Do everything from here on out in nested [ScriptBlock].
        # Why?  So that the object pipeline sends objects as they are ready.

        . {
            # Walk thru all we were to invoke
            foreach ($iq in $InvokeQueue.ToArray()) {
                # create a splat for each
                $toSplat = [Ordered]@{}
                # and strip out anything not a parameter to Invoke-RestMethod              
                foreach ($keyToSplat in $iq.Keys -match $invokeRestMethodRegex) {
                    $toSplat[$keyToSplat] = $iq[$keyToSplat]
                }
                
                
                # If -WhatIf was passed
                if ($WhatIfPreference) {
                    # strip headers
                    $toSplat.Remove('Headers')
                    $toSplat # and return the splat.
                    continue
                }

                if ($cache -and $script:InvokeAtProtoCache[$toSplat.uri]) {
                    $script:InvokeAtProtoCache[$toSplat.uri]
                } else {

                    # Create a human readable form of the request
                    $methodAndUri = $toSplat.Method, $toSplat.uri -join ' '
                    # and -Confirm the activity (if they passed -Confirm, that is)
                    if ($psCmdlet.ShouldProcess($methodAndUri)) {
                        Write-Verbose $methodAndUri
                        # If we want bytes back
                        if ($AsByte) {
                            # use Invoke-WebRequest
                            Invoke-WebRequest @toSplat
                        } else {
                            # otherwise, use Invoke-RestMethod.
                            Invoke-RestMethod @toSplat
                        }
                    }
                }
            }
        } | 
        & { 
            process {
                $in = $_
                if ($cache -and $script:InvokeAtProtoCache[$toSplat.uri]) {
                    return $script:InvokeAtProtoCache[$toSplat.uri]
                }
                if ($in -eq 'null') {
                    return
                }
                
                if ($AsByte -and $in.Content) {
                    $in.Content
                }
                elseif ($ExpandProperty -and -not $Raw) {
                    if ($in.$ExpandProperty) {
                        return $in.$ExpandProperty
                    }
                } 
                elseif ($in -isnot [string] -and $(
                    $inProperties = @($in.psobject.properties)
                    $inProperties.Length -eq 1
                )) {
                    $inProperties[0].Value
                }
                else {
                    $in
                }                
            }
        } 2>&1  |        
            & { 
                [CmdletBinding()]
                param(
                [Parameter(ValueFromPipeline)]
                [PSObject]
                $InputObject
                )
                process { 
                    # One more step of the pipeline will unroll each of the values.
                    if ($Raw) { return $_ }

                if ($cache -and $script:InvokeAtProtoCache[$toSplat.uri]) {
                    return $script:InvokeAtProtoCache[$toSplat.uri]
                }
            $in = $_
            if ($in -is [string]) { return $in }

            if ($PSTypeName -and # If we have a PSTypeName (to apply formatting)
                $in -isnot [Management.Automation.ErrorRecord] # and it is not an error (which we do not want to format)
            ) {
                $in.PSTypeNames.Clear() # then clear the existing typenames and decorate the object.
                if ($in.'$type') {
                    $in.PSTypeNames.add($in.'$type')
                }
                foreach ($t in $PSTypeName) {
                    $in.PSTypeNames.add($T)
                }
            }

            if ($psProperties) {
                foreach ($prop in $psProperties) {
                    if ($in.psobject.members[$prop.Name]) { continue }
                    try {                        
                        $in.PSObject.Members.Add($prop, $true)
                    } catch {
                        $exception = $_                        
                        $null = $exception
                    }
                }
            }

            if ($RemoveProperty) {
                foreach ($propToRemove in $RemoveProperty) {
                    $in.PSObject.Properties.Remove($propToRemove)
                }
            }
            if ($DecorateProperty) {
                foreach ($kv in $DecorateProperty.GetEnumerator()) {
                    $dotKeys = @($kv.Key -split '\.')
                    $target = $in
                    foreach ($dot in $dotKeys) {
                        $target = $target.$dot
                    }
                    if (-not $target) { continue }
                    
                    foreach ($v in @($target)) {
                        if ($null -eq $v -or -not $v.pstypenames) { continue }
                        $v.pstypenames.clear()
                        foreach ($tn in $kv.Value) {
                            $v.pstypenames.add($tn)
                        }
                    }
                }
            }
            return $in # output the object and we're almost done.
        } } -OutVariable OutputToCache

        if ($Cache -and 
            $Method -eq 'Get' -and 
            $OutputToCache -and 
            (-not $script:InvokeAtProtoCache[$toSplat.Uri])
        ) {            
            $script:InvokeAtProtoCache[$toSplat.Uri] = $OutputToCache
        }
    } 
}