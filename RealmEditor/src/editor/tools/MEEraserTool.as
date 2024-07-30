package editor.tools {
import editor.MEBrush;
import editor.MEDrawType;
import editor.MapTileData;
import editor.actions.MapActionSet;
import editor.actions.MapReplaceTileAction;
import editor.ui.MainView;
import editor.MapHistory;
import editor.ui.MapView;
import editor.ui.TileMapView;

import util.IntPoint;

public class MEEraserTool extends METool {

    public function MEEraserTool(view:MainView) {
        super(METool.ERASER_ID, view);
    }

    public override function init(tilePos:IntPoint, history:MapHistory):void {
        if (tilePos == null){
            return;
        }

        this.mainView.mapView.moveBrushOverlay(tilePos.x_, tilePos.y_, this.mainView.userBrush, true, true);
    }

    public override function mouseDrag(tilePos:IntPoint, history:MapHistory):void {
        if (tilePos == null){
            return;
        }

        this.useEraser(tilePos, history);
    }

    public override function tileClick(tilePos:IntPoint, history:MapHistory):void {
        if (tilePos == null){
            return;
        }

        this.useEraser(tilePos, history);
    }

    public override function mouseMoved(tilePos:IntPoint, history:MapHistory):void {
        if (tilePos == null){
            return;
        }

        this.mainView.mapView.moveBrushOverlay(tilePos.x_, tilePos.y_, this.mainView.userBrush, true);
    }

    private function useEraser(tilePos:IntPoint, history:MapHistory):void {
        if (!this.mainView.mapView.isInsideSelection(tilePos.x_, tilePos.y_)){
            return;
        }

        var brush:MEBrush = this.mainView.userBrush;
        var mapX:int = tilePos.x_;
        var mapY:int = tilePos.y_;

        var action:MapReplaceTileAction = null;
        if (brush.size == 0) {
            action = this.eraseTile(mapX, mapY);
            if (action != null) {
                history.record(action);
            }
            return;
        }

        var actions:MapActionSet = new MapActionSet();
        var brushRadius:int = (1 + (brush.size * 2)) / 2;
        for (var y:int = mapY - brushRadius; y <= mapY + brushRadius; y++) {
            for (var x:int = mapX - brushRadius; x <= mapX + brushRadius; x++) {
                var dx:int = x - mapX;
                var dy:int = y - mapY;
                var distSq:int = dx * dx + dy * dy;
                if (distSq > brush.size * brush.size || !this.mainView.mapView.isInsideSelection(x, y)) {
                    continue;
                }

                action = this.eraseTile(x, y);
                if (action != null) {
                    actions.push(action);
                }
            }
        }

        history.recordSet(actions);
    }

    private function eraseTile(mapX:int, mapY:int):MapReplaceTileAction {
        var brush:MEBrush = this.mainView.userBrush;
        var tileMap:TileMapView = this.mainView.mapView.tileMap;
        var prevData:MapTileData = tileMap.getTileData(mapX, mapY);
        if (prevData == null){
            return null;
        }
        else {
            prevData = prevData.clone();
        }

        switch (brush.elementType) {
            case MEDrawType.GROUND:
                if (prevData.groundType == -1) { // Don't update tile data if it's already default value
                    return null;
                }
                tileMap.clearGround(mapX, mapY); // No need to call drawTile after these
                break;
            case MEDrawType.OBJECTS:
                if (prevData.objType == 0) {
                    return null;
                }
                tileMap.clearObject(mapX, mapY);
                break;
            case MEDrawType.REGIONS:
                if (prevData.regType == 0) {
                    return null;
                }
                tileMap.clearRegion(mapX, mapY);
                break;
        }

        return new MapReplaceTileAction(mapX, mapY, prevData, tileMap.getTileData(mapX, mapY).clone());
    }
}
}
