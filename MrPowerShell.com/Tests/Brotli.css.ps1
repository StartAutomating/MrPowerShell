#requires -Module Zippy

".big { font-size: 2rem; }"

[IO.File]::WriteAllBytes(
    "$psScriptRoot/Brotli.css.br",
    (Compress-Zippy -Text ".big { font-size: 2rem; }" -Algorithm Brotli -AsByteStream)
)

[IO.File]::WriteAllBytes(
    "$psScriptRoot/Brotli.html.br",
    (Compress-Zippy -Text "<h1>Hello World</h1>" -Algorithm Brotli -AsByteStream)
)

 