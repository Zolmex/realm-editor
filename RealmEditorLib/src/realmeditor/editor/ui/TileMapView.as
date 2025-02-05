package realmeditor.editor.ui {

import editor.MEEvent;

import editor.MapData;
import editor.MapTileData;

import flash.display.Bitmap;

import flash.display.BitmapData;

import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.Dictionary;

import realmeditor.editor.MEEvent;

import realmeditor.editor.MapData;

import realmeditor.editor.MapTileData;

public class TileMapView extends Sprite {

    public static const TILE_SIZE:Number = 8;

    private static var emptyBitmap:BitmapData = new BitmapData(TILE_SIZE, TILE_SIZE, true, 0);
    private static var emptyRegionBitmap:BitmapData = new BitmapData(1, 1, true, 0);

    private var mapData:MapData; // Contains the original map data (last saved data)
    private var tiles:Vector.<MapTileSprite>; // This is our own copy of the tile

    private var tileMapTexture:BitmapData;
    private var tileMap:Bitmap;
    private var objectMapTexture:BitmapData;
    private var objectMap:Bitmap;
    private var regionMapTexture:BitmapData;
    private var regionMap:Bitmap;

    private var highResObjLayer:Sprite; // For higher resolution object sprites
    private var highResObjSprites:Dictionary = new Dictionary();
    private var highResTileLayer:Sprite; // For higher resolution tile sprites
    private var highResTileSprites:Dictionary = new Dictionary();

    public function setup(mapData:MapData):void {
        this.mapData = mapData;
        this.tiles = new Vector.<MapTileSprite>(this.mapData.mapWidth * this.mapData.mapHeight);

        if (this.tileMapTexture) {
            this.tileMapTexture.dispose();
            removeChild(this.tileMap);
        }
        if (this.objectMapTexture) {
            this.objectMapTexture.dispose();
            removeChild(this.objectMap);
        }
        if (this.regionMapTexture) {
            this.regionMapTexture.dispose();
            removeChild(this.regionMap);
        }
        if (this.highResObjLayer) {
            this.highResObjLayer.removeChildren();
            removeChild(this.highResObjLayer);
        }
        if (this.highResTileLayer) {
            this.highResTileLayer.removeChildren();
            removeChild(this.highResTileLayer);
        }

        this.tileMapTexture = new BitmapData(TILE_SIZE * mapData.mapWidth, TILE_SIZE * mapData.mapHeight, true, 0);
        this.objectMapTexture = new BitmapData(TILE_SIZE * mapData.mapWidth, TILE_SIZE * mapData.mapHeight, true, 0);
        this.regionMapTexture = new BitmapData(mapData.mapWidth, mapData.mapHeight, true, 0);
        this.highResObjLayer = new Sprite();
        this.highResObjLayer.cacheAsBitmap = true;
        this.highResTileLayer = new Sprite();
        this.highResTileLayer.cacheAsBitmap = true;
    }

    // IMPORTANT: This should only be used when the map loads
    // Creates a new tile sprite object based on tile data
    public function loadTileFromMap(tileData:MapTileData, mapX:int, mapY:int):void {
//        trace("TILE LOADED, X:", x, "Y:", y);

        var idx:int = mapX + mapY * this.mapData.mapWidth;
        var tile:MapTileSprite = new MapTileSprite(mapX, mapY, mapX * TILE_SIZE, mapY * TILE_SIZE);

        this.tiles[idx] = tile; // Make sure we have a tile sprite object even though there's nothing in that tile
        if (tileData == null) {
            return;
        }

        tile.setTileData(tileData);
        this.drawTile(mapX, mapY);
    }

    public function drawTile(mapX:int, mapY:int):void {
        if (mapX < 0 || mapX >= this.mapData.mapWidth || mapY < 0 || mapY >= this.mapData.mapHeight) {
            return;
        }

        var idx:int = mapX + mapY * this.mapData.mapWidth;
        if (idx < 0 || idx >= this.tiles.length) {
            return;
        }
        var tile:MapTileSprite = this.tiles[idx];
        if (tile == null) {
            return;
        }

        // Clear space before drawing object
        this.objectMapTexture.copyPixels(emptyBitmap, new Rectangle(0, 0, emptyBitmap.width, emptyBitmap.height), new Point(tile.spriteX, tile.spriteY));
        if (this.highResObjSprites[idx] != null && this.highResObjLayer.contains(this.highResObjSprites[idx])) {
            this.highResObjLayer.removeChild(this.highResObjSprites[idx]);
            delete this.highResObjSprites[idx];
        }

        // Draw object
        if (tile.objTexture != null) {
            var size:int = Math.max(tile.objTexture.width, tile.objTexture.height);
            if (size != 8) { // Draw high quality texture, but also draw on the low quality bitmap for when camera is zoomed out
                var obj:Bitmap = new Bitmap(tile.objTexture);
                obj.scaleX = 8 / tile.objTexture.width;
                obj.scaleY = 8 / tile.objTexture.height;
                obj.x = tile.spriteX;
                obj.y = tile.spriteY;
                this.highResObjLayer.addChild(obj);
                this.highResObjSprites[idx] = obj; // Cache so that we can remove it later
            }

            var matrix:Matrix = new Matrix();
            matrix.scale(TILE_SIZE / tile.objTexture.width, TILE_SIZE / tile.objTexture.height);
            matrix.translate(tile.spriteX, tile.spriteY);

            this.objectMapTexture.draw(tile.objTexture, matrix);
        }

        // Draw region
        this.regionMapTexture.copyPixels(emptyRegionBitmap, new Rectangle(0, 0, emptyRegionBitmap.width, emptyRegionBitmap.height), new Point(mapX, mapY));
        if (tile.tileData.regType > 0) {
            this.regionMapTexture.fillRect(new Rectangle(mapX, mapY, 1, 1), 1593835520 | tile.regColor);
        }

        // Draw tile
        this.tileMapTexture.copyPixels(emptyBitmap, new Rectangle(0, 0, emptyBitmap.width, emptyBitmap.height), new Point(tile.spriteX, tile.spriteY));
        if (this.highResTileSprites[idx] != null && this.highResTileLayer.contains(this.highResTileSprites[idx])) {
            this.highResTileLayer.removeChild(this.highResTileSprites[idx]);
            delete this.highResTileSprites[idx];
        }

        if (tile.groundTexture != null) {
            var tileSize:int = Math.max(tile.groundTexture.width, tile.groundTexture.height);
            if (tileSize != 8) { // Draw high quality texture, but also draw on the low quality bitmap for when camera is zoomed out
                var tileTex:Bitmap = new Bitmap(tile.groundTexture);
                tileTex.scaleX = 8 / tile.groundTexture.width;
                tileTex.scaleY = 8 / tile.groundTexture.height;
                tileTex.x = tile.spriteX;
                tileTex.y = tile.spriteY;
                this.highResTileLayer.addChild(tileTex);
                this.highResTileSprites[idx] = tileTex; // Cache so that we can remove it later
            }

            matrix = new Matrix();
            matrix.scale(TILE_SIZE / tile.groundTexture.width, TILE_SIZE / tile.groundTexture.height);
            matrix.translate(tile.spriteX, tile.spriteY);

            this.tileMapTexture.draw(tile.groundTexture, matrix);
        }
    }

    // Note: don't forget to call drawTile() after this method
    public function setTileData(mapX:int, mapY:int, tileData:MapTileData):void {
        if (mapX < 0 || mapX >= this.mapData.mapWidth || mapY < 0 || mapY >= this.mapData.mapHeight) {
            return;
        }

        var idx:int = mapX + mapY * this.mapData.mapWidth;
        if (idx < 0 || idx >= this.tiles.length) {
            return;
        }
        var tile:MapTileSprite = this.tiles[idx];
        if (tile == null) { // Should never happen but eh
            return;
        }

        tile.setTileData(tileData);
        this.mapData.setTileData(mapX, mapY, tileData);
        this.dispatchEvent(new Event(MEEvent.MAP_CHANGED));
    }

    public function setTileGround(mapX:int, mapY:int, groundType:int):void { // Modify the tile's data, but don't draw unless we want to, in that case we cal drawTile()
        if (mapX < 0 || mapX >= this.mapData.mapWidth || mapY < 0 || mapY >= this.mapData.mapHeight) {
            return;
        }

        var idx:int = mapX + mapY * this.mapData.mapWidth;
        if (idx < 0 || idx >= this.tiles.length) {
            return;
        }
        var tile:MapTileSprite = this.tiles[idx];
        if (tile == null) { // Should never happen but eh
            return;
        }

        tile.setGroundType(groundType);
        this.mapData.setTileData(mapX, mapY, tile.tileData);
        this.dispatchEvent(new Event(MEEvent.MAP_CHANGED));
    }

    public function setTileObject(mapX:int, mapY:int, objType:int):void {
        if (mapX < 0 || mapX >= this.mapData.mapWidth || mapY < 0 || mapY >= this.mapData.mapHeight) {
            return;
        }

        var idx:int = mapX + mapY * this.mapData.mapWidth;
        if (idx < 0 || idx >= this.tiles.length) {
            return;
        }
        var tile:MapTileSprite = this.tiles[idx];
        if (tile == null) {
            return;
        }

        tile.setObjectType(objType);
        this.mapData.setTileData(mapX, mapY, tile.tileData);
        this.dispatchEvent(new Event(MEEvent.MAP_CHANGED));
    }

    public function setTileRegion(mapX:int, mapY:int, regType:int):void {
        if (mapX < 0 || mapX >= this.mapData.mapWidth || mapY < 0 || mapY >= this.mapData.mapHeight) {
            return;
        }

        var idx:int = mapX + mapY * this.mapData.mapWidth;
        if (idx < 0 || idx >= this.tiles.length) {
            return;
        }
        var tile:MapTileSprite = this.tiles[idx];
        if (tile == null) {
            return;
        }

        tile.setRegionType(regType);
        this.mapData.setTileData(mapX, mapY, tile.tileData);
        this.dispatchEvent(new Event(MEEvent.MAP_CHANGED));
    }

    public function onMapLoadEnd():void {
        this.tileMap = new Bitmap(this.tileMapTexture);
        addChild(this.tileMap);

        addChild(this.highResTileLayer);

        this.objectMap = new Bitmap(this.objectMapTexture);
        addChild(this.objectMap);

        addChild(this.highResObjLayer);

        this.regionMap = new Bitmap(this.regionMapTexture);
        this.regionMap.scaleX = TILE_SIZE;
        this.regionMap.scaleY = TILE_SIZE;
        addChild(this.regionMap);
    }

    public function getTileSprite(mapX:int, mapY:int):MapTileSprite {
        if (mapX < 0 || mapX >= this.mapData.mapWidth || mapY < 0 || mapY >= this.mapData.mapHeight) {
            return null;
        }

        var idx:int = mapX + mapY * this.mapData.mapWidth;
        if (idx < 0 || idx >= this.tiles.length) {
            return null;
        }
        return this.tiles[idx];
    }

    public function getTileData(mapX:int, mapY:int):MapTileData {
        if (mapX < 0 || mapX >= this.mapData.mapWidth || mapY < 0 || mapY >= this.mapData.mapHeight) {
            return null;
        }

        var idx:int = mapX + mapY * this.mapData.mapWidth;
        if (idx < 0 || idx >= this.tiles.length) {
            return null;
        }
        return this.tiles[idx].tileData;
    }

    public function clearGround(mapX:int, mapY:int):void {
        if (mapX < 0 || mapX >= this.mapData.mapWidth || mapY < 0 || mapY >= this.mapData.mapHeight) {
            return;
        }

        var idx:int = mapX + mapY * this.mapData.mapWidth;
        if (idx < 0 || idx >= this.tiles.length) {
            return;
        }
        var tile:MapTileSprite = this.tiles[idx];
        if (tile == null) {
            return;
        }

        this.setTileGround(mapX, mapY, -1); // 0 is dark water I think
        this.drawTile(mapX, mapY);
    }

    public function clearObject(mapX:int, mapY:int):void {
        if (mapX < 0 || mapX >= this.mapData.mapWidth || mapY < 0 || mapY >= this.mapData.mapHeight) {
            return;
        }

        var idx:int = mapX + mapY * this.mapData.mapWidth;
        if (idx < 0 || idx >= this.tiles.length) {
            return;
        }
        var tile:MapTileSprite = this.tiles[idx];
        if (tile == null) {
            return;
        }

        this.setTileObject(mapX, mapY, 0);
        this.drawTile(mapX, mapY);
    }

    public function clearRegion(mapX:int, mapY:int):void {
        if (mapX < 0 || mapX >= this.mapData.mapWidth || mapY < 0 || mapY >= this.mapData.mapHeight) {
            return;
        }

        var idx:int = mapX + mapY * this.mapData.mapWidth;
        if (idx < 0 || idx >= this.tiles.length) {
            return;
        }
        var tile:MapTileSprite = this.tiles[idx];
        if (tile == null) {
            return;
        }

        this.setTileRegion(mapX, mapY, 0);
        this.drawTile(mapX, mapY);
    }

    public function clearTile(mapX:int, mapY:int):void {
        this.clearGround(mapX, mapY);
        this.clearObject(mapX, mapY);
        this.clearRegion(mapX, mapY);
    }

    public function showHighQualityTiles(val:Boolean):void {
        this.highResTileLayer.visible = val;
    }

    public function showHighQualityObjects(val:Boolean):void {
        this.highResObjLayer.visible = val;
    }
}
}
