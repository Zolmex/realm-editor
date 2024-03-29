package assets.regions {
import assets.TextureData;

import flash.utils.Dictionary;

public class RegionLibrary {

    public static const typeToTextureData_:Dictionary = new Dictionary();

    public static const xmlLibrary_:Dictionary = new Dictionary();

    public static var idToType_:Dictionary = new Dictionary();


    public function RegionLibrary() {
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

    public static function parseFromXML(xml:XML):void {
        var regionXML:XML = null;
        var type:int = 0;
        for each(regionXML in xml.Region) {
            type = int(regionXML.@type);
            xmlLibrary_[type] = regionXML;
            idToType_[String(regionXML.@id)] = type;
            typeToTextureData_[type] = new TextureData(regionXML, true);
        }
    }

    public static function getIdFromType(type:int):String {
        var objectXML:XML = xmlLibrary_[type];
        if (objectXML == null) {
            return null;
        }
        return String(objectXML.@id);
    }

    public static function getColor(type:int):int {
        var objectXML:XML = xmlLibrary_[type];
        if (objectXML == null) {
            return 0;
        }
        return int(objectXML.Color);
    }
}
}
