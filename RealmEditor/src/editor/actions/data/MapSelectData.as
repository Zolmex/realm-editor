package editor.actions.data {
import editor.actions.MapDragAction;

public class MapSelectData {

    public var startX:int;
    public var startY:int;
    public var endX:int;
    public var endY:int;
    public var width:int;
    public var height:int;
    public var lastDragAction:MapDragAction;

    public function MapSelectData(startX:int, startY:int, endX:int, endY:int, dragAction:MapDragAction = null) {
        this.startX = startX;
        this.startY = startY;
        this.endX = endX;
        this.endY = endY;
        this.lastDragAction = dragAction;

        this.width = this.endX - this.startX + 1;
        this.height = this.endY - this.startY + 1;
    }

    public function clone():MapSelectData{
        return new MapSelectData(this.startX, this.startY, this.endX, this.endY, this.lastDragAction);
    }
}
}
