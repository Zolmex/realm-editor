package realmeditor.editor {
import assets.GroundLibrary;
import assets.ObjectLibrary;
import assets.RegionLibrary;

import com.brokenfunction.json.decodeJson;
import com.brokenfunction.json.encodeJson;
import com.hurlant.util.Base64;

import editor.ui.TileMapView;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.geom.Rectangle;
import flash.net.FileFilter;
import flash.net.FileReference;
import flash.utils.ByteArray;
import flash.utils.Dictionary;
import flash.utils.Endian;

import realmeditor.assets.GroundLibrary;
import realmeditor.assets.ObjectLibrary;
import realmeditor.assets.RegionLibrary;
import realmeditor.editor.ui.MainView;
import realmeditor.editor.ui.MapView;

import realmeditor.editor.ui.TileMapView;
import realmeditor.util.BinaryUtils;
import realmeditor.util.TimedAction;

import util.BinaryUtils;

public class MapData extends EventDispatcher {

    public var tileDict:Dictionary;
    public var mapWidth:int;
    public var mapHeight:int;
    private var loadedFile:FileReference;
    private var selectedFile:FileReference;
    public var mapName:String;
    private var tileMap:TileMapView;
    public var savedChanges:Boolean;

    public function changeMapDimensions(mapView:MapView, width:int, height:int):void {
        var oldMapRect:Rectangle = this.getRealMapRect();
        var oldWidth:int = this.mapWidth;
        var oldHeight:int = this.mapHeight;
        var mapRectEndX:int = oldMapRect.x + oldMapRect.width - 1;
        var mapRectEndY:int = oldMapRect.y + oldMapRect.height - 1;
//        trace("[Rect] X:", oldMapRect.x, "Y:", oldMapRect.y, "Width:", oldMapRect.width, "Height:", oldMapRect.height);

        this.savedChanges = false;
        this.mapWidth = width;
        this.mapHeight = height;

        var xOffset:int = (width - oldWidth) / 2;
        var yOffset:int = (height - oldHeight) / 2;

        this.tileMap.setup(this);
        mapView.onMapLoadBegin();

        var newTileDict:Dictionary = new Dictionary();
        for (var yi:int = 0; yi < Math.max(height, oldHeight); yi++) {
            for (var xi:int = 0; xi < Math.max(width, oldWidth); xi++) {
                if (xi < width && yi < height &&
                        (xi < oldMapRect.x + xOffset || xi > mapRectEndX + xOffset || yi < oldMapRect.y + yOffset || yi > mapRectEndY + yOffset)){
                    this.tileMap.loadTileFromMap(null, xi, yi);
                }

                if (xi >= oldMapRect.x && xi <= mapRectEndX && yi >= oldMapRect.y && yi <= mapRectEndY) { // Current position is inside the "real" map area (area with tiles on it)
                    var newX:int = xi + xOffset; // Transform the current old map coordinate to the new map
                    var newY:int = yi + yOffset;
                    if (newX < 0 || newY < 0 || newX >= width || newY >= height || xi >= oldWidth || yi >= oldHeight) { // Out of bounds
                        continue;
                    }

                    var tile:MapTileData = this.tileDict[xi + yi * oldWidth];
                    newTileDict[newX + newY * width] = tile;
                    this.tileMap.loadTileFromMap(tile, newX, newY); // If tile is null when this method is called, the tilemap will create an empty tile data, while the map data holds a null value
                }
            }
        }
        this.tileDict = newTileDict;

        mapView.onMapLoadEnd();
    }

    private function getRealMapRect():Rectangle {
        var minX:int = this.mapWidth;
        var minY:int = this.mapHeight;
        var maxX:int = 0;
        var maxY:int = 0;

        for (var y:int = 0; y < this.mapHeight; y++) {
            for (var x:int = 0; x < this.mapWidth; x++) {
                var tile:MapTileData = this.tileDict[x + y * this.mapWidth];
                if (tile == null) {
                    continue;
                }

                if (x < minX) {
                    minX = x;
                }
                if (y < minY) {
                    minY = y;
                }
                if (x > maxX) {
                    maxX = x;
                }
                if (y > maxY) {
                    maxY = y;
                }
            }
        }

        return new Rectangle(minX, minY, maxX - minX + 1, maxY - minY + 1);
    }

    public function newMap(tileMap:TileMapView, name:String, width:int, height:int):void {
        this.savedChanges = false;
        this.tileMap = tileMap;
        this.tileMap.addEventListener(MEEvent.MAP_CHANGED, this.onMapChanged);
        this.mapName = name;
        this.mapWidth = width;
        this.mapHeight = height;

        this.tileMap.setup(this);
        this.dispatchEvent(new Event(MEEvent.MAP_LOAD_BEGIN));

        this.tileDict = new Dictionary();
        for (var yi:int = 0; yi < height; yi++) {
            for (var xi:int = 0; xi < width; xi++) {
                tileMap.loadTileFromMap(null, xi, yi); // Empty tiles
            }
        }

        this.dispatchEvent(new Event(MEEvent.MAP_LOAD_END));
    }

    public function save(wmap:Boolean, autoSave:Boolean = false):void {
        if (this.tileDict == null || this.tileDict.length == 0) {
            return;
        }

        var mapBytes:ByteArray = wmap ? this.exportWmap() : this.exportJson();
        if (mapBytes == null || mapBytes.length == 0) {
            return;
        }

        var fullMapName:String = this.mapName + (wmap ? ".wmap" : ".jm");
        if (!autoSave) {
            var saveFile:FileReference = new FileReference(); // Prompts the user to save to a specific folder
            saveFile.addEventListener(Event.SELECT, this.onMapSaved);
            saveFile.save(mapBytes, fullMapName);
        } else { // Automatic saving every 15 seconds
            var autoSaveFolder:File = File.workingDirectory.resolvePath("autoSave");
            autoSaveFolder.createDirectory(); // This will create the directory if it doesn't exist already

            var file:File = autoSaveFolder.resolvePath(fullMapName);
            var fs:FileStream = new FileStream();
            fs.open(file, FileMode.WRITE);
            fs.writeBytes(mapBytes);
            fs.close();
            this.onMapSaved(null); // Force save event
        }
    }

    private function onMapSaved(e:Event):void {
        this.savedChanges = true;
        this.dispatchEvent(new Event(MEEvent.MAP_SAVED));
    }

    private function onMapChanged(e:Event):void {
        this.savedChanges = false;
    }

    public function load(tileMap:TileMapView):void {
        this.tileMap = tileMap;
        this.tileMap.addEventListener(MEEvent.MAP_CHANGED, this.onMapChanged);
        this.loadedFile = new FileReference();
        this.loadedFile.addEventListener(Event.SELECT, this.onFileBrowseSelect);
        this.loadedFile.browse([new FileFilter("Map file (*.jm, *.wmap)", "*.jm;*.wmap")]);
    }

    private function onFileBrowseSelect(e:Event):void {
        this.selectedFile = e.target as FileReference;
        MainView.Instance.notifications.showNotification("Loading map " + this.selectedFile.name + "...");
        MainView.Instance.timers.push(new TimedAction(100, this.finishLoadFile));
    }

    private function finishLoadFile():void {
        this.selectedFile.addEventListener(Event.COMPLETE, this.onFileLoadComplete);
        this.selectedFile.addEventListener(IOErrorEvent.IO_ERROR, onFileLoadIOError);
        try {
            this.loadedFile.load();
        } catch (e:Error) {
            trace("Error: " + e);
        }
    }

    private function onFileLoadComplete(e:Event):void {
        this.savedChanges = true;
        var loadedFile:FileReference = e.target as FileReference;
        var wmapIdx:int = loadedFile.name.indexOf(".wmap");
        if (wmapIdx != -1) {
            this.mapName = loadedFile.name.substr(0, wmapIdx);
            this.loadWMap(loadedFile.data);
            return;
        }

        var jsonIdx:int = loadedFile.name.indexOf(".jm");
        if (jsonIdx == -1) {
            return;
        }

        this.mapName = loadedFile.name.substr(0, jsonIdx);
        var jm:Object = decodeJson(loadedFile.data.toString());
        this.mapWidth = jm["width"];
        this.mapHeight = jm["height"];

        this.tileMap.setup(this);
        this.dispatchEvent(new Event(MEEvent.MAP_LOAD_BEGIN));

        var dict:Array = jm["dict"];
        var byteArray:ByteArray = Base64.decodeToByteArray(jm["data"]);
        byteArray.uncompress();
        this.tileDict = new Dictionary();
        for (var yi:int = 0; yi < this.mapHeight; yi++) {
            for (var xi:int = 0; xi < this.mapWidth; xi++) {
                var entry:Object = dict[byteArray.readShort()];
                if (entry == null) {
                    trace("NULL ENTRY");
                    this.tileMap.loadTileFromMap(null, xi, yi);
                    continue;
                }
                if (entry.hasOwnProperty("ground")) {
                    var groundType:int = GroundLibrary.idToType_[entry["ground"]];
                    this.updateTileGround(xi, yi, groundType);
                }
                var objs:Array = entry["objs"];
                if (objs != null) {
                    for each(var obj:Object in objs) {
                        if (!ObjectLibrary.idToType_.hasOwnProperty(obj["id"])) {
                            trace("ERROR: Unable to find: " + obj["id"]);
                        } else {
                            var objType:int = ObjectLibrary.idToType_[obj["id"]];
                            this.updateTileObject(xi, yi, objType);
                            if (obj.hasOwnProperty("name")) {
                                this.updateTileObjectName(xi, yi, obj["name"]);
                            }
                        }
                    }
                }
                var regions:Array = entry["regions"];
                if (regions != null) {
                    for each(var region:Object in regions) {
                        var regType:int = RegionLibrary.idToType_[region["id"]];
                        this.updateTileRegion(xi, yi, regType);
                    }
                }
//                trace("TILE DATA X:", xi, "Y:", yi);

                this.tileMap.loadTileFromMap(getTile(xi, yi), xi, yi);
            }
        }
        this.dispatchEvent(new Event(MEEvent.MAP_LOAD_END));
    }

    private function loadWMap(origData:ByteArray):void {
        var data:ByteArray = new ByteArray();
        data.writeBytes(origData, 1, origData.length - 1);
        var ver:int = origData.readUnsignedByte();
        if (ver < 0 || ver > 2) {
            trace("INVALID WMAP VERSION");
            return;
        }

//        trace("WMAP VERSION", ver);
        data.uncompress();
        data.endian = Endian.LITTLE_ENDIAN;
        var tileCount:int = data.readShort();
//        trace("WMAP TILE COUNT", tileCount);
        var tiles:Vector.<MapTileData> = new Vector.<MapTileData>(tileCount);
        for (var i:int = 0; i < tileCount; i++) {
            var tileType:int = data.readUnsignedShort();
            var objIdLen:int = BinaryUtils.Read7BitEncodedInt(data);
            var objId:String = data.readMultiByte(objIdLen, "utf-8");
            var objCfgLen:int = BinaryUtils.Read7BitEncodedInt(data);
            var objCfg:String = data.readMultiByte(objCfgLen, "utf-8");
            var terrainType:int = data.readUnsignedByte();
            var regionType:int = data.readUnsignedByte();
            var elevation:int = 0;
            if (ver == 1) {
                elevation = data.readUnsignedByte();
            }

            var tile:MapTileData = new MapTileData();
            tile.groundType = tileType == 65535 ? -1 : tileType;
            if (objId != "" && !ObjectLibrary.idToType_.hasOwnProperty(objId)) {
                trace("ERROR: Unable to find: " + objId);
            } else {
                var objType:int = ObjectLibrary.idToType_[objId];
                tile.objType = objType;
            }
            tile.objCfg = objCfg;
            tile.terrainType = terrainType;
            tile.regType = regionType;
            tile.elevation = elevation;

            tiles[i] = tile;
//            trace("WMAP TILE DATA #", i);
        }

        this.mapWidth = data.readInt();
        this.mapHeight = data.readInt();
//        trace("WIDTH", this.mapWidth, "HEIGHT", this.mapHeight);

        this.tileMap.setup(this);
        this.dispatchEvent(new Event(MEEvent.MAP_LOAD_BEGIN));

        this.tileDict = new Dictionary();
        for (var y:int = 0; y < this.mapHeight; y++) {
            for (var x:int = 0; x < this.mapWidth; x++) {
                tile = tiles[data.readShort()].clone();
                if (ver == 2) {
                    tile.elevation = data.readUnsignedByte();
                }

                this.tileDict[x + y * this.mapWidth] = tile;
                this.tileMap.loadTileFromMap(tile, x, y);
            }
        }
        this.dispatchEvent(new Event(MEEvent.MAP_LOAD_END));
    }

    private static function onFileLoadIOError(e:Event):void {
        trace("JM Map load error: " + e);
    }

    public function setTileData(x:int, y:int, tileData:MapTileData):void {
        var tile:MapTileData = this.getTile(x, y);
        if (tileData == null && tile == null) {
            return;
        }

        if (tile == null){
            tile = this.createTile(x, y);
        }

        tile.copy(tileData);
    }

    public function getTile(x:int, y:int):MapTileData {
        var index:int = x + y * this.mapWidth;
        var tile:MapTileData = this.tileDict[index];
        return tile;
    }

    private function createTile(x:int, y:int):MapTileData {
        var index:int = x + y * this.mapWidth;
        var tile:MapTileData = new MapTileData();
        this.tileDict[index] = tile;
        return tile;
    }

    private function updateTileGround(x:int, y:int, groundType:int):void {
        var tile:MapTileData = this.getTile(x, y) || createTile(x, y);
        tile.groundType = groundType;
    }

    private function updateTileObject(x:int, y:int, objType:int):void {
        var tile:MapTileData = this.getTile(x, y) || createTile(x, y);
        tile.objType = objType;
    }

    private function updateTileObjectName(x:int, y:int, objName:String):void {
        var tile:MapTileData = this.getTile(x, y) || createTile(x, y);
        tile.objCfg = objName;
    }

    private function updateTileRegion(x:int, y:int, regType:int):void {
        var tile:MapTileData = this.getTile(x, y) || createTile(x, y);
        tile.regType = regType;
    }

    private function exportWmap():ByteArray {
        var ret:ByteArray = new ByteArray();
        var ver:int = 1;
        ret.writeByte(ver);

        var tiles:Vector.<MapTileData> = new Vector.<MapTileData>();
        var tileData:ByteArray = new ByteArray();
        tileData.endian = Endian.LITTLE_ENDIAN;
        for (var y:int = 0; y < this.mapHeight; y++) {
            for (var x:int = 0; x < this.mapWidth; x++) {
                tile = this.tileMap.getTileData(x, y);

                var idx:int = -1;
                for (var i:int = 0; i < tiles.length; i++) {
                    if (tiles[i].groundType == tile.groundType &&
                            tiles[i].objType == tile.objType &&
                            tiles[i].regType == tile.regType &&
                            tiles[i].objCfg == tile.objCfg &&
                            tiles[i].terrainType == tile.terrainType) {
                        idx = i;
                        break;
                    }
                }

                if (idx == -1) {
                    idx = tiles.length;
                    tiles.push(tile);
                }

                tileData.writeShort(idx);

                if (ver == 2) {
                    tileData.writeByte(tile.elevation * 255);
                }
            }
        }

        var mapData:ByteArray = new ByteArray();
        mapData.endian = Endian.LITTLE_ENDIAN;

        var tileCount:int = tiles.length;
        mapData.writeShort(tileCount);
        for (i = 0; i < tileCount; i++) {
            var tile:MapTileData = tiles[i];
            mapData.writeShort(tile.groundType);
            var objId:String = ObjectLibrary.getIdFromType(tile.objType);
            BinaryUtils.Write7BitEncodedInt(mapData, objId ? objId.length : 0);
            mapData.writeMultiByte(objId ? objId : "", "utf-8");
            var objCfg:String = tile.objCfg;
            BinaryUtils.Write7BitEncodedInt(mapData, objCfg ? objCfg.length : 0);
            mapData.writeMultiByte(objCfg ? objCfg : "", "utf-8");
            mapData.writeByte(tile.terrainType);
            mapData.writeByte(tile.regType);
            if (ver == 1) {
                mapData.writeByte(tile.elevation);
            }
        }

        mapData.writeInt(this.mapWidth);
        mapData.writeInt(this.mapHeight);
        mapData.writeBytes(tileData);

        mapData.compress();
        ret.writeBytes(mapData);
        return ret;
    }

    private function exportJson():ByteArray {
        var ret:ByteArray = new ByteArray();
        var json:String = getMapJsonString();
        ret.writeMultiByte(json, "utf-8");
        return ret;
    }

    public function getMapJsonString():String {
        var jm:Object = {};

        jm["width"] = this.mapWidth;
        jm["height"] = this.mapHeight;

        var dict:Object = {};
        var entries:Array = [];
        var indices:ByteArray = new ByteArray();
        var index:int;
        for (var yi:int = 0; yi < this.mapHeight; yi++) {
            for (var xi:int = 0; xi < this.mapWidth; xi++) {
                var entry:Object = this.getJsonTile(xi, yi);
                var entryJSON:String = encodeJson(entry);
                if (!dict.hasOwnProperty(entryJSON)) {
                    index = entries.length;
                    dict[entryJSON] = index;
                    entries.push(entry);
                } else {
                    index = dict[entryJSON];
                }
                indices.writeShort(index);
            }
        }
        jm["dict"] = entries;
        indices.compress();
        jm["data"] = Base64.encodeByteArray(indices);
        return encodeJson(jm);
    }

    private function getJsonTile(x:int, y:int):Object {
        var ret:Object = {};
        var tileData:MapTileData = this.tileMap.getTileData(x, y);
        if (tileData == null) {
            return ret;
        }

        if (tileData.groundType != -1) {
            ret["ground"] = GroundLibrary.getIdFromType(tileData.groundType);
        }
        if (tileData.objType != 0) {
            var obj:Object = {"id": ObjectLibrary.getIdFromType(tileData.objType)};
            if (tileData.objCfg != null) {
                obj["name"] = tileData.objCfg;
            }
            ret["objs"] = [obj];
        }
        if (tileData.regType != 0) {
            var reg:Object = {"id": RegionLibrary.getIdFromType(tileData.regType)};
            ret["regions"] = [reg];
        }
        return ret;
    }
}
}
