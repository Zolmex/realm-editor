package realmeditor.assets {
import flash.display.BitmapData;
import flash.utils.Dictionary;

public class ObjectLibrary {

    public static var propsLibrary_:Dictionary = new Dictionary();
    public static var xmlLibrary_:Dictionary = new Dictionary();
    public static var idToType_:Dictionary = new Dictionary();
    public static var typeToDisplayId_:Dictionary = new Dictionary();
    public static var typeToTextureData_:Dictionary = new Dictionary();
    public static var typeToTopTextureData_:Dictionary = new Dictionary();
    public static var typeToAnimationsData_:Dictionary = new Dictionary();

    public static function load(xmls:Dictionary):void {
        for each (var xml:XML in xmls){
            parseFromXML(xml);
        }
    }

    public static function clear():void {
        propsLibrary_ = new Dictionary();
        xmlLibrary_ = new Dictionary();
        idToType_ = new Dictionary();
        typeToDisplayId_ = new Dictionary();
        typeToTextureData_ = new Dictionary();
        typeToTopTextureData_ = new Dictionary();
        typeToAnimationsData_ = new Dictionary();
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

    public static function parseFromXML(objectXML:XML):void {
        if (objectXML.name() != "Object") {
            return;
        }

        try {
            var id:String = String(objectXML.@id);
            var displayId:String = id;
            if (objectXML.hasOwnProperty("DisplayId")) {
                displayId = objectXML.DisplayId;
            }
            var objectType:int = int(objectXML.@type);
            propsLibrary_[objectType] = new ObjectProperties(objectXML);
            xmlLibrary_[objectType] = objectXML;
            idToType_[id] = objectType;
            typeToDisplayId_[objectType] = displayId;
            typeToTextureData_[objectType] = new TextureData(objectXML);
            if (objectXML.hasOwnProperty("Top")) {
                typeToTopTextureData_[objectType] = new TextureData(XML(objectXML.Top));
            }
        } catch (e:Error) {
            trace("OBJECT ASSET FAILED ", id);
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

    public static function getTextureFromType(objectType:int):BitmapData {
        var textureData:TextureData = typeToTextureData_[objectType];
        if (textureData == null) {
            return null;
        }
        return textureData.getTexture();
    }
}
}
