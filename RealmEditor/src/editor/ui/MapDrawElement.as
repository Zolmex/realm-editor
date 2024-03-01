package editor.ui {
import assets.ground.GroundLibrary;
import assets.objects.ObjectLibrary;
import assets.regions.RegionLibrary;

import editor.MEDrawType;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;

public class MapDrawElement extends Sprite {

    public var elementType:int;
    public var texture:BitmapData;
    private var tooltip:DrawListTooltip;

    public function MapDrawElement(elementType:int, texture:BitmapData, drawType:int) {
        this.elementType = elementType;
        this.texture = texture;
        addChild(new Bitmap(texture));

        var xml:XML;
        switch(drawType){
            case MEDrawType.GROUND:
                xml = GroundLibrary.xmlLibrary_[elementType];
                break;
            case MEDrawType.OBJECTS:
                xml = ObjectLibrary.xmlLibrary_[elementType];
                break;
            case MEDrawType.REGIONS:
                xml = RegionLibrary.xmlLibrary_[elementType];
                break;
        }

        this.tooltip = new DrawListTooltip(this, texture, xml, drawType);
        Main.STAGE.addChild(this.tooltip);
    }
}
}
