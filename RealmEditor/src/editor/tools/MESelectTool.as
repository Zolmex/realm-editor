package editor.tools {
import editor.MEBrush;
import editor.MEEvent;
import editor.MapTileData;
import editor.MapTileData;
import editor.actions.MapAction;
import editor.actions.MapActionSet;
import editor.actions.MapActionSet;
import editor.actions.MapActionSet;
import editor.actions.MapReplaceTileAction;
import editor.actions.MapSelectAction;
import editor.actions.MapSelectAction;
import editor.actions.data.MapSelectData;
import editor.ui.MainView;
import editor.MapHistory;
import editor.ui.MapInputHandler;
import editor.ui.MapTileSprite;
import editor.ui.MapView;
import editor.ui.TileMapView;

import flash.display.Shape;
import flash.events.Event;

import flash.geom.Point;
import flash.net.registerClassAlias;

import util.IntPoint;

public class MESelectTool extends METool {

    private var selectionStart:IntPoint;
    private var prevSelection:MapSelectData;

    private var draggingSelection:Boolean;
    private var lastDragPos:IntPoint;

    public function MESelectTool(view:MainView) {
        super(METool.SELECT_ID, view);
    }

    public override function init(tilePos:IntPoint, history:MapHistory):void {
        if (!this.mainView.mapView.isInsideSelection(tilePos.x_, tilePos.y_, true)) {
            this.mainView.mapView.highlightTile(tilePos.x_, tilePos.y_);
        }
    }

    public override function reset():void {
        this.selectionStart = null;
        this.draggingSelection = false;
        this.prevSelection = null;
        this.lastDragPos = null;
    }

    public override function mouseDrag(tilePos:IntPoint, history:MapHistory):void {
        if (this.selectionStart == null) {
            if (this.draggingSelection || this.mainView.mapView.isInsideSelection(tilePos.x_, tilePos.y_, true)) { // Drag selected tiles
                this.draggingSelection = true;
                this.dragSelectionTo(tilePos.x_, tilePos.y_, history);
                return;
            }

            if (!this.mainView.mapView.isInsideSelection(tilePos.x_, tilePos.y_, true)) { // Select new tiles
                this.draggingSelection = false;
                this.selectionStart = tilePos; // Set the map position where we started selecting

                this.savePreviousSelection();
                this.mainView.mapView.clearTileSelection();
            }
        }

        this.mainView.mapView.selectTileArea(this.selectionStart.x_, this.selectionStart.y_, tilePos.x_, tilePos.y_);
    }

    public override function mouseDragEnd(tilePos:IntPoint, history:MapHistory):void {
        if (this.selectionStart == null) {
            this.reset(); // Make sure to reset our selecting action, unless we're selecting an area
            return;
        }

        var beginX:int = this.selectionStart.x_ < tilePos.x_ ? this.selectionStart.x_ : tilePos.x_;
        var beginY:int = this.selectionStart.y_ < tilePos.y_ ? this.selectionStart.y_ : tilePos.y_;
        var endX:int = this.selectionStart.x_ < tilePos.x_ ? tilePos.x_ : this.selectionStart.x_;
        var endY:int = this.selectionStart.y_ < tilePos.y_ ? tilePos.y_ : this.selectionStart.y_;
        history.record(new MapSelectAction(this.prevSelection.clone(), new MapSelectData(beginX, beginY, endX, endY)));
        this.lastDragPos = new IntPoint(beginX, beginY);

        this.reset();
    }

    public override function tileClick(tilePos:IntPoint, history:MapHistory):void {
        var tileMap:TileMapView = this.mainView.mapView.tileMap;
        var selection:MapSelectData = this.mainView.mapView.selection;
        var tile:MapTileSprite = tileMap.getTileSprite(tilePos.x_, tilePos.y_);
        if (tile == null) {
            return;
        }

        var startX:int = tilePos.x_ * TileMapView.TILE_SIZE;
        var startY:int = tilePos.y_ * TileMapView.TILE_SIZE;
        if (selection.startX == startX && selection.startY == startY) { // Clear selection if we selected the same one-tile area
            this.mainView.mapView.recordSelectionClear(history);
            this.mainView.mapView.clearTileSelection();
            return;
        }

        history.record(new MapSelectAction(selection.clone(), new MapSelectData(tilePos.x_, tilePos.y_, tilePos.x_, tilePos.y_)));

        this.mainView.mapView.clearTileSelection();
        this.mainView.mapView.drawTileSelection(tilePos.x_, tilePos.y_, tilePos.x_, tilePos.y_); // Redraw the tile selection rectangle
        this.lastDragPos = new IntPoint(tilePos.x_, tilePos.y_);
    }

    public override function mouseMoved(tilePos:IntPoint, history:MapHistory):void {
        if (!this.mainView.mapView.isInsideSelection(tilePos.x_, tilePos.y_, true)) {
            this.mainView.mapView.highlightTile(tilePos.x_, tilePos.y_);
        }
    }

    public function dragSelection(diffX:int, diffY:int, history:MapHistory):void {
        this.savePreviousSelection();

        var selection:MapSelectData = this.mainView.mapView.selection;
        var startX:int = selection.startX;
        var startY:int = selection.startY;
        var beginX:int = startX + diffX;
        var beginY:int = startY + diffY;
        var endX:int = beginX + this.mainView.mapView.selection.width - 1;
        var endY:int = beginY + this.mainView.mapView.selection.height - 1;

        if (diffX == 0 && diffY == 0) { // Prevent from re-selecting in the same place
            return;
        }

        this.moveSelectedTiles(beginX, beginY, endX, endY, history);

        this.mainView.mapView.selectTileArea(beginX, beginY, endX, endY); // The select action is already recorder inside moveSelectedTiles
    }

    public function dragSelectionTo(mapX:int, mapY:int, history:MapHistory):void {
        if (this.lastDragPos == null) {
            this.lastDragPos = new IntPoint(mapX, mapY);
        }

        var diffX:int = mapX - this.lastDragPos.x_;
        var diffY:int = mapY - this.lastDragPos.y_;

        this.dragSelection(diffX, diffY, history);

        this.lastDragPos = new IntPoint(mapX, mapY);
    }

    private function moveSelectedTiles(beginX:int, beginY:int, endX:int, endY:int, history:MapHistory):void {
        var firstMove:Boolean = false;
        if (this.mainView.mapView.tilesMoved == null) {
            firstMove = true;
            this.copySelectedTiles();
        }

        var selectAction:MapSelectAction = new MapSelectAction(this.prevSelection.clone(), new MapSelectData(beginX, beginY, endX, endY));
        var actions:MapActionSet = new MapActionSet();
        actions.push(selectAction); // Push first our new selection to map history

        if (!firstMove) {
            var lastActions:MapActionSet = this.mainView.mapView.moveHistory.undo(); // Undo last moved tiles
            if (lastActions != null) {
                lastActions.swap(true); // Swap so that when user undoes these actions are redone
                actions.pushSet(lastActions);
            }

            for each (var undoneActions:MapActionSet in this.mainView.mapView.moveHistory.erased){
                undoneActions.redoAll();
            }
        } else { // Clear selected tile area the first time we move
            this.clearSelectedArea(actions);
        }

        var idx:int = 0;
        var newActions:MapActionSet = new MapActionSet();
        var tileMap:TileMapView = this.mainView.mapView.tileMap;
        for (var y:int = beginY; y <= endY; y++) { // Draw the saved tiles
            for (var x:int = beginX; x <= endX; x++) {
                var prevTile:MapTileData = tileMap.getTileData(x, y).clone();
                var newTile:MapTileData = this.mainView.mapView.tilesMoved[idx].clone();

                tileMap.setTileData(x, y, newTile);
                tileMap.drawTile(x, y);

                newActions.push(new MapReplaceTileAction(x, y, prevTile, newTile)); // Push these new tiles into newActions
                actions.push(new MapReplaceTileAction(x, y, prevTile, newTile));
                idx++;
            }
        }

        history.recordSet(actions);
        this.mainView.mapView.moveHistory.recordSet(newActions); // Record these actions into our own move history so we can undo these, without undoing the history on the actual map
    }

    private function copySelectedTiles():void {
        this.mainView.mapView.tilesMoved = new Vector.<MapTileData>();

        var lastActions:MapActionSet = this.mainView.mapView.moveHistory.present.pop(); // When we're moving a new set of tiles, make sure to add the last moved tiles to erased
        while (lastActions != null){
            this.mainView.mapView.moveHistory.erased.push(lastActions);
            lastActions = this.mainView.mapView.moveHistory.present.pop();
        }

        var startX:int = this.mainView.mapView.selection.startX;
        var startY:int = this.mainView.mapView.selection.startY;
        var endX:int = this.mainView.mapView.selection.endX;
        var endY:int = this.mainView.mapView.selection.endY;

        var idx:int = 0;
        var tileMap:TileMapView = this.mainView.mapView.tileMap;
        for (var y:int = startY; y <= endY; y++) {
            for (var x:int = startX; x <= endX; x++) {
                var tile:MapTileData = tileMap.getTileData(x, y);
                this.mainView.mapView.tilesMoved[idx] = tile.clone();
                idx++;
            }
        }
    }

    private function clearSelectedArea(actions:MapActionSet):void {
        var startX:int = this.mainView.mapView.selection.startX;
        var startY:int = this.mainView.mapView.selection.startY;
        var endX:int = this.mainView.mapView.selection.endX;
        var endY:int = this.mainView.mapView.selection.endY;

        var tileMap:TileMapView = this.mainView.mapView.tileMap;
        for (var y:int = startY; y <= endY; y++) {
            for (var x:int = startX; x <= endX; x++) {
                var prevData:MapTileData = tileMap.getTileData(x, y).clone();
                tileMap.clearTile(x, y);

                actions.push(new MapReplaceTileAction(x, y, prevData, tileMap.getTileData(x, y).clone()));
            }
        }
    }

    private function savePreviousSelection():void {
        var selection:MapSelectData = this.mainView.mapView.selection;
        this.prevSelection = selection.clone();
    }
}
}
