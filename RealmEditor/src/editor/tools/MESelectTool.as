package editor.tools {
import editor.MEBrush;
import editor.actions.MapAction;
import editor.actions.MapActionSet;
import editor.actions.MapSelectAction;
import editor.actions.MapSelectAction;
import editor.actions.data.MapSelectData;
import editor.ui.MainView;
import editor.ui.MapHistory;
import editor.ui.MapTileSprite;
import editor.ui.MapView;
import editor.ui.TileMapView;

import flash.display.Shape;

import flash.geom.Point;
import flash.net.registerClassAlias;

import util.IntPoint;

public class MESelectTool extends METool {

    private static const CLEARED_DATA:MapSelectData = new MapSelectData(-1, -1, -1, -1);

    private var selectionStart:IntPoint;
    private var draggingSelection:Boolean;
    private var prevSelection:MapSelectData;
    
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
    }

    public override function mouseDrag(tilePos:IntPoint, history:MapHistory):void {
        if (this.selectionStart == null) {
            if (this.draggingSelection || this.mainView.mapView.isInsideSelection(tilePos.x_, tilePos.y_, true)) { // Drag selected tiles
                this.draggingSelection = true;
                this.mainView.mapView.moveSelectionTo(tilePos);
                return;
            }

            if (!this.mainView.mapView.isInsideSelection(tilePos.x_, tilePos.y_, true)) { // Select new tiles
                this.draggingSelection = false;
                this.selectionStart = tilePos; // Set the map position where we started selecting

                var selectionPos:Shape = this.mainView.mapView.selectionPos;
                var selectionSize:IntPoint = this.mainView.mapView.selectionSize;

                var startX:int = selectionPos.x / TileMapView.TILE_SIZE; // Save previous selection data
                var startY:int = selectionPos.y / TileMapView.TILE_SIZE;
                if (selectionSize.x_ == 0 && selectionSize.y_ == 0){
                    this.prevSelection = CLEARED_DATA;
                }
                else {
                    this.prevSelection = new MapSelectData(startX, startY, startX + selectionSize.x_ - 1, startY + selectionSize.y_ - 1);
                }

                this.mainView.mapView.clearTileSelection();
            }
        }

        this.mainView.mapView.selectTileArea(this.selectionStart.x_, this.selectionStart.y_, tilePos.x_, tilePos.y_);
    }

    public override function mouseDragEnd(tilePos:IntPoint, history:MapHistory):void {
        var beginX:int = this.selectionStart.x_ < tilePos.x_ ? this.selectionStart.x_ : tilePos.x_;
        var beginY:int = this.selectionStart.y_ < tilePos.y_ ? this.selectionStart.y_ : tilePos.y_;
        var endX:int = this.selectionStart.x_ < tilePos.x_ ? tilePos.x_ : this.selectionStart.x_;
        var endY:int = this.selectionStart.y_ < tilePos.y_ ? tilePos.y_ : this.selectionStart.y_;
        history.record(new MapSelectAction(this.prevSelection.clone(), new MapSelectData(beginX, beginY, endX, endY)));

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
            history.record(getAction(selectionPos, selectionSize, CLEARED_DATA));
            this.mainView.mapView.clearTileSelection();
            return;
        }

        history.record(getAction(selectionPos, selectionSize, new MapSelectData(tilePos.x_, tilePos.y_, tilePos.x_, tilePos.y_)));

        this.mainView.mapView.clearTileSelection();
        this.mainView.mapView.drawTileSelection(tilePos.x_, tilePos.y_, tilePos.x_, tilePos.y_); // Redraw the tile selection rectangle
    }

    public override function mouseMoved(tilePos:IntPoint, history:MapHistory):void {
        if (!this.mainView.mapView.isInsideSelection(tilePos.x_, tilePos.y_, true)) {
            this.mainView.mapView.highlightTile(tilePos.x_, tilePos.y_);
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
