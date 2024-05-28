package editor.ui {
import assets.ground.GroundLibrary;
import assets.objects.ObjectLibrary;
import assets.regions.RegionLibrary;

import editor.MEAction;
import editor.MEBrush;
import editor.MEClipboard;
import editor.MEDrawType;
import editor.METool;
import editor.MapActionDesc;
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

    public var mapData:MapData;
    public var tileMap:TileMapView;
    public var mapOffset:IntPoint;
    public var zoomLevel:int = 100;
    public var gridEnabled:Boolean;
    private var gridTexture:BitmapData;
    private var grid:Bitmap;

    private var selectionSize:IntPoint;
    private var selectionRect:Shape;
    private var highlightRect:Shape;
    private var brushPencil:Bitmap; // Draws a transparent view of the tiles (ground/object/region) the user will be painting on the map
    private var brushDrawType:int;
    private var brushTextureType:int;

    private var userHistory:Vector.<MapActionDesc>; // Used for undoing. Contains user actions
    private var undoHistory:Vector.<MapActionDesc>; // Used for redoing. Contains undone actions

    public var lastDragPos:IntPoint;

    public function MapView(mapData:MapData) {
        this.mapData = mapData;
        this.mapOffset = new IntPoint();
        this.userHistory = new Vector.<MapActionDesc>();
        this.undoHistory = new Vector.<MapActionDesc>();

        this.grid = new Bitmap(null);
        this.grid.visible = false;
        addChild(this.grid);

        this.tileMap = new TileMapView();
        addChild(this.tileMap);

        this.highlightRect = new Shape();
        addChild(this.highlightRect);

        this.selectionSize = new IntPoint(0, 0);
        this.selectionRect = new Shape();
        addChild(this.selectionRect);

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
        this.selectionRect.graphics.clear();
        this.highlightRect.graphics.clear();
        this.userHistory.splice(0, this.userHistory.length);
        this.undoHistory.splice(0, this.undoHistory.length);

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

    public function clearTileSelection():void {
        this.selectionSize.x_ = 0;
        this.selectionSize.y_ = 0;
        this.selectionRect.graphics.clear();
        this.lastDragPos = null;
    }

    public function selectSingleTile(mapX:int, mapY:int):void { // If user clicks on just one tile, clear selection and add tile to the new selection
        var tile:MapTileSprite = this.tileMap.getTileSprite(mapX, mapY);
        if (tile == null) {
            return;
        }

        var startX:int = mapX * TileMapView.TILE_SIZE;
        var startY:int = mapY * TileMapView.TILE_SIZE;

        if (this.selectionRect.x == startX && this.selectionRect.y == startY) {
            this.clearTileSelection();
            return;
        }

        this.drawTileSelection(mapX, mapY, mapX, mapY); // Redraw the tile selection rectangle
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
        if (brush.drawType != this.brushDrawType) { // Re-draw if the draw type has changed
            this.drawBrushTiles(mapX, mapY, brush);
            return;
        }

        switch (brush.drawType) { // If draw type matces,re-draw if the texture we're drawing also has changed
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

        this.brushDrawType = brush.drawType;
        switch (brush.drawType) {
            case MEDrawType.GROUND:
                groundTexture = GroundLibrary.getBitmapData(brush.groundType);
                this.brushTextureType = brush.groundType;
                break;
            case MEDrawType.OBJECTS:
                objectTexture = ObjectLibrary.getTextureFromType(brush.objType);
                this.brushTextureType = brush.objType;
                break;
            case MEDrawType.REGIONS:
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

    private function drawTileSelection(mapStartX:int, mapStartY:int, mapEndX:int, mapEndY:int):void {
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

        this.selectionSize.x_ = width / TileMapView.TILE_SIZE;
        this.selectionSize.y_ = height / TileMapView.TILE_SIZE;
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

        var prevName:String = data.objCfg;
        tile.setObjectCfg(cfg);

        this.userHistory.push(new MapActionDesc(MEAction.EDIT_OBJ_NAME, x, y, prevName, data.objCfg));
    }

    public function undo():void {
        var finalNode:Boolean = false;
        while (!finalNode) {
            var idx:int = this.userHistory.length - 1;
            if (idx < 0) {
                return;
            }

            // Push undone action to undoHistory
            var action:MapActionDesc = this.userHistory[idx];
            this.undoHistory.push(action);
            this.userHistory.splice(idx, 1) // Remove from user history
            finalNode = this.handleAction(action, true);
        }
    }

    public function redo():void {
        var finalNode:Boolean = false;
        while (!finalNode) {
            var idx:int = this.undoHistory.length - 1;
            if (idx < 0) {
                return;
            }

            // Push undone action to undoHistory
            var action:MapActionDesc = this.undoHistory[idx];
            this.userHistory.push(action);
            this.undoHistory.splice(idx, 1) // Remove from user history
            finalNode = this.handleAction(action, false);
        }
    }

    public function useTool(toolId:int, mapX:int, mapY:int, first:Boolean = true, last:Boolean = true):MapActionDesc {
        var brush:MEBrush = Main.View.userBrush;
        if (brush == null) {
            return null;
        }

        this.undoHistory.splice(0, this.undoHistory.length); // Clear undo history since we just made new changes
        var prevTileData:MapTileData = this.tileMap.getTileData(mapX, mapY);

        var actionId:int; // Put these here just to make switch less annoying in this language
        var prevValue:*;
        var newValue:*;

        var action:MapActionDesc = null;
        switch (toolId) {
            case METool.ERASER_ID:
                if (prevTileData == null || !this.isInsideSelection(mapX, mapY)) {
                    return null;
                }

                switch (brush.drawType) {
                    case MEDrawType.GROUND:
                        if (prevTileData.groundType == -1) {
                            return null;
                        }

                        prevValue = prevTileData.groundType;
                        actionId = MEAction.ERASE_TILE;
                        this.tileMap.clearGround(mapX, mapY);
                        break;
                    case MEDrawType.OBJECTS:
                        if (prevTileData.objType == 0) {
                            return null;
                        }

                        prevValue = prevTileData.objType;
                        actionId = MEAction.ERASE_OBJECT;
                        this.tileMap.clearObject(mapX, mapY);
                        break;
                    case MEDrawType.REGIONS:
                        if (prevTileData.regType == 0) {
                            return null;
                        }

                        prevValue = prevTileData.regType;
                        actionId = MEAction.ERASE_REGION;
                        this.tileMap.clearRegion(mapX, mapY);
                        break;
                }
                this.tileMap.drawTile(mapX, mapY); // Draw tile with new data

                action = new MapActionDesc(actionId, mapX, mapY, prevValue, null, first, last);
                this.userHistory.push(action);
                break;
            case METool.PENCIL_ID:
                if (!this.isInsideSelection(mapX, mapY)) {
                    return null;
                }

                switch (brush.drawType) {
                    case MEDrawType.GROUND:
                        prevValue = prevTileData != null ? prevTileData.groundType : -1;
                        if (brush.groundType == -1 || prevValue == brush.groundType) { // Make sure to only save in history if something was actually changed
                            return null;
                        }

                        actionId = MEAction.DRAW_TILE;
                        newValue = brush.groundType;
                        this.tileMap.setTileGround(mapX, mapY, brush.groundType);
                        break;
                    case MEDrawType.OBJECTS:
                        prevValue = prevTileData != null ? prevTileData.objType : -1;
                        if (brush.objType == -1 || prevValue == brush.objType) {
                            return null;
                        }

                        actionId = MEAction.DRAW_OBJECT;
                        newValue = brush.objType;
                        this.tileMap.setTileObject(mapX, mapY, brush.objType);
                        break;
                    case MEDrawType.REGIONS:
                        prevValue = prevTileData != null ? prevTileData.regType : -1;
                        if (brush.regType == -1 || prevValue == brush.regType) {
                            return null;
                        }

                        actionId = MEAction.DRAW_REGION;
                        newValue = brush.regType;
                        this.tileMap.setTileRegion(mapX, mapY, brush.regType);
                        break;
                }
                this.tileMap.drawTile(mapX, mapY); // Draw tile with new data

                action = new MapActionDesc(actionId, mapX, mapY, prevValue, newValue, first, last);
                this.userHistory.push(action);
                break;
            case METool.BUCKET_ID:
                if (!this.isInsideSelection(mapX, mapY, true)) { // Only use bucket with a selected area
                    return null;
                }

                this.fillSelection(brush);
                break;
        }
        return action;
    }

    private function handleAction(action:MapActionDesc, undo:Boolean, userAction:Boolean = true, deleteFromHistory:Boolean = false):Boolean {
        if (deleteFromHistory) {
            var userIdx:int = this.userHistory.indexOf(action);
            if (userIdx != -1) {
                this.userHistory.splice(userIdx, 1);
            }

            var undoIdx:int = this.undoHistory.indexOf(action);
            if (undoIdx != -1) {
                this.undoHistory.splice(undoIdx, 1);
            }
        }

        switch (action.actionId) {
            case MEAction.DRAW_TILE:
                if (undo) {
                    if (action.prevValue == -1) { // Clear the ground if it was clear before, otherwise, set the ground to previous value
                        this.tileMap.clearGround(action.mapX, action.mapY);
                    } else {
                        this.tileMap.setTileGround(action.mapX, action.mapY, action.prevValue);
                    }
                } else {
                    this.tileMap.setTileGround(action.mapX, action.mapY, action.newValue);
                }
                break;
            case MEAction.ERASE_TILE:
                if (undo) {
                    this.tileMap.setTileGround(action.mapX, action.mapY, action.prevValue);
                } else {
                    this.tileMap.clearGround(action.mapX, action.mapY);
                }
                break;
            case MEAction.DRAW_OBJECT:
                if (undo) {
                    if (action.prevValue == 0) {
                        this.tileMap.clearObject(action.mapX, action.mapY);
                    } else {
                        this.tileMap.setTileObject(action.mapX, action.mapY, action.prevValue);
                    }
                } else {
                    this.tileMap.setTileObject(action.mapX, action.mapY, action.newValue);
                }
                break;
            case MEAction.ERASE_OBJECT:
                if (undo) {
                    this.tileMap.setTileObject(action.mapX, action.mapY, action.prevValue);
                } else {
                    this.tileMap.clearObject(action.mapX, action.mapY);
                }
                break;
            case MEAction.DRAW_REGION:
                if (undo) {
                    if (action.prevValue == 0) {
                        this.tileMap.clearRegion(action.mapX, action.mapY);
                    } else {
                        this.tileMap.setTileRegion(action.mapX, action.mapY, action.prevValue);
                    }
                } else {
                    this.tileMap.setTileRegion(action.mapX, action.mapY, action.newValue);
                }
                break;
            case MEAction.ERASE_REGION:
                if (undo) {
                    this.tileMap.setTileRegion(action.mapX, action.mapY, action.prevValue);
                } else {
                    this.tileMap.clearRegion(action.mapX, action.mapY);
                }
                break;
            case MEAction.EDIT_OBJ_NAME:
                this.editTileObjCfg(action.mapX, action.mapY, undo ? action.prevValue : action.newValue);
                break;
            case MEAction.PASTE:
                if (action.finalUndoNode) { // Clear selection only on the last tile when undoing
                    this.clearTileSelection();
                }

                this.tileMap.setTileData(action.mapX, action.mapY, undo ? action.prevValue : action.newValue);
                break;
            case MEAction.FILL_GROUND:
                this.tileMap.setTileGround(action.mapX, action.mapY, undo ? action.prevValue : action.newValue);
                break;
            case MEAction.FILL_OBJECT:
                this.tileMap.setTileObject(action.mapX, action.mapY, undo ? action.prevValue : action.newValue);
                break;
            case MEAction.FILL_REGION:
                this.tileMap.setTileRegion(action.mapX, action.mapY, undo ? action.prevValue : action.newValue);
                break;
        }
        this.tileMap.drawTile(action.mapX, action.mapY);
        return undo ? action.finalUndoNode : action.finalRedoNode;
    }

    public function copySelectionToClipboard(clipboard:MEClipboard):void {
        if (this.selectionRect.x == -1 && this.selectionRect.y == -1) {
            return;
        }

        var startX:int = this.selectionRect.x / TileMapView.TILE_SIZE;
        var startY:int = this.selectionRect.y / TileMapView.TILE_SIZE;
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

    public function pasteFromClipboard(clipboard:MEClipboard, mapX:int, mapY:int):void {
        if (mapX < 0 || mapX > this.mapData.mapWidth || mapY < 0 || mapY > this.mapData.mapHeight || clipboard.width <= 0 || clipboard.height <= 0 ||
                mapX + clipboard.width > this.mapData.mapWidth || mapY + clipboard.height > this.mapData.mapHeight) {
            return;
        }

        this.undoHistory.splice(0, this.undoHistory.length);

        // Select pasted tiles
        this.clearTileSelection();
        this.drawTileSelection(mapX, mapY, mapX + clipboard.width - 1, mapY + clipboard.height - 1); // Make the new pasted tiles the new selection

        var first:Boolean = true;
        var prevAction:MapActionDesc;
        for (var tileY:int = mapY; tileY < mapY + clipboard.height; tileY++) { // Draw tile by tile from clipboard
            for (var tileX:int = mapX; tileX < mapX + clipboard.width; tileX++) {
                var tileData:MapTileData = clipboard.getTile(tileX - mapX, tileY - mapY);
                var prevData:MapTileData = this.tileMap.getTileData(tileX, tileY).clone();
                if (tileData == null || tileData == prevData) { // Skip empty tiles
                    continue;
                }

                this.tileMap.setTileData(tileX, tileY, tileData);
                this.tileMap.drawTile(tileX, tileY);

                var action:MapActionDesc = new MapActionDesc(MEAction.PASTE, tileX, tileY, prevData, tileData, first, false);

                if (action != null) {
                    if (first) {
                        first = false;
                    }
                    prevAction = action; // Make sure we know what the last action was
                }

                this.userHistory.push(prevAction);
            }
        }

        if (prevAction != null) {
            prevAction.finalRedoNode = true;
        }
    }

    private function fillSelection(brush:MEBrush):void {
        var startX:int = this.selectionRect.x / TileMapView.TILE_SIZE;
        var startY:int = this.selectionRect.y / TileMapView.TILE_SIZE;
        var width:int = this.selectionSize.x_;
        var height:int = this.selectionSize.y_;

        var first:Boolean = true;
        var prevAction:MapActionDesc;
        for (var mapY:int = startY; mapY < startY + height; mapY++) {
            for (var mapX:int = startX; mapX < startX + width; mapX++) {
                var prevData:MapTileData = this.tileMap.getTileData(mapX, mapY);
                var actId:int;
                var prevValue:int;
                var newValue:int;
                switch (brush.drawType) {
                    case MEDrawType.GROUND:
                        actId = MEAction.FILL_GROUND;
                        prevValue = prevData == null ? -1 : prevData.groundType;
                        newValue = brush.groundType;
                        this.tileMap.setTileGround(mapX, mapY, brush.groundType);
                        break;
                    case MEDrawType.OBJECTS:
                        actId = MEAction.FILL_OBJECT;
                        prevValue = prevData == null ? 0 : prevData.objType;
                        newValue = brush.objType;
                        this.tileMap.setTileObject(mapX, mapY, brush.objType);
                        break;
                    case MEDrawType.REGIONS:
                        actId = MEAction.FILL_REGION;
                        prevValue = prevData == null ? 0 : prevData.regType;
                        newValue = brush.regType;
                        this.tileMap.setTileRegion(mapX, mapY, brush.regType);
                        break;
                }
                this.tileMap.drawTile(mapX, mapY);

                var action:MapActionDesc = new MapActionDesc(actId, mapX, mapY, prevValue, newValue, first, false);

                if (action != null) {
                    if (first) {
                        first = false;
                    }
                    prevAction = action; // Make sure we know what the last action was
                }

                this.userHistory.push(prevAction);
            }
        }

        if (prevAction != null) {
            prevAction.finalRedoNode = true;
        }
    }

    public function dragSelection(diffX:int, diffY:int):void {
        var fromX:int = this.selectionRect.x / TileMapView.TILE_SIZE;
        var fromY:int = this.selectionRect.y / TileMapView.TILE_SIZE;
        var toX:int = fromX + diffX;
        var toY:int = fromY + diffY;

        var endX:int = toX + this.selectionSize.x_ - 1;
        var endY:int = toY + this.selectionSize.y_ - 1;
        if (diffX == 0 && diffY == 0) {
            return;
        }

        this.selectTileArea(toX, toY, endX, endY);
    }

    public function moveSelectionTo(toPos:IntPoint):void {
        if (this.lastDragPos == null) {
            this.lastDragPos = toPos;
        }

        var diffX:int = toPos.x_ - this.lastDragPos.x_;
        var diffY:int = toPos.y_ - this.lastDragPos.y_;

        this.dragSelection(diffX, diffY);

        this.lastDragPos = toPos;
    }
}
}
