package realmeditor {
import flash.events.Event;

public class RealmEditorTestEvent extends Event {

    public var mapJSON_:String;

    public function RealmEditorTestEvent(mapJSON:String) {
        super(Event.CONNECT);
        this.mapJSON_ = mapJSON;
    }
}
}
