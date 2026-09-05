#requires -Module Zippy

$svg = @'
<?xml version="1.0" encoding="utf-8"?>
<!-- Generated with PSSVG 0.2.10 https://github.com/StartAutomating/PSSVG -->
<svg viewBox="0 0 1920 1080" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <style type="text/css">@import url('https://fonts.googleapis.com/css?family=Roboto')</style>
  </defs>
  <text x="50%" y="50%" font-size="24em" dominant-baseline="middle" text-anchor="middle" fill="#4488ff" class="" font-family="'Roboto', sans-serif">Hello World</text>
</svg>
'@

[IO.File]::WriteAllBytes(
    "$psScriptRoot/GZip.svgz",
    (Compress-Zippy -Text $svg -Algorithm GZip -AsByteStream)
)

[IO.File]::WriteAllBytes(
    "$psScriptRoot/Gzip.cssz",
    (Compress-Zippy -Text ".big { font-size: 2rem }" -Algorithm GZip -AsByteStream)
)


[IO.File]::WriteAllBytes(
    "$psScriptRoot/Gzip.htmlz",
    (Compress-Zippy -Text "<h1>Hello World</h1>" -Algorithm GZip -AsByteStream)
)

 