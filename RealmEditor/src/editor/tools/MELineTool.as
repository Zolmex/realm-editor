package editor.tools {
import editor.MEBrush;
import editor.MapTileData;
import editor.ui.MainView;
import editor.MapHistory;
import editor.ui.MapView;

import util.IntPoint;

public class MELineTool extends METool {

    public function MELineTool(view:MainView) {
        super(METool.LINE_ID, view);
    }

    public override function init(tilePos:IntPoint, history:MapHistory):void {
        this.mainView.mapView.highlightTile(tilePos.x_, tilePos.y_);
    }

    public override function mouseMoved(tilePos:IntPoint, history:MapHistory):void {
        this.mainView.mapView.highlightTile(tilePos.x_, tilePos.y_);
    }
}
}
