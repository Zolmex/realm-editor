package realmeditor.editor.ui {
import assets.ObjectLibrary;

import editor.MEDrawType;
import editor.ui.elements.IDrawElementFilter;

import flash.utils.Dictionary;

import realmeditor.assets.ObjectLibrary;

import realmeditor.editor.MEDrawType;

import realmeditor.editor.ui.elements.IDrawElementFilter;

public class DrawListObjectFilter implements IDrawElementFilter {

    private var drawType:int;
    private var props:Object = {};

    public function addProp(propName:String, value:*):void {
        this.props[propName] = value;
    }

    public function removeProp(propName:String):void {
        if (!this.props.hasOwnProperty(propName)) {
            return;
        }
        delete this.props[propName];
    }

    public function setDrawType(drawType:int):void {
        this.drawType = drawType;
    }

    public function filter(elementType:int):Boolean {
        if (this.drawType != MEDrawType.OBJECTS) {
            return true;
        }

        var xml:XML = ObjectLibrary.xmlLibrary_[elementType];
        if (xml.Class == "Projectile" || xml.Class == "Equipment" || xml.Class == "Dye") {
            return false;
        }

        for (var propName:String in this.props) {
            var value:* = this.props[propName];
            if ((value && !xml.hasOwnProperty(propName)) || (!value && xml.hasOwnProperty(propName)) ||
                    (value && xml.hasOwnProperty(propName) && !ValuesMatch(xml, propName, value))) {
                return false;
            }
        }

        return true;
    }

    private static function ValuesMatch(xml:XML, propName:String, value:*):Boolean {
        if (value is Boolean) {
            return xml.hasOwnProperty(propName) == value;
        }
        if (value is String || value is int) {
            return xml[propName] == value;
        }
        return false;
    }
}
}
