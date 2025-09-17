<#
.SYNOPSIS
    Small file server 
.DESCRIPTION
    A small file server to help test this website.
.NOTES
    This will only serve get requests for existing files.

    This is also not anywhere near the fastest static server in existence.
    
    As such, a proper static server would be preferred for production scenarios.
#>
param(
# The URL we will serve.
# By default, this is a random local port.
# Within a container, it will be http://*:80/
[uri]
$ServerUrl = "http://localhost:$(Get-Random -Min 4200 -Max 42000)/",

# The content types to serve
# This maps an extension to a desired content type.
[Collections.IDictionary]
$ContentTypes = [Ordered]@{
    ".css"  = "text/css"
    ".js"   = "text/javascript"
    ".html" = "text/html"
    ".svg"  = "image/svg+xml"
    ".png"  = "image/png"
    ".jpg"  = "image/jpg"
},

# The script root for the server.
# By default, the same as this directory
[string]
$ScriptRoot = $PSScriptRoot
)

# If we are in a container
if ($env:IN_CONTAINER) {
    # bind to any incoming traffic on 80
    $ServerUrl = "http://*:80/"
}

# Determine if the job exists
$jobExists = Get-Job -ErrorAction Ignore -Name $ServerUrl 

# If it does not, or is not running
if ($jobExists.State -ne 'Running') {
    # create a listener
    $httpListener = [Net.HttpListener]::new()
    # add our prefix
    $httpListener.Prefixes.Add("$ServerUrl")
    try {
        # and try to start
        $httpListener.Start()
    } catch {
        # (if that fails, throw )
        throw $_
        return
    }

    # Pack the information into an $IO dictionary
    $io = [Ordered]@{
        HttpListener = $httpListener
        PSScriptRoot = $ScriptRoot
        ContentTypes = $ContentTypes
    }
    
    # Start a background job for the server
    Start-ThreadJob -ScriptBlock {
        param([Collections.IDictionary]$io)

        # unpack any IO items
        foreach ($key in $io.Keys) {
            $ExecutionContext.SessionState.PSVariable.set($key, $io[$key])
        }

        # and push into the script root
        if ($PSScriptRoot) { Push-Location $PSScriptRoot}

        # Collect all error pages into an unordered hashtable
        # (so we can look up by number)
        $ErrorPages = @{}                
        Get-ChildItem -Path $PSScriptRoot |
            Where-Object Name -match '^\d+.html$' |
            ForEach-Object { 
                $ErrorPages[$_.Name -replace '\D' -as [int]] = Get-Content $_.FullName -AsByteStream
            }
        # Set the error pages into IO, so we can access it from outside.
        $io.ErrorPages = $ErrorPages
        
        # Declare a small filter to provide error codes, since we may do this a few places.
        filter httpError {
            param([int]$ErrorCode)
            $_.StatusCode = $ErrorCode
            if ($ErrorPages[$_.StatusCode]) {
                $_.Close($ErrorPages[$_.StatusCode], $false)
            } else {
                $_.Close()
            }
        }

        # While we are listening
        while ($httpListener.IsListening) {
            # try to get the next request
            $gotContext = $httpListener.GetContextAsync()
            # while we are waiting
            while (-not $gotContext.IsCompleted -and -not $gotContext.IsFaulted) {
                # sleep random short intervals so as to be kind to CPUs.
                Start-Sleep -Milliseconds (7,11 | Get-Random)                
            }
            # Get the context
            $context = $gotContext.Result
            # and start a clock
            $t = [DateTime]::Now
            # Separate the context into request and response
            $request, $response = $context.Request, $context.Response
            # If they want any method other than GET
            if ($request.HttpMethod -ne 'get') {
                # error out
                $response | httpError 405
            }
            # Try to get the local path
            $localPath = "." + ($request.Url.LocalPath -replace '/$', '/index.html')
            # If there was no extension
            if ($localPath -notmatch '/.+?\..+?$') {
                # assume it is an .html file
                $localPath = $localPath + '.html'
            }
            # Write a little bit of logging information
            Write-Host "Reqeusting $($request.Url.LocalPath) - $localPath" -ForegroundColor Cyan
            # try to find our path
            $resolvedFile = Get-Item -ErrorAction Ignore $localPath

            # If it was actually a directory
            if ($resolvedFile -is [IO.DirectoryInfo]) {
                # look for a valid index
                $indexExtensions = '.html','.js','.css','.svg'

                # If any index exists
                foreach ($ext in $indexExtensions) {
                    $combinedPath  =$resolvedFile.FullName, [IO.Path]::DirectorySeparatorChar, 'index.html'
                    if ([IO.File]::Exists($combinedPath)) {
                        # change resolved file and break out
                        $resolvedFile = [IO.FileInfo]$combinedPath
                        break
                    }
                }
                # If it is still a directory,
                if ($resolvedFile -is [IO.DirectoryInfo]) {
                    $response | httpError 404 # return a 404 
                }
                
            }
            
            # If we have a file _and_ that file is beneath our root
            if ($resolvedFile -and $resolvedFile -like "$psScriptRoot*") {
                # let us serve it:
                Write-Host "Found $localPath" -ForegroundColor Cyan
                # * Get our content type right
                $response.ContentType =
                    if ($contentTypes[$resolvedFile.Extension]) {
                        $contentTypes[$resolvedFile.Extension]
                    } else {
                        'text/plain'
                    }
                # * Read our bytes
                $contentBytes = (Get-Content -Path $resolvedFile -Raw -AsByteStream )
                # * Close out the request
                $response.Close($contentBytes, $false)
                # * And leave a note
                Write-Host -ForegroundColor Green "Responded with $($contentBytes.Length/1kb)kb in $([DateTime]::Now - $t)"
            }            
            else {
                # If we could not find the file, or it is not beneath $psScriptRoot
                # error out
                $response | httpError 404
                Write-Host -ForegroundColor Yellow "Responded with 404 in $([DateTime]::Now - $t)"
            }
            # output the context in case of any additional debugging is needed.
            $context
        }
    } -Name "$serverUrl" -ArgumentList $io |
        Add-Member NoteProperty IO $io -Force -PassThru |
        Add-Member NoteProperty HttpListener $io.HttpListener -Force -PassThru
}