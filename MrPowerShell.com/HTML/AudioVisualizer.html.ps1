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
    <#$page.Background = 
        # turtle SierpinskiArrowheadCurve 15 4 |
        # turtle KochIsland 5 4 |
        # turtle Flower 30 (360/12) 18 |
        # turtle Flower 30 (360/8) 8 |
        # turtle Flower 30 (360/10) 12 |
        # turtle Flower 25 8 16 72 |
        turtle Flower 30 60 6 | 
        Set-Turtle PatternTransform @{
            scale = 1
        } | 
        Set-Turtle PatternAnimation ([Ordered]@{
            type = 'scale'    ; values = 0.66,0.33, 0.66 ; repeatCount = 'indefinite' ;dur = "23s"; additive = 'sum';id ='scale-pattern'
        }, [Ordered]@{
            type = 'rotate'   ; values = 0, 360 ;repeatCount = 'indefinite'; dur = "41s"; additive = 'sum'; id ='rotate-pattern'
        }, [Ordered]@{
            type = 'translate'   ; values = "0 0;"; dur = "41s"; additive = 'sum'; id ='translate-pattern'
        }) |
        Set-Turtle StrokeWidth '0.1%' |
        Select-Object -expand Pattern #>
}

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
</script>
'

$colorSelector = @"
<select id='SelectColor' selected='foreground'>
$(foreach ($colorName in 'foreground','red','green','blue','yellow','purple','cyan','brightBlue','brightRed','brightGreen','brightYellow','brightPurple','brightCyan') {
    "<option value='--$colorName'>$colorName</option>"    
})
</select>
"@

$randomPalette
$randomColor
$savePng

$html = @"
<style>
.controlsGrid {
    display: grid; 
    gap: .42%;
    padding: 1em;
    text-align: center;    
    width:100vw;
    height:100vh;
    vertical-align: middle;
    margin: 1em;
    grid-template-areas: "left-controls . . right-controls";    
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

.grid-left {
    grid-area: left-controls;
}
.grid-right { 
    grid-area: right-controls;
}
.grid-right select, options, button, div {
    width: 100%;    
}
.grid-middle {
    grid-area: middle;
}

.innerGrid {
    display: grid;
    vertical-align: middle;
    width: 100%;
    grid-template-columns: 1fr;
}
#visuals {
    width: 100vh;
    position: fixed;
    top: 0;
    left: 0;
    z-index: -10;
}
    
#PowerShellCode {
    top: 100vh;
    width: 100vw;
}

pre { text-align: left }
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
  <filter id='erodeFilter'>
    <feMorphology in="SourceGraphic" operator="erode" radius="1" result="eroded">
        <animate attributeName="radius" values="0;1;0" dur="4.2s" repeatCount="indefinite"/>
    </feMorphology>
  </filter>
  <filter id='dilateFilter'>
    <feMorphology in="SourceGraphic" operator="dilate" radius="1" result="dilated">
        <animate attributeName="radius" values="1;8;1" dur="4.2s" repeatCount="indefinite"/>
    </feMorphology>
  </filter>  
  <filter id='blurFilter'>
    <feGaussianBlur in="SourceGraphic" stdDeviation="0.5" result="blur" />    
        <animate id='blurFilterAnimation' attributeName="stdDeviation" values="0;1;0" dur="0.42s" repeatCount="indefinite"/>
    </feGaussianBlur>
  </filter>
  <filter id='hueRotate'>
    <feColorMatrix in="SourceGraphic" type="hueRotate" values="180">
        <animate attributeName="values" values="0;360" dur="0.42s" repeatCount="indefinite"/>
    </feColorMatrix>
  </filter>
  </defs>
</svg>
<style>
// .colorWheel { filter: url('#colorWheel'); }
// canvas { filter: url('#blurFilter'); }
// #background-svg { filter: url('#blurFilter') }
</style>
<div class='visualsGrid'>
    <canvas id='visuals'></canvas>
</div>
<div class='controlsGrid'>
    <div class='grid-left'>    
        <input type="file" id="audioFile" multiple="true" />
        
        <br/>
        <!--
            <input id='audioUrl' type="url" id="audioUrl" />
            <label for='audioUrl'>Audio Url</label>
            <br />
        -->
        <audio controls="true" autoplay="true" id="audio">
            <!-- <source src='http://knhc-ice.streamguys1.com/live' type='audio/mpeg' /> -->
            <!-- <source src='https://kjzz.streamguys1.com/kbaq_mp3_128' type='audio/mpeg' /> -->
        </audio>
    </div>
    <div class='grid-right'>
        <div>        
        <details>
        <summary>Options</summary>
        <div class='innerGrid'>
            <div>                
                $(
                    if ($site.Includes.SelectPalette) {                        
                        . $site.Includes.SelectPalette
                    }                    
                )
            </div>
            <div>
                <button id="SetRandomPalette" onclick="SetRandomPalette()">Random Palette</button>
            </div>
            <div>
                <button id="SetRandomColor" onclick="SetRandomColor()">Random Color</button>
            </div>
            <div>

                $colorSelector
            </div>
            <!--
            -->
            <div>                
                <input type="checkbox" id="autoColor" />
                <label for="autoColor">Auto Color</label>
            </div>

            <div>
                <input type="checkbox" id="showCustomColor" />
                <label for="showCustomColor">Custom Color</label>
            </div>
            <div>
                <input type="color" id="customColor" />                
            </div>

            <div>
                <input type="checkbox" id="showScope" checked="true" />
                <label for="showScope">Show Oscilloscope</label>
            </div>
            <div>
                <input type="checkbox" id="showRadialScope" checked="true" />
                <label for="showRadialScope">Show Radial Oscilloscope</label>
            </div>            
            <div>
                <input type="checkbox" id="showBars" checked="true" />
                <label for="showBars">Show Bars</label>
            </div>    
        </div>        
        <div>
            <button id="SavePNG" onclick="SavePNG('visuals')">Save PNG</button>
        </div>
        </div>
        </details>
        <details>
            <summary>View Source</summary>
            <div id='PowerShellCode'>
                <pre>
                    <code class='language-PowerShell'>
$([Web.HttpUtility]::HtmlEncode($MyInvocation.MyCommand.ScriptBlock))
                    </code>
                </pre>
            </div>
        </details>
        </div>
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
const translateDistance = {x:0.0, y:0.0, r: 0.0 };


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
        let lowCount = 1
        let midCount = 1
        let highCount = 1
        const nonZero = []
        const levels = {
            all: [],
            low: [],
            mid: [],
            high: [],
            nonZero: []
        }
        
        const scopeLine = []
        for (let frequencyIndex = 0; frequencyIndex < frequencyArray.length; frequencyIndex++) {            
            const frequencyValue = frequencyArray[frequencyIndex];
            const frequencyRatio = frequencyValue/255.0
            levels.all.push(frequencyRatio)
            if (frequencyValue > 0 ) { levels.nonZero.push(frequencyRatio) }
            totalVolume += frequencyValue;
            if (frequencyValue > 0 && frequencyIndex < (frequencyArray.length / 3)) {
                // low frequencies
                levels.low.push(frequencyRatio)
                totalLow += frequencyValue;
                lowCount++
            } else if (frequencyValue > 0 && frequencyIndex < (2 * (frequencyArray.length / 3))) {
                // mid frequencies
                levels.mid.push(frequencyRatio)
                totalMid += frequencyValue;                
                midCount++
            } else if (frequencyValue > 0) {
                // high frequencies
                levels.mid.push(frequencyRatio)
                totalHigh += frequencyValue;
                highCount++
            }    
        }
        
        const averageVolume = (totalVolume / frequencyArray.length) / 255.0;
        const averageLow = (totalLow / lowCount) / 255.0;
        const averageMid = (totalMid / midCount) / 255.0;
        const averageHigh = (totalHigh / highCount)  / 255.0;
          
        
        for (let sampleIndex = 0; sampleIndex < dataArray.length; sampleIndex++) {            
            const sampleValue = dataArray[sampleIndex];            
            scopeLine.push(sampleValue/128.0)
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
            },
            levels: levels,
            scope: scopeLine            
        }
    }


    // draw an oscilloscope of the current audio source
    function draw() {
        requestAnimationFrame(draw);

        analyser.getByteTimeDomainData(dataArray);
        barsAnalyzer.getByteFrequencyData(frequencyArray);

        const info = measure();
        const levels = info.levels;
        
        let turtlePattern = document.getElementById("turtle-pattern")
        

        if (turtlePattern) {
            translateDistance.x = (info.average.volume * 23) + (info.average.frequency) * 42; // audio.currentTime/audio.duration * 1024;
            translateDistance.y = (info.average.volume * 23) + (info.average.frequency - 0.5) * 42; // audio.currentTime/audio.duration * -512; // // (info.average.volume * - 4.2);
            translateDistance.r = ( (info.average.frequency - 0.5) * 180)
            if (info.average.volume > 0) {
                let scaleX = info.average.volume + (info.average.low*1.6)/(info.average.frequency)
                let scaleY = info.average.volume + (info.average.low*0.4+info.average.mid*0.8+info.average.high*1.5)/(info.average.frequency)
                turtlePattern.setAttribute("patternTransform", ``
                    translate(`${translateDistance.x} `${translateDistance.y})
                    
                    scale(`${scaleX} `${scaleY}`)
                ``);
            }
            
        }

        let rotatePattern = document.getElementById("rotate-pattern")
        if (rotatePattern) {            
            rotatePattern.setAttribute('values', (audio.currentTime/60 * 360 * 33) - (info.average.volume * 30) - translateDistance.r)
        }
       
        const notePercent = {}
        notePercent['red'] = info.average.low;
        notePercent['green'] = info.average.mid;
        notePercent['blue'] = info.average.high;

        const noteRGB = {}

        let baseColor = getComputedStyle(visualsCanvas).getPropertyValue(colorSelector.value);

        noteRGB['red'] = Math.floor(Math.min(info.average.volume + (info.average.low * 1.5) * 255, 255));
        noteRGB['green'] = Math.floor(Math.min(info.average.volume + (info.average.mid * 2.1) * 255, 255));
        noteRGB['blue'] = Math.floor(Math.min(info.average.volume + (info.average.high * 1.6) * 255, 255));
        noteRGB['color'] = ``#`${noteRGB.red.toString(16).padStart(2, '0')}`${noteRGB.green.toString(16).padStart(2, '0')}`${noteRGB.blue.toString(16).padStart(2, '0')}``;


        let backgroundColor = getComputedStyle(visualsCanvas).getPropertyValue('--background')
        if (backgroundColor == '') {
            backgroundColor = '#FFFFFF'
        }
        
        let turtlePath = document.getElementById("turtle-path")
        if (turtlePath) {
            turtlePath.setAttribute("opacity", (info.average.volume + info.average.low)/2);
        }

        // getComputedStyle(document).setPropertyValue('--foreground',noteRGB['color'])
        let foregroundColor = ''
        if (document.getElementById('autoColor').checked) {
            foregroundColor = noteRGB['color']
            if (turtlePath) {                
                turtlePath.style.setProperty('--foreground', foregroundColor)
            }            
        }
        else if (document.getElementById('showCustomColor').checked) {
            foregroundColor = document.getElementById('customColor').value
            if (turtlePath) {                
                turtlePath.style.setProperty('--foreground', foregroundColor)
            }
        }
        else {
            foregroundColor = getComputedStyle(visualsCanvas).getPropertyValue(colorSelector.value)
            if (turtlePath) {
                turtlePath.style.setProperty('--foreground', foregroundColor)
            }
        }
       
        visualsCanvas.width = window.innerWidth
        visualsCanvas.height = window.innerHeight
        visualsCanvas.style.width = "100%"
        visualsCanvas.style['margin-left'] = "0%"
        const visualsWidth = window.innerWidth
        const visualsHeight = window.innerHeight
    
        visualsCanvas2d.fillStyle = backgroundColor
        visualsCanvas2d.clearRect(0, 0, visualsWidth, visualsHeight)

        visualsCanvas2d.lineWidth = info.average.low * 4.2;
        visualsCanvas2d.strokeStyle = foregroundColor;
        let x = 0;
        
        if (document.getElementById('showScope').checked) {
            visualsCanvas2d.beginPath();
            const sliceWidth = (visualsWidth * 1.0) / info.scope.length;
            x = 0;
            for (let i = 0; i < info.scope.length; i++) {
                const v = info.scope[i];
                const y = v * (visualsHeight / 2);

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

        if (document.getElementById('showRadialScope').checked) {
            /*
            Radial Oscilloscope
            */
        
            const centerX = visualsWidth / 2;
            const centerY = visualsHeight / 2;
            const radius = Math.min(centerX, centerY) * 0.66 * info.average.volume;
            const angleStep = (Math.PI * 2) / (bufferLength - 1);
            
            for (let i = 0; i < info.scope.length; i++) {
                const v = info.scope[i];
                const x = centerX + Math.cos(angleStep * i) * radius * v;
                const y = centerY + Math.sin(angleStep * i) * radius * v;                
                if (i === 0) {            
                    visualsCanvas2d.moveTo(x, y);
                } else {
                    visualsCanvas2d.lineTo(x, y);
                }
            }

            visualsCanvas2d.stroke();
        }
                
        if (document.getElementById('showBars').checked) {
            x = 0;            
            const gapWidth = 3
            const barLevels = levels.nonZero
            let barWidth = ((visualsWidth * 1.0) / barLevels.length) - gapWidth
            let barHeight = 0;
            for (let i = 0; i < barLevels.length; i++) {
                barHeight = barLevels[i] * visualsHeight * 1/8;
                visualsCanvas2d.fillStyle = foregroundColor;
                visualsCanvas2d.fillRect(x, visualsHeight - barHeight, barWidth, barHeight);
                x += barWidth + gapWidth;
            }                        
        }
    }
    draw();
}
</script>
"@
$html


"<details>"
"<summary>View Source</summary>"
"<div id='PowerShellCode'>"
"<pre><code class='language-PowerShell'>"
[Web.HttpUtility]::HtmlEncode($MyInvocation.MyCommand.ScriptBlock)
"</code></pre>"
"</div>"
"</details>"
$OnResize