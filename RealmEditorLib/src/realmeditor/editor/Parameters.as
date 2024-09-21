package realmeditor.editor {
import flash.net.SharedObject;

public class Parameters {

    private static const ASSET_DIRS_KEY:String = "assetDirs";

    private static var sharedObj:SharedObject;
    public static var data:Object;

    public static function load():void {
        try {
            sharedObj = SharedObject.getLocal("RealmEditorSettings", "/");
            data = sharedObj.data;
        }
        catch (error:Error) {
            trace("WARNING: unable to save settings");
            data = {};
        }
        setDefaults();
        save();
    }

    public static function save():void {
        try {
            if (sharedObj) {
                sharedObj.flush();
            }
        }
        catch (error:Error) {
        }
    }

    public static function getAssetDirs():Vector.<String>{
        var ret:Vector.<String> = new Vector.<String>();
        if (data[ASSET_DIRS_KEY] != null){
            var dataStr:String = String(data[ASSET_DIRS_KEY]);
            if (dataStr == ""){
                return ret;
            }

            for each (var dir:String in dataStr.split("$")){ // Directories are split with '$' and assetId from dir is split with '?'
                ret.push(dir);
            }
        }
        return ret;
    }

    public static function saveAssetsDir(dir:String):void {
        trace("ADDED ASSETS DIRECTORY", dir);
        if (data[ASSET_DIRS_KEY] == null || data[ASSET_DIRS_KEY] == ""){
            data[ASSET_DIRS_KEY] = dir;
        }
        else {
            data[ASSET_DIRS_KEY] += "$" + dir;
        }
        save();
    }

    public static function deleteAssetsDir(dir:String):void { // indexOf returns the index of the first character
        var savedAssets:String = data[ASSET_DIRS_KEY];
        var deleteDelim:int = 0;
        if (savedAssets.indexOf("$") != -1){ // This indicates that there's more than 1 directory saved
            deleteDelim = 1; // This erases the $ at the beginning of the directory
        }

        var firstCut:String = savedAssets.substr(0, savedAssets.indexOf(dir)); // Cuts from beginning until first index of dir. Minus de $ delimiter
        var secondCut:String = savedAssets.substr(savedAssets.indexOf(dir) + dir.length + deleteDelim); // Cuts from the end of dir to the end of the string
        data[ASSET_DIRS_KEY] = firstCut + secondCut;
        trace("REMOVED ASSETS DIRECTORY", dir, data[ASSET_DIRS_KEY]);
        save();
    }

    private static function setDefaults():void {
    }
}
}
