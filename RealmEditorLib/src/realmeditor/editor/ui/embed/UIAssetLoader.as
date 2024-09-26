package realmeditor.editor.ui.embed {
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.Dictionary;

import mx.core.BitmapAsset;

import realmeditor.editor.ui.embed.AuruUI;
import realmeditor.util.IntPoint;

public class UIAssetLoader {

    public static const TOOLBAR_ELEMENTS:String = "toolBarElementsView";

    private static const assets:Dictionary = new Dictionary(); // id:String, uiAsset:BitmapData

    public static function load():void {
        var uiSheet:BitmapData = new AuruUI().bitmapData;
        var cutXMLS:XMLList = XML(new UICuts()).Cut;

        for each (var cut:XML in cutXMLS){
            var start:IntPoint = new IntPoint(cut.Start.@x, cut.Start.@y);
            var end:IntPoint = new IntPoint(cut.End.@x, cut.End.@y);

            var id:String = String(cut.@id);
            if (assets[id] != undefined){
                throw new Error("Duplicate UI asset id: " + id);
            }

            var width:int = end.x_ - start.x_ + 1;
            var height:int = end.y_ - start.y_ + 1;
            var data:BitmapData = new BitmapData(width, height);
            data.copyPixels(uiSheet, new Rectangle(start.x_, start.y_, width, height), new Point(0, 0));
            assets[id] = data;
        }
    }

    public static function getAsset(id:String):BitmapData {
        if (assets[id] == undefined || assets[id] == null){
            throw new Error("UI asset not found: " + id);
        }
        return assets[id];
    }
}
}
