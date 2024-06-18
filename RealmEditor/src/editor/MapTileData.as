package editor {
import flash.events.Event;
import flash.events.EventDispatcher;

public class MapTileData {

    public var groundType:int = -1; // These are the default values used everywhere
    public var objType:int = 0;
    public var objCfg:String;
    public var regType:int = 0;
    public var terrainType:int;
    public var elevation:int;

    public function clone():MapTileData {
        var ret:MapTileData = new MapTileData();
        ret.groundType = this.groundType;
        ret.objType = this.objType;
        ret.objCfg = this.objCfg;
        ret.regType = this.regType;
        ret.terrainType = this.terrainType;
        ret.elevation = this.elevation;
        return ret;
    }
}
}
