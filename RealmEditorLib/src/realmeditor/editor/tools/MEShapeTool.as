package realmeditor.editor.tools {
import editor.MEBrush;
import editor.MapHistory;
import editor.MapTileData;
import editor.ui.MainView;
import editor.ui.MapView;

import realmeditor.editor.MapHistory;

import realmeditor.editor.ui.MainView;
import realmeditor.util.IntPoint;

import util.IntPoint;

public class MEShapeTool extends METool {

    public function MEShapeTool(view:MainView) {
        super(METool.LINE_ID, view);
    }

    public override function init(tilePos:IntPoint, history:MapHistory):void {
        if (tilePos == null){
            return;
        }

        this.mainView.mapView.highlightTile(tilePos.x_, tilePos.y_);
    }

    public override function mouseMoved(tilePos:IntPoint, history:MapHistory):void {
        if (tilePos == null){
            return;
        }

        this.mainView.mapView.highlightTile(tilePos.x_, tilePos.y_);
    }
}
}
