/*
 * UBC CPSC 314
 * Assignment 3 Template
 */
import { setup, createScene, createRayMarchingScene, loadGLTFAsync, loadOBJAsync } from './js/setup.js';
import * as THREE from './js/three.module.js';
import { SourceLoader } from './js/SourceLoader.js';
import { THREEx } from './js/KeyboardState.js';

// Setup the renderer
// You should look into js/setup.js to see what exactly is done here.
const { renderer, canvas } = setup();

/////////////////////////////////
//   YOUR WORK STARTS BELOW    //
/////////////////////////////////

// Uniforms - Pass these into the appropriate vertex and fragment shader files
const spherePosition = { type: 'v3', value: new THREE.Vector3(0.0, 0.0, 0.0) };

const ambientColor = { type: 'c', value: new THREE.Color(0.0, 0.0, 1.0) };
const diffuseColor = { type: 'c', value: new THREE.Color(0.0, 1.0, 1.0) };
const specularColor = { type: 'c', value: new THREE.Color(1.0, 1.0, 1.0) };

const kAmbient = { type: "f", value: 0.3 };
const kDiffuse = { type: "f", value: 0.6 };
const kSpecular = { type: "f", value: 1.0 };
const shininess = { type: "f", value: 50.0 };
const ticks = { type: "f", value: 0.0 };
const resolution =  { type: 'v3', value: new THREE.Vector3() };

const baseHelmetLight = new THREE.PointLight(0xffffff, 200);
const helmetLights = [];

// Shader materials
const sphereMaterial = new THREE.ShaderMaterial({
  uniforms: {
    spherePosition: spherePosition
  }
});

const blinnPhongMaterial = new THREE.ShaderMaterial({
  uniforms: {
    spherePosition: spherePosition,
    ambientColor: ambientColor,
    diffuseColor: diffuseColor,
    specularColor: specularColor,
    kAmbient: kAmbient,
    kDiffuse: kDiffuse,
    kSpecular: kSpecular,
    shininess: shininess
  }
});

const rayMarchingMaterial = new THREE.ShaderMaterial({
  uniforms: {
    time: ticks,
    resolution: resolution,
    camPos: spherePosition
  }
});

// ---------------------------Albedo, MetalRoughness, Emissive, Normal, AO maps for helmet-------------------------

// TODO: implement helmetMetalRoughnessMap, helmetEmissiveMap, helmetNormalMap, helmetAOMap
// similarly to how helmetAlbedoMap is implemented

const helmetAlbedoMap = new THREE.TextureLoader().load( 'gltf/Default_albedo.jpg' );
helmetAlbedoMap.colorSpace = THREE.SRGBColorSpace;
helmetAlbedoMap.flipY = false;
helmetAlbedoMap.wrapS = THREE.RepeatWrapping; // 1000
helmetAlbedoMap.wrapT = THREE.RepeatWrapping; // 1000

//*====================================(c)====================================
function loadHelmetTexture(path) {
  const t = new THREE.TextureLoader().load(path);
  t.flipY = false;
  t.wrapS = THREE.RepeatWrapping; // 1000
  t.wrapT = THREE.RepeatWrapping;
  return t;
}
const helmetMetalRoughnessMap = loadHelmetTexture('gltf/Default_metalRoughness.jpg');
const helmetEmissiveMap = loadHelmetTexture('gltf/Default_emissive.jpg');
const helmetNormalMap = loadHelmetTexture('gltf/Default_normal.jpg');
const helmetAOMap = loadHelmetTexture('gltf/Default_AO.jpg');
//*====================================(c)====================================*/
// ----------------------------------------------------------------------------------------------------------------

// ---------------------------PBR material for helmet--------------------------------------------------------------


// TODO: Create different materials like the following to view the effect of each map
const helmetAlbedoMaterial = new THREE.MeshBasicMaterial({
  map: helmetAlbedoMap,
  toneMapped: false,
});
//*====================================(c)====================================*/
const helmetMetalRoughnessMaterial = new THREE.MeshBasicMaterial({
  map: helmetMetalRoughnessMap,
  toneMapped: false,
});
const helmetEmissiveMaterial = new THREE.MeshBasicMaterial({
  map: helmetEmissiveMap,
  toneMapped: false,
});
const helmetNormalMaterial = new THREE.MeshBasicMaterial({
  map: helmetNormalMap,
  toneMapped: false,
});
const helmetAOMaterial = new THREE.MeshBasicMaterial({
  map: helmetAOMap,
  toneMapped: false,
});
//*====================================(c)====================================*/
// TODO: set the material's emissive color and metalness, you can play around these values
// helmetPBRMaterial.emissive = ;
// helmetPBRMaterial.metalness = ;
//*====================================(c)====================================*/
const helmetPBRMaterial = new THREE.MeshStandardMaterial({
  map: helmetAlbedoMap,
  metalnessMap: helmetMetalRoughnessMap, // metalnessMap and roughnessMap use the same texture
  roughnessMap: helmetMetalRoughnessMap, // roughnessMap is used to add roughness to the helmet
  emissiveMap: helmetEmissiveMap, // emissiveMap is used to add emission to the helmet
  normalMap: helmetNormalMap, // normalMap is used to add detail to the helmet
  aoMap: helmetAOMap, // aoMap is used to add ambient occlusion to the helmet
});
helmetPBRMaterial.emissive = new THREE.Color(0x000000); // emissiveMap is used to add emission to the helmet
helmetPBRMaterial.metalness = 1.0; // metalnessMap is used to add metalness to the helmet
helmetPBRMaterial.roughness = 1.0; // roughnessMap is used to add roughness to the helmet

const helmetMaterials = [
  helmetAlbedoMaterial,
  helmetMetalRoughnessMaterial,
  helmetEmissiveMaterial,
  helmetNormalMaterial,
  helmetAOMaterial,
  helmetPBRMaterial,
];

//*====================================(c)====================================*/

//-----------------------------------------------------------------------------------------------------------------


// Load shaders
const shaderFiles = [
  'glsl/sphere.vs.glsl',
  'glsl/sphere.fs.glsl',
  'glsl/blinn_phong.vs.glsl',
  'glsl/blinn_phong.fs.glsl',
  'glsl/raymarching.vs.glsl',
  'glsl/raymarching.fs.glsl',
];

new SourceLoader().load(shaderFiles, function (shaders) {
  sphereMaterial.vertexShader = shaders['glsl/sphere.vs.glsl'];
  sphereMaterial.fragmentShader = shaders['glsl/sphere.fs.glsl'];

  blinnPhongMaterial.vertexShader = shaders['glsl/blinn_phong.vs.glsl'];
  blinnPhongMaterial.fragmentShader = shaders['glsl/blinn_phong.fs.glsl'];

  rayMarchingMaterial.vertexShader = shaders['glsl/raymarching.vs.glsl'];
  rayMarchingMaterial.fragmentShader = shaders['glsl/raymarching.fs.glsl'];
});

// Define the shader modes, note: here the key is not the key pressed on keyboard
const shaders = {
  BLINNPHONG: { key: 0, material: blinnPhongMaterial, type: 'snowman' },
  RAYMARCHING: { key: 1, material: rayMarchingMaterial, type: 'raymarching' },
  HELMET_ALBEDO: { key: 2, material: helmetAlbedoMaterial, type: 'helmet' },
  HELMET_METAL_ROUGHNESS: { key: 3, material: helmetMetalRoughnessMaterial, type: 'helmet' },
  HELMET_EMISSIVE: { key: 4, material: helmetEmissiveMaterial, type: 'helmet' },
  HELMET_NORMAL: { key: 5, material: helmetNormalMaterial, type: 'helmet' },
  HELMET_AO: { key: 6, material: helmetAOMaterial, type: 'helmet' },
  HELMET_PBR: { key: 7, material: helmetPBRMaterial, type: 'helmet' },
};

let mode = shaders.BLINNPHONG.key; // Default

// Set up scenes
let scenes = [];
for (let shader of Object.values(shaders)) {
  // Create the scene
  let scene, camera, worldFrame;

  if (shader.type === 'raymarching') {
    ({ scene, camera } = createRayMarchingScene(canvas, renderer));
    const plane = new THREE.PlaneGeometry(2, 2);
    scene.add(new THREE.Mesh(plane, shaders.RAYMARCHING.material));
  } else {
    ({ scene, camera, worldFrame } = createScene(canvas, renderer));
    
    // Create the main sphere geometry (light source)
    // https://threejs.org/docs/#api/en/geometries/SphereGeometry
    const sphereGeometry = new THREE.SphereGeometry(1.0, 32.0, 32.0);
    const sphere = new THREE.Mesh(sphereGeometry, sphereMaterial);
    sphere.position.set(0.0, 1.5, 0.0);
    sphere.parent = worldFrame;
    scene.add(sphere);
  }

  if (shader.type === 'helmet') {
    await loadGLTFAsync(['gltf/DamagedHelmet.glb'], function(models) {
      const helmet = models[0].scene;
      helmet.position.set(0, 0, -10.0);
      helmet.scale.set(7, 7, 7);
      helmet.traverse(function(child) {
        if (child instanceof THREE.Mesh) {
          child.material = shader.material;
        }
      });
      scene.add(helmet);
    });

    const ambientLight = new THREE.AmbientLight(0xffffff, 3.0);
    scene.add(ambientLight);

    const pointLight = baseHelmetLight.clone();
    pointLight.position.copy(spherePosition.value);
    pointLight.parent = worldFrame;
    scene.add(pointLight);
    helmetLights.push(pointLight);
  } else if (shader.type === 'snowman') {
    await loadOBJAsync(['obj/snowman.obj'], function(models) {
      const snowman = models[0];
      snowman.traverse( function ( child ) {
        if ( child instanceof THREE.Mesh ) {
          child.material = shader.material;
        }
      });
      snowman.position.set(0.0, 0.0, -10.0);
      snowman.rotation.y = 0.0;
      snowman.scale.set(1.0e-3, 1.0e-3, 1.0e-3);
      scene.add(snowman);
    });
  }

  scenes.push({ scene, camera });
}



// Listen to keyboard events.
const keyboard = new THREEx.KeyboardState();
function checkKeyboard() {

  if (keyboard.pressed("1"))
    mode = shaders.BLINNPHONG.key;
  else if (keyboard.pressed("2"))
    mode = shaders.RAYMARCHING.key;
  else   if (keyboard.pressed("3"))
    mode = shaders.HELMET_ALBEDO.key;
  //*====================================(c)====================================*/
  else if (keyboard.pressed("4"))
    mode = shaders.HELMET_METAL_ROUGHNESS.key;
  else if (keyboard.pressed("5"))
    mode = shaders.HELMET_EMISSIVE.key;
  else if (keyboard.pressed("6"))
    mode = shaders.HELMET_NORMAL.key;
  else if (keyboard.pressed("7"))
    mode = shaders.HELMET_AO.key;
  //*====================================(c)====================================*/
  else if (keyboard.pressed("8"))
    mode = shaders.HELMET_PBR.key;

  if (keyboard.pressed("W"))
    spherePosition.value.z -= 0.3;
  else if (keyboard.pressed("S"))
    spherePosition.value.z += 0.3;

  if (keyboard.pressed("A"))
    spherePosition.value.x -= 0.3;
  else if (keyboard.pressed("D"))
    spherePosition.value.x += 0.3;

  if (keyboard.pressed("E"))
    spherePosition.value.y -= 0.3;
  else if (keyboard.pressed("Q"))
    spherePosition.value.y += 0.3;
  
  if (mode == shaders.RAYMARCHING.key) {
    const canvas = renderer.domElement;
    resolution.value.set(canvas.width, canvas.height, 1);
  } else {
     helmetLights.forEach(function(light) {
      light.position.set(
        spherePosition.value.x,
        spherePosition.value.y,
        spherePosition.value.z
      );
    });
  }

  // The following tells three.js that some uniforms might have changed
  sphereMaterial.needsUpdate = true;
  blinnPhongMaterial.needsUpdate = true;
  helmetMaterials.forEach(function(material) {
    material.needsUpdate = true;
  });
  rayMarchingMaterial.needsUpdate = true;
}

let clock = new THREE.Clock;

// Setup update callback
function update() {
  checkKeyboard();
  ticks.value += clock.getDelta();

  // Requests the next update call, this creates a loop
  requestAnimationFrame(update);
  const { scene, camera } = scenes[mode];
  renderer.render(scene, camera);
}

// Start the animation loop.
update();