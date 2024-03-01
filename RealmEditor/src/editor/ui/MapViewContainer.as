package editor.ui {
import flash.display.Sprite;

public class MapViewContainer extends Sprite {

    private var maps:Vector.<MapView>;

    public function MapViewContainer() {
        this.maps = new Vector.<MapView>();
    }

    public function addMapView(mapView:MapView):int {
        mapView.visible = false;
        addChild(mapView);

        this.maps.push(mapView);

        return this.maps.length - 1;
    }

    public function removeMapView(mapId:int):void {
        if (mapId < 0 || mapId >= this.maps.length){
            return;
        }

        removeChild(this.maps[mapId]);
        this.maps.splice(mapId, 1);
    }

    public function viewMap(mapId:int):MapView {
        if (mapId < 0 || mapId >= this.maps.length){
            return null;
        }

        for (var i:int = 0; i < this.maps.length; i++){
            this.maps[i].visible = false;
        }

        this.maps[mapId].visible = true;
        return this.maps[mapId];
    }
}
}
