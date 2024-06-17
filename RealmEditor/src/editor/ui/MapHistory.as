package editor.ui {
import editor.actions.MapAction;
import editor.actions.MapActionSet;

public class MapHistory {

    // We can change the present, we can revert actions from it and erase them (they are now the past), or we can make the erased actions come back (they are now the present, again)
    private var present:Vector.<MapActionSet>; // MapActionSet has all of the actions in normal and in reverse order
    private var erased:Vector.<MapActionSet>;

    public function MapHistory() {
        this.present = new Vector.<MapActionSet>();
        this.erased = new Vector.<MapActionSet>();
    }

    public function record(action:MapAction):void { // This is the actual present, things that aren't being redone
        var actionSet:MapActionSet = new MapActionSet();
        actionSet.push(action);
        this.present.push(actionSet);

        this.erased.length = 0; // Clear erased events, they're now forgotten, forever
    }

    public function recordSet(action:MapActionSet):void {
        this.present.push(action);
        this.erased.length = 0;
    }

    public function undo():void {
        if (this.present.length == 0){
            return;
        }

        var lastActions:MapActionSet = this.present.pop();
        lastActions.undoAll();

        this.erased.push(lastActions); // Here's where we change the past, and erase it
    }

    public function redo():void {
        if (this.erased.length == 0){
            return;
        }

        var erasedActions:MapActionSet = this.erased.pop();
        erasedActions.redoAll();

        this.present.push(erasedActions); // Here's where we go back to the present
    }
}
}
