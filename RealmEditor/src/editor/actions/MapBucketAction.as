package editor.actions {
import editor.MapTileData;
import editor.ui.MapView;

public class MapBucketAction extends MapAction {

    private var mapX:int;
    private var mapY:int;
    private var prevTileData:MapTileData;
    private var newTileData:MapTileData;

    public function MapBucketAction(mapX:int, mapY:int, prevTileData:MapTileData, newTileData:MapTileData) {
        this.mapX = mapX;
        this.mapY = mapY;
        this.prevTileData = prevTileData;
        this.newTileData = newTileData;
    }

    public override function doAction():void {
        var mapView:MapView = Main.View.mapView;
        mapView.tileMap.setTileData(this.mapX, this.mapY, this.newTileData);
        mapView.tileMap.drawTile(this.mapX, this.mapY);
    }

    public override function undoAction():void {
        var mapView:MapView = Main.View.mapView;
        mapView.tileMap.setTileData(this.mapX, this.mapY, this.prevTileData);
        mapView.tileMap.drawTile(this.mapX, this.mapY);
    }
}
}
