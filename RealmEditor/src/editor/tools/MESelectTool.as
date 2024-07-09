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
import editor.ui.MapHistory;
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

    public static const CLEARED_DATA:MapSelectData = new MapSelectData(-1, -1, -1, -1);

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
        var selectionPos:Shape = this.mainView.mapView.selectionPos;
        var selectionSize:IntPoint = this.mainView.mapView.selectionSize;
        var tile:MapTileSprite = tileMap.getTileSprite(tilePos.x_, tilePos.y_);
        if (tile == null) {
            return;
        }

        var startX:int = tilePos.x_ * TileMapView.TILE_SIZE;
        var startY:int = tilePos.y_ * TileMapView.TILE_SIZE;
        if (selectionPos.x == startX && selectionPos.y == startY) { // Clear selection if we selected the same one-tile area
            this.mainView.mapView.recordSelectionClear(history);
            this.mainView.mapView.clearTileSelection();
            return;
        }

        history.record(getAction(selectionPos, selectionSize, new MapSelectData(tilePos.x_, tilePos.y_, tilePos.x_, tilePos.y_)));

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

        var startX:int = this.mainView.mapView.selectionPos.x / TileMapView.TILE_SIZE;
        var startY:int = this.mainView.mapView.selectionPos.y / TileMapView.TILE_SIZE;
        var beginX:int = startX + diffX;
        var beginY:int = startY + diffY;
        var endX:int = beginX + this.mainView.mapView.selectionSize.x_ - 1;
        var endY:int = beginY + this.mainView.mapView.selectionSize.y_ - 1;

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

        var tileMap:TileMapView = this.mainView.mapView.tileMap;

        var selectAction:MapSelectAction = new MapSelectAction(this.prevSelection.clone(), new MapSelectData(beginX, beginY, endX, endY));
        var actions:MapActionSet = new MapActionSet();
        actions.push(selectAction); // Push first our new selection to map history

        if (!firstMove) {
            var undoneActions:MapActionSet = this.mainView.mapView.moveHistory.undo(); // Undo last moved tiles
            if (undoneActions != null) {
                undoneActions.swap(true); // Swap so that when user undoes these actions are redone
                actions.pushSet(undoneActions);
            }
        } else { // Clear selected tile area the first time we move
            this.clearSelectedArea(actions);
        }

        var idx:int = 0;
        var newActions:MapActionSet = new MapActionSet();
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

        var startX:int = this.mainView.mapView.selectionPos.x / TileMapView.TILE_SIZE;
        var startY:int = this.mainView.mapView.selectionPos.y / TileMapView.TILE_SIZE;
        var endX:int = startX + this.mainView.mapView.selectionSize.x_;
        var endY:int = startY + this.mainView.mapView.selectionSize.y_;

        var idx:int = 0;
        var tileMap:TileMapView = this.mainView.mapView.tileMap;
        for (var y:int = startY; y < endY; y++) {
            for (var x:int = startX; x < endX; x++) {
                var tile:MapTileData = tileMap.getTileData(x, y);
                this.mainView.mapView.tilesMoved[idx] = tile.clone();
                idx++;
            }
        }
    }

    private function clearSelectedArea(actions:MapActionSet):void {
        var startX:int = this.mainView.mapView.selectionPos.x / TileMapView.TILE_SIZE;
        var startY:int = this.mainView.mapView.selectionPos.y / TileMapView.TILE_SIZE;
        var endX:int = startX + this.mainView.mapView.selectionSize.x_;
        var endY:int = startY + this.mainView.mapView.selectionSize.y_;

        var tileMap:TileMapView = this.mainView.mapView.tileMap;
        for (var y:int = startY; y < endY; y++) {
            for (var x:int = startX; x < endX; x++) {
                var prevData:MapTileData = tileMap.getTileData(x, y).clone();
                tileMap.clearTile(x, y);

                actions.push(new MapReplaceTileAction(x, y, prevData, tileMap.getTileData(x, y).clone()));
            }
        }
    }

    private function savePreviousSelection():void {
        var selectionPos:Shape = this.mainView.mapView.selectionPos;
        var selectionSize:IntPoint = this.mainView.mapView.selectionSize;
        var startX:int = selectionPos.x / TileMapView.TILE_SIZE; // Save previous selection data
        var startY:int = selectionPos.y / TileMapView.TILE_SIZE;
        if (selectionSize.x_ == 0 && selectionSize.y_ == 0) {
            this.prevSelection = CLEARED_DATA;
        } else {
            this.prevSelection = new MapSelectData(startX, startY, startX + selectionSize.x_ - 1, startY + selectionSize.y_ - 1);
        }
    }

    private static function getAction(selectionPos:Shape, selectionSize:IntPoint, newSelection:MapSelectData):MapSelectAction {
        var startX:int = selectionPos.x / TileMapView.TILE_SIZE;
        var startY:int = selectionPos.y / TileMapView.TILE_SIZE;
        var prevSelection:MapSelectData = new MapSelectData(startX, startY, startX + selectionSize.x_ - 1, startY + selectionSize.y_ - 1);
        return new MapSelectAction(prevSelection, newSelection);
    }
}
}
