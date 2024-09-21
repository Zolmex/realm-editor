package realmeditor.editor.ui {
import assets.GroundLibrary;
import assets.ObjectLibrary;
import assets.RegionLibrary;
import editor.MapTileData;

import flash.display.Bitmap;

import flash.display.BitmapData;

import flash.display.Sprite;

import realmeditor.assets.GroundLibrary;
import realmeditor.assets.ObjectLibrary;
import realmeditor.assets.RegionLibrary;

import realmeditor.editor.MapTileData;

public class MapTileSprite { // Contains the texture information for each tile sprite

    public var spriteX:int; // Position when rendered
    public var spriteY:int;
    public var mapX:int; // Tile position in the map
    public var mapY:int;

    public var tileData:MapTileData;
    public var groundTexture:BitmapData;
    public var objTexture:BitmapData;
    public var regColor:uint;

    public function MapTileSprite(mapX:int, mapY:int, spriteX:int, spriteY:int) {
        this.mapX = mapX;
        this.mapY = mapY;
        this.spriteX = spriteX;
        this.spriteY = spriteY;
        this.tileData = new MapTileData();
    }

    public function setGroundType(groundType:int):void{
        this.tileData.groundType = groundType;
        this.groundTexture = GroundLibrary.getBitmapData(groundType);
    }

    public function setObjectType(objType:int):void{
        this.tileData.objType = objType;
        this.objTexture = ObjectLibrary.getTextureFromType(objType);
    }

    public function setObjectCfg(cfg:String):void {
        this.tileData.objCfg = cfg;
    }

    public function setRegionType(regType:int):void{
        this.tileData.regType = regType;
        this.regColor = RegionLibrary.getColor(regType);
    }

    public function setTileData(tileData:MapTileData):void{ // Copy the values of a MapTileData object to our own tile data
        this.setGroundType(tileData == null ? -1 : tileData.groundType);
        this.setObjectType(tileData == null ? 0 : tileData.objType);
        this.setObjectCfg(tileData == null ? null : tileData.objCfg);
        this.setRegionType(tileData == null ? 0 : tileData.regType);
        this.tileData.elevation = tileData == null ? 0 : tileData.elevation;
        this.tileData.terrainType = tileData == null ? 0 : tileData.terrainType;
    }
}
}
