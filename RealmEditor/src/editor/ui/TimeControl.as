package editor.ui {
import editor.actions.MapAction;

import flash.utils.Dictionary;

public class TimeControl {

    private var history:Dictionary;

    public function TimeControl() {
        this.history = new Dictionary(); // Key: map id, Value: MapTimeHistory.as
    }

    public function createHistory(mapId:int):void { // Note: this method will rewrite history if it already exists
        this.history[mapId] = new MapHistory();
    }

    public function getHistory(mapId:int):MapHistory {
        return this.history[mapId] as MapHistory;
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
