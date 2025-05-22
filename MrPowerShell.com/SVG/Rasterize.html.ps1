param(
    $VectorImage,
    [int]$Width = 1080,
    [int]$Height = 1080
)

if ($PSScriptRoot) { Push-Location $PSScriptRoot}

$rasterizer = @'
<script>
    const dataHeader = 'data:image/svg+xml;charset=utf-8'
    const $svg = document.getElementById('svg-container').querySelector('svg')
    const imageContainer = document.getElementById('img-container')
    const imageFormatLabel = document.getElementById('img-format')

    const destroyChildren = svgElement => {
        while (svgElement.firstChild) {
            const lastChild = svgElement.lastChild ?? false
            if (lastChild) svgElement.removeChild(lastChild)
        }
    }

const loadImage = async url => {
  const newImage = document.createElement('img')
  newImage.src = url
  return new Promise((resolve, reject) => {
    newImage.onload = () => resolve(newImage)
    newImage.onerror = reject
  })
}

const serializeAsXML = e => (new XMLSerializer()).serializeToString(e)

const encodeAsUTF8 = s => `${dataHeader},${encodeURIComponent(s)}`
const encodeAsB64 = s => `${dataHeader};base64,${btoa(s)}`

const ConvertFromSVG = async e => {
  const button = e.target
  const format = button.dataset.format ?? 'png'
  imageFormatLabel.textContent = format
  
  destroyChildren(imageContainer)

  const svgData = encodeAsUTF8(serializeAsXML($svg))

  const img = await loadImage(svgData)
  
  const rasterizeCanvas = document.createElement('canvas')
  rasterizeCanvas.width = $svg.clientWidth
  rasterizeCanvas.height = $svg.clientHeight
  rasterizeCanvas.getContext('2d').drawImage(img, 0, 0, $svg.clientWidth, $svg.clientHeight)
  
  const dataURL = await rasterizeCanvas.toDataURL(`image/${format}`, 1.0)
  console.log(dataURL)
  
  const newImage = document.createElement('img')
  newImage.src = dataURL
  imageContainer.appendChild(newImage)
}

const buttons = [...document.querySelectorAll('[data-format]')]
for (const button of buttons) {
  button.onclick = ConvertFromSVG
}
document.getElementById('btn-png').click()
</script>
'@

$style = @'
<style>
.wrapper {
  display: flex;
  flex-flow: row nowrap;
  width: 100vw;
}

.images {
  display: flex;
  flex-flow: row nowrap;
  width: 70%;
}

.image {
  width: 50%;
  display: flex;
  flex-flow: row wrap;
  justify-content: center;
}

.label {
  width: 100%;
  text-align: center;
}
</style>
'@

$content = @"
<div class="wrapper">
  <div class="item images">
    <div class="image left">
      <div class="label">svg</div>
      <div id="svg-container">
        <svg xmlns="http://www.w3.org/2000/svg" xml:space="preserve" width="$Width" height="$Height">
$(
if ($VectorImage) {
    if ($VectorImage -is [xml]) {
        $VectorImage.OuterXml
    } elseif ($vectorImage -is [IO.FileInfo]) {
        $VectorImage.FullName | Get-Content -Raw
    } else {
        $VectorImage
    }
} else {
    $((Get-Content .\Butterfly.svg -Raw)) 
}
)
</svg>
      </div>
    </div>
    <div class="image right">
      <div id="img-format" class="label"></div>
      <div id="img-container"></div>
    </div>
  </div>
  <div class="item buttons">
    <button id="btn-bmp" data-format="bmp">bmp</button>
    <button id="btn-png" data-format="png">png</button>
    <button id="btn-jpg" data-format="jpeg">jpg</button>
    <button id="btn-webp" data-format="webp">webp</button>
  </div>
</div>
"@

$style
$content
$rasterizer

if ($PSScriptRoot) { Pop-Location }