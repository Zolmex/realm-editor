package editor {
import editor.ui.MapTileSprite;

public class MapActionDesc {

    public var actionId:int; // Different from tool id, check MEAction.as
    public var x:int;
    public var y:int;
    public var prevValue:*;
    public var newValue:*;

    public var finalUndoNode:Boolean = true;
    public var finalRedoNode:Boolean = true;

    public function MapActionDesc(actionId:int, x:int, y:int, prevValue:*, newValue:*) {
        this.actionId = actionId;
        this.x = x;
        this.y = y;
        this.prevValue = prevValue; // Tile information before performing this action
        this.newValue = newValue;
    }
}
}
