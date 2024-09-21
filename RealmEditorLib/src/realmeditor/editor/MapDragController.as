package realmeditor.editor {
import editor.actions.MapActionSet;
import editor.actions.MapClearAreaAction;
import editor.actions.MapDragAction;
import editor.actions.MapReplaceTileAction;
import editor.actions.MapSelectAction;
import editor.actions.data.MapSelectData;
import editor.ui.MapView;
import editor.ui.TileMapView;

import realmeditor.editor.actions.MapDragAction;
import realmeditor.editor.actions.data.MapSelectData;

import realmeditor.editor.ui.MapView;
import realmeditor.editor.ui.TileMapView;

public class MapDragController {

    private var mapView:MapView;
    public var lastDragAction:MapDragAction;

    public function MapDragController(mapView:MapView) {
        this.mapView = mapView;
    }

    public function reset():void {
        this.mapView.setLastDragAction(null);
    }

    public function dragSelection(startX:int, startY:int, endX:int, endY:int):MapDragAction { // This method is only called when user drags tiles, not when a drag action is undone/redone
        var prevSelection:MapSelectData = this.mapView.selection.clone();

        var firstMove:Boolean = this.lastDragAction == null;
        var newTiles:Vector.<MapTileData> = this.getSelectedTiles();
        if (firstMove) {
            this.clearTileArea(prevSelection.startX, prevSelection.startY, prevSelection.endX, prevSelection.endY);
        } else {
            this.pasteTiles(this.lastDragAction.oldTiles, prevSelection.startX, prevSelection.startY, prevSelection.endX, prevSelection.endY); // Undo previously moved tiles. NOTE: don't call undoAction(), since that redoes the previous to that action
        }

        this.mapView.selectTileArea(startX, startY, endX, endY); // Select new area

        var oldTiles:Vector.<MapTileData> = this.getSelectedTiles(); // Copy the original tiles of the new area

        this.pasteTiles(newTiles, startX, startY, endX, endY);

        var lastDragAction:MapDragAction = null;
        if (this.lastDragAction != null){
            this.lastDragAction.userNewTiles = newTiles; // Make sure the previous action has updated tile set in case user drew on the selection before moving again
            lastDragAction = this.lastDragAction;
        }

        var action:MapDragAction = new MapDragAction(this, lastDragAction, oldTiles, newTiles, prevSelection, this.mapView.selection.clone());
        this.mapView.setLastDragAction(action);

        return action;
    }

    public function pasteTiles(tileDict:Vector.<MapTileData>, startX:int, startY:int, endX:int, endY:int):void {
        var idx:int = 0;
        var tileMap:TileMapView = this.mapView.tileMap;
        for (var y:int = startY; y <= endY; y++) { // Draw the saved tiles
            for (var x:int = startX; x <= endX; x++) {
                var newTile:MapTileData = tileDict[idx].clone(); // Can probably remove the .clone() call

                tileMap.setTileData(x, y, newTile);
                tileMap.drawTile(x, y);

                idx++;
            }
        }
    }

    private function getSelectedTiles():Vector.<MapTileData> {
        var idx:int = 0;
        var tileMap:TileMapView = this.mapView.tileMap;
        var tileDict:Vector.<MapTileData> = new Vector.<MapTileData>();
        for (var y:int = this.mapView.selection.startY; y <= this.mapView.selection.endY; y++) {
            for (var x:int = this.mapView.selection.startX; x <= this.mapView.selection.endX; x++) {
                var tile:MapTileData = tileMap.getTileData(x, y);
                tileDict[idx] = tile.clone();
                idx++;
            }
        }
        return tileDict;
    }

    public function clearTileArea(startX:int, startY:int, endX:int, endY:int):void {
        var tileMap:TileMapView = this.mapView.tileMap;
        for (var y:int = startY; y <= endY; y++) {
            for (var x:int = startX; x <= endX; x++) {
                tileMap.clearTile(x, y);
            }
        }
    }
}
}
