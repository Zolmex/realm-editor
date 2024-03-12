# realm-editor

## Getting started
Download the .rar file from the [latest release](https://github.com/Zolmex/realm-editor/releases/latest) and extract the files into a folder, then simply run the executable to use the editor.

### Basic controls
Drag middle-click to move the map around.

Use scroll-wheel to zoom in/out.

[Ctrl+C / Ctrl+V]: copy / pasting.

[Ctrl+Z / Ctrl+Y]: undoing / redoing.

[Shift + G]: toggle grid.

### Tools
- Select tool:
Drag left-click to select multiple tiles. Click once to select a single tile. Escape to unselect everything.
Hold click on selected tile/s to move them around the map.
- Pencil tool:
Affects selected area only.
Press left-click to draw selected tile/object/region (depending on what's selected in the left-side panel).
- Erase tool:
Affects selected area only.
Press left-click to erase tile/object/region.
- Picker tool:
Click on any tile/object/region on the map to select it for pencil tool.
- Bucket tool:
Click anywhere inside the selected area to fill it with the selected tile/object/region.
- Line tool:
NOT IMPLEMENTED.
- Shape tool:
NOT IMPLEMENTED.
- Edit tool:
Click on an object to edit its name/cfg string.

### Property filter
Click the arrow to the right of the right-side panel (elements panel) to open the property filter list.

Write the name of the property and the desired value for it (leave blank for *true*).
Press "Add" to add it to the list.

The elements panel will update based on the filter list. Elements that don't match every property in the filter list will not show in the panel.
