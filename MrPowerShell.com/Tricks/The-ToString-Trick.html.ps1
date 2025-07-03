<#
.SYNOPSIS
    The ToString Trick
.DESCRIPTION
    Output custom objects any way you want.
.NOTES        
    Output a `[PSCustomObject]` any way you want by overriding the `ToString()` method on the object.
.LINK
    https://MrPowerShell.com/Tricks/The-ToString-Trick
#>

# Create an object to represent the page.
$ThisPage = 
    [PSCustomObject]@{
        Title = 'The ToString Trick'
        Description = 'Output custom objects any way you want'
        Markdown = @(
"PowerShell is great for dealing with custom objects."
'We can easily create custom objects by casting a dictionary to `[PSCustomObject]` or using `New-Object PSObject -Property @{}`.'
"
~~~PowerShell
$({
    [PSCustomObject]@{MyNumber = 42; MyString = 'Hello World!'}
}.ToString()
)~~~
"

"PowerShell can also add methods to custom objects."

"One of the most useful methods to add is the `ToString()` method."

"Imagine you have some custom object and you want to make a report or a webpage"

"There are many ways to approach this, but one of the easiest ways is to override the `ToString()` method of the object."

"By overriding the `ToString()` method, you can control how the object is represented as a string."

"This page is actually an example of this trick in action"

        )
        Source = "$($MyInvocation.MyCommand.ScriptBlock)"
    }

# Add a ToString method to the object that formats the output as HTML.
$ThisPage | 
    Add-Member -MemberType ScriptMethod -Name ToString -Value {
        @(
            "<h1>$($this.Title)</h1>"
            "<h2>$($this.Description)</h2>"
            (ConvertFrom-Markdown -InputObject $(
                $this.Markdown -join ([Environment]::NewLine * 2)
            )).Html
            
            "<h3>Page Source</h3>" 
            "<pre><code class='language-powershell'>$([Web.HttpUtility]::HtmlEncode($this.Source))</code></pre>"
        ) -join [Environment]::NewLine
    } -Force

# Set the title and description for the page.
$title = $ThisPage.Title
$description = $ThisPage.Description

# And stringify the page.
"$thisPage" 