<#
.SYNOPSIS
    XML and PowerShell
.DESCRIPTION
    Using XML in PowerShell
.NOTES
    ### A Brief History of XML

    Languages have long made use of punctuation.

    Around the dawn of the internet, a number of "markup" languages came into existence (most famously HTML)

    These languages used `<tags>` to describe how things should be displayed and should link together.

    Infamously, there was much debate on if tags needed to be balanced.
    
    That is, for every opening `<tag>`, there should be a corresponding `</tag>`
    
    Many display languages, like HTML, wanted to be forgiving, and decided that they would try to work even if tags were unclosed.

    This simply would not work for an easy-to-implement standard, and so, XML was born in 1998.

    [XML](https://en.wikipedia.org/wiki/XML) stands for "Extensible Markup Language".

    It was created to help standardize how information could be stored:

    Anything could be described in a `<tag>` and it's children and attributes (as long as they are closed)

    Finally, after decades of disagreement, we could all store data in _one_ way.  Right?

    While several other answers to these problems have come out over the years, XML is still everywhere.

    The era of "XML is the answer to everything" lasted roughly until the creation of JSON (2013), so there is quite a lot of technology that uses XML.

    Which makes it really quite handy that PowerShell can deal with XML so well :-)

    ### PowerShell and XML

    Since we've established that XML is far older than PowerShell (`2008 -gt 1998`),
    it should be no surprise that PowerShell has always supported XML.

    Since the very first alphas of PowerShell, XML has been built into the language.
    
    We can cast any string to XML:
    ~~~PowerShell
    [xml]"<h1>Hello World</h1>"
    ~~~

    Because PowerShell joins multiple items by spaces when you stringify them, we can also cast an expression to XML

    ~~~PowerShell
    [xml]@(
        "<html>"
            "<head>"
                "<title>Hello World</title>"
            "</head>"
            "<body>"
                "<h1>Hello World</h1>"
                "<h2>PowerShell and XML are cool!</h2>"
            "</body>"
        "</html>"        
    )
    ~~~

    We can access attributes or children of the XML as properties:

    ~~~PowerShell
    ([xml]"<h1 class='heading'>Hello World</h1>").h1.class
    ~~~
    
    If there a node only has inner text, accessing that node will return a `[string]`

    ~~~PowerShell
    ([xml]"<h1>Hello World</h1>").h1
    ~~~

    We can also set inner text this way:

    ~~~PowerShell
    $xHtml = [xml]"<h1>Hello World</h1>"
    $xHtml.h1 = 'hi'
    $xHtml.OuterXml
    ~~~

    If a node has attributes and inner text, text will be available within the `#text` property
    ~~~PowerShell
    ([xml]"<h1 class='heading'>Hello World</h1>").h1.'#text'    
    ~~~

    We can still set it:

    ~~~PowerShell
    $xHtml = [xml]"<h1 class='heading'>Hello World</h1>"
    $xHtml.h1.'#text' = 'hi'
    $xHtml.OuterXml
    ~~~

    #### Escaping Content

    Almost everything is valid XML, but not _quite_ everything.

    Some characters need to be escaped instead of included inline.

    For example, in XML, an ampersand begins an "entity".

    This next code will produce an error.

    ~~~PowerShell
    [xml]"<h1>PowerShell & XML</h1>"
    ~~~

    We can escape the inner text in a few ways.

    We will start by using a static method [`[Security.SecurityElement]::Escape`](https://learn.microsoft.com/en-us/dotnet/api/system.security.securityelement.escape)

    ~~~PowerShell
    [xml]"<h1>$([Security.SecurityElement]::Escape("PowerShell & XML"))</h1>"
    ~~~

    We can also set the text property, and this will automatically escape our text.

    ~~~PowerShell
    $xhtml = [xml]"<h1>PowerShell</h1>"
    $xhtml.h1 = 'PowerShell & XML are cool'
    $xhtml.OuterXml
    ~~~
    
    #### Invoke-RestMethod and XML
    
    One more useful thing to note is that PowerShell is pretty smart when it comes to content types.

    When we use Invoke-RestMethod to access a URI, if the result is XML, it will be returned as XML.

    ~~~PowerShell
    $svg = Invoke-RestMethod https://MrPowerShell.com/MrPowerShell.svg
    $svg.GetType()
    ~~~

    This makes it incredibly easy to work with web content and services that serve up XML.
    
    #### Saving XML

    Every `[xml]` object knows how to save itself.

    They have a `.Save()` method which accepts a file name or a memory stream.

    It excepts an absolute path, so please provide one.  `$pwd` is the current working directory.

    ~~~PowerShell
    $svg = Invoke-RestMethod https://MrPowerShell.com/MrPowerShell.svg
    $svg.Save("$pwd/MrPowerShell.svg")
    Get-Content $pwd/MrPowerShell.svg
    ~~~

    You can also write the OuterXML to a file:

    ~~~PowerShell
    $svg = Invoke-RestMethod https://MrPowerShell.com/MrPowerShell.svg
    $svg.OuterXml | Set-Content ./MrPowerShell.svg
    Get-Content ./MrPowerShell.svg
    ~~~

    #### Loading XML

    If we need to load XML locally, we simply get it as a string and cast to XML:

    ~~~PowerShell
    $svg = Invoke-RestMethod https://MrPowerShell.com/MrPowerShell.svg
    $svg.OuterXml | Set-Content ./MrPowerShell.svg
    [xml](Get-Content ./MrPowerShell.svg)
    ~~~

    We can also use .NET classes to read and write our files

    ~~~PowerShell
    $svg = Invoke-RestMethod https://MrPowerShell.com/MrPowerShell.svg
    [IO.File]::WriteAllText("$pwd/MrPowerShell.svg")
    [xml][IO.File]::ReadAllText("$pwd/MrPowerShell.svg")
    ~~~

    As we can see, XML is pretty easy to make and manipulate with PowerShell.

    Hopefully, now you see that anything built atop of XML should be fairly easily to work with in PowerShell.
#>
if ($PSScriptRoot) { Push-Location $PSScriptRoot}
$myHelp = Get-Help $MyInvocation.MyCommand.ScriptBlock.File
$title = $myHelp.Synopsis
$description = $myHelp.description.text -join [Environment]::NewLine
ConvertFrom-Markdown -InputObject (
    @(
        "# $title"
        "## $description"
        $myHelp.alertSet.alert.text
    ) -join [Environment]::NewLine
) | 
    Select-Object -ExpandProperty Html


"<details>"
"<summary>View Source</summary>"
"<pre><code class='language-powershell'>"
[Web.HttpUtility]::HtmlEncode($MyInvocation.MyCommand.ScriptBlock)
"</code></pre>"
"</details>"

if ($PSScriptRoot) { Pop-Location}