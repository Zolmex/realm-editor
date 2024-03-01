package editor.ui {
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

    public function selectSingleTile(tileX:int, tileY:int):void { // If user clicks on just one tile, clear selection and add tile to the new selection
        var tile:MapTileSprite = this.tileMap.getTileSprite(tileX, tileY);
        if (tile == null) {
            return;
        }

        var startX:int = tileX * TileMapView.TILE_SIZE;
        var startY:int = tileY * TileMapView.TILE_SIZE;

        if (this.selectionRect.x == startX && this.selectionRect.y == startY) {
            this.clearTileSelection();
            return;
        }

        this.drawTileSelection(tileX, tileY, tileX, tileY); // Redraw the tile selection rectangle
    }

    public function selectTileArea(tileStartX:int, tileStartY:int, tileEndX:int, tileEndY:int):void { // Use this for selecting a rectangle area of tiles by holding left mouse button
        var beginX:int = tileStartX < tileEndX ? tileStartX : tileEndX;
        var beginY:int = tileStartY < tileEndY ? tileStartY : tileEndY;
        var endX:int = tileStartX < tileEndX ? tileEndX : tileStartX;
        var endY:int = tileStartY < tileEndY ? tileEndY : tileStartY;

        this.drawTileSelection(beginX, beginY, endX, endY); // Redraw the tile selection rectangle
    }

    public function highlightTile(tileX:int, tileY:int):void { // Draws rectangle over hovered tile
        var g:Graphics = this.highlightRect.graphics;
        g.clear(); // Always clear the highlight first

        if (tileX < 0 || tileX > this.mapData.mapWidth || tileY < 0 || tileY > this.mapData.mapHeight) {
            return;
        }

        var x:int = tileX * TileMapView.TILE_SIZE;
        var y:int = tileY * TileMapView.TILE_SIZE;
        var width:int = TileMapView.TILE_SIZE;
        var height:int = TileMapView.TILE_SIZE;

        g.lineStyle(1, 0xFFFFFF, 0.5);
        g.drawRect(x, y, width, height);
        g.lineStyle();
    }

    private function drawTileSelection(tileStartX:int, tileStartY:int, tileEndX:int, tileEndY:int):void {
        var g:Graphics = this.selectionRect.graphics;
        g.clear(); // Always clear first

        var startX:int = tileStartX * TileMapView.TILE_SIZE;
        var startY:int = tileStartY * TileMapView.TILE_SIZE;
        var endX:int = tileEndX * TileMapView.TILE_SIZE;
        var endY:int = tileEndY * TileMapView.TILE_SIZE;

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

    public function isInsideSelection(x:int, y:int, needsSelection:Boolean = false):Boolean {
        if (needsSelection && this.selectionRect.width == 0) {
            return false;
        }

        if (this.selectionRect.width != 0) {
            var spriteX:int = x * TileMapView.TILE_SIZE;
            var spriteY:int = y * TileMapView.TILE_SIZE;
            if (spriteX < this.selectionRect.x || spriteX >= this.selectionRect.x + this.selectionRect.width || // Check if tile is within selection limits
                    spriteY < this.selectionRect.y || spriteY >= this.selectionRect.y + this.selectionRect.height) {
                return false;
            }
        }
        return true;
    }

    private function clearGround(x:int, y:int, checkSelection:Boolean = true):Boolean {
        if (checkSelection && !this.isInsideSelection(x, y)) {
            return false;
        }

        this.tileMap.clearGround(x, y);
        return true;
    }

    private function editGround(x:int, y:int, groundType:int, checkSelection:Boolean = true):MapTileSprite {
        if (checkSelection && !this.isInsideSelection(x, y)) {
            return null;
        }

        var tileData:MapTileData = this.tileMap.getTileData(x, y) || new MapTileData();
        tileData.groundType = groundType;

        return this.tileMap.redrawTile(tileData, x, y);
    }

    private function clearObject(x:int, y:int, checkSelection:Boolean = true):Boolean {
        if (checkSelection && !this.isInsideSelection(x, y)) {
            return false;
        }

        this.tileMap.clearObject(x, y);
        return true;
    }

    private function editObject(x:int, y:int, objectType:int, checkSelection:Boolean = true):MapTileSprite {
        if (checkSelection && !this.isInsideSelection(x, y)) {
            return null;
        }

        var tileData:MapTileData = this.tileMap.getTileData(x, y) || new MapTileData();
        tileData.objType = objectType;

        return this.tileMap.redrawTile(tileData, x, y);
    }

    private function clearRegion(x:int, y:int, checkSelection:Boolean = true):Boolean {
        if (checkSelection && !this.isInsideSelection(x, y)) {
            return false;
        }

        this.tileMap.clearRegion(x, y);
        return true;
    }

    private function editRegion(x:int, y:int, regionType:int, checkSelection:Boolean = true):MapTileSprite {
        if (checkSelection && !this.isInsideSelection(x, y)) {
            return null;
        }

        var tileData:MapTileData = this.tileMap.getTileData(x, y) || new MapTileData();
        tileData.regType = regionType;

        return this.tileMap.redrawTile(tileData, x, y);
    }

    public function editTileName(x:int, y:int, name:String):void {
        var tileData:MapTileData = this.tileMap.getTileData(x, y);
        if (tileData == null || tileData.objType == 0) {
            return;
        }

        var prevName:String = tileData.objName;
        tileData.objName = name;

        this.userHistory.push(new MapActionDesc(MEAction.EDIT_OBJ_NAME, x, y, prevName, tileData.objName));
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

    public function useTool(toolId:int, x:int, y:int):void {
        var brush:MEBrush = Main.View.userBrush;
        if (brush == null) {
            return;
        }

        this.undoHistory.splice(0, this.undoHistory.length);
        var prevTileData:MapTileData = this.tileMap.getTileData(x, y);

        var action:int;
        var prevValue:*;
        var newValue:*;

        var newTile:MapTileSprite = null;
        switch (toolId) {
            case METool.ERASER_ID:
                if (prevTileData == null) {
                    return;
                }

                switch (brush.drawType) {
                    case MEDrawType.GROUND:
                        if (prevTileData.groundType == -1) {
                            return;
                        }

                        prevValue = prevTileData.groundType;
                        if (!this.clearGround(x, y)) {
                            return;
                        }

                        action = MEAction.ERASE_TILE;
                        break;
                    case MEDrawType.OBJECTS:
                        if (prevTileData.objType == 0) {
                            return;
                        }

                            trace(prevTileData.objType);
                        prevValue = prevTileData.objType;
                        if (!this.clearObject(x, y)) {
                            return;
                        }

                        action = MEAction.ERASE_OBJECT;
                        break;
                    case MEDrawType.REGIONS:
                        if (prevTileData.regType == 0) {
                            return;
                        }

                        prevValue = prevTileData.regType;
                        if (!this.clearRegion(x, y)) {
                            return;
                        }

                        action = MEAction.ERASE_REGION;
                        break;
                }
                this.userHistory.push(new MapActionDesc(action, x, y, prevValue, null));
                break;
            case METool.PENCIL_ID:
                switch (brush.drawType) {
                    case MEDrawType.GROUND:
                        if (prevTileData != null) {
                            prevValue = prevTileData.groundType;
                        } else {
                            prevValue = -1;
                        }

                        if (brush.groundType == -1 || prevValue == brush.groundType) { // Make sure to only save in history if something was actually changed
                            return;
                        }

                        newTile = this.editGround(x, y, brush.groundType);
                        if (newTile == null) {
                            return;
                        }

                        action = MEAction.DRAW_TILE;
                        newValue = newTile.tileData.groundType;
                        break;
                    case MEDrawType.OBJECTS:
                        if (prevTileData != null) {
                            prevValue = prevTileData.objType;
                        } else {
                            prevValue = 0;
                        }

                        if (brush.objType == 0 || prevValue == brush.objType) {
                            return;
                        }

                        newTile = this.editObject(x, y, brush.objType);
                        if (newTile == null) {
                            return;
                        }

                        action = MEAction.DRAW_OBJECT;
                        newValue = newTile.tileData.objType;
                        break;
                    case MEDrawType.REGIONS:
                        if (prevTileData != null) {
                            prevValue = prevTileData.regType;
                        } else {
                            prevValue = 0;
                        }

                        if (brush.regType == 0 || prevValue == brush.regType) {
                            return;
                        }

                        newTile = this.editRegion(x, y, brush.regType);
                        if (newTile == null) {
                            return;
                        }

                        action = MEAction.DRAW_REGION;
                        newValue = newTile.tileData.regType;
                        break;
                }
                this.userHistory.push(new MapActionDesc(action, x, y, prevValue, newValue));
                break;
            case METool.BUCKET_ID:
                if (this.selectionRect.width != 0 && !this.isInsideSelection(x, y)) { // Only use bucket with a selected area
                    return;
                }

                this.fillTool(brush);
                break;
        }
    }

    private function handleAction(action:MapActionDesc, undo:Boolean, userAction:Boolean = true):Boolean {
        switch (action.actionId) {
            case MEAction.DRAW_TILE:
                if (undo) {
                    if (action.prevValue == -1) {
                        this.clearGround(action.x, action.y, false);
                    } else {
                        this.editGround(action.x, action.y, action.prevValue, false);
                    }
                } else {
                    this.editGround(action.x, action.y, action.newValue, false);
                }
                break;
            case MEAction.ERASE_TILE:
                if (action.prevValue == -1) {
                    break;
                }
                if (undo) {
                    this.editGround(action.x, action.y, action.prevValue, false);
                } else {
                    this.clearGround(action.x, action.y, false);
                }
                break;
            case MEAction.DRAW_OBJECT:
                if (undo) {
                    if (action.prevValue == 0) {
                        this.clearObject(action.x, action.y, false);
                    } else {
                        this.editObject(action.x, action.y, action.prevValue, false);
                    }
                } else {
                    this.editObject(action.x, action.y, action.newValue, false);
                }
                break;
            case MEAction.ERASE_OBJECT:
                if (action.prevValue == 0) {
                    break;
                }
                if (undo) {
                    this.editObject(action.x, action.y, action.prevValue, false);
                } else {
                    this.clearObject(action.x, action.y, false);
                }
                break;
            case MEAction.DRAW_REGION:
                if (undo) {
                    if (action.prevValue == 0) {
                        this.clearRegion(action.x, action.y, false);
                    } else {
                        this.editRegion(action.x, action.y, action.prevValue, false);
                    }
                } else {
                    this.editRegion(action.x, action.y, action.newValue, false);
                }
                break;
            case MEAction.ERASE_REGION:
                if (action.prevValue == 0) {
                    break;
                }
                if (undo) {
                    this.editRegion(action.x, action.y, action.prevValue, false);
                } else {
                    this.clearRegion(action.x, action.y, false);
                }
                break;
            case MEAction.EDIT_OBJ_NAME:
                this.editTileName(action.x, action.y, undo ? action.prevValue : action.newValue);
                break;
            case MEAction.PASTE:
                this.tileMap.redrawTile(undo ? action.prevValue : action.newValue, action.x, action.y);
                break;
            case MEAction.FILL_GROUND:
                this.editGround(action.x, action.y, undo ? action.prevValue : action.newValue, false);
                break;
            case MEAction.FILL_OBJECT:
                this.editObject(action.x, action.y, undo ? action.prevValue : action.newValue, false);
                break;
            case MEAction.FILL_REGION:
                this.editRegion(action.x, action.y, undo ? action.prevValue : action.newValue, false);
                break;
            case MEAction.TILE_REPLACED:
                var data:MapTileData = (undo ? action.prevValue : action.newValue) as MapTileData;
                this.tileMap.redrawTile(data, action.x, action.y);

                if (userAction) {
                    if (undo) {
                        var moveIdx:int = this.moveActions.indexOf(action);
                        if (moveIdx != -1) {
                            this.moveActions.splice(moveIdx, 1);
                        }
                    } else {
                        this.moveActions.push(action);
                    }

                    if (this.moveActions.length == 0){
                        this.clearTileSelection();
                    }
                }
                break;
        }
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
        for (var y:int = startY; y < startY + height; y++) {
            for (var x:int = startX; x < startX + width; x++) {
                var tileData:MapTileData = this.mapData.getTile(x, y);
                clipboard.addTile(tileData, x - startX, y - startY);
            }
        }
    }

    public function pasteFromClipboard(clipboard:MEClipboard, tileX:int, tileY:int):void {
        if (tileX < 0 || tileX > this.mapData.mapWidth || tileY < 0 || tileY > this.mapData.mapHeight || clipboard.width <= 0 || clipboard.height <= 0 ||
                tileX + clipboard.width > this.mapData.mapWidth || tileY + clipboard.height > this.mapData.mapHeight) {
            return;
        }

        this.undoHistory.splice(0, this.undoHistory.length);

        // Select pasted tiles
        this.clearTileSelection();
        this.drawTileSelection(tileX, tileY, tileX + clipboard.width - 1, tileY + clipboard.height - 1);

        var first:Boolean = true;
        var action:MapActionDesc;
        for (var y:int = tileY; y < tileY + clipboard.height; y++) {
            for (var x:int = tileX; x < tileX + clipboard.width; x++) {
                var tileData:MapTileData = clipboard.getTile(x - tileX, y - tileY);
                var prevData:MapTileData = this.mapData.getTile(x, y);
                if (tileData == null || tileData == prevData) { // Skip empty tiles
                    continue;
                }

                this.tileMap.redrawTile(tileData, x, y);

                action = new MapActionDesc(MEAction.PASTE, x, y, prevData, tileData);
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

    private function fillTool(brush:MEBrush):void {
        var startX:int = this.selectionRect.x / TileMapView.TILE_SIZE;
        var startY:int = this.selectionRect.y / TileMapView.TILE_SIZE;
        var width:int = this.selectionSize.x_;
        var height:int = this.selectionSize.y_;

        var first:Boolean = true;
        var action:MapActionDesc;
        for (var y:int = startY; y < startY + height; y++) {
            for (var x:int = startX; x < startX + width; x++) {
                var prevData:MapTileData = this.mapData.getTile(x, y);
                var actId:int;
                var prevValue:int;
                var newValue:int;
                switch (brush.drawType) {
                    case MEDrawType.GROUND:
                        actId = MEAction.FILL_GROUND;
                        prevValue = prevData == null ? -1 : prevData.groundType;
                        this.editGround(x, y, brush.groundType);
                        newValue = brush.groundType;
                        break;
                    case MEDrawType.OBJECTS:
                        actId = MEAction.FILL_OBJECT;
                        prevValue = prevData == null ? 0 : prevData.objType;
                        this.editObject(x, y, brush.objType);
                        newValue = brush.objType;
                        break;
                    case MEDrawType.REGIONS:
                        actId = MEAction.FILL_REGION;
                        prevValue = prevData == null ? 0 : prevData.regType;
                        this.editRegion(x, y, brush.regType);
                        newValue = brush.regType;
                        break;
                }

                action = new MapActionDesc(actId, x, y, prevValue, newValue);
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
                    var ogTile:MapTileData = this.mapData.getTile(ogX, ogY);
                    var tileData:MapTileData = ogTile != null ? ogTile.clone() : null;

                    this.tilesMoved[idx] = tileData;
                    this.tileMap.redrawTile(null, ogX, ogY);

                    action = new MapActionDesc(MEAction.TILE_REPLACED, ogX, ogY, tileData, null);
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

        for (var y:int = toY; y < toY + this.selectionSize.y_; y++) { // Draw moved tiles where they're supposed to be
            for (var x:int = toX; x < toX + this.selectionSize.x_; x++) {
                idx = (x - toX) + (y - toY) * this.selectionSize.x_;
                var tile:MapTileData = this.tilesMoved[idx];
                var prevTile:MapTileData = this.mapData.getTile(x, y);

                this.tileMap.redrawTile(tile, x, y);

                action = new MapActionDesc(MEAction.TILE_REPLACED, x, y, prevTile, tile);
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
