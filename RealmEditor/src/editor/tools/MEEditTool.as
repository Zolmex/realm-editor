package editor.tools {
import editor.MEBrush;
import editor.MapTileData;
import editor.ui.MainView;
import editor.ui.MapHistory;
import editor.ui.MapView;

import util.IntPoint;

public class MEEditTool extends METool {

    public function MEEditTool(view:MainView) {
        super(METool.EDIT_ID, view);
    }

    public override function tileClick(tilePos:IntPoint, history:MapHistory):void {
        var tileData:MapTileData = this.mainView.mapView.tileMap.getTileData(tilePos.x_, tilePos.y_);
        if (tileData == null || tileData.objType == 0) {
            return;
        }

        this.mainView.showEditNameView(tilePos.x_, tilePos.y_, tileData.objCfg);
    }
}
}
