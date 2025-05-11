$title = "Audio Visualizer"
$description = "A simple audio visualizer using the Web Audio API, made with PowerShell."
if ($Page) {
    $Page.Image = "https://MrPowerShell.com/HTML/AudioVisualizer.png"
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
    var randomNumber = Math.floor(Math.random() * SelectColor.length);
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
    if (window.innerWidth) {        
        visuals.width = window.innerWidth
        visuals.height = window.innerHeight * 0.7            
    } else {
        visuals.width = screen.width
        visuals.height = screen.height * 0.7            
    }    
    console.log(`Resized ${screen.width}x${screen.height}`)
}
window.addEventListener("resize", function() {
    Resize()
})
Resize()
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
    text-align:center
    width:100vw;
    height:100vh;
}
.innerGrid {
    display: grid;
    grid-template-columns: repeat(3, auto);
}
#visuals {
    width: 100vh;    
}
#PowerShellCode {
    top: 100vh;
    width: 100vw;
}
</style>
<div class='controlsGrid'>
    <div>
        <input type="file" id="audioFile" multiple="true" />
    </div>
    <div>
        <div class='innerGrid'>
            <div>
            Palette
            <br/>
            $paletteSelector
            </div>
            <div>
            </div>
            <div>
            Primary Color
            <br/>
            $colorSelector
            </div>
        </div>
        
    </div>
    <div>
        <button id="SetRandomPalette" onclick="SetRandomPalette()">Random Palette</button>
        <button id="SetRandomColor" onclick="SetRandomColor()">Random Color</button>
    </div>    
    <div>
        <audio controls="true" autoplay="true" id="audio"></audio>
    </div>
    <div>
        <input type="checkbox" id="showScope" checked="true" />
        <label for="showScope">Show Oscilloscope</label>        
        <input type="checkbox" id="showBars" checked="true" />
        <label for="showBars">Show Bars</label>        
    </div>
    <div>
        <button id="SavePNG" onclick="SavePNG('visuals')">Save PNG</button>
    </div>
    <div>
        <canvas id="visuals" width='1920' height='320'></canvas>
    </div>    
</div>

<script>
var audio = document.getElementById('audio');
var audioLoader = document.getElementById('audioFile');
var playlistFiles = []
var playlistIndex = 0;
audioLoader.addEventListener('change', (e) => {
    var reader = new FileReader();
    reader.onload = (event) => {
        audio.src = event.target.result;
    }
    
    for (var i = 0; i < e.target.files.length; i++) {
        playlistFiles.push(e.target.files[i])
    }
    playlistIndex = 0;
    reader.readAsDataURL(e.target.files[playlistIndex])
}, false);

audio.addEventListener('playing', (e) => {
    ShowOscilliscope();
}, false);
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


// Get a canvas defined with ID "oscilloscope"
const visualsCanvas = document.getElementById("visuals");
const visualsCanvas2d = visualsCanvas.getContext("2d");


async function ShowOscilliscope() {
    const audioCtx = new (window.AudioContext || window.webkitAudioContext)();
    const analyser = audioCtx.createAnalyser();
    analyser.fftSize = 2048;
    const barsAnalyzer = audioCtx.createAnalyser();    
    barsAnalyzer.fftSize = 512;
    const bufferLength = analyser.frequencyBinCount;
    const barsBufferLength = barsAnalyzer.frequencyBinCount;
    const dataArray = new Uint8Array(bufferLength);
    const frequencyArray = new Uint8Array(barsBufferLength);
    const colorSelector = document.getElementById('SelectColor')
    
    source = audioCtx.createMediaElementSource(document.getElementById("audio"));    
    // Connect the source to be analysed
    source.connect(analyser);
    source.connect(barsAnalyzer);
    analyser.connect(audioCtx.destination);
    // draw an oscilloscope of the current audio source
    function draw() {
        requestAnimationFrame(draw);

        analyser.getByteTimeDomainData(dataArray);
        barsAnalyzer.getByteFrequencyData(frequencyArray);

        let backgroundColor = getComputedStyle(visualsCanvas).getPropertyValue('--background')
        if (backgroundColor == '') {
            backgroundColor = '#FFFFFF'
        }

        let foregroundColor = getComputedStyle(visualsCanvas).getPropertyValue(colorSelector.value)
        if (foregroundColor == '') {
            foregroundColor = '#000000'
        }
        
        const visualsWidth = visualsCanvas.scrollWidth
        const visualsHeight = visualsCanvas.scrollHeight
    
        visualsCanvas2d.fillStyle = backgroundColor
        visualsCanvas2d.fillRect(0, 0, visualsWidth, visualsHeight)

        visualsCanvas2d.lineWidth = Math.random() + 1;
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
$OnResize
"<div id='PowerShellCode'>"
"<pre><code class='language-PowerShell'>"
[Web.HttpUtility]::HtmlEncode($MyInvocation.MyCommand.ScriptBlock)
"</code></pre>"
"</div>"