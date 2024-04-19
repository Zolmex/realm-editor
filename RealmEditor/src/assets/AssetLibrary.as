package assets {
import flash.display.BitmapData;
import flash.media.Sound;
import flash.media.SoundTransform;
import flash.utils.Dictionary;

public class AssetLibrary {

    private static var images_:Dictionary = new Dictionary();

    private static var imageSets_:Dictionary = new Dictionary();

    private static var imageLookup_:Dictionary = new Dictionary();


    public function AssetLibrary(se:StaticEnforcer) {
        super();
    }

    public static function addImage(name:String, data:BitmapData):void {
        images_[name] = data;
        imageLookup_[data] = name;
    }

    public static function addImageSet(name:String, data:BitmapData, width:int, height:int):void {
        images_[name] = data;
        var imageSet:ImageSet = new ImageSet();
        imageSet.addFromBitmapData(data, width, height);
        imageSets_[name] = imageSet;
        for (var i:int = 0; i < imageSet.images_.length; i++) {
            imageLookup_[imageSet.images_[i]] = [name, i];
        }
    }

    public static function addToImageSet(name:String, data:BitmapData):void {
        var imageSet:ImageSet = imageSets_[name];
        if (imageSet == null) {
            imageSet = new ImageSet();
            imageSets_[name] = imageSet;
        }
        imageSet.add(data);
        var i:int = imageSet.images_.length - 1;
        imageLookup_[imageSet.images_[i]] = [name, i];
    }

    public static function lookupImage(data:BitmapData):Object {
        return imageLookup_[data];
    }

    public static function getImage(name:String):BitmapData {
        return images_[name];
    }

    public static function getImageSet(name:String):ImageSet {
        return imageSets_[name];
    }

    public static function getImageFromSet(name:String, id:int):BitmapData {
        var imageSet:ImageSet = imageSets_[name];
        return imageSet.images_[id];
    }

    public static function clear():void {
        images_ = new Dictionary();
        imageSets_ = new Dictionary();
        imageLookup_ = new Dictionary();
    }
}
}

class StaticEnforcer {


    function StaticEnforcer() {
        super();
    }
}
