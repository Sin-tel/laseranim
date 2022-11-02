# laseranim
 
Make hand-drawn animations for a laser.
Animations are exported into an RGB texture and loaded into a TouchDesigner patch that controls the laser.

## Controls
### File
 * ctrl + N: New file
 * ctrl + O: Open save folder (drag and drop a .sav file to open it)
 * ctrl + S: Save and export (will not overwrite)
 * ctrl + R: Rename current file (enter or escape to confirm)
 * Drag and drop a jpg or png file to load as a background image (you can load multiple ones on different frames)
 * R: Remove all images

### Frames
 * ctrl + X/C/V: Cut/copy/paste whole frame
 * Delete: Delete frame 
 * N: Insert frame
 * X: Clear frame
 * A/D: Move between frames

### Edit
 * ctrl + Z/Y: Undo/redo
 * Space: Play/pause preview
 * P: Toggle laser animation play
 * W/S: Increase/decrease laser tracing speed
 * E/Q: Increase/decrease animation fps
 * O: Cycle onion skinning between 0, 1 or 2 frames
 * ctrl + I: Toggle debug info

### Brush tool (B)
 * left mouse: freehand draw
 * right mouse: draw straight lines
 * C: Toggle drawing closed curves
 * M: Cycle between different brush smoothing values

### Grab tool (G)
 * left mouse: grab line
 * right mouse: grab whole frame

### Image tool (I)
 * left mouse: move image
 * right mouse: scale image