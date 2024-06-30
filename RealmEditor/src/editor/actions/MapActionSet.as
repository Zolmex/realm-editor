package editor.actions {

public class MapActionSet {

    public var empty:Boolean = true;
    private var normal:Vector.<MapAction>; // Used for undoing
    private var reversed:Vector.<MapAction>; // Used for redoing

    public function MapActionSet() {
        this.normal = new Vector.<MapAction>();
        this.reversed = new Vector.<MapAction>();
    }

    // Make actions redo when undoing and viceversa
    public function swap(val):void{
        var action:MapAction;
        for each (action in this.normal){
            action.swapped = val;
        }
        for each (action in this.reversed){
            action.swapped = val;
        }
    }

    public function push(action:MapAction):void { // Make sure you don't accidentally push null actions
        this.normal.insertAt(0, action); // Start undoing from last action to first
        this.reversed.push(action); // Start redoing from first to last
        this.empty = false;
    }

    public function pushSet(actions:MapActionSet):void {
        for each (var action:MapAction in actions) {
            this.normal.insertAt(0, action); // Start undoing from last action to first
            this.reversed.push(action); // Start redoing from first to last
        }
        this.empty = false;
    }

    public function undoAll():void {
        for each (var action:MapAction in this.normal){
            if (action.swapped){
                action.doAction();
            }
            else {
                action.undoAction();
            }
        }
    }

    public function redoAll():void {
        for each (var action:MapAction in this.reversed){
            if (action.swapped){
                action.undoAction();
            }
            else {
                action.doAction();
            }
        }
    }
}
}
