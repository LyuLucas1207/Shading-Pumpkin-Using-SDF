Controls 

WASD to move the light/sphere on the xz plane
QE to move the light up and down
Click and drag to orbit camera (when applicable)

1 = Blinn-Phong Snowman
2 = Ray Marching (jack-o-lantern)
3-8 = Helmet views (Albedo, MetalRoughness, Emissive, Normal, AO, PBR)

---
Part d - Feature Extension

In Scene 2 (Ray Marching), two extensions use the "time" uniform in raymarching.fs.glsl:

1) Orbit camera: the ray origin ro is set to ro = ta + vec3(4.0*cos(0.8*time), 1.5, 4.0*sin(0.8*time)) so the camera moves on a circle around the pumpkin center (ta = PUMPKIN_CENTER). The view rotates continuously without user input.

2) Orbiting candle light: the inner light (candle) position is animated on a ring around the pumpkin center. In getColor(), lightPos2 = vec3(0, 1.5, 5) + vec3(orbitRadius*cos(time), 0, orbitRadius*sin(time)) with orbitRadius = 0.45, so the light moves in a horizontal circle inside the jack-o-lantern and the shading/shadows change as it orbits.
