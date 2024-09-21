package realmeditor.assets {
import flash.utils.Dictionary;

public class RegionLibrary {

    public static var typeToTextureData_:Dictionary = new Dictionary();
    public static var xmlLibrary_:Dictionary = new Dictionary();
    public static var idToType_:Dictionary = new Dictionary();

    public static function load(xmls:Dictionary):void {
        for each (var xml:XML in xmls){
            parseFromXML(xml);
        }
    }

    public static function clear():void {
        typeToTextureData_ = new Dictionary();
        xmlLibrary_ = new Dictionary();
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

    public static function parseFromXML(regionXML:XML):void {
        if (regionXML.name() != "Region") {
            return;
        }

        try {
            var type:int = int(regionXML.@type);
            xmlLibrary_[type] = regionXML;
            idToType_[String(regionXML.@id)] = type;
            typeToTextureData_[type] = new TextureData(regionXML, true);
        } catch (e:Error) {
            trace("REGION ASSET FAILED", regionXML.@id);
            trace(e.getStackTrace());
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
