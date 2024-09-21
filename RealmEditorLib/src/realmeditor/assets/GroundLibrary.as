package realmeditor.assets {
import flash.display.BitmapData;
import flash.utils.Dictionary;

import realmeditor.util.BitmapUtil;

import util.BitmapUtil;

public class GroundLibrary {

    public static var propsLibrary_:Dictionary = new Dictionary();
    public static var xmlLibrary_:Dictionary = new Dictionary();
    private static var tileTypeColorDict_:Dictionary = new Dictionary();
    public static var typeToTextureData_:Dictionary = new Dictionary();
    public static var idToType_:Dictionary = new Dictionary();

    public static function load(xmls:Dictionary):void {
        for each (var xml:XML in xmls){
            parseFromXML(xml);
        }
    }

    public static function clear():void {
        propsLibrary_ = new Dictionary();
        xmlLibrary_ = new Dictionary();
        tileTypeColorDict_ = new Dictionary();
        typeToTextureData_ = new Dictionary();
        idToType_ = new Dictionary();
    }

    public static function search(text:String):Vector.<int> {
        var ret:Vector.<int> = new Vector.<int>();
        for (var item:String in idToType_) {
            if (item.toLowerCase().indexOf(text.toLowerCase()) != -1) {
                ret.push(idToType_[item]);
            }
        }
        return ret;
    }

    public static function parseFromXML(groundXML:XML):void {
        if (groundXML.name() != "Ground") {
            return;
        }

        try {
            var groundType:int = int(groundXML.@type);
            propsLibrary_[groundType] = new GroundProperties(groundXML);
            xmlLibrary_[groundType] = groundXML;
            typeToTextureData_[groundType] = new TextureData(groundXML);
            idToType_[String(groundXML.@id)] = groundType;
        } catch (e:Error) {
            trace("GROUND ASSET FAILED", groundXML.@id);
            trace(e.getStackTrace());
        }
    }

    public static function getIdFromType(type:int):String {
        var props:GroundProperties = propsLibrary_[type];
        if (props == null) {
            return null;
        }
        return props.id_;
    }

    public static function getBitmapData(type:int, id:int = 0):BitmapData {
        var textureData:TextureData = typeToTextureData_[type];
        if (textureData == null) {
            return null;
        }
        return textureData.getTexture(id);
    }

    public static function getColor(groundType:int):uint {
        var groundXML:XML = null;
        var color:uint = 0;
        var bd:BitmapData = null;
        if (!tileTypeColorDict_.hasOwnProperty(groundType)) {
            groundXML = xmlLibrary_[groundType];
            if (groundXML.hasOwnProperty("Color")) {
                color = uint(groundXML.Color);
            } else {
                bd = getBitmapData(groundType);
                color = BitmapUtil.mostCommonColor(bd);
            }
            tileTypeColorDict_[groundType] = color;
        }
        return tileTypeColorDict_[groundType];
    }
}
}
