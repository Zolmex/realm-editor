package editor.actions.data {

public class MapSelectData {

    public var startX:int;
    public var startY:int;
    public var endX:int;
    public var endY:int;

    public function MapSelectData(startX:int, startY:int, endX:int, endY:int) {
        this.startX = startX;
        this.startY = startY;
        this.endX = endX;
        this.endY = endY;
    }

    public function clone():MapSelectData{
        return new MapSelectData(this.startX, this.startY, this.endX, this.endY);
    }
}
}
