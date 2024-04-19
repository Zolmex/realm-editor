package assets.objects {
import assets.*;

import flash.display.BitmapData;
import flash.utils.Dictionary;
import util.GlowRedrawer;

import util.TextureRedrawer;

public class ObjectLibrary {

    public static var playerChars_:Vector.<XML> = new Vector.<XML>();
    public static var hexTransforms_:Vector.<XML> = new Vector.<XML>();
    public static var playerClassAbbr_:Dictionary = new Dictionary();
    public static var propsLibrary_:Dictionary = new Dictionary();
    public static var xmlLibrary_:Dictionary = new Dictionary();
    public static var idToType_:Dictionary = new Dictionary();
    public static var typeToDisplayId_:Dictionary = new Dictionary();
    public static var typeToTextureData_:Dictionary = new Dictionary();
    public static var typeToTopTextureData_:Dictionary = new Dictionary();
    public static var typeToAnimationsData_:Dictionary = new Dictionary();
    public static var defaultProps_:ObjectProperties = new ObjectProperties(null);

    public function ObjectLibrary() {
        super();
    }

    public static function clear():void{
        playerChars_ = new Vector.<XML>();
        hexTransforms_ = new Vector.<XML>();
        playerClassAbbr_ = new Dictionary();
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

    public static function parseFromXML(xml:XML):void {
        if (!xml.hasOwnProperty("Object")){
            return;
        }

        var objectXML:XML = null;
        var id:String = null;
        var displayId:String = null;
        var objectType:int = 0;
        var found:Boolean = false;
        var i:int = 0;
        for each(objectXML in xml.Object) {
            id = String(objectXML.@id);
            displayId = id;
            if (objectXML.hasOwnProperty("DisplayId")) {
                displayId = objectXML.DisplayId;
            }
            if (objectXML.hasOwnProperty("Group")) {
                if (objectXML.Group == "Hexable") {
                    hexTransforms_.push(objectXML);
                }
            }
            objectType = int(objectXML.@type);
            propsLibrary_[objectType] = new ObjectProperties(objectXML);
            xmlLibrary_[objectType] = objectXML;
            idToType_[id] = objectType;
            typeToDisplayId_[objectType] = displayId;
            if (String(objectXML.Class) == "Player") {
                playerClassAbbr_[objectType] = String(objectXML.@id).substr(0, 2);
                found = false;
                for (i = 0; i < playerChars_.length; i++) {
                    if (int(playerChars_[i].@type) == objectType) {
                        playerChars_[i] = objectXML;
                        found = true;
                    }
                }
                if (!found) {
                    playerChars_.push(objectXML);
                }
            }
            typeToTextureData_[objectType] = new TextureData(objectXML);
            if (objectXML.hasOwnProperty("Top")) {
                typeToTopTextureData_[objectType] = new TextureData(XML(objectXML.Top));
            }
            if (objectXML.hasOwnProperty("Animation")) {
                typeToAnimationsData_[objectType] = new AnimationsData(objectXML);
            }
        }
    }

    public static function getIdFromType(type:int):String {
        var objectXML:XML = xmlLibrary_[type];
        if (objectXML == null) {
            return null;
        }
        return String(objectXML.@id);
    }

    public static function getPropsFromId(id:String):ObjectProperties {
        var objectType:int = idToType_[id];
        return propsLibrary_[objectType];
    }

    public static function getXMLfromId(id:String):XML {
        var objectType:int = idToType_[id];
        return xmlLibrary_[objectType];
    }

    public static function getTextureFromType(objectType:int):BitmapData {
        var textureData:TextureData = typeToTextureData_[objectType];
        if (textureData == null) {
            return null;
        }
        return textureData.getTexture();
    }

    public static function getRedrawnTextureFromFile(file:String, index:int, size:int, glowColor:uint = 0, scaleSize:Boolean = false):BitmapData {
        var texture:BitmapData = AssetLibrary.getImageFromSet(file, index);
        if (texture == null) {
            texture = AssetLibrary.getImageFromSet("lofiObj3", 255);
        }
        if (scaleSize) {
            size /= texture.width / 8;
        }
        texture = TextureRedrawer.redraw(texture, size, true, glowColor);
        return texture;
    }

    public static function getRedrawnTextureFromType(objectType:int, size:int, includeBottom:Boolean, useCaching:Boolean = true, scaleValue:int = 5, glowColor:uint = 0, scaleSize:Boolean = false):BitmapData {
        var textureData:TextureData = typeToTextureData_[objectType];
        var texture:BitmapData = Boolean(textureData) ? textureData.getTexture() : null;
        if (texture == null) {
            texture = AssetLibrary.getImageFromSet("lofiObj3", 255);
        }
        if (scaleSize) {
            size /= texture.width / 8;
        }
        var mask:BitmapData = Boolean(textureData) ? textureData.mask_ : null;
        if (mask == null) {
            return TextureRedrawer.redraw(texture, size, includeBottom, glowColor, useCaching, scaleValue);
        }
        var objectXML:XML = xmlLibrary_[objectType];
        var tex1:int = Boolean(objectXML.hasOwnProperty("Tex1")) ? int(int(objectXML.Tex1)) : int(0);
        var tex2:int = Boolean(objectXML.hasOwnProperty("Tex2")) ? int(int(objectXML.Tex2)) : int(0);
        texture = TextureRedrawer.resize(texture, mask, size, includeBottom, tex1, tex2);
        texture = GlowRedrawer.outlineGlow(texture, 0);
        return texture;
    }

    public static function getSizeFromType(objectType:int):int {
        var objectXML:XML = xmlLibrary_[objectType];
        if (!objectXML.hasOwnProperty("Size")) {
            return 100;
        }
        return int(objectXML.Size);
    }

    public static function getSlotTypeFromType(objectType:int):int {
        var objectXML:XML = xmlLibrary_[objectType];
        if (!objectXML.hasOwnProperty("SlotType")) {
            return -1;
        }
        return int(objectXML.SlotType);
    }
}
}
