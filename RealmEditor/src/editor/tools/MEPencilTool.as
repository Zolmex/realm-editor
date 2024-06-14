package editor.tools {
import editor.MEBrush;
import editor.ui.MainView;
import editor.ui.MapView;

import util.IntPoint;

public class MEPencilTool extends METool {

    public function MEPencilTool(view:MainView) {
        super(METool.PENCIL_ID, view);
    }

    public override function init(tilePos:IntPoint):void {
        if (!this.mainView.mapView.isInsideSelection(tilePos.x_, tilePos.y_, true)) {
            this.mainView.mapView.moveBrushTiles(tilePos.x_, tilePos.y_, this.mainView.userBrush);
        }
    }

    public override function mouseDrag(tilePos:IntPoint):void {
        var userBrush:MEBrush = this.mainView.userBrush;
        var mapX:int = tilePos.x_;
        var mapY:int = tilePos.y_;

        var brushRadius:int = (1 + (userBrush.size * 2)) / 2;
        for (var y:int = mapY - brushRadius; y <= mapY + brushRadius; y++) {
            for (var x:int = mapX - brushRadius; x <= mapX + brushRadius; x++) {
                var dx:int = x - mapX;
                var dy:int = y - mapY;
                var distSq:int = dx * dx + dy * dy;
                if (distSq > userBrush.size * userBrush.size) {
                    continue;
                }

                // MapView code
            }
        }
    }

    public override function tileClick(tilePos:IntPoint):void {
        var userBrush:MEBrush = this.mainView.userBrush;
        var mapX:int = tilePos.x_;
        var mapY:int = tilePos.y_;

        if (userBrush.size == 0) {
            // MapView code
            return;
        }

        var brushRadius:int = (1 + (userBrush.size * 2)) / 2;
        for (var y:int = mapY - brushRadius; y <= mapY + brushRadius; y++) {
            for (var x:int = mapX - brushRadius; x <= mapX + brushRadius; x++) {
                var dx:int = x - mapX;
                var dy:int = y - mapY;
                var distSq:int = dx * dx + dy * dy;
                if (distSq > userBrush.size * userBrush.size) {
                    continue;
                }

                // MapView code
            }
        }
    }

    public override function mouseMoved(tilePos:IntPoint):void {
        if (!this.mainView.mapView.isInsideSelection(tilePos.x_, tilePos.y_, true)) {
            this.mainView.mapView.highlightTile(tilePos.x_, tilePos.y_);
        }
    }
}
}
