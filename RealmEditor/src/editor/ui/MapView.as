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
import editor.ui.MapTileSprite;
import editor.ui.MapTileSprite;
import editor.ui.MapTileSprite;
import editor.ui.MapTileSprite;
import editor.ui.MapTileSprite;

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

    private var userHistory:Vector.<MapActionDesc>; // Used for undoing. Contains user actions
    private var undoHistory:Vector.<MapActionDesc>; // Used for redoing. Contains undone actions

    public var lastDragPos:IntPoint;
    private var tilesMoved:Dictionary;
    private var moveActions:Vector.<MapActionDesc>;

    public function MapView(mapData:MapData) {
        this.mapData = mapData;
        this.mapOffset = new IntPoint();
        this.userHistory = new Vector.<MapActionDesc>();
        this.undoHistory = new Vector.<MapActionDesc>();
        this.moveActions = new Vector.<MapActionDesc>();

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
        this.tilesMoved = null;
        this.lastDragPos = null;
        this.moveActions.splice(0, this.moveActions.length);
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
        this.brushPencil.x = (mapX - brush.size) * TileMapView.TILE_SIZE;
        this.brushPencil.y = (mapY - brush.size) * TileMapView.TILE_SIZE;
        this.brushPencil.visible = true;
    }

    public function drawBrushTiles(mapX:int, mapY:int, brush:MEBrush):void {
        var regColor:uint;
        var groundTexture:BitmapData;
        var objectTexture:BitmapData;
        switch (brush.drawType){
            case MEDrawType.GROUND:
                groundTexture = GroundLibrary.getBitmapData(brush.groundType);
                break;
            case MEDrawType.OBJECTS:
                objectTexture = ObjectLibrary.getTextureFromType(brush.objType);
                break;
            case MEDrawType.REGIONS:
                regColor = RegionLibrary.getColor(brush.regType);
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
                if (distSq > brush.size * brush.size){
                    continue;
                }

                if (groundTexture != null){
                    brushTexture.copyPixels(groundTexture, new Rectangle(0, 0, groundTexture.width, groundTexture.height), new Point(xi * TileMapView.TILE_SIZE, yi * TileMapView.TILE_SIZE));
                }
                else if (objectTexture != null){
                    brushTexture.copyPixels(objectTexture, new Rectangle(0, 0, objectTexture.width, objectTexture.height), new Point(xi * TileMapView.TILE_SIZE, yi * TileMapView.TILE_SIZE));
                }
                else { // Must mean we're rendering a region
                    brushTexture.fillRect(new Rectangle(xi * TileMapView.TILE_SIZE, yi * TileMapView.TILE_SIZE, 1, 1), 1593835520 | regColor);
                }
            }
        }

        if (this.brushPencil.bitmapData != null){ // Make sure to clear our previous textures before we start drawing again
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

    public function useTool(toolId:int, mapX:int, mapY:int):void {
        var brush:MEBrush = Main.View.userBrush;
        if (brush == null) {
            return;
        }

        this.undoHistory.splice(0, this.undoHistory.length); // Clear undo history since we just made new changes
        var prevTileData:MapTileData = this.tileMap.getTileData(mapX, mapY);

        var action:int; // Put these here just to make switch less annoying in this language
        var prevValue:*;
        var newValue:*;

        switch (toolId) {
            case METool.ERASER_ID:
                if (prevTileData == null || !this.isInsideSelection(mapX, mapY)) {
                    return;
                }

                switch (brush.drawType) {
                    case MEDrawType.GROUND:
                        if (prevTileData.groundType == -1) {
                            return;
                        }

                        prevValue = prevTileData.groundType;
                        action = MEAction.ERASE_TILE;
                        this.tileMap.clearGround(mapX, mapY);
                        break;
                    case MEDrawType.OBJECTS:
                        if (prevTileData.objType == 0) {
                            return;
                        }

                        prevValue = prevTileData.objType;
                        action = MEAction.ERASE_OBJECT;
                        this.tileMap.clearObject(mapX, mapY);
                        break;
                    case MEDrawType.REGIONS:
                        if (prevTileData.regType == 0) {
                            return;
                        }

                        prevValue = prevTileData.regType;
                        action = MEAction.ERASE_REGION;
                        this.tileMap.clearRegion(mapX, mapY);
                        break;
                }
                this.tileMap.drawTile(mapX, mapY); // Draw tile with new data
                this.userHistory.push(new MapActionDesc(action, mapX, mapY, prevValue, null));
                break;
            case METool.PENCIL_ID:
                if (!this.isInsideSelection(mapX, mapY)) {
                    return;
                }

                switch (brush.drawType) {
                    case MEDrawType.GROUND:
                        prevValue = prevTileData != null ? prevTileData.groundType : -1;
                        if (brush.groundType == -1 || prevValue == brush.groundType) { // Make sure to only save in history if something was actually changed
                            return;
                        }

                        action = MEAction.DRAW_TILE;
                        newValue = brush.groundType;
                        this.tileMap.setTileGround(mapX, mapY, brush.groundType);
                        break;
                    case MEDrawType.OBJECTS:
                        prevValue = prevTileData != null ? prevTileData.objType : -1;
                        if (brush.objType == -1 || prevValue == brush.objType) {
                            return;
                        }

                        action = MEAction.DRAW_OBJECT;
                        newValue = brush.objType;
                        this.tileMap.setTileObject(mapX, mapY, brush.objType);
                        break;
                    case MEDrawType.REGIONS:
                        prevValue = prevTileData != null ? prevTileData.regType : -1;
                        if (brush.regType == -1 || prevValue == brush.regType) {
                            return;
                        }

                        action = MEAction.DRAW_REGION;
                        newValue = brush.regType;
                        this.tileMap.setTileRegion(mapX, mapY, brush.regType);
                        break;
                }
                this.tileMap.drawTile(mapX, mapY); // Draw tile with new data
                this.userHistory.push(new MapActionDesc(action, mapX, mapY, prevValue, newValue));
                break;
            case METool.BUCKET_ID:
                if (!this.isInsideSelection(mapX, mapY, true)) { // Only use bucket with a selected area
                    return;
                }

                this.fillSelection(brush);
                break;
        }
    }

    private function handleAction(action:MapActionDesc, undo:Boolean, userAction:Boolean = true):Boolean {
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
            case MEAction.TILE_REPLACED:
                var data:MapTileData = (undo ? action.prevValue : action.newValue) as MapTileData;
                this.tileMap.setTileData(action.mapX, action.mapY, data);

                if (userAction) {
                    if (undo) {
                        var moveIdx:int = this.moveActions.indexOf(action);
                        if (moveIdx != -1) {
                            this.moveActions.splice(moveIdx, 1);
                        }
                    } else {
                        this.moveActions.push(action);
                    }

                    if (this.moveActions.length == 0) {
                        this.clearTileSelection();
                    }
                }
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
        var action:MapActionDesc;
        for (var tileY:int = mapY; tileY < mapY + clipboard.height; tileY++) { // Draw tile by tile from clipboard
            for (var tileX:int = mapX; tileX < mapX + clipboard.width; tileX++) {
                var tileData:MapTileData = clipboard.getTile(tileX - mapX, tileY - mapY);
                var prevData:MapTileData = this.tileMap.getTileData(tileX, tileY).clone();
                if (tileData == null || tileData == prevData) { // Skip empty tiles
                    continue;
                }

                this.tileMap.setTileData(tileX, tileY, tileData);
                this.tileMap.drawTile(tileX, tileY);

                action = new MapActionDesc(MEAction.PASTE, tileX, tileY, prevData, tileData);
                action.finalRedoNode = false;
                action.finalUndoNode = first;

                if (first) {
                    first = false;
                }

                this.userHistory.push(action);
            }
        }

        if (action != null) {
            action.finalRedoNode = true;
        }
    }

    private function fillSelection(brush:MEBrush):void {
        var startX:int = this.selectionRect.x / TileMapView.TILE_SIZE;
        var startY:int = this.selectionRect.y / TileMapView.TILE_SIZE;
        var width:int = this.selectionSize.x_;
        var height:int = this.selectionSize.y_;

        var first:Boolean = true;
        var action:MapActionDesc;
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

                action = new MapActionDesc(actId, mapX, mapY, prevValue, newValue);
                action.finalRedoNode = false;
                action.finalUndoNode = first;

                if (first) {
                    first = false;
                }

                this.userHistory.push(action);
            }
        }

        if (action != null) {
            action.finalRedoNode = true;
        }
    }

    public function moveSelection(diffX:int, diffY:int):void {
        var fromX:int = this.selectionRect.x / TileMapView.TILE_SIZE;
        var fromY:int = this.selectionRect.y / TileMapView.TILE_SIZE;
        var toX:int = fromX + diffX;
        var toY:int = fromY + diffY;

        var endX:int = toX + this.selectionSize.x_ - 1;
        var endY:int = toY + this.selectionSize.y_ - 1;
        if (diffX == 0 && diffY == 0) {
            return;
        }

        this.moveSelectedTiles(fromX, fromY, toX, toY);
        this.selectTileArea(toX, toY, endX, endY);
    }

    public function dragSelection(toPos:IntPoint):void {
        if (this.lastDragPos == null) {
            this.lastDragPos = toPos;
        }

        var diffX:int = toPos.x_ - this.lastDragPos.x_;
        var diffY:int = toPos.y_ - this.lastDragPos.y_;

        this.moveSelection(diffX, diffY);

        this.lastDragPos = toPos;
    }

    private function moveSelectedTiles(fromX:int, fromY:int, toX:int, toY:int):void {
        var first:Boolean = true;
        var action:MapActionDesc;

        this.undoHistory.splice(0, this.undoHistory.length);

        var idx:int;
        if (this.tilesMoved == null) { // Save original tile data into tilesMoved
            this.tilesMoved = new Dictionary();
            for (var ogY:int = fromY; ogY < fromY + this.selectionSize.y_; ogY++) {
                for (var ogX:int = fromX; ogX < fromX + this.selectionSize.x_; ogX++) {
                    idx = (ogX - fromX) + (ogY - fromY) * this.selectionSize.x_;
                    var ogTile:MapTileData = this.tileMap.getTileData(ogX, ogY).clone();

                    this.tilesMoved[idx] = ogTile; // Clone the tile data
                    this.tileMap.clearTile(ogX, ogY);
                    this.tileMap.drawTile(ogX, ogY); // Draws the empty tile

                    action = new MapActionDesc(MEAction.TILE_REPLACED, ogX, ogY, ogTile.clone(), null);
                    action.finalRedoNode = false;
                    action.finalUndoNode = first;

                    if (first) {
                        first = false;
                    }

                    this.userHistory.push(action);
                }
            }
        } else { // Restore original tiles
            first = false;
            this.undoMoveActions();
        }

        for (var mapY:int = toY; mapY < toY + this.selectionSize.y_; mapY++) { // Draw moved tiles where they're supposed to be
            for (var mapX:int = toX; mapX < toX + this.selectionSize.x_; mapX++) {
                idx = (mapX - toX) + (mapY - toY) * this.selectionSize.x_;
                var tile:MapTileData = this.tilesMoved[idx];
                if (tile == null) {
                    continue;
                }

                var prevTile:MapTileData = this.tileMap.getTileData(mapX, mapY).clone();

                this.tileMap.setTileData(mapX, mapY, tile);
                this.tileMap.drawTile(mapX, mapY);

                action = new MapActionDesc(MEAction.TILE_REPLACED, mapX, mapY, prevTile, tile);
                action.finalRedoNode = false;
                action.finalUndoNode = first;

                if (first) {
                    first = false;
                }

                this.moveActions.push(action); // Push the change to moveActions
                this.userHistory.push(action);
            }
        }

        if (action != null) {
            action.finalRedoNode = true;
        }
    }

    private function undoMoveActions():void {
        for (var i:int = 0; i < this.moveActions.length; i++) {
            var action:MapActionDesc = this.moveActions[i];
            this.handleAction(action, true, false);
        }
        this.moveActions.splice(0, this.moveActions.length);
    }
}
}
