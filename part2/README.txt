================================================================================
A3 Part 2 - Feature Extension (Part d)
================================================================================

Part d extends the assignment with:

1) All material helmets recolor
   The six helmet views (keys 3–8: Albedo, MetalRoughness, Emissive, Normal, AO,
   and full PBR) use custom colors/tints so the damaged helmet has a consistent
   custom look across all material maps.

2) Ray Marching (Scene 2) — pumpkin assembly + camera sector path
   - Pumpkin assembly: When you press 2 to enter Scene 2, the eyes, nose,
     mouth, and teeth fly in from around the pumpkin and assemble into their
     final positions. The animation starts from the beginning when you switch to
     scene 2 (time resets on scene entry).
   - Camera sector path: After a delay, the camera moves along a sector-shaped
     path: it zooms in then zooms out, orbiting in that fan shape to film the
     jack-o-lantern.
   - When in Scene 2 only, four buttons appear in the top-right corner:
     Sun rotate, Candle rotate, View sector, Reset. They are hidden in other
     scenes. Sun/Candle/View sector toggle the corresponding effect on or off;
     Reset restarts the scene-2 animation (time resets).

--------------------------------------------------------------------------------
Controls (same as Part 1)
--------------------------------------------------------------------------------
  1–8   Switch scenes (Snowman, Ray Marching, 6 helmet views)
  WASD  Move light on xz plane
  Q/E   Move light up/down
  Mouse Drag  Orbit camera

  Scene 2 only (top-right buttons): Sun rotate | Candle rotate | View sector | Reset

================================================================================
