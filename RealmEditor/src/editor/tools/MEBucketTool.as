package editor.tools {
import editor.MEBrush;
import editor.MEDrawType;
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

public class MEBucketTool extends METool {

    public function MEBucketTool(view:MainView) {
        super(METool.BUCKET_ID, view);
    }

    public override function tileClick(tilePos:IntPoint, history:MapHistory):void {
        if (!this.mainView.mapView.isInsideSelection(tilePos.x_, tilePos.y_, true)){
            return;
        }

        this.doFill(history);
    }

    private function doFill(history:MapHistory):void {
        var brush:MEBrush = this.mainView.userBrush;
        var tileMap:TileMapView = this.mainView.mapView.tileMap;
        var selection:MapSelectData = this.mainView.mapView.selection;

        var startX:int = selection.startX;
        var startY:int = selection.startY;
        var endX:int = selection.endX;
        var endY:int = selection.endY;

        var actions:MapActionSet = new MapActionSet();
        for (var mapY:int = startY; mapY <= endY; mapY++) {
            for (var mapX:int = startX; mapX <= endX; mapX++) {
                var prevData:MapTileData = tileMap.getTileData(mapX, mapY).clone();
                var changed:Boolean = true; // Flag to make sure we updated the tile data
                switch (brush.elementType) {
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
                        break;
                }

                if (changed) {
                    tileMap.drawTile(mapX, mapY);
                    actions.push(new MapReplaceTileAction(mapX, mapY, prevData, tileMap.getTileData(mapX, mapY).clone()));
                }
            }
        }

        history.recordSet(actions);
    }
}
}
