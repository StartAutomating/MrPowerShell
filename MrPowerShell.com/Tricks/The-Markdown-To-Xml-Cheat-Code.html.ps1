<#
.SYNOPSIS
    The Markdown to XML Cheat Code
.DESCRIPTION
    Making Markdown into XML in one line of PowerShell
.NOTES
    Some tricks are so good they feel like old video game cheat codes, and this is one of them.

    We can turn Markdown into XML in one line of PowerShell.

    Ready?

    ~~~PowerShell
    "<x>$((ConvertFrom-Markdown -InputObject '# Hello World').html)</x>" -as [xml]
    ~~~

    ### How does this work?

    ConvertFrom-Markdown will return HTML that's balanced and properly escaped.

    This saves us a fair amount of trouble.  
    
    The only problem is that XML has to have a single root note, and our HTML will have more than one.

    So we do a little cheat, and put the html into an arbitrary node named x.

    Now we have some string that would be valid XML, so we just `-as [xml]` to make it the real thing.

    Voila!  One little cheat code later, our Markdown is now XML.

    ### What does this give us?

    Quite a lot, actually.

    Markdown is **easy to write** but _hard to read_.

    XML is _hard to write_ and **easy to read**.

    Markdown is static.  XML is dynamic.

    Once we turn our Markdown into XML, it's easier to manipulate and query.

    ### Basic Exploration

    Let's start with one our most basic questions:
    
    What's the actual text?

    ~~~PowerShell
    $markdown = "### Hello $(Get-Random)"
    $markdownXml =
        "<x>$((ConvertFrom-Markdown -InputObject $markdown).html)</x>" -as [xml]
    $markdownXml.x.InnerText    
    ~~~

    ### Querying nodes

    Let's have a little more fun.

    Let's query for tables.

    ~~~PowerShell
    # Make our table
    $markdownTable = @(        
        '|d6|d20|'
        '|-|-|'
        "|$(Get-Random -Min 1 -Max 6)|$(Get-Random -Min 1 -Max 20)|"
    ) -join [Environment]::Newline
    $markdownXml = 
        "<x>$(($markdownTable | ConvertFrom-Markdown).html)</x>" -as [xml]
    $markdownXml | 
        Select-Xml -XPath //table |
        Foreach-Object { 
            $_.node.tbody.tr.td
        }
    ~~~
    
    ### Manipulating HTML

    We can also change the XML.  
    
    Let's do something reasonable simple:

    Add an index to each node, in the order they appeared.

    ~~~PowerShell
    $markdown = @(
        "# One"
        "## Two"
        "### Three"
    ) -join [Environment]::Newline
    $markdownXml =
        "<x>$(($markdown | ConvertFrom-Markdown).html)</x>" -as [xml]
    $markdownXml.x | 
        Select-Xml -xPath //* | 
        Select-Object -Skip 1 | 
        Foreach-Object -Begin {
            $nodeCount = 0
        } {
            $_.Node.SetAttribute('data-markdown-index', $nodeCount++) 
        }

    $markdownXml.x.innerXML
    ~~~
    

    ## In Conclusion

    Markdown is great.  Making it into XML opens up plenty of possibilities.
    
    It's a trick so good, and so simple, it feels like cheating.
    
    Enjoy!

    Hope this Helps,

    James
#>


$myHelp = Get-Help $MyInvocation.MyCommand.ScriptBlock.File

$title = $myHelp.Synopsis
$description = $myHelp.Description.text -join [Environment]::NewLine
$notes = $myHelp.alertset.alert.text -join [Environment]::NewLine

if ($page -is [Collections.IDictionary]) {
    $page.Title = $title
    $page.Description = $description
}

ConvertFrom-Markdown -InputObject @"
# $($title)

## $($description)

$notes
"@ | 
    Select-Object -ExpandProperty Html
