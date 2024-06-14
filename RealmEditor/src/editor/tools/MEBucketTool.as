package editor.tools {
import editor.MEBrush;
import editor.ui.MainView;
import editor.ui.MapView;

import util.IntPoint;

public class MEBucketTool extends METool {

    public function MEBucketTool(view:MainView) {
        super(METool.BUCKET_ID, view);
    }

    public override function mouseDrag(tilePos:IntPoint):void {
        var userBrush:MEBrush = this.mainView.userBrush;
        var mapX:int = tilePos.x_;
        var mapY:int = tilePos.y_;

        // MapView code
    }
}
}
