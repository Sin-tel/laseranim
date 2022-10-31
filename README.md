# laseranim
 
Make hand-drawn animations for a laser.
Animations are exported into an RGB texture and loaded into a TouchDesigner patch that controls the laser.

## Controls
### File
 * ctrl + N: New file
 * ctrl + O: Open save folder (drag and drop a .sav file to open it)
 * ctrl + S: Save and export (will not overwrite)
 * ctrl + R: Rename current file (enter or escape to confirm)

### Editing
 * left mouse: freehand draw
 * right mouse: draw straight lines

 * ctrl + X/C/V: Cut/copy/paste whole frame
 * Delete: Delete frame 

 * A/D: Move between frames
 * W/S: Increase/decrease laser tracing speed
 * E/Q: Increase/decrease fps

 * Space: Play/pause preview
 * P: Toggle laser animate
 * N: Insert frame
 * X: Clear frame
 * O: Cycle onion skinning between 0, 1 or 2 frames
 * C: Toggle drawing closed curves (not really functional right now)
 * I: Toggle debug info