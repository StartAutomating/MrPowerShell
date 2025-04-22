$Random3dScene = @(
"let geometry = null"
"let material = null"
"let newshape = null"
"let shapes = []"
foreach ($n in 1..(Get-Random -Min 1 -Max 16)) {    
@"
geometry = $(
    switch ('Box', 'Sphere', 'Cylinder','Cone','Torus','TorusKnot','Ring' | Get-Random) {
        Box {
            "new THREE.BoxGeometry( $(Get-Random -Min 1 -Max 24), $(Get-Random -Min 1 -Max 24), $(Get-Random -Min 1 -Max 24) );"
        }
        Sphere {
            "new THREE.SphereGeometry( $(Get-Random -Min 1 -Max 24), $(Get-Random -Min 1 -Max 24), $(Get-Random -Min 1 -Max 24) );"
        }
        Cylinder {
            "new THREE.CylinderGeometry( $(Get-Random -Min 1 -Max 24), $(Get-Random -Min 1 -Max 24), $(Get-Random -Min 1 -Max 24), $(Get-Random -Min 3 -Max 12) );"
        }
        Cone {
            "new THREE.ConeGeometry( $(Get-Random -Min 1 -Max 24), $(Get-Random -Min 1 -Max 24), $(Get-Random -Min 3 -Max 12) );"
        }
        Torus {
            "new THREE.TorusGeometry( $(Get-Random -Min 1 -Max 24), $(Get-Random -Min 1 -Max 24), $(Get-Random -Min 3 -Max 12), $(Get-Random -Min 3 -Max 12) );"
        }
        TorusKnot {
            "new THREE.TorusKnotGeometry( $(Get-Random -Min 1 -Max 24), $(Get-Random -Min 1 -Max 24), $(Get-Random -Min 3 -Max 12), $(Get-Random -Min 3 -Max 12), $(Get-Random -Min 3 -Max 12)  );"
        }
        Ring {
            "new THREE.RingGeometry( $(Get-Random -Min 1 -Max 24), $(Get-Random -Min 1 -Max 24), $(Get-Random -Min 3 -Max 12) );"
        }
    }
)
material = $(
    switch ('MeshBasicMaterial', 'LineBasicMaterial', 'LineDashedMaterial' | Get-Random) {
        MeshBasicMaterial {
            "new THREE.MeshBasicMaterial( { color: 0x$("{0:x6}" -f (Get-Random -Max 0xffffff)), wireframe: $('true', 'false' | Get-Random) } );"
        }
        LineBasicMaterial {
            "new THREE.LineBasicMaterial( { color: 0x$("{0:x6}" -f (Get-Random -Max 0xffffff)), linewidth: $(Get-Random -Min 1 -Max 3) } );"
        }
        LineDashedMaterial {
            "new THREE.LineDashedMaterial( { color: 0x$("{0:x6}" -f (Get-Random -Max 0xffffff)), linewidth: $(Get-Random -Min 1 -Max 3), dashSize: $(Get-Random -Min 1 -Max 10) } );"
        }        
    }
)
newshape = new THREE.Mesh( geometry, material );
newshape.position.x = $(Get-Random -Min -100 -Max 100);
newshape.position.y = $(Get-Random -Min -100 -Max 100);
newshape.position.z = $(Get-Random -Min -100 -Max 100);
newshape.rotation.x = $(Get-Random -Min 0 -Max 180);
newshape.rotation.y = $(Get-Random -Min 0 -Max 180);
newshape.rotation.z = $(Get-Random -Min 0 -Max 180);
scene.add(newshape);
shapes.push(newshape);
"@
}
) -join [Environment]::NewLine

    $OrbitSpeed = (Get-Random -Min 1 -Max 100)*.01

    $Random3dControls = @(
"
let controls = new OrbitControls( camera, renderer.domElement );
controls.minDistance = $(Get-Random -Min 1 -Max 10);
controls.maxDistance = $(Get-Random -Min 1 -Max 10);
controls.autoRotate = true;
controls.autoRotateSpeed = $OrbitSpeed;
controls.listenToKeyEvents( window );
controls.enableDamping = true;
controls.addEventListener( 'change', renderer.render( scene, camera ) );
"
)

    $sceneAnimation = @(
@"
for (let i = 0; i < shapes.length; i++) {
    let cube = shapes[i];
    cube.rotation.x += $((Get-Random -Min 1 -Max 100) / 1000);
    cube.rotation.y += $((Get-Random -Min 1 -Max 100) / 1000);
}
"@
) -join [Environment]::NewLine

    $3dScene = @"
import * as THREE from 'three';
import { CSS3DRenderer, CSS3DObject } from 'three/addons/renderers/CSS3DRenderer.js';
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';
import { TrackballControls } from 'three/addons/controls/TrackballControls.js';

const scene = new THREE.Scene();
const camera = new THREE.PerspectiveCamera( 75, window.innerWidth / window.innerHeight, 0.1, 1000 );

$Random3dScene


$(
    if ($CssRenderer) {
        "
const renderer = new CSS3DRenderer();
document.getElementById( 'container-3d' ).appendChild( renderer.domElement );
"
    } else {
        "
const renderer = new THREE.WebGLRenderer({alpha: true});
renderer.setClearColor( 0xffffff, 0 );
renderer.setAnimationLoop( animate );
document.body.appendChild( renderer.domElement );
"
    }
    
)

renderer.setSize( window.innerWidth, window.innerHeight );

camera.position.z = $(Get-Random -Min 100 -Max 200);

window.addEventListener( 'resize', () => {
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();
    renderer.setSize( window.innerWidth, window.innerHeight );
    renderer.render( scene, camera );
} );

$Random3dControls

function animate() {
    $sceneAnimation
    
    renderer.render( scene, camera );
    
}
"@


    @"
<html lang='$(Get-Culture)'>
    <head>
        <meta charset="utf-8">
        <title>There is no route table</title>
        <style>body { margin: 0; }</style>
    </head>
    <script type="importmap">$(
        ConvertTo-JSON -InputObject ([Ordered]@{
            "imports" = [Ordered]@{
                "three" = "https://cdn.jsdelivr.net/npm/three@latest/build/three.module.js"
                "three/addons/" = "https://cdn.jsdelivr.net/npm/three@latest/examples/jsm/"
            }
        })
    )</script>
    </head>
    <body>
    <div id="container-3d"></div>
    <script type="module">$3dScene</script>
    </body>
"@