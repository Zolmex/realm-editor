package editor.ui {
import editor.actions.MapAction;

import flash.utils.Dictionary;

public class TimeControl {

    private var history:Dictionary;

    public function TimeControl() {
        this.history = new Dictionary(); // Key: map id, Value: MapTimeHistory.as
    }

    public function recordAction(mapId:int, action:MapAction):void {
        var mapHistory:MapHistory = this.history[mapId] as MapHistory;
        if (mapHistory == null){
            mapHistory = new MapHistory();
        }

        mapHistory.record(action);
    }

    public function eraseHistory(mapId:int):void {
        if (this.history[mapId] != null){
            delete this.history[mapId];
        }
    }

    public function undoLastAction(mapId:int):void {
        var mapHistory:MapHistory = this.history[mapId] as MapHistory;
        if (mapHistory == null){
            return;
        }

        mapHistory.undo();
    }

    public function redoLastUndoneAction(mapId:int):void {
        var mapHistory:MapHistory = this.history[mapId] as MapHistory;
        if (mapHistory == null){
            return;
        }

        mapHistory.redo();
    }
}
}
