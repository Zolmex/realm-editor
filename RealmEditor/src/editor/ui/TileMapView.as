package editor.ui {
import assets.ground.GroundLibrary;
import assets.objects.ObjectLibrary;
import assets.regions.RegionLibrary;

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

public class TileMapView extends Sprite {

    public static const TILE_SIZE:Number = 8;

    private var mapData:MapData;
    private var tiles:Vector.<MapTileSprite>;

    private static var emptyBitmap:BitmapData = new BitmapData(TILE_SIZE, TILE_SIZE, true, 0);
    private static var emptyRegionBitmap:BitmapData = new BitmapData(1, 1, true, 0);

    private var tileMapTexture:BitmapData;
    private var tileMap:Bitmap;
    private var objectMapTexture:BitmapData;
    private var objectMap:Bitmap;
    private var regionMapTexture:BitmapData;
    private var regionMap:Bitmap;

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

        this.tileMapTexture = new BitmapData(TILE_SIZE * mapData.mapWidth, TILE_SIZE * mapData.mapHeight, true, 0);
        this.objectMapTexture = new BitmapData(TILE_SIZE * mapData.mapWidth, TILE_SIZE * mapData.mapHeight, true, 0);
        this.regionMapTexture = new BitmapData(mapData.mapWidth, mapData.mapHeight, true, 0);
    }

    public function drawTile(tileData:MapTileData, x:int, y:int):MapTileSprite { // IMPORTANT: this is only meant to be used when the map loads
        var idx:int = x + y * this.mapData.mapWidth;
        if (tileData == null) {
            this.tiles[idx] = null;
            this.mapData.tileDict[idx] = null;
            return null;
        }

        var tile:MapTileSprite = new MapTileSprite(x, y);
        tile.tileData = tileData;
        tile.texture = GroundLibrary.getBitmapData(tileData.groundType);
        tile.x = x * TILE_SIZE;
        tile.y = y * TILE_SIZE;
        this.tiles[idx] = tile;
        this.mapData.tileDict[idx] = tileData;

        // Draw object
        if (tileData.objType > 0) {
            var objTexture:BitmapData = ObjectLibrary.getTextureFromType(tileData.objType);
            if (objTexture != null) {
                var matrix:Matrix = new Matrix();
                matrix.scale(TILE_SIZE / objTexture.width, TILE_SIZE / objTexture.height);
                matrix.translate(tile.x, tile.y);

                // Clear space before drawing object
                this.objectMapTexture.copyPixels(emptyBitmap, new Rectangle(0, 0, emptyBitmap.width, emptyBitmap.height), new Point(tile.x, tile.y));
                this.objectMapTexture.draw(objTexture, matrix);
            }
        }

        if (tileData.regType > 0) {
            var regColor:uint = RegionLibrary.getColor(tileData.regType);
            this.regionMapTexture.fillRect(new Rectangle(x, y, 1, 1), 1593835520 | regColor);
        }

        // Draw tile
        if (tile.texture != null) {
            this.tileMapTexture.copyPixels(tile.texture, new Rectangle(0, 0, tile.texture.width, tile.texture.height), new Point(tile.x, tile.y));
        }

//        trace("TILE TEXTURE DRAWN X:", x, "Y:", y);
        return tile;
    }

    public function redrawTile(tileData:MapTileData, x:int, y:int):MapTileSprite { // IMPORTANT: use this for drawing after map is loaded
        var spriteX:int = x * TILE_SIZE;
        var spriteY:int = y * TILE_SIZE;
        var idx:int = x + y * this.mapData.mapWidth;
        if (tileData == null) {
            this.tiles[idx] = null;
            this.mapData.tileDict[idx] = null;
            this.tileMapTexture.copyPixels(emptyBitmap, new Rectangle(0, 0, emptyBitmap.width, emptyBitmap.height), new Point(spriteX, spriteY));
            this.objectMapTexture.copyPixels(emptyBitmap, new Rectangle(0, 0, emptyBitmap.width, emptyBitmap.height), new Point(spriteX, spriteY));
            this.regionMapTexture.copyPixels(emptyRegionBitmap, new Rectangle(0, 0, emptyRegionBitmap.width, emptyRegionBitmap.height), new Point(x, y));
            return null;
        }

        var tile:MapTileSprite = this.getTileSprite(x, y) || new MapTileSprite(x, y);
        tile.tileData = tileData;
        tile.texture = GroundLibrary.getBitmapData(tileData.groundType);
        tile.x = x * TILE_SIZE;
        tile.y = y * TILE_SIZE;
        this.tiles[idx] = tile;
        this.mapData.tileDict[idx] = tileData;

        // Draw object
        if (tileData.objType > 0) {
            var objTexture:BitmapData = ObjectLibrary.getTextureFromType(tileData.objType);
            if (objTexture != null) {
                var matrix:Matrix = new Matrix();
                matrix.scale(TILE_SIZE / objTexture.width, TILE_SIZE / objTexture.height);
                matrix.translate(tile.x, tile.y);

                // Clear space before drawing object
                this.objectMapTexture.copyPixels(emptyBitmap, new Rectangle(0, 0, emptyBitmap.width, emptyBitmap.height), new Point(tile.x, tile.y));
                this.objectMapTexture.draw(objTexture, matrix);
            }
        } else {
            this.objectMapTexture.copyPixels(emptyBitmap, new Rectangle(0, 0, emptyBitmap.width, emptyBitmap.height), new Point(spriteX, spriteY));
        }

        if (tileData.regType > 0) {
            var regColor:uint = RegionLibrary.getColor(tileData.regType);
            this.regionMapTexture.fillRect(new Rectangle(x, y, 1, 1), 1593835520 | regColor);
        } else {
            this.regionMapTexture.copyPixels(emptyRegionBitmap, new Rectangle(0, 0, emptyRegionBitmap.width, emptyRegionBitmap.height), new Point(x, y));
        }

        // Draw tile
        if (tile.texture != null) {
            this.tileMapTexture.copyPixels(tile.texture, new Rectangle(0, 0, tile.texture.width, tile.texture.height), new Point(tile.x, tile.y));
        } else {
            this.tileMapTexture.copyPixels(emptyBitmap, new Rectangle(0, 0, emptyBitmap.width, emptyBitmap.height), new Point(spriteX, spriteY));
        }

//        trace("TILE TEXTURE DRAWN X:", x, "Y:", y);
        return tile;
    }

    public function onMapLoadEnd():void {
        this.tileMap = new Bitmap(this.tileMapTexture);
        addChild(this.tileMap);

        this.objectMap = new Bitmap(this.objectMapTexture);
        addChild(this.objectMap);

        this.regionMap = new Bitmap(this.regionMapTexture);
        this.regionMap.scaleX = TILE_SIZE;
        this.regionMap.scaleY = TILE_SIZE;
        addChild(this.regionMap);
    }

    public function getTileData(x:int, y:int):MapTileData {
        var idx:int = x + y * this.mapData.mapWidth;
        if (idx < 0 || idx >= this.tiles.length) {
            return null;
        }
        var tile:MapTileSprite = this.tiles[idx];
        if (tile == null) {
            return null;
        }
        return tile.tileData;
    }

    public function getTileSprite(x:int, y:int):MapTileSprite {
        var idx:int = x + y * this.mapData.mapWidth;
        if (idx < 0 || idx >= this.tiles.length) {
            return null;
        }
        var tile:MapTileSprite = this.tiles[idx];
        if (tile == null) {
            return null;
        }
        return tile;
    }

    public function clearGround(x:int, y:int):void {
        var idx:int = x + y * this.mapData.mapWidth;
        if (idx < 0 || idx >= this.tiles.length) {
            return;
        }
        var tile:MapTileSprite = this.tiles[idx];
        if (tile == null) {
            return;
        }

        var spriteX:int = x * TILE_SIZE;
        var spriteY:int = y * TILE_SIZE;
        this.tileMapTexture.copyPixels(emptyBitmap, new Rectangle(0, 0, emptyBitmap.width, emptyBitmap.height), new Point(spriteX, spriteY));
        this.tiles[idx].tileData.groundType = -1;
    }

    public function clearObject(x:int, y:int):void {
        var idx:int = x + y * this.mapData.mapWidth;
        if (idx < 0 || idx >= this.tiles.length) {
            return;
        }
        var tile:MapTileSprite = this.tiles[idx];
        if (tile == null) {
            return;
        }

        var spriteX:int = x * TILE_SIZE;
        var spriteY:int = y * TILE_SIZE;
        this.objectMapTexture.copyPixels(emptyBitmap, new Rectangle(0, 0, emptyBitmap.width, emptyBitmap.height), new Point(spriteX, spriteY));
        this.tiles[idx].tileData.objType = 0;
    }

    public function clearRegion(x:int, y:int):void {
        var idx:int = x + y * this.mapData.mapWidth;
        if (idx < 0 || idx >= this.tiles.length) {
            return;
        }
        var tile:MapTileSprite = this.tiles[idx];
        if (tile == null) {
            return;
        }

        this.regionMapTexture.copyPixels(emptyRegionBitmap, new Rectangle(0, 0, emptyRegionBitmap.width, emptyRegionBitmap.height), new Point(x, y));
        this.tiles[idx].tileData.regType = 0;
    }
}
}
