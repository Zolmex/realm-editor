package editor.ui {
import assets.ground.GroundLibrary;
import assets.objects.ObjectLibrary;
import assets.regions.RegionLibrary;

import editor.MEDrawType;
import editor.ui.elements.DrawListTooltip;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

public class MapDrawElement extends Sprite {

    public var elementType:int;
    public var texture:BitmapData;
    private var drawType:int;
    private var tooltip:DrawListTooltip;

    public function MapDrawElement(elementType:int, texture:BitmapData, drawType:int) {
        this.elementType = elementType;
        this.drawType = drawType;
        this.texture = texture;
        addChild(new Bitmap(texture));

        this.addEventListener(MouseEvent.ROLL_OVER, this.onRollOver);
    }

    private function onRollOver(e:Event):void {
        this.removeEventListener(MouseEvent.ROLL_OVER, this.onRollOver);

        var xml:XML;
        switch(this.drawType){
            case MEDrawType.GROUND:
                xml = GroundLibrary.xmlLibrary_[this.elementType];
                break;
            case MEDrawType.OBJECTS:
                xml = ObjectLibrary.xmlLibrary_[this.elementType];
                break;
            case MEDrawType.REGIONS:
                xml = RegionLibrary.xmlLibrary_[this.elementType];
                break;
        }

        if (xml == null){
            return;
        }

        this.tooltip = new DrawListTooltip(this, this.texture, xml, this.drawType);
        Main.STAGE.addChild(this.tooltip);
    }
}
}
