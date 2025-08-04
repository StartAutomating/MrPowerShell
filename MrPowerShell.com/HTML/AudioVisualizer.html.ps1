#requires -Module Turtle 

if (-not $Page) {
    $Page = [Ordered]@{}
}

$title = "Audio Visualizer"

$description = "A simple audio visualizer using the Web Audio API, made with PowerShell."

if ($Page) {
    $page.Title = $title
    $Page.Description = $description
    $Page.Image = "https://MrPowerShell.com/HTML/AudioVisualizer.png"
    $page.Background = 
        turtle SierpinskiTriangle 10 4 | 
        Set-Turtle PatternTransform @{
            scale = 1
        } | 
        Set-Turtle PatternAnimation ([Ordered]@{
            type = 'scale'    ; values = 0.66,0.33, 0.66 ; repeatCount = 'indefinite' ;dur = "23s"; additive = 'sum';id ='scale-pattern'
        }, [Ordered]@{
            type = 'rotate'   ; values = 0, 360 ;repeatCount = 'indefinite'; dur = "41s"; additive = 'sum'; id ='rotate-pattern'
        }) |
        Set-Turtle StrokeWidth '0.1%' |
        Select-Object -expand Pattern
}

$setPalette = "
<script>
    function SetPalette() {
        var palette = document.getElementById('palette')
        if (! palette) {
            palette = document.createElement('link')
            palette.rel = 'stylesheet'
            palette.id = 'palette'
            document.head.appendChild(palette)
        }
        var selectedPalette = document.getElementById('SelectPalette').value
        palette.href = 'https://cdn.jsdelivr.net/gh/2bitdesigns/4bitcss@latest/css/' + selectedPalette + '.css'
    }
</script>
"

$randomPalette = @"
<script>
function SetRandomPalette() {
    var SelectPalette = document.getElementById('SelectPalette')
    var randomNumber = Math.floor(Math.random() * SelectPalette.length);
    SelectPalette.selectedIndex = randomNumber
    SetPalette()
}
</script>
"@

$randomColor = @"
<script>
function SetRandomColor() {
    var SelectColor = document.getElementById('SelectColor')
    if (!SelectColor) { return }
    var randomNumber = Math.floor(Math.random() * SelectColor.length)
    SelectColor.selectedIndex = randomNumber
}
</script>
"@

$savePng = @"
<script>
function SavePNG(elementId) {
    var canvas = document.getElementById(elementId)
    var dataURL = canvas.toDataURL('image/png')
    var a = document.createElement('a')
    a.href = dataURL
    a.download = ```${elementId}.png``
    a.click()
    console.log('Saved PNG')
}
</script>
"@

$OnResize = '
<script>
function Resize() {    
    var visuals = document.getElementById("visuals")    
    var powerShellCode = document.getElementById("PowerShellCode")
    if (window.innerWidth) {        
        //visuals.width = window.innerWidth
        //visuals.height = window.innerHeight * 0.7
        powerShellCode.style.top = window.innerHeight
    } else {
        //visuals.width = screen.width
        //visuals.height = screen.height * 0.7
        powerShellCode.style.top = screen.height            
    }
        
    console.log(`Resized ${screen.width}x${screen.height}`)
}
window.addEventListener("resize", function() {
    Resize()
})
Resize()
let backgroundSvg = document.getElementById("background-svg")
// backgroundSvg.setAttribute("opacity", 0.25)
</script>
'

$paletteSelector = @"
<select id='SelectPalette' onchange='SetPalette()'>
$(foreach ($paletteName in (Invoke-RestMethod https://4bitcss.com/Palette-List.json)) {
    "<option value='$([Web.HttpUtility]::HtmlAttributeEncode($paletteName))'>$([Web.HttpUtility]::HtmlEncode($paletteName))</option>"
})
</select>
"@

$colorSelector = @"
<select id='SelectColor' selected='foreground'>
$(foreach ($colorName in 'foreground','red','green','blue','yellow','purple','cyan','brightBlue','brightRed','brightGreen','brightYellow','brightPurple','brightCyan') {
    "<option value='--$colorName'>$colorName</option>"    
})
</select>
"@


$setPalette
$randomPalette
$randomColor
$savePng

$html = @"
<style>
.controlsGrid {
    display: grid; 
    gap: .42%;
    text-align: center;    
    width:100vw;
    height:100vh;
    vertical-align: middle;
    grid-template-columns: repeat(6, auto);
}
.visualsGrid {
    position: absolute;
    z-index: -1;
    top: 0;
    left: 0;
    display: grid;
    width: 100vw;
    height: 100vh;
}


.innerGrid {
    display: grid;
    vertical-align: middle;
    grid-template-columns: repeat(5, auto);
}
#visuals {
    width: 100vh;    
}
#PowerShellCode {
    top: 100vh;
    width: 100vw;
}
</style>
<!-- Generated with PSSVG 0.2.10 <https://github.com/StartAutomating/PSSVG> -->
<svg width='0%' height='0%' xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <filter id="colorWheel">
      <feColorMatrix type="hueRotate">
          <animate attributeName="values" values="0; 360" dur=".42s" repeatCount="indefinite" />
      </feColorMatrix>
      <feMorphology operator="dilate" radius="1" result="dilated">
        <animate attributeName="radius" values="0;42;0" dur="0.42s" repeatCount="indefinite"/>
      </feMorphology>
      <feMorphology operator="erode" radius="1" result="eroded">
        <animate attributeName="radius" values="0;42;0" dur="0.42s" repeatCount="indefinite"/>
      </feMorphology>      
      <feBlend mode="exclusion" in="SourceGraphic" in2="eroded" result="blendedEroded">        
        <animate attributeName="mode" values="screen;overlay;screen" dur="0.42s" repeatCount="indefinite"/>
      </feBlend>
      <feBlend mode="exclusion" in2="eroded" in="blendedEroded" />
  </filter>
  <filter id='erode'>
    <feMorphology in="SourceGraphic" operator="erode" radius="1" result="eroded">
        <animate attributeName="radius" values="1;3;1" dur="0.42s" repeatCount="indefinite"/>
    </feMorphology>
  </filter>
  <filter id='blur'>
    <feGaussianBlur in="SourceGraphic" stdDeviation="2" result="blur" />    
        <animate attributeName="stdDeviation" values="1;2;1" dur="0.42s" repeatCount="indefinite"/>
    </feGaussianBlur>
  </filter>
  </defs>
</svg>
<style>
// .colorWheel { filter: url('#colorWheel'); }
canvas { filter: url('#blur'); }
</style>
<div class='visualsGrid'>
    <canvas id='visuals'></canvas>
</div>
<div class='controlsGrid'>
    <div>
        <input type="file" id="audioFile" multiple="true" />
        <br />
        <audio controls="true" autoplay="true" id="audio"></audio>
    </div>
    <div>
        <div class='innerGrid'>
            <div>
                Palette:
                $paletteSelector
            </div>
            <div>
                <button id="SetRandomPalette" onclick="SetRandomPalette()">Random Palette</button>
            </div>
            <div>
                <button id="SetRandomColor" onclick="SetRandomColor()">Random Color</button>
            </div>
            <div>
                Color:
                $colorSelector
            </div>
        </div>        
    </div>    
    <div>
        
    </div>
    <div>
        <input type="checkbox" id="showScope" checked="true" />
        <label for="showScope">Show Oscilloscope</label>
    </div>
    <div>
        <input type="checkbox" id="showBars" checked="true" />
        <label for="showBars">Show Bars</label>        
    </div>
    <div>
        <button id="SavePNG" onclick="SavePNG('visuals')">Save PNG</button>
    </div>
</div>

<script>
var audio = document.getElementById('audio');
var audioLoader = document.getElementById('audioFile');
var playlistFiles = []
var playlistIndex = 0;
audioLoader.addEventListener('change', (e) => {
    var reader = new FileReader();
    reader.onload = (event) => { audio.src = event.target.result }
    for (var i = 0; i < e.target.files.length; i++) {
        playlistFiles.push(e.target.files[i])
    }
    playlistIndex = 0;
    reader.readAsDataURL(e.target.files[playlistIndex])
}, false);

audio.addEventListener('playing', (e) => {ShowVisualizer();}, false);
audio.addEventListener('ended', (e) => {
    if (playlistIndex < playlistFiles.length - 1) {
        var reader = new FileReader();
        reader.onload = (event) => {
            audio.src = event.target.result;
            audio.play();
        }
        playlistIndex++;
        reader.readAsDataURL(playlistFiles[playlistIndex])        
    }        
}, false);


// Get a canvas defined with ID "visuals"
const visualsCanvas = document.getElementById("visuals");
const visualsCanvas2d = visualsCanvas.getContext("2d");
const volumeHistory = [];


async function ShowVisualizer() {
    const audioCtx = new (window.AudioContext || window.webkitAudioContext)();
    const analyser = audioCtx.createAnalyser();
    analyser.fftSize = 2048;
    const barsAnalyzer = audioCtx.createAnalyser();
    barsAnalyzer.fftSize = 512;
    const bufferLength = analyser.frequencyBinCount;
    const barsBufferLength = barsAnalyzer.frequencyBinCount;
    const dataArray = new Uint8Array(bufferLength);
    const frequencyArray = new Uint8Array(barsBufferLength);
    
    // For the color bar analyzer we want a average of a few frequencies    
    const colorSelector = document.getElementById('SelectColor')
    const colorBarAnalyzer = audioCtx.createAnalyser();
    // so we want use a smaller fftSize
    colorBarAnalyzer.fftSize = 32;
    const colorArray = new Uint8Array(colorBarAnalyzer.frequencyBinCount);     

    source = audioCtx.createMediaElementSource(document.getElementById("audio"));
    // Connect the source to be analysed
    source.connect(analyser);
    source.connect(barsAnalyzer);
    analyser.connect(audioCtx.destination);


    function measure() {
        let totalVolume = 0.0
        let totalFrequency = 0.0
        let totalLow = 0.0
        let totalMid = 0.0
        let totalHigh = 0.0
        for (let frequencyIndex = 0; frequencyIndex < frequencyArray.length; frequencyIndex++) {
            const frequencyValue = frequencyArray[frequencyIndex];
            totalVolume += frequencyValue;
            if (frequencyIndex < (frequencyArray.length / 3)) {
                // low frequencies
                totalLow += frequencyValue;
            } else if (frequencyIndex < (2 * (frequencyArray.length / 3))) {
                // mid frequencies
                totalMid += frequencyValue;
            } else {
                // high frequencies
                totalHigh += frequencyValue;
            }    
        }
        const averageVolume = (totalVolume / frequencyArray.length) / 255.0;
        const averageLow = (totalLow / (frequencyArray.length / 3)) / 255.0;
        const averageMid = (totalMid / (frequencyArray.length / 3)) / 255.0;
        const averageHigh = (totalHigh / (frequencyArray.length / 3))  / 255.0;
        
        for (let sampleIndex = 0; sampleIndex < dataArray.length; sampleIndex++) {
            const sampleValue = dataArray[sampleIndex];
            totalFrequency += sampleValue;
        }

        const averageFrequency = (totalFrequency / dataArray.length) / 255.0;

        return {
            average: {
                volume: averageVolume,
                frequency: averageFrequency,
                low: averageLow,
                mid: averageMid,
                high: averageHigh
            }
        }
    }


    // draw an oscilloscope of the current audio source
    function draw() {
        requestAnimationFrame(draw);

        analyser.getByteTimeDomainData(dataArray);
        barsAnalyzer.getByteFrequencyData(frequencyArray);

        const info = measure();

        let backgroundSVG = document.getElementById("background-svg")
        if (backgroundSVG) {
            backgroundSVG.setAttribute("opacity", info.average.volume);
        }
        let scalePattern = document.getElementById("scale-pattern")
        if (scalePattern) {
            scalePattern.setAttribute("values", 1 - info.average.volume);
        }
        let rotatePattern = document.getElementById("rotate-pattern")
        if (rotatePattern) {
            rotatePattern.setAttribute("values", (info.average.frequency * 360).toString());
        }
        
        /*
        // We are going to turn the frequency array into colors
        // Lower notes become red
        // Middle notes become green
        // higher notes become blue    
        const rgbTotals = {red: 0, green: 0, blue: 0};
        const rgbCounts = {red: 0, green: 0, blue: 0};
        const rgbPeaks = {red: 0, green: 0, blue: 0};
        const nonZeroColor = []
        for (let colorIndex = 0; colorIndex < frequencyArray.length; colorIndex++) {
            if (frequencyArray[colorIndex] > 25) {
                nonZeroColor.push(frequencyArray[colorIndex])
            }            
        }
        for (let colorIndex2 = 0; colorIndex2 < nonZeroColor.length; colorIndex2++) {
            const colorValue = nonZeroColor[colorIndex2];
            if (colorIndex2 < (nonZeroColor.length / 3)) {
                // red
                rgbTotals.red += nonZeroColor[colorIndex2];
                rgbCounts.red++;
                rgbPeaks.red = Math.max(rgbPeaks.red, nonZeroColor[colorIndex2]);
            } else if (colorIndex2 < (2 * (nonZeroColor.length / 3))) {
                // green
                rgbTotals.green += nonZeroColor[colorIndex2];
                rgbCounts.green++;
                rgbPeaks.green = Math.max(rgbPeaks.green, nonZeroColor[colorIndex2]);
            } else {
                // blue
                rgbTotals.blue += nonZeroColor[colorIndex2];
                rgbCounts.blue++;
                rgbPeaks.blue = Math.max(rgbPeaks.blue, nonZeroColor[colorIndex2]);
            }
        }
       
        const notePercent = {}
        notePercent['red'] = 1 - (rgbTotals.red / rgbCounts.red);
        notePercent['green'] = 1 - (rgbTotals.green / rgbCounts.green);
        notePercent['blue'] = 1 - (rgbTotals.blue / rgbCounts.blue);

        const noteRGB = {}
        noteRGB['red'] = Math.floor(rgbPeaks.red * 1.1);
        noteRGB['green'] = Math.floor(rgbPeaks.green * 1.2);
        noteRGB['blue'] = Math.floor(rgbPeaks.blue * 1.3);
        if (noteRGB['red'] > 255) {
            noteRGB['red'] = 255
        }
        if (noteRGB['green'] > 255) {
            noteRGB['green'] = 255
        }
        if (noteRGB['blue'] > 255) {
            noteRGB['blue'] = 255
        }
        noteRGB['color'] = ``#`${noteRGB.red.toString(16).padStart(2, '0')}`${noteRGB.green.toString(16).padStart(2, '0')}`${noteRGB.blue.toString(16).padStart(2, '0')}``;
        */

        let backgroundColor = getComputedStyle(visualsCanvas).getPropertyValue('--background')
        if (backgroundColor == '') {
            backgroundColor = '#FFFFFF'
        }

        let foregroundColor = getComputedStyle(visualsCanvas).getPropertyValue(colorSelector.value)
        if (foregroundColor == '') {
            foregroundColor = noteRGB['color']
        }
        
        visualsCanvas.width = window.innerWidth
        visualsCanvas.height = window.innerHeight
        visualsCanvas.style.width = "100%"
        visualsCanvas.style['margin-left'] = "0%"
        const visualsWidth = window.innerWidth
        const visualsHeight = window.innerHeight
    
        visualsCanvas2d.fillStyle = backgroundColor
        visualsCanvas2d.clearRect(0, 0, visualsWidth, visualsHeight)

        visualsCanvas2d.lineWidth = info.average.volume * 7;
        visualsCanvas2d.strokeStyle = foregroundColor;
        let x = 0;
        if (document.getElementById('showScope').checked) {
            visualsCanvas2d.beginPath();
            const sliceWidth = (visualsWidth * 1.0) / bufferLength;                        
            x = 0;
            for (let i = 0; i < bufferLength; i++) {
                const v = dataArray[i] / 128.0;
                const y = (v * visualsHeight) / 2;

                if (i === 0) {
                    visualsCanvas2d.moveTo(x, y);
                } else {
                    visualsCanvas2d.lineTo(x, y);
                }

                x += sliceWidth;
            }
        
            visualsCanvas2d.lineTo(visualsWidth, visualsHeight / 2);
            visualsCanvas2d.stroke();    
        }

        /*
        Radial Oscilloscope
        */
        
            const centerX = visualsWidth / 2;
            const centerY = visualsHeight / 2;
            const radius = Math.min(centerX, centerY) * info.average.volume;
            const angleStep = (Math.PI * 2) / bufferLength;

            for (let i = 0; i < bufferLength; i++) {
                const v = dataArray[i] / 128.0;
                const x = centerX + Math.cos(angleStep * i) * radius * v;
                const y = centerY + Math.sin(angleStep * i) * radius * v;
                if (i === 0) {
                    visualsCanvas2d.moveTo(x, y);
                } else {
                    visualsCanvas2d.lineTo(x, y);
                }                
            }

            visualsCanvas2d.stroke();
        

        if (document.getElementById('showBars').checked) {
            x = 0;
            const barWidth = (visualsWidth * 1.0) / barsBufferLength;
            let barHeight = 0;
            for (let i = 0; i < barsBufferLength; i++) {
                barHeight = frequencyArray[i] / 2;
                visualsCanvas2d.fillStyle = foregroundColor;
                visualsCanvas2d.fillRect(x, visualsHeight - barHeight / 2, barWidth, barHeight);
                x += barWidth + 1;
            }    
        }
    }
    draw();
}
</script>
"@
$html
"<div id='PowerShellCode'>"
"<pre><code class='language-PowerShell'>"
[Web.HttpUtility]::HtmlEncode($MyInvocation.MyCommand.ScriptBlock)
"</code></pre>"
"</div>"
$OnResize