package editor.actions {

public class MapActionSet {

    public var empty:Boolean = true;
    private var normal:Vector.<MapAction>; // Used for undoing
    private var reversed:Vector.<MapAction>; // Used for redoing

    public function MapActionSet() {
        this.normal = new Vector.<MapAction>();
        this.reversed = new Vector.<MapAction>();
    }

    public function push(action:MapAction):void {
        this.normal.insertAt(0, action); // Start undoing from last action to first
        this.reversed.push(action); // Start redoing from first to last
        this.empty = false;
    }

    public function undoAll():void {
        for each (var action:MapAction in this.normal){
            action.undoAction();
        }
    }

    public function redoAll():void {
        for each (var action:MapAction in this.reversed){
            action.doAction();
        }
    }
}
}
