package editor.ui {
import editor.actions.MapAction;
import editor.actions.MapActionSet;

public class MapHistory {

    // We can change the present, we can revert actions from it and erase them (they are now the past), or we can make the erased actions come back (they are now the present, again)
    public var present:Vector.<MapActionSet>; // MapActionSet has all of the actions in normal and in reverse order
    public var erased:Vector.<MapActionSet>;
    public var linear:Boolean;

    public function MapHistory(linear:Boolean = true) {
        this.linear = linear;
        this.present = new Vector.<MapActionSet>();
        this.erased = new Vector.<MapActionSet>();
    }

    public function record(action:MapAction):void { // This is the actual present, things that aren't being redone
        var actionSet:MapActionSet = new MapActionSet();
        actionSet.push(action);
        this.present.push(actionSet);

        if (this.linear) {
            this.erased.length = 0; // Clear erased events, they're now forgotten, forever
        }
    }

    public function recordSet(actions:MapActionSet):void {
        if (actions.empty) { // Let's make sure we don't add empty actions
            return;
        }

        this.present.push(actions);
        if (this.linear) {
            this.erased.length = 0;
        }
    }

    public function undo():MapActionSet {
        if (this.present.length == 0) {
            return null;
        }

        var lastActions:MapActionSet = this.present.pop();
        lastActions.undoAll();

        this.erased.push(lastActions); // Here's where we change the past, and erase it
        return lastActions;
    }

    public function redo():MapActionSet {
        if (this.erased.length == 0) {
            return null;
        }

        var erasedActions:MapActionSet = this.erased.pop();
        erasedActions.redoAll();

        this.present.push(erasedActions); // Here's where we go back to the present
        return erasedActions;
    }
}
}
