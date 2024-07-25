package editor.tools {
import editor.MEBrush;
import editor.MEDrawType;
import editor.MapData;
import editor.MapTileData;
import editor.MapTileData;
import editor.actions.MapAction;
import editor.actions.MapActionSet;
import editor.actions.MapReplaceTileAction;
import editor.actions.data.MapSelectData;
import editor.ui.MainView;
import editor.MapHistory;
import editor.ui.MapView;
import editor.ui.TileMapView;

import flash.display.Shape;

import util.IntPoint;

import util.IntPoint;

public class MEBucketTool extends METool {

    private var continuous:Boolean;

    public function MEBucketTool(view:MainView) {
        super(METool.BUCKET_ID, view);
    }

    public override function init(tilePos:IntPoint, history:MapHistory):void {
        this.mainView.mapView.highlightTile(tilePos.x_, tilePos.y_);
    }

    public override function mouseMoved(tilePos:IntPoint, history:MapHistory):void {
        this.mainView.mapView.highlightTile(tilePos.x_, tilePos.y_);
    }

    public override function tileClick(tilePos:IntPoint, history:MapHistory):void {
        this.doFill(tilePos, history);
    }

    public function toggleContinuous():void {
        this.continuous = !this.continuous;
    }

    private function doFill(tilePos:IntPoint, history:MapHistory):void {
        var actions:MapActionSet = new MapActionSet();

        var tileMap:TileMapView = this.mainView.mapView.tileMap;
        var origTile:MapTileData = tileMap.getTileData(tilePos.x_, tilePos.y_).clone();
        if (this.continuous) {
            this.continuousFill(origTile, actions);
        } else {
            // DFS (Depth-First Search) algorithm
            this.fillTile(tilePos.x_, tilePos.y_, origTile, actions); // Do fill on the current tile, recursion will continue within this method
        }

        history.recordSet(actions);
    }

    private function continuousFill(origTile:MapTileData, actions:MapActionSet):void {
        var mapData:MapData = this.mainView.mapView.mapData;
        for (var yi:int = 0; yi < mapData.mapHeight; yi++) { // Iterate over the entire map
            for (var xi:int = 0; xi < mapData.mapWidth; xi++) {
                this.fillTile(xi, yi, origTile, actions, false); // Make sure we don't do the recursive call
            }
        }
    }

    private function fillTile(mapX:int, mapY:int, origTile:MapTileData, actions:MapActionSet, recursive:Boolean = true):void {
        var brush:MEBrush = this.mainView.userBrush;
        var tileMap:TileMapView = this.mainView.mapView.tileMap;

        var prevData:MapTileData = tileMap.getTileData(mapX, mapY);
        if (prevData == null) {
            return;
        }

        prevData = prevData.clone();

        switch (brush.elementType) {
            case MEDrawType.GROUND:
                if (prevData.groundType != origTile.groundType || prevData.groundType == brush.groundType) { // Don't update tile data if it's already the same
                    return;
                }
                tileMap.setTileGround(mapX, mapY, brush.groundType);
                break;
            case MEDrawType.OBJECTS:
                if (prevData.objType != origTile.objType || prevData.objType == brush.objType) {
                    return;
                }
                tileMap.setTileObject(mapX, mapY, brush.objType);
                break;
            case MEDrawType.REGIONS:
                if (prevData.regType != origTile.regType || prevData.regType == brush.regType) {
                    return;
                }
                tileMap.setTileRegion(mapX, mapY, brush.regType);
                break;
        }

        tileMap.drawTile(mapX, mapY);
        actions.push(new MapReplaceTileAction(mapX, mapY, prevData, tileMap.getTileData(mapX, mapY).clone()));

        if (recursive) {
            this.fillTile(mapX + 1, mapY, origTile, actions); // Try to perform fill on the nearby tiles
            this.fillTile(mapX - 1, mapY, origTile, actions);
            this.fillTile(mapX, mapY + 1, origTile, actions);
            this.fillTile(mapX, mapY - 1, origTile, actions);
        }
    }
}
}
