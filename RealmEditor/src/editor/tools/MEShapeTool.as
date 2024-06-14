package editor.tools {
import editor.MEBrush;
import editor.MapTileData;
import editor.ui.MainView;
import editor.ui.MapView;

import util.IntPoint;

public class MEShapeTool extends METool {

    public function MEShapeTool(view:MainView) {
        super(METool.LINE_ID, view);
    }
}
}
