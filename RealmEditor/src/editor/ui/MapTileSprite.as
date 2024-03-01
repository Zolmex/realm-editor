package editor.ui {
import assets.ground.GroundLibrary;

import editor.MapTileData;

import flash.display.Bitmap;

import flash.display.BitmapData;

import flash.display.Sprite;

public class MapTileSprite {

    public var x:int;
    public var y:int;
    public var mapX:int;
    public var mapY:int;
    public var texture:BitmapData;
    public var tileData:MapTileData;

    public function MapTileSprite(mapX:int, mapY:int) {
        this.mapX = mapX;
        this.mapY = mapY;
    }
}
}
