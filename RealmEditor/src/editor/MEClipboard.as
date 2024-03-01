package editor {

public class MEClipboard {

    public var width:int;
    public var height:int;
    public var tiles:Vector.<MapTileData>;

    public function setSize(width:int, height:int):void {
        this.width = width;
        this.height = height;
        this.tiles = new Vector.<MapTileData>(width * height);
    }

    public function addTile(tile:MapTileData, x:int, y:int):void {
        var idx:int = x + y * this.width;
        if (idx < 0 || idx >= this.tiles.length) {
            return;
        }

        this.tiles[idx] = tile;
    }

    public function getTile(x:int, y:int):MapTileData {
        var idx:int = x + y * this.width;
        if (idx < 0 || idx >= this.tiles.length) {
            return null;
        }

        return this.tiles[idx];
    }

    public function clear():void {
        this.width = 0;
        this.height = 0;
        this.tiles = null;
    }
}
}
