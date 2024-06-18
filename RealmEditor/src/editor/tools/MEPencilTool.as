package editor.tools {
import editor.MEBrush;
import editor.MEDrawType;
import editor.MapTileData;
import editor.actions.MapActionSet;
import editor.actions.MapReplaceTileAction;
import editor.ui.MainView;
import editor.ui.MapHistory;
import editor.ui.TileMapView;

import util.IntPoint;

public class MEPencilTool extends METool {

    public function MEPencilTool(view:MainView) {
        super(METool.PENCIL_ID, view);
    }

    public override function init(tilePos:IntPoint, history:MapHistory):void {
        if (this.mainView.mapView.isInsideSelection(tilePos.x_, tilePos.y_)) {
            this.mainView.mapView.moveBrushTiles(tilePos.x_, tilePos.y_, this.mainView.userBrush);
        }
    }

    public override function mouseDrag(tilePos:IntPoint, history:MapHistory):void {
        this.usePencil(tilePos, history);
    }

    public override function tileClick(tilePos:IntPoint, history:MapHistory):void {
        this.usePencil(tilePos, history);
    }

    public override function mouseMoved(tilePos:IntPoint, history:MapHistory):void {
        if (this.mainView.mapView.isInsideSelection(tilePos.x_, tilePos.y_)) {
            this.mainView.mapView.moveBrushTiles(tilePos.x_, tilePos.y_, this.mainView.userBrush);
        }
    }

    private function usePencil(tilePos:IntPoint, history:MapHistory):void {
        if (!this.mainView.mapView.isInsideSelection(tilePos.x_, tilePos.y_)){
            return;
        }

        var brush:MEBrush = this.mainView.userBrush;
        var mapX:int = tilePos.x_;
        var mapY:int = tilePos.y_;

        var action:MapReplaceTileAction = null;
        if (brush.size == 0) {
            action = this.paintTile(mapX, mapY);
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

                action = this.paintTile(x, y);
                if (action != null) {
                    actions.push(action);
                }
            }
        }

        history.recordSet(actions);
    }

    private function paintTile(mapX:int, mapY:int):MapReplaceTileAction {
        var brush:MEBrush = this.mainView.userBrush;
        var tileMap:TileMapView = this.mainView.mapView.tileMap;
        var prevData:MapTileData = tileMap.getTileData(mapX, mapY).clone();
        var changed:Boolean = true; // Flag to make sure we updated the tile data

        var ret:MapReplaceTileAction = null;
        switch (brush.drawType) {
            case MEDrawType.GROUND:
                if (prevData.groundType == brush.groundType) { // Don't update tile data if it's already the same
                    changed = false;
                    break;
                }
                tileMap.setTileGround(mapX, mapY, brush.groundType);
                break;
            case MEDrawType.OBJECTS:
                if (prevData.objType == brush.objType) {
                    changed = false;
                    break;
                }
                tileMap.setTileObject(mapX, mapY, brush.objType);
                break;
            case MEDrawType.REGIONS:
                if (prevData.regType == brush.regType) {
                    changed = false;
                    break;
                }
                tileMap.setTileRegion(mapX, mapY, brush.regType);
                break
        }

        if (changed){
            tileMap.drawTile(mapX, mapY);
            ret = new MapReplaceTileAction(mapX, mapY, prevData, tileMap.getTileData(mapX, mapY).clone());
        }

        return ret;
    }
}
}
