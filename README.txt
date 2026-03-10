================================================================================
CPSC 314 Assignment 3 - README
================================================================================

Name:           Lucas Lyu
Student Number: [30349559]
CWL Username:   [clyu05]


--------------------------------------------------------------------------------
HOW TO RUN
--------------------------------------------------------------------------------
- Serve the project from a local web server (do not open the HTML file directly).
  Example: python -m http.server 8000, or use VS Code Live Server.
- Part 1 (core): Open part1/A3.html in the browser.
- Part 2 (feature extension): Open part2/A3.html in the browser.


--------------------------------------------------------------------------------
KEYBOARD ACTIONS & USAGE
--------------------------------------------------------------------------------

Part 1 & Part 2 (shared):
  1              - Blinn-Phong Snowman
  2              - Ray Marching (jack-o-lantern)
  3              - Helmet Albedo map
  4              - Helmet MetalRoughness map
  5              - Helmet Emissive map
  6              - Helmet Normal map
  7              - Helmet AO map
  8              - Helmet PBR (full)
  W / S / A / D  - Move the light/sphere on the xz plane
  Q / E          - Move the light up / down
  Mouse          - Click and drag to orbit camera (when applicable)


--------------------------------------------------------------------------------
DIRECTORY STRUCTURE
--------------------------------------------------------------------------------
  part1/   - All parts before the feature extension (Blinn-Phong, Ray Marching,
             PBR helmet textures and materials).
  part2/   - Feature extension (Part d): All helmet material views with custom
             recoloring; and in Ray Marching (Scene 2), camera orbits around the
             pumpkin (rotation of view, not helmet).


--------------------------------------------------------------------------------
NOTES FOR THE MARKER
--------------------------------------------------------------------------------
- Part 2 (Part d) extends the assignment with:
  1) All material helmets recolor: The six helmet views (Albedo, MetalRoughness,
     Emissive, Normal, AO, and the full PBR material) use modified colors/tints
     so the damaged helmet has a consistent custom look across all maps.
  2) Pumpkin rotation: In Scene 2 (Ray Marching), the camera orbits around the
     jack-o-lantern over time (using the time uniform in the shader), so the
     view rotates around the pumpkin—not the helmet.


--------------------------------------------------------------------------------
COLLABORATION & RESOURCES (fill in as required)
--------------------------------------------------------------------------------
People I discussed the assignment with:

Websites / resources I used:

================================================================================
