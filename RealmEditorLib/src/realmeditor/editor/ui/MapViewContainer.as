package realmeditor.editor.ui {
import flash.display.Sprite;
import flash.utils.Dictionary;

public class MapViewContainer extends Sprite {

    public var maps:Dictionary;

    public function MapViewContainer() {
        this.maps = new Dictionary();
    }

    public function trySaveMap(mapId:int):void {
        var map:MapView = this.maps[mapId] as MapView;
        if (map == null){
            return;
        }

        if (!map.mapData.savedChanges) {
            map.mapData.save(false);
        }
    }

    public function addMapView(mapView:MapView):int {
        mapView.visible = false;
        addChild(mapView);

        this.maps[mapView.id] = mapView;
        return mapView.id;
    }

    public function removeMapView(mapId:int):void {
        if (this.maps[mapId] == null){
            return;
        }

        removeChild(this.maps[mapId]);
        delete this.maps[mapId];
    }

    public function viewMap(mapId:int):MapView {
        if (this.maps[mapId] == null){
            return null;
        }

        for each (var map:MapView in this.maps){
            map.visible = false;
        }

        this.maps[mapId].visible = true;
        return this.maps[mapId];
    }
}
}
