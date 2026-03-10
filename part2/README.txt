================================================================================
A3 Part 2 - Feature Extension (Part d)
================================================================================

Part d extends the assignment with:

1) All material helmets recolor
   The six helmet views (keys 3–8: Albedo, MetalRoughness, Emissive, Normal, AO,
   and full PBR) use custom colors/tints so the damaged helmet has a consistent
   custom look across all material maps.

2) Pumpkin rotation (Ray Marching only)
   In Scene 2, the camera orbits around the jack-o-lantern over time (using the
   time uniform in raymarching.fs.glsl). The view rotates around the pumpkin—
   this is the pumpkin/camera rotation, not the helmet.

--------------------------------------------------------------------------------
Controls (same as Part 1)
--------------------------------------------------------------------------------
  1–8   Switch scenes (Snowman, Ray Marching, 6 helmet views)
  WASD  Move light on xz plane
  Q/E   Move light up/down
  Mouse Drag  Orbit camera

================================================================================
