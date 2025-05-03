$Title = "How to Build Static Websites with PowerShell"

"<h1>Building a Static Website with PowerShell</h1>"
"<h2>Building static sites with PowerShell is easy!</h2>"
"<h3>Seriously. This site is built with simple PowerShell</h3>"
"<p>PowerShell is pretty powerful when it comes to text processing, and static sites are almost entirely text.</p>"    
"<h2>Hello World</h2>"
"<p>Let's start very simple, with a customizable Hello World</p>"
(ConvertFrom-Markdown -InputObject "
~~~PowerShell
$({
    # Set our message
    $Message = "Hello World!"
    # Generate a string that embeds our message, and redirect it to a file
    "<h1>$Message</h1>" > MyFirstPowerShellPage.html
    # use Invoke-Item to open the file in the default browser
    Invoke-Item ./MyFirstPowerShellPage.html
})
~~~
").Html
    "<p>When you run this code, it will create a file called MyFirstPowerShellPage.html in the current directory.</p>"
    "<p>When you open that file in a browser, you'll see the text 'Hello World!' displayed.</p>"
    "<h3>Once more, with Markdown</h3>"
    "<p>PowerShell core includes a ConvertFrom-Markdown cmdlet, which can be used to generate HTML from Markdown.</p>"
    "<p>Markdown is a simple markup language that can be used to format text.</p>"
    $LearnLink = 'https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/convertfrom-markdown?wt.mc_id=MVP_321542'
    "<p>Here's an example of how to use <a href='$LearnLink'>ConvertFrom-Markdown</a> to generate HTML:</p>"
    (ConvertFrom-Markdown -InputObject "
~~~PowerShell
$({

    $Markdown = "# Hello From Markdown"
    # ConvertFrom-Markdown returns an object with a property called 'Html'
    # convert our markdown to HTML, and redirect it to a file        
    (ConvertFrom-Markdown -InputObject $Markdown).Html > HelloFromMarkdown.html
    # use Invoke-Item to open the file in the default browser
    Invoke-Item ./HelloFromMarkdown.html
})
~~~
").Html

"<p>Since GitHub Workflows allow us to run PowerShell scripts, this is all we need to do to build a static site.</p>"

"<p>Now, let's get a little meta.  We're going to include the source for this page in this page</p>"

"<p>To to this, we can use the <code>MyInvocation</code> automatic variable to get the script block for this page, like so:</p>"

(ConvertFrom-Markdown -InputObject '
~~~PowerShell
$($myInvocation.MyCommand.ScriptBlock)
~~~
')

"<p>The full code is below:</p>"

"<hr/>"

(ConvertFrom-Markdown -InputObject "
~~~PowerShell
$($MyInvocation.MyCommand.ScriptBlock)
~~~
").Html
