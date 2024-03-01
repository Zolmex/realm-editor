package assets.ground {
import assets.*;

import flash.display.BitmapData;
import flash.utils.Dictionary;

import util.BitmapUtil;

public class GroundLibrary {

    public static const propsLibrary_:Dictionary = new Dictionary();

    public static const xmlLibrary_:Dictionary = new Dictionary();

    private static var tileTypeColorDict_:Dictionary = new Dictionary();

    public static const typeToTextureData_:Dictionary = new Dictionary();

    public static var idToType_:Dictionary = new Dictionary();

    public static var defaultProps_:GroundProperties;


    public function GroundLibrary() {
        super();
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

    public static function getProperties(type:int):GroundProperties {
        var props:GroundProperties = propsLibrary_[type];
        if (props == null) {
            return null;
        }
        return props;
    }

    public static function parseFromXML(xml:XML):void {
        var groundXML:XML = null;
        var groundType:int = 0;
        for each(groundXML in xml.Ground) {
            groundType = int(groundXML.@type);
            propsLibrary_[groundType] = new GroundProperties(groundXML);
            xmlLibrary_[groundType] = groundXML;
            typeToTextureData_[groundType] = new TextureData(groundXML);
            idToType_[String(groundXML.@id)] = groundType;
        }
        defaultProps_ = propsLibrary_[255];
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
