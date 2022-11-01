# laseranim
 
Make hand-drawn animations for a laser.
Animations are exported into an RGB texture and loaded into a TouchDesigner patch that controls the laser.

## Controls
### File
 * ctrl + N: New file
 * ctrl + O: Open save folder (drag and drop a .sav file to open it)
 * ctrl + S: Save and export (will not overwrite)
 * ctrl + R: Rename current file (enter or escape to confirm)

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
 * I: Toggle debug info

### Brush tool (B)
 * left mouse: freehand draw
 * right mouse: draw straight lines
 * C: Toggle drawing closed curves

### Grab tool (G)
 * left mouse: grab line
 * right mouse: grab whole frame