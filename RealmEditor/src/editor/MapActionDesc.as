package editor {
import editor.ui.MapTileSprite;

public class MapActionDesc {

    public var actionId:int; // Different from tool id, check MEAction.as
    public var mapX:int;
    public var mapY:int;
    public var prevValue:*;
    public var newValue:*;

    public var firstNode:Boolean = true;
    public var lastNode:Boolean = true;

    public function MapActionDesc(actionId:int, x:int, y:int, prevValue:*, newValue:*, firstNode:Boolean = true, lastNode:Boolean = true) {
        this.actionId = actionId;
        this.mapX = x;
        this.mapY = y;
        this.prevValue = prevValue; // Tile information before performing this action
        this.newValue = newValue;

        this.firstNode = firstNode;
        this.lastNode = lastNode;
    }
}
}
