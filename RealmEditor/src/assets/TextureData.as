package assets {
import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.utils.Dictionary;

public class TextureData {
    public var texture_:BitmapData = null;

    public var mask_:BitmapData = null;

    public var animatedChar_:AnimatedChar = null;

    public var randomTextureData_:Vector.<TextureData> = null;

    public var altTextures_:Dictionary = null;

    public var effectProps_:EffectProperties = null;

    public function TextureData(objectXML:XML, region:Boolean = false) {
        var altTexture:XML = null;
        super();
        if (region){
            this.texture_ = new BitmapData(8, 8, true, 0);
            this.texture_.fillRect(new Rectangle(0, 0, 8, 8), 1593835520 | int(objectXML.Color));
            return;
        }

        if (objectXML.hasOwnProperty("Texture")) {
            this.parse(XML(objectXML.Texture));
        } else if (objectXML.hasOwnProperty("AnimatedTexture")) {
            this.parse(XML(objectXML.AnimatedTexture));
        } else if (objectXML.hasOwnProperty("RandomTexture")) {
            this.parse(XML(objectXML.RandomTexture));
        } else {
            this.parse(objectXML);
        }
        for each(altTexture in objectXML.AltTexture) {
            this.parse(altTexture);
        }
        if (objectXML.hasOwnProperty("Mask")) {
            this.parse(XML(objectXML.Mask));
        }
        if (objectXML.hasOwnProperty("Effect")) {
            this.parse(XML(objectXML.Effect));
        }
    }

    public function getTexture(id:int = 0):BitmapData {
        if (this.randomTextureData_ == null) {
            return this.texture_;
        }
        var textureData:TextureData = this.randomTextureData_[id % this.randomTextureData_.length];
        return textureData.getTexture(id);
    }

    public function getAltTextureData(id:int):TextureData {
        if (this.altTextures_ == null) {
            return null;
        }
        return this.altTextures_[id];
    }

    private function parse(xml:XML):void {
        var image:MaskedImage = null;
        var childXML:XML = null;
        switch (xml.name().toString()) {
            case "Texture":
                this.texture_ = AssetLibrary.getImageFromSet(String(xml.File), int(xml.Index));
                break;
            case "Mask":
                this.mask_ = AssetLibrary.getImageFromSet(String(xml.File), int(xml.Index));
                break;
            case "Effect":
                this.effectProps_ = new EffectProperties(xml);
                break;
            case "AnimatedTexture":
                this.animatedChar_ = AnimatedChars.getAnimatedChar(String(xml.File), int(xml.Index));
                image = this.animatedChar_.imageFromAngle(0, AnimatedChar.STAND, 0);
                this.texture_ = image.image_;
                this.mask_ = image.mask_;
                break;
            case "RandomTexture":
                this.randomTextureData_ = new Vector.<TextureData>();
                for each(childXML in xml.children()) {
                    this.randomTextureData_.push(new TextureData(childXML));
                }
                break;
            case "AltTexture":
                if (this.altTextures_ == null) {
                    this.altTextures_ = new Dictionary();
                }
                this.altTextures_[int(xml.@id)] = new TextureData(xml);
        }
    }
}
}
