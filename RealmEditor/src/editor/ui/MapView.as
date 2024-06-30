package editor.ui {
import assets.ground.GroundLibrary;
import assets.objects.ObjectLibrary;
import assets.regions.RegionLibrary;

import editor.actions.MapAction;
import editor.MEBrush;
import editor.MEClipboard;
import editor.MEDrawType;
import editor.actions.MapActionSet;
import editor.actions.MapReplaceTileAction;
import editor.actions.MapSelectAction;
import editor.actions.data.MapSelectData;
import editor.tools.MESelectTool;
import editor.tools.METool;
import editor.actions.MapAction;
import editor.actions.MapAction;
import editor.MapData;
import editor.MapTileData;

import flash.display.Bitmap;

import flash.display.BitmapData;

import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.Dictionary;

import util.IntPoint;

public class MapView extends Sprite {

    public var id:int; // Id of the map (based on load/create order)
    public var mapData:MapData;
    public var tileMap:TileMapView;
    public var mapOffset:IntPoint;
    public var zoomLevel:int = 100;
    public var gridEnabled:Boolean;
    private var gridTexture:BitmapData;
    private var grid:Bitmap;

    public var selectionSize:IntPoint;
    public var selectionPos:Shape;
    private var highlightRect:Shape;
    private var brushPencil:Bitmap; // Draws a transparent view of the tiles (ground/object/region) the user will be painting on the map
    private var brushElementType:int;
    private var brushTextureType:int;

    public function MapView(id:int, mapData:MapData) {
        this.id = id;
        this.mapData = mapData;
        this.mapOffset = new IntPoint();

        this.grid = new Bitmap(null);
        this.grid.visible = false;
        addChild(this.grid);

        this.tileMap = new TileMapView();
        addChild(this.tileMap);

        this.highlightRect = new Shape();
        addChild(this.highlightRect);

        this.selectionSize = new IntPoint(0, 0);
        this.selectionPos = new Shape();
        addChild(this.selectionPos);

        this.brushPencil = new Bitmap();
        this.brushPencil.alpha = 0.9;
        addChild(this.brushPencil);
    }

    private function drawGrid():void {
        for (var i:int = 0; i <= this.mapData.mapWidth; i++) { // Vertical lines
            var x:Number = TileMapView.TILE_SIZE * i;
            this.gridTexture.fillRect(new Rectangle(x, 0, 1, this.gridTexture.height), 1593835520 | 0xFF0000);
        }
        for (i = 0; i <= this.mapData.mapHeight; i++) { // Horizontal lines
            var y:Number = TileMapView.TILE_SIZE * i;
            this.gridTexture.fillRect(new Rectangle(0, y, this.gridTexture.width, 1), 1593835520 | 0xFF0000);
        }

        this.grid.bitmapData = this.gridTexture;
    }

    public function onMapLoadBegin():void {
//        trace("GRAPHICS CLEARED");

        this.selectionSize.x_ = 0;
        this.selectionSize.y_ = 0;
        this.selectionPos.graphics.clear();
        this.highlightRect.graphics.clear();
        // Clear user and undo actions

        this.tileMap.graphics.clear();
        if (this.gridTexture) {
            this.gridTexture.dispose();
            this.gridTexture = null;
        }

        this.gridTexture = new BitmapData(TileMapView.TILE_SIZE * this.mapData.mapWidth, TileMapView.TILE_SIZE * this.mapData.mapHeight, true, 0);
    }

    public function onMapLoadEnd():void {
//        trace("MAP LOADED");

        this.tileMap.onMapLoadEnd();
        this.drawGrid();
    }

    public function toggleGrid():Boolean {
        if (this.grid == null) {
            return false;
        }
        var val:Boolean = this.grid.visible = !this.grid.visible;
        this.gridEnabled = val;
        return val;
    }

    public function recordSelectionClear(history:MapHistory):void{
        var prevSelectionPos:Shape = this.selectionPos;
        var prevSelectionSize:IntPoint = this.selectionSize;
        var prevStartX:int = prevSelectionPos.x / TileMapView.TILE_SIZE;
        var prevStartY:int = prevSelectionPos.y / TileMapView.TILE_SIZE;
        var prevSelectionData:MapSelectData = new MapSelectData(prevStartX, prevStartY, prevStartX + prevSelectionSize.x_ - 1, prevStartY + prevSelectionSize.y_ - 1);
        history.record(new MapSelectAction(prevSelectionData, MESelectTool.CLEARED_DATA));
    }

    public function clearTileSelection():void {
        this.selectionSize.x_ = 0;
        this.selectionSize.y_ = 0;
        this.selectionPos.graphics.clear();
    }

    public function selectTileArea(mapStartX:int, mapStartY:int, mapEndX:int, mapEndY:int):void { // Use this for selecting a rectangle area of tiles by holding left mouse button
        var beginX:int = mapStartX < mapEndX ? mapStartX : mapEndX;
        var beginY:int = mapStartY < mapEndY ? mapStartY : mapEndY;
        var endX:int = mapStartX < mapEndX ? mapEndX : mapStartX;
        var endY:int = mapStartY < mapEndY ? mapEndY : mapStartY;

        this.drawTileSelection(beginX, beginY, endX, endY); // Redraw the tile selection rectangle
    }

    public function highlightTile(mapX:int, mapY:int):void { // Draws rectangle over hovered tile
        var g:Graphics = this.highlightRect.graphics;
        g.clear(); // Always clear the highlight first

        if (mapX < 0 || mapX > this.mapData.mapWidth || mapY < 0 || mapY > this.mapData.mapHeight) {
            return;
        }

        var x:int = mapX * TileMapView.TILE_SIZE;
        var y:int = mapY * TileMapView.TILE_SIZE;
        var width:int = TileMapView.TILE_SIZE;
        var height:int = TileMapView.TILE_SIZE;

        g.lineStyle(1, 0xFFFFFF, 0.5);
        g.drawRect(x, y, width, height);
        g.lineStyle();
    }

    public function hideBrushTiles():void {
        this.brushPencil.visible = false;
    }

    public function moveBrushTiles(mapX:int, mapY:int, brush:MEBrush):void {
        if (brush.elementType != this.brushElementType) { // Re-draw if the draw type has changed
            this.drawBrushTiles(mapX, mapY, brush);
            return;
        }

        switch (brush.elementType) { // If element type matches, re-draw if the texture we're drawing also has changed
            case MEDrawType.GROUND:
                if (brush.groundType != this.brushTextureType) {
                    this.drawBrushTiles(mapX, mapY, brush);
                    return;
                }
                break;
            case MEDrawType.OBJECTS:
                if (brush.objType != this.brushTextureType) {
                    this.drawBrushTiles(mapX, mapY, brush);
                    return;
                }
                break;
            case MEDrawType.REGIONS:
                if (brush.regType != this.brushTextureType) {
                    this.drawBrushTiles(mapX, mapY, brush);
                    return;
                }
                break;
        }

        this.brushPencil.x = (mapX - brush.size) * TileMapView.TILE_SIZE;
        this.brushPencil.y = (mapY - brush.size) * TileMapView.TILE_SIZE;
        this.brushPencil.visible = true;
    }

    public function drawBrushTiles(mapX:int, mapY:int, brush:MEBrush):void {
        var regColor:uint;
        var groundTexture:BitmapData;
        var objectTexture:BitmapData;

        this.brushElementType = brush.elementType;
        switch (brush.elementType) {
            case MEDrawType.GROUND:
                if (brush.groundType == -1) {
                    return;
                }

                groundTexture = GroundLibrary.getBitmapData(brush.groundType);
                this.brushTextureType = brush.groundType;
                break;
            case MEDrawType.OBJECTS:
                if (brush.objType == 0) {
                    return;
                }

                objectTexture = ObjectLibrary.getTextureFromType(brush.objType);
                this.brushTextureType = brush.objType;
                break;
            case MEDrawType.REGIONS:
                if (brush.regType == 0) {
                    return;
                }

                regColor = RegionLibrary.getColor(brush.regType);
                this.brushTextureType = brush.regType;
                break;
        }

        var diameter:int = (1 + (brush.size * 2)); // Times 2 because we have tiles on the front and on the back
        var center:int = diameter / 2;
        var bitmapSize:int = diameter * TileMapView.TILE_SIZE;
        var brushTexture:BitmapData = new BitmapData(bitmapSize, bitmapSize, true, 0);
        for (var yi:int = 0; yi <= diameter; yi++) { // The brush size represents the amount of tiles from the center we will render
            for (var xi:int = 0; xi <= diameter; xi++) {
                var dx:int = xi - center;
                var dy:int = yi - center;
                var distSq:int = dx * dx + dy * dy;
                if (distSq > brush.size * brush.size) {
                    continue;
                }

                if (groundTexture != null) {
                    brushTexture.copyPixels(groundTexture, new Rectangle(0, 0, groundTexture.width, groundTexture.height), new Point(xi * TileMapView.TILE_SIZE, yi * TileMapView.TILE_SIZE));
                } else if (objectTexture != null) {
                    brushTexture.copyPixels(objectTexture, new Rectangle(0, 0, objectTexture.width, objectTexture.height), new Point(xi * TileMapView.TILE_SIZE, yi * TileMapView.TILE_SIZE));
                } else { // Must mean we're rendering a region
                    brushTexture.fillRect(new Rectangle(xi * TileMapView.TILE_SIZE, yi * TileMapView.TILE_SIZE, 1, 1), 1593835520 | regColor);
                }
            }
        }

        if (this.brushPencil.bitmapData != null) { // Make sure to clear our previous textures before we start drawing again
            this.brushPencil.bitmapData.dispose();
            this.brushPencil.bitmapData = null;
        }

        this.brushPencil.bitmapData = brushTexture;
        this.brushPencil.x = (mapX - brush.size) * TileMapView.TILE_SIZE;
        this.brushPencil.y = (mapY - brush.size) * TileMapView.TILE_SIZE;
        this.brushPencil.visible = true;
    }

    public function drawTileSelection(mapStartX:int, mapStartY:int, mapEndX:int, mapEndY:int):void {
        var g:Graphics = this.selectionPos.graphics;
        g.clear(); // Always clear first

        var startX:int = mapStartX * TileMapView.TILE_SIZE;
        var startY:int = mapStartY * TileMapView.TILE_SIZE;
        var endX:int = mapEndX * TileMapView.TILE_SIZE;
        var endY:int = mapEndY * TileMapView.TILE_SIZE;

        var width:int = (endX + TileMapView.TILE_SIZE) - startX;
        var height:int = (endY + TileMapView.TILE_SIZE) - startY;

        g.lineStyle(0.5, 0xFFFFFF);
        g.drawRect(0, 0, width, height);
        g.lineStyle();

        this.selectionSize.x_ = width / TileMapView.TILE_SIZE;
        this.selectionSize.y_ = height / TileMapView.TILE_SIZE;
        this.selectionPos.x = startX;
        this.selectionPos.y = startY;
    }

    public function isInsideSelection(mapX:int, mapY:int, needsSelection:Boolean = false):Boolean {
        if (needsSelection && this.selectionPos.width == 0) {
            return false;
        }

        if (this.selectionPos.width != 0) {
            var spriteX:int = mapX * TileMapView.TILE_SIZE;
            var spriteY:int = mapY * TileMapView.TILE_SIZE;
            if (spriteX < this.selectionPos.x || spriteX >= this.selectionPos.x + this.selectionPos.width || // Check if tile is within selection limits
                    spriteY < this.selectionPos.y || spriteY >= this.selectionPos.y + this.selectionPos.height) {
                return false;
            }
        }
        return true;
    }

    public function editTileObjCfg(x:int, y:int, cfg:String):void {
        var tile:MapTileSprite = this.tileMap.getTileSprite(x, y);
        var data:MapTileData = tile.tileData;
        if (tile == null || data.objType == 0) {
            return;
        }

        tile.setObjectCfg(cfg);
    }

    public function copySelectionToClipboard(clipboard:MEClipboard):void {
        if (this.selectionPos.x == -1 && this.selectionPos.y == -1) {
            return;
        }

        var startX:int = this.selectionPos.x / TileMapView.TILE_SIZE;
        var startY:int = this.selectionPos.y / TileMapView.TILE_SIZE;
        var width:int = this.selectionSize.x_;
        var height:int = this.selectionSize.y_;

        clipboard.setSize(width, height);
        for (var mapY:int = startY; mapY < startY + height; mapY++) {
            for (var mapX:int = startX; mapX < startX + width; mapX++) {
                var tileData:MapTileData = this.tileMap.getTileData(mapX, mapY).clone(); // Save current tilemap data
                clipboard.addTile(tileData, mapX - startX, mapY - startY);
            }
        }
    }

    public function pasteFromClipboard(clipboard:MEClipboard, mapX:int, mapY:int, history:MapHistory):void {
        if (mapX < 0 || mapX > this.mapData.mapWidth || mapY < 0 || mapY > this.mapData.mapHeight || clipboard.width <= 0 || clipboard.height <= 0 ||
                mapX + clipboard.width > this.mapData.mapWidth || mapY + clipboard.height > this.mapData.mapHeight) {
            return;
        }

        var actions:MapActionSet = new MapActionSet();
        var prevSelectionPos:Shape = this.selectionPos;
        var prevSelectionSize:IntPoint = this.selectionSize;
        var prevStartX:int = prevSelectionPos.x / TileMapView.TILE_SIZE;
        var prevStartY:int = prevSelectionPos.y / TileMapView.TILE_SIZE;
        var prevSelectionData:MapSelectData = new MapSelectData(prevStartX, prevStartY, prevStartX + prevSelectionSize.x_ - 1, prevStartY + prevSelectionSize.y_ - 1);

        // Select pasted tiles
        this.clearTileSelection();
        this.drawTileSelection(mapX, mapY, mapX + clipboard.width - 1, mapY + clipboard.height - 1); // Make the new pasted tiles the new selection

        var newSelectionData:MapSelectData = new MapSelectData(mapX, mapY, mapX + clipboard.width - 1, mapY + clipboard.height - 1);
        actions.push(new MapSelectAction(prevSelectionData, newSelectionData));

        for (var tileY:int = mapY; tileY < mapY + clipboard.height; tileY++) { // Draw tile by tile from clipboard
            for (var tileX:int = mapX; tileX < mapX + clipboard.width; tileX++) {
                var tileData:MapTileData = clipboard.getTile(tileX - mapX, tileY - mapY);
                var prevData:MapTileData = this.tileMap.getTileData(tileX, tileY).clone();
                if (tileData == null || tileData == prevData) { // Skip empty tiles
                    continue;
                }

                this.tileMap.setTileData(tileX, tileY, tileData);
                this.tileMap.drawTile(tileX, tileY);

                actions.push(new MapReplaceTileAction(tileX, tileY, prevData, tileData.clone()));
            }
        }

        history.recordSet(actions);
    }
}
}
