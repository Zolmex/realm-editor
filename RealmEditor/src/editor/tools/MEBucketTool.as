package editor.tools {
import editor.MEBrush;
import editor.MEDrawType;
import editor.MapTileData;
import editor.actions.MapAction;
import editor.actions.MapActionSet;
import editor.ui.MainView;
import editor.ui.MapHistory;
import editor.ui.MapView;
import editor.ui.TileMapView;

import flash.display.Shape;

import util.IntPoint;

public class MEBucketTool extends METool {

    public function MEBucketTool(view:MainView) {
        super(METool.BUCKET_ID, view);
    }

    public override function mouseDrag(tilePos:IntPoint, history:MapHistory):void {
        var brush:MEBrush = this.mainView.userBrush;
        var tileMap:TileMapView = this.mainView.mapView.tileMap;
        var selectionPos:Shape = this.mainView.mapView.selectionPos;
        var selectionSize:IntPoint = this.mainView.mapView.selectionSize;

        var startX:int = selectionPos.x / TileMapView.TILE_SIZE;
        var startY:int = selectionPos.y / TileMapView.TILE_SIZE;
        var width:int = selectionSize.x_;
        var height:int = selectionSize.y_;

        for (var mapY:int = startY; mapY < startY + height; mapY++) {
            for (var mapX:int = startX; mapX < startX + width; mapX++) {
                var prevData:MapTileData = tileMap.getTileData(mapX, mapY);
                var prevValue:int;
                var newValue:int;
                switch (brush.drawType) {
                    case MEDrawType.GROUND:
                        prevValue = prevData == null ? -1 : prevData.groundType;
                        newValue = brush.groundType;
                        tileMap.setTileGround(mapX, mapY, brush.groundType);
                        break;
                    case MEDrawType.OBJECTS:
                        prevValue = prevData == null ? 0 : prevData.objType;
                        newValue = brush.objType;
                        tileMap.setTileObject(mapX, mapY, brush.objType);
                        break;
                    case MEDrawType.REGIONS:
                        prevValue = prevData == null ? 0 : prevData.regType;
                        newValue = brush.regType;
                        tileMap.setTileRegion(mapX, mapY, brush.regType);
                        break;
                }
                tileMap.drawTile(mapX, mapY);
            }
        }
    }
}
}
