package realmeditor.editor.ui {
import assets.GroundLibrary;
import assets.ObjectLibrary;
import assets.RegionLibrary;

import editor.MapDragController;

import editor.MapHistory;

import editor.actions.MapAction;
import editor.MEBrush;
import editor.MEClipboard;
import editor.MEDrawType;
import editor.actions.MapActionSet;
import editor.actions.MapDragAction;
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
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.Dictionary;

import realmeditor.assets.GroundLibrary;
import realmeditor.assets.ObjectLibrary;
import realmeditor.assets.RegionLibrary;

import realmeditor.editor.MEBrush;
import realmeditor.editor.MEClipboard;
import realmeditor.editor.MEDrawType;

import realmeditor.editor.MapData;
import realmeditor.editor.MapDragController;
import realmeditor.editor.MapHistory;
import realmeditor.editor.MapTileData;
import realmeditor.editor.actions.MapActionSet;
import realmeditor.editor.actions.MapDragAction;
import realmeditor.editor.actions.MapReplaceTileAction;
import realmeditor.editor.actions.MapSelectAction;
import realmeditor.editor.actions.data.MapSelectData;
import realmeditor.util.IntPoint;

import util.IntPoint;

public class MapView extends Sprite {

    public static const EMPTY_SELECTION:MapSelectData = new MapSelectData(-1, -1, -1, -1);

    public var id:int; // Id of the map (based on load/create order)
    public var mapData:MapData;
    public var tileMap:TileMapView;
    public var mapOffset:IntPoint;
    public var zoomLevel:int = 100;
    public var gridEnabled:Boolean;
    private var gridTexture:BitmapData;
    private var grid:Bitmap;

    public var selection:MapSelectData;
    public var selectionRect:Shape;
    private var highlightRect:Shape;
    public var brushOverlay:Bitmap; // Draws a transparent view of the tiles (ground/object/region) the user will be painting on the map
    private var brushElementType:int;
    private var brushSize:int;
    private var brushTextureType:int;
    private var canvasTexture:BitmapData;
    private var canvasOutline:Bitmap;

    public var dragController:MapDragController;

    public function MapView(id:int, mapData:MapData) {
        this.id = id;
        this.mapData = mapData;
        this.mapOffset = new IntPoint();
        this.dragController = new MapDragController(this);

        this.tileMap = new TileMapView();
        addChild(this.tileMap);

        this.grid = new Bitmap(null);
        this.grid.visible = false;
        addChild(this.grid);

        this.highlightRect = new Shape();
        addChild(this.highlightRect);

        this.selection = EMPTY_SELECTION;
        this.selectionRect = new Shape();
        addChild(this.selectionRect);

        this.brushOverlay = new Bitmap();
        this.brushOverlay.alpha = 0.9;
        addChild(this.brushOverlay);

        this.canvasOutline = new Bitmap(null);
        addChild(this.canvasOutline);
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

        this.selection = EMPTY_SELECTION;
        this.selectionRect.graphics.clear();
        this.highlightRect.graphics.clear();
        // Clear user and undo actions

        this.tileMap.graphics.clear();
        if (this.gridTexture) {
            this.gridTexture.dispose();
            this.gridTexture = null;
        }

        if (this.canvasTexture) {
            this.canvasTexture.dispose();
            this.canvasTexture = null;
        }

        this.gridTexture = new BitmapData(TileMapView.TILE_SIZE * this.mapData.mapWidth, TileMapView.TILE_SIZE * this.mapData.mapHeight, true, 0);
        this.canvasTexture = new BitmapData(this.mapData.mapWidth * TileMapView.TILE_SIZE, this.mapData.mapHeight * TileMapView.TILE_SIZE, true, 0);
    }

    public function onMapLoadEnd():void {
//        trace("MAP LOADED");

        this.tileMap.onMapLoadEnd();
        this.drawGrid();
        this.drawCanvasOutline();
    }

    private function drawCanvasOutline():void {
        this.canvasTexture.fillRect(new Rectangle(0, 0, 1, this.canvasTexture.height), 1593835520 | 0xFFFFFF);
        this.canvasTexture.fillRect(new Rectangle(0, 0, this.canvasTexture.width, 1), 1593835520 | 0xFFFFFF);
        this.canvasTexture.fillRect(new Rectangle(this.canvasTexture.width - 1, 0, 1, this.canvasTexture.height), 1593835520 | 0xFFFFFF);
        this.canvasTexture.fillRect(new Rectangle(0, this.canvasTexture.height - 1, this.canvasTexture.width, 1), 1593835520 | 0xFFFFFF);
        this.canvasOutline.bitmapData = this.canvasTexture;
    }

    public function toggleGrid():Boolean {
        if (this.grid == null) {
            return false;
        }
        var val:Boolean = this.grid.visible = !this.grid.visible;
        this.gridEnabled = val;
        return val;
    }

    public function recordSelectionClear(history:MapHistory):void {
        history.record(new MapSelectAction(this.selection.clone(), EMPTY_SELECTION));
    }

    public function clearTileSelection():void {
        this.selection = EMPTY_SELECTION;
        this.selectionRect.graphics.clear();
        this.dragController.reset();
    }

    public function setLastDragAction(dragAction:MapDragAction):void {
        this.selection.lastDragAction = dragAction;
        this.dragController.lastDragAction = dragAction;
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

    public function hideBrushOverlay():void {
        this.brushOverlay.visible = false;
    }

    public function hideOverlays():void {
        this.highlightTile(-1, -1);
        this.hideBrushOverlay();
    }

    public function moveBrushOverlay(mapX:int, mapY:int, brush:MEBrush, eraser:Boolean = false, forceDraw:Boolean = false):void {
        if (eraser) {
            if (forceDraw || brush.size != this.brushSize) {
                this.drawBrushOutline(mapX, mapY, brush);
                return;
            }
        } else {
            if (forceDraw || brush.elementType != this.brushElementType) { // Re-draw if the draw type has changed
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
        }

        this.brushOverlay.x = (mapX - brush.size) * TileMapView.TILE_SIZE;
        this.brushOverlay.y = (mapY - brush.size) * TileMapView.TILE_SIZE;
        this.brushOverlay.visible = true;
    }

    public function drawBrushTiles(mapX:int, mapY:int, brush:MEBrush):void {
        var regColor:uint;
        var texture:BitmapData;

        var size:int = TileMapView.TILE_SIZE; // Default to 8x8
        this.brushElementType = brush.elementType;
        switch (brush.elementType) {
            case MEDrawType.GROUND:
                if (brush.groundType == -1) {
                    return;
                }

                texture = GroundLibrary.getBitmapData(brush.groundType);
                this.brushTextureType = brush.groundType;
                if (MainView.Instance.qualityTiles) {
                    size = Math.max(texture.width, texture.height);
                }
                break;
            case MEDrawType.OBJECTS:
                if (brush.objType == 0) {
                    return;
                }

                texture = ObjectLibrary.getTextureFromType(brush.objType);
                this.brushTextureType = brush.objType;
                if (MainView.Instance.qualityObjects) {
                    size = Math.max(texture.width, texture.height);
                }
                break;
            case MEDrawType.REGIONS:
                if (brush.regType == 0) {
                    return;
                }

                regColor = RegionLibrary.getColor(brush.regType);
                this.brushTextureType = brush.regType;
                break;
        }

        var diameter:int = 1 + (brush.size * 2); // Times 2 because we have tiles on the front and on the back
        var radius:int = diameter / 2;
        var bitmapSize:int = diameter * size;
        var brushTexture:BitmapData = new BitmapData(bitmapSize, bitmapSize, true, 0);
        for (var yi:int = 0; yi <= diameter; yi++) { // The brush size represents the amount of tiles from the center we will render
            for (var xi:int = 0; xi <= diameter; xi++) {
                var dx:int = xi - radius;
                var dy:int = yi - radius;
                var distSq:int = dx * dx + dy * dy;
                if (distSq > radius * radius) {
                    continue;
                }

                if (texture != null) {
                    if (texture.width > size || texture.height > size) {
                        var matrix:Matrix = new Matrix();
                        matrix.scale(size / texture.width, size / texture.height);
                        matrix.translate(xi * size, yi * size);
                        brushTexture.draw(texture, matrix);
                    } else {
                        brushTexture.copyPixels(texture, new Rectangle(0, 0, texture.width, texture.height), new Point(xi * texture.width, yi * texture.height));
                    }
                } else { // Must mean we're rendering a region
                    brushTexture.fillRect(new Rectangle(xi * size, yi * size, size, size), 1593835520 | regColor);
                }
            }
        }

        if (this.brushOverlay.bitmapData != null) { // Make sure to clear our previous textures before we start drawing again
            this.brushOverlay.bitmapData.dispose();
            this.brushOverlay.bitmapData = null;
        }

        this.brushOverlay.bitmapData = brushTexture;
        this.brushOverlay.scaleX = 8 / size;
        this.brushOverlay.scaleY = 8 / size;
        this.brushOverlay.x = (mapX - brush.size) * TileMapView.TILE_SIZE;
        this.brushOverlay.y = (mapY - brush.size) * TileMapView.TILE_SIZE;
        this.brushOverlay.visible = true;
    }

    public function drawBrushOutline(mapX:int, mapY:int, brush:MEBrush):void {
        this.brushSize = brush.size;

        var diameter:int = 1 + (brush.size * 2); // Times 2 because we have tiles on the front and on the back
        var radius:int = diameter / 2;
        var bitmapSize:int = diameter * TileMapView.TILE_SIZE;
        var brushTexture:BitmapData = new BitmapData(bitmapSize, bitmapSize, true, 0);

        for (var yi:int = 0; yi <= diameter; yi++) {
            for (var xi:int = 0; xi <= diameter; xi++) {
                var dx:int = xi - radius;
                var dy:int = yi - radius;
                var distSq:int = dx * dx + dy * dy;
                if (distSq > radius * radius) {
                    continue;
                }

                brushTexture.fillRect(new Rectangle(xi * TileMapView.TILE_SIZE, yi * TileMapView.TILE_SIZE, TileMapView.TILE_SIZE, TileMapView.TILE_SIZE), 1593835520 | 0xFFFFFF);
            }
        }

        if (this.brushOverlay.bitmapData != null) { // Make sure to clear our previous textures before we start drawing again
            this.brushOverlay.bitmapData.dispose();
            this.brushOverlay.bitmapData = null;
        }

        this.brushOverlay.bitmapData = brushTexture;
        this.brushOverlay.scaleX = 1; // Paint brush changes the scale so we reset it here just in case
        this.brushOverlay.scaleY = 1;
        this.brushOverlay.x = (mapX - brush.size) * TileMapView.TILE_SIZE;
        this.brushOverlay.y = (mapY - brush.size) * TileMapView.TILE_SIZE;
        this.brushOverlay.visible = true;
    }

    public function drawTileSelection(mapStartX:int, mapStartY:int, mapEndX:int, mapEndY:int):void {
        var g:Graphics = this.selectionRect.graphics;
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

        this.selection = new MapSelectData(startX / TileMapView.TILE_SIZE, startY / TileMapView.TILE_SIZE, endX / TileMapView.TILE_SIZE, endY / TileMapView.TILE_SIZE);
        this.selectionRect.x = startX;
        this.selectionRect.y = startY;
    }

    public function isInsideSelection(mapX:int, mapY:int, needsSelection:Boolean = false):Boolean {
        if (needsSelection && this.selectionRect.width == 0) {
            return false;
        }

        if (this.selectionRect.width != 0) {
            var spriteX:int = mapX * TileMapView.TILE_SIZE;
            var spriteY:int = mapY * TileMapView.TILE_SIZE;
            if (spriteX < this.selectionRect.x || spriteX >= this.selectionRect.x + this.selectionRect.width || // Check if tile is within selection limits
                    spriteY < this.selectionRect.y || spriteY >= this.selectionRect.y + this.selectionRect.height) {
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
        if (this.selectionRect.x == -1 && this.selectionRect.y == -1) {
            return;
        }

        var startX:int = this.selection.startX;
        var startY:int = this.selection.startY;
        var width:int = this.selection.width;
        var height:int = this.selection.height;

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
        var prevSelection:MapSelectData = this.selection.clone();

        // Select pasted tiles
        this.clearTileSelection();
        this.drawTileSelection(mapX, mapY, mapX + clipboard.width - 1, mapY + clipboard.height - 1); // Make the new pasted tiles the new selection

        var newSelectionData:MapSelectData = new MapSelectData(mapX, mapY, mapX + clipboard.width - 1, mapY + clipboard.height - 1);
        actions.push(new MapSelectAction(prevSelection, newSelectionData));

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
