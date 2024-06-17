package editor.actions {
import editor.actions.data.MapSelectData;
import editor.ui.MapView;

public class MapSelectAction extends MapAction {

    public var prevData:MapSelectData;
    public var newData:MapSelectData;

    public function MapSelectAction(prevData:MapSelectData, newData:MapSelectData) {
        this.prevData = prevData;
        this.newData = newData;
    }

    public override function doAction():void {
        var mapView:MapView = Main.View.mapView;
        if (this.newData.startX == -1){ // Assume the rest are also -1 to clear selection
            mapView.clearTileSelection();
            return;
        }

        mapView.drawTileSelection(this.newData.startX, this.newData.startY, this.newData.endX, this.newData.endY);
    }

    public override function undoAction():void {
        var mapView:MapView = Main.View.mapView;
        if (this.prevData.startX == -1){ // Assume the rest are also -1 to clear selection
            mapView.clearTileSelection();
            return;
        }

        mapView.drawTileSelection(this.prevData.startX, this.prevData.startY, this.prevData.endX, this.prevData.endY);
    }
}
}
