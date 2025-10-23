<#
.SYNOPSIS
    The Zip Epiphany
.DESCRIPTION
    More files are zip files than you might think.
.NOTES
    Here's an epiphany for anyone in tech:

    Lots of files are zip files in a trenchcoat.

    Just because a file does not have the extension `.zip` does not mean that it is not, in fact, a zip file.

    One great simple way to tell:  rename the file to .zip and try to extract.

    If it is a .zip file, you'll get a directory full of understanding of how that file type works.

    ### Open Packaging Conventions

    This approach really got supercharged in 2006, with the standardization of [Open Packaging Conventions](https://en.wikipedia.org/wiki/Open_Packaging_Conventions)

    Here's a short list of Open Packaging Convention files you might have heard of.

    |File Format|Extension|
    |-|-|
    |Word Document|`.docx`| 
    |Excel Workbook|`.xlsx`|
    |PowerPoint Presentation|`.pptx`|
    |Nuget Package|`.nupkg`|
    |Visual Studio Installer|`.vsix`|
    |Microsoft App-V|`.appv`|
    |Microsoft PowerBI reports/templates|`.pbit`, `.pbix`|
    |3D Model Format|`.3mf`|

    Open Packaging Convention files offer quite a few benefits over normal .zips:

    * They can contain package metadata
    * Each file can have a content-type
    * They can be signed and encrypted

    We can also easily open up any open packaging convention file using the [`[System.IO.Packaging.Package]`](https://learn.microsoft.com/en-us/dotnet/api/system.io.packaging.package?wt.mc_id=MVP_321542) class:

    ~~~PowerShell
    # Open a .zip and try to read its parts
    $PackageFile = [IO.Packaging.Package]::Open($pathToZip, 'Open', 'Read')
    if ($PackageFile) {
        $PackageFile.GetParts()
        $PackageFile.Close()
    }    
    ~~~    
    
    ### Other .zip files

    There are a few other file types of note that are .zip files in a trenchoat (and not Open Packaging files)

    |File Type|Extension|
    |-|-|
    |Java Archive| `.jar`|
    |Python Wheel| `.whl`|

    We can expand these files with Expand-Archive:

    ~~~PowerShell
    Expand-Archive ./example.jar -DestinationPath ./SomeJava
    ~~~


    ## How this helps

    Nobody wants to reinvent the wheel, and so prudent programmers choose not to.

    Understanding that many files are archives helps us understand packages work, and how to work with packages.

    We often construct a package by putting files in the right place and zipping them up.

    We often deploy packages by unzipping them to the right location.

    We often provide package metadata by peeking into an archive and grabbing the right file.

    If you have the Zip Epiphany, and realize how many packages are .zip files in a trenchcoat, packaging becomes much easier to understand.

    Hope this Helps!
#>
param()

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