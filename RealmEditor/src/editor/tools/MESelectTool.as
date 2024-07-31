package editor.tools {
import editor.MEBrush;
import editor.MEEvent;
import editor.MapTileData;
import editor.MapTileData;
import editor.actions.MapAction;
import editor.actions.MapActionSet;
import editor.actions.MapActionSet;
import editor.actions.MapActionSet;
import editor.actions.MapDragAction;
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
        if (tilePos == null){
            return;
        }

        this.mainView.mapView.highlightTile(tilePos.x_, tilePos.y_);
    }

    public override function reset():void {
        this.selectionStart = null;
        this.draggingSelection = false;
        this.prevSelection = null;
        this.lastDragPos = null;
    }

    public override function mouseDrag(tilePos:IntPoint, history:MapHistory):void {
        if (tilePos == null){
            this.reset();
            return;
        }

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

        if (this.selectionStart.x_ != tilePos.x_ || this.selectionStart.y_ != tilePos.y_) {
            this.mainView.mapView.selectTileArea(this.selectionStart.x_, this.selectionStart.y_, tilePos.x_, tilePos.y_);
        }
    }

    public override function mouseDragEnd(tilePos:IntPoint, history:MapHistory):void {
        if (this.selectionStart == null || tilePos == null) {
            this.reset(); // Make sure to reset our selecting action, unless we're selecting an area
            return;
        }

        var beginX:int = this.selectionStart.x_ < tilePos.x_ ? this.selectionStart.x_ : tilePos.x_;
        var beginY:int = this.selectionStart.y_ < tilePos.y_ ? this.selectionStart.y_ : tilePos.y_;
        var endX:int = this.selectionStart.x_ < tilePos.x_ ? tilePos.x_ : this.selectionStart.x_;
        var endY:int = this.selectionStart.y_ < tilePos.y_ ? tilePos.y_ : this.selectionStart.y_;
        if (endX == beginX && endY == beginY) { // 1 tile selected = unselect
            this.mainView.mapView.recordSelectionClear(history);
            this.mainView.mapView.clearTileSelection();
            this.reset();
            return;
        }

        history.record(new MapSelectAction(this.prevSelection.clone(), this.mainView.mapView.selection.clone()));
        this.lastDragPos = new IntPoint(beginX, beginY);

        this.reset();
    }

    public override function tileClick(tilePos:IntPoint, history:MapHistory):void {
        if (tilePos == null){
            this.reset();
            return;
        }

        if (this.mainView.mapView.isInsideSelection(tilePos.x_, tilePos.y_, true)){ // Don't do anything if user clicked once inside selection
            return;
        }

        this.mainView.mapView.recordSelectionClear(history);
        this.mainView.mapView.clearTileSelection();
    }

    public override function mouseMoved(tilePos:IntPoint, history:MapHistory):void {
        if (tilePos == null){
            this.reset();
            return;
        }

        this.mainView.mapView.highlightTile(tilePos.x_, tilePos.y_);
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

    public function dragSelection(diffX:int, diffY:int, history:MapHistory):void {
        var selection:MapSelectData = this.mainView.mapView.selection;
        var startX:int = selection.startX;
        var startY:int = selection.startY;
        var beginX:int = startX + diffX;
        var beginY:int = startY + diffY;
        var endX:int = beginX + selection.width - 1;
        var endY:int = beginY + selection.height - 1;

        if ((diffX == 0 && diffY == 0) || // Prevent from re-selecting in the same place
            beginX < 0 || endX >= this.mainView.mapView.mapData.mapWidth || // Check map bounds
            beginY < 0 || endY >= this.mainView.mapView.mapData.mapHeight) {
            return;
        }

        var action:MapDragAction = this.mainView.mapView.dragController.dragSelection(beginX, beginY, endX, endY);
        history.record(action);
    }

    private function savePreviousSelection():void {
        this.prevSelection = this.mainView.mapView.selection.clone();
    }
}
}
