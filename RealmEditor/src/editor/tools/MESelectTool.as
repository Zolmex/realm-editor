package editor.tools {
import editor.MEBrush;
import editor.ui.MainView;
import editor.ui.MapView;

import flash.geom.Point;

import util.IntPoint;

public class MESelectTool extends METool {

    private var selectionStart:IntPoint;
    private var draggingSelection:Boolean;
    
    public function MESelectTool(view:MainView) {
        super(METool.SELECT_ID, view);
    }

    public override function init(tilePos:IntPoint):void {
        if (!this.mainView.mapView.isInsideSelection(tilePos.x_, tilePos.y_, true)) {
            this.mainView.mapView.highlightTile(tilePos.x_, tilePos.y_);
        }
    }

    public override function reset():void {
        this.selectionStart = null;
        this.draggingSelection = false;
    }

    public override function mouseDrag(tilePos:IntPoint):void {
        if (this.selectionStart == null) {
            if (this.draggingSelection || this.mainView.mapView.isInsideSelection(tilePos.x_, tilePos.y_, true)) {
                this.draggingSelection = true;
                this.mainView.mapView.moveSelectionTo(tilePos);
                return;
            }

            if (!this.mainView.mapView.isInsideSelection(tilePos.x_, tilePos.y_, true)) {
                this.draggingSelection = false;
                this.selectionStart = null;
                this.mainView.mapView.clearTileSelection();
            }

            this.selectionStart = tilePos;
        }

        this.mainView.mapView.selectTileArea(this.selectionStart.x_, this.selectionStart.y_, tilePos.x_, tilePos.y_);
    }

    public override function mouseDragEnd(tilePos:IntPoint):void {
        this.reset();
    }

    public override function tileClick(tilePos:IntPoint):void {
        this.mainView.mapView.clearTileSelection();

        this.mainView.mapView.selectSingleTile(tilePos.x_, tilePos.y_);
    }

    public override function mouseMoved(tilePos:IntPoint):void {
        if (!this.mainView.mapView.isInsideSelection(tilePos.x_, tilePos.y_, true)) {
            this.mainView.mapView.highlightTile(tilePos.x_, tilePos.y_);
        }
    }
}
}
