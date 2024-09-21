package realmeditor.editor.actions {
import editor.MapDragController;
import editor.MapDragController;
import editor.MapHistory;
import editor.MapTileData;
import editor.actions.data.MapSelectData;
import editor.ui.MainView;
import editor.ui.MapView;
import editor.ui.TileMapView;

import realmeditor.editor.MapTileData;
import realmeditor.editor.ui.MainView;
import realmeditor.editor.ui.TileMapView;

import util.IntPoint;

public class MapClearAreaAction extends MapAction {

    private var tileDict:Vector.<MapTileData>;
    private var startX:int;
    private var startY:int;
    private var endX:int;
    private var endY:int;

    public function MapClearAreaAction(tileDict:Vector.<MapTileData>, startX:int, startY:int, endX:int, endY:int) {
        this.tileDict = tileDict;
        this.startX = startX;
        this.startY = startY;
        this.endX = endX;
        this.endY = endY;
    }

    public override function doAction():void {
        var startX:int = this.startX;
        var startY:int = this.startY;
        var endX:int = this.endX;
        var endY:int = this.endY;

        var tileMap:TileMapView = MainView.Instance.mapView.tileMap;
        for (var y:int = startY; y <= endY; y++) {
            for (var x:int = startX; x <= endX; x++) {
                tileMap.clearTile(x, y);
            }
        }
    }

    public override function undoAction():void {
        var startX:int = this.startX;
        var startY:int = this.startY;
        var endX:int = this.endX;
        var endY:int = this.endY;

        var idx:int = 0;
        var tileMap:TileMapView = MainView.Instance.mapView.tileMap;
        for (var y:int = startY; y <= endY; y++) {
            for (var x:int = startX; x <= endX; x++) {
                tileMap.setTileData(x, y, this.tileDict[idx]);
                tileMap.drawTile(x, y);
                idx++;
            }
        }
    }

    public override function clone():MapAction {
        return new MapClearAreaAction(this.tileDict, this.startX, this.startY, this.endX, this.endY);
    }
}
}
