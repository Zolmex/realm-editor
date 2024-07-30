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

    public function MEBucketTool(view:MainView) {
        super(METool.BUCKET_ID, view);
    }

    public override function init(tilePos:IntPoint, history:MapHistory):void {
        if (tilePos == null){
            return;
        }

        this.mainView.mapView.highlightTile(tilePos.x_, tilePos.y_);
    }

    public override function mouseMoved(tilePos:IntPoint, history:MapHistory):void {
        if (tilePos == null){
            return;
        }

        this.mainView.mapView.highlightTile(tilePos.x_, tilePos.y_);
    }

    public override function tileClick(tilePos:IntPoint, history:MapHistory):void {
        if (tilePos == null){
            return;
        }

        if (this.mainView.mapView.isInsideSelection(tilePos.x_, tilePos.y_)) { // Restrict bucket tool to only work inside the selected area
            this.doFill(tilePos, history);
        }
    }

    public override function mouseDragEnd(tilePos:IntPoint, history:MapHistory):void {
        if (tilePos == null){
            return;
        }

        if (this.mainView.mapView.isInsideSelection(tilePos.x_, tilePos.y_)) {
            this.doFill(tilePos, history);
        }
    }

    private function doFill(tilePos:IntPoint, history:MapHistory):void {
        var actions:MapActionSet = new MapActionSet();

        var continuous:Boolean = this.mainView.inputHandler.ctrlKey; // Hold ctrl key for continuous
        var tileMap:TileMapView = this.mainView.mapView.tileMap;
        var origTile:MapTileData = tileMap.getTileData(tilePos.x_, tilePos.y_).clone();
        if (continuous) {
            this.continuousFill(origTile, actions);
        } else {
            // DFS (Depth-First Search) algorithm. Edit: it's BFS (Breadth-First Search) now

            // Try to perform fill on the nearby tiles. Edit: iterative approach, recursive gives stack overflow
            var pending:Vector.<IntPoint> = new Vector.<IntPoint>();
            pending.push(tilePos);

            while (pending.length != 0){
                var pos:IntPoint = pending.pop();
                if (!this.mainView.mapView.isInsideSelection(pos.x_, pos.y_)) {
                    continue;
                }

                if (this.fillTile(pos.x_, pos.y_, origTile, actions)) {
                    pending.push(new IntPoint(pos.x_ + 1, pos.y_)); // Push to queue adjacent tiles
                    pending.push(new IntPoint(pos.x_ - 1, pos.y_));
                    pending.push(new IntPoint(pos.x_, pos.y_ + 1));
                    pending.push(new IntPoint(pos.x_, pos.y_ - 1));
                }
            }
        }

        history.recordSet(actions);
    }

    private function continuousFill(origTile:MapTileData, actions:MapActionSet):void {
        var mapData:MapData = this.mainView.mapView.mapData;
        for (var yi:int = 0; yi < mapData.mapHeight; yi++) { // Iterate over the entire map
            for (var xi:int = 0; xi < mapData.mapWidth; xi++) {
                if (!this.mainView.mapView.isInsideSelection(xi, yi)) {
                    continue;
                }

                this.fillTile(xi, yi, origTile, actions); // Make sure we don't do the recursive call
            }
        }
    }

    private function fillTile(mapX:int, mapY:int, origTile:MapTileData, actions:MapActionSet):Boolean {
        var brush:MEBrush = this.mainView.userBrush;
        var tileMap:TileMapView = this.mainView.mapView.tileMap;

        var prevData:MapTileData = tileMap.getTileData(mapX, mapY);
        if (prevData == null) {
            return false;
        }

        prevData = prevData.clone();

        switch (brush.elementType) {
            case MEDrawType.GROUND:
                if (prevData.groundType != origTile.groundType || prevData.groundType == brush.groundType) { // Don't update tile data if it's already the same
                    return false;
                }
                tileMap.setTileGround(mapX, mapY, brush.groundType);
                break;
            case MEDrawType.OBJECTS:
                if (prevData.objType != origTile.objType || prevData.objType == brush.objType) {
                    return false;
                }
                tileMap.setTileObject(mapX, mapY, brush.objType);
                break;
            case MEDrawType.REGIONS:
                if (prevData.regType != origTile.regType || prevData.regType == brush.regType) {
                    return false;
                }
                tileMap.setTileRegion(mapX, mapY, brush.regType);
                break;
        }

        tileMap.drawTile(mapX, mapY);
        actions.push(new MapReplaceTileAction(mapX, mapY, prevData, tileMap.getTileData(mapX, mapY).clone()));
        return true;
    }
}
}
