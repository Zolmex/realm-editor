package realmeditor.editor.actions {

public class MapActionSet {

    public var empty:Boolean = true;
    private var reversed:Vector.<MapAction>; // Used for undoing
    private var normal:Vector.<MapAction>; // Used for redoing

    public function MapActionSet(original:MapActionSet = null) {
        this.reversed = new Vector.<MapAction>();
        this.normal = new Vector.<MapAction>();

        if (original != null){ // This means we're copying the original's data
            this.copy(original);
        }
    }

    // Make actions redo when undoing and viceversa
    public function swap(val:Boolean):void{
        var action:MapAction;
        for each (action in this.reversed){
            action.swapped = val;
        }
        for each (action in this.normal){
            action.swapped = val;
        }
    }

    public function push(action:MapAction):void { // Make sure you don't accidentally push null actions
        this.reversed.insertAt(0, action); // Start undoing from last action to first
        this.normal.push(action); // Start redoing from first to last
        this.empty = false;
    }

    public function pushSet(actions:MapActionSet):void {
        for each (var action:MapAction in actions.normal) {
            this.reversed.insertAt(0, action); // Start undoing from last action to first
            this.normal.push(action); // Start redoing from first to last
        }
        this.empty = false;
    }

    // Actions are undone from last to first
    public function undoAll():void {
        for each (var action:MapAction in this.reversed){
            if (action.swapped){
                action.doAction();
            }
            else {
                action.undoAction();
            }
        }
    }

    // Actions are redone from first to last
    public function redoAll():void {
        for each (var action:MapAction in this.normal){
            if (action.swapped){
                action.undoAction();
            }
            else {
                action.doAction();
            }
        }
    }

    public function clone():MapActionSet {
        return new MapActionSet(this);
    }

    private function copy(actions:MapActionSet):void {
        for each (var action:MapAction in actions.reversed){
            this.push(action.clone());
        }
    }
}
}
