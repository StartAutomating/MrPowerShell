param(
    $VectorImage,
    [int]$Width = 512,
    [int]$Height = 512
)

if ($PSScriptRoot) { Push-Location $PSScriptRoot}

$rasterizer = @'
<script type='module'>
    const dataHeader = 'data:image/svg+xml;charset=utf-8'
    const defaultSvg = document.getElementById('svg-container').querySelector('svg')
    const imageContainer = document.getElementById('img-container')
    const imageFormatLabel = document.getElementById('img-format')
    const searchParameters = new URLSearchParams(window.location.search)

    const widthParameters = ["width", "Width", "W", "w"]
    const heightParameters = ["height", "Height", "H", "h"]
    const sourceParameters = ["Source", "source", "Src", "src", "S", "s"]
    
    for (const widthParameter of widthParameters) {
        if (searchParameters.has(widthParameter)) {
            defaultSvg.setAttribute('width', searchParameters.get(widthParameter))
        }
    }

    for (const heightParameter of heightParameters) {
        if (searchParameters.has(heightParameter)) {
            defaultSvg.setAttribute('height', searchParameters.get(heightParameter))
        }
    }

    for (const sourceParameter of sourceParameters) {
        if (searchParameters.has(sourceParameter)) {
            const response = await fetch(searchParameters.get(sourceParameter));
            const contentType = response.headers.get('content-type')
            if (!contentType || !contentType.includes('image/svg+xml')) {
                throw new TypeError `Expected SVG content, but got: ${contentType}`
            }
            defaultSvg.innerHTML = await response.text()
        }
    }

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

  const svgData = encodeAsUTF8(serializeAsXML(defaultSvg))

  const img = await loadImage(svgData)
  
  const rasterizeCanvas = document.createElement('canvas')
  rasterizeCanvas.width = defaultSvg.clientWidth
  rasterizeCanvas.height = defaultSvg.clientHeight
  rasterizeCanvas.getContext('2d').drawImage(img, 0, 0, defaultSvg.clientWidth, defaultSvg.clientHeight)
  
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
  text-align: center;
  margin-right: auto;
  margin-left: auto;
  width: 90%;
}

.buttons {
  display: flex;
  flex-flow: row wrap;
  justify-content: center;
  gap: 1em
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
        <svg xmlns="http://www.w3.org/2000/svg" id='svg' xml:space="preserve" width="$Width" height="$Height">
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
    $((Get-Content .\..\MrPowerShell.svg -Raw))
}
)
</svg>
      </div>
    </div>
    <div class="item buttons">
      <button id="btn-bmp" data-format="bmp">bmp</button>
      <button id="btn-png" data-format="png">png</button>
      <button id="btn-jpg" data-format="jpeg">jpg</button>
      <button id="btn-webp" data-format="webp">webp</button>
    </div>
    <div class="image right">
      <div id="img-format" class="label"></div>
      <div id="img-container"></div>
    </div>
  </div>  
</div>
"@

$style
$content
$rasterizer

if ($PSScriptRoot) { Pop-Location }