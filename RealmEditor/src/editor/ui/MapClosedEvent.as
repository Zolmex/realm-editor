package editor.ui {
import flash.events.Event;

public class MapClosedEvent extends Event {

    public var mapId:int;

    public function MapClosedEvent(str:String, mapId:int) {
        super(str);

        this.mapId = mapId;
    }
}
}
