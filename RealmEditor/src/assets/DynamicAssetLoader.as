package assets {
import assets.ground.GroundLibrary;
import assets.objects.ObjectLibrary;
import assets.regions.RegionLibrary;

import editor.Parameters;

import flash.display.Bitmap;

import flash.display.BitmapData;

import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.ByteArray;

public class DynamicAssetLoader {

    public static var FailedAssets:String;
    public static var PendingNotifs:String;

    public static function load():void {
        FailedAssets = null;
        PendingNotifs = null;

        AssetLibrary.clear();
        AnimatedChars.clear();
        GroundLibrary.clear();
        ObjectLibrary.clear();
        RegionLibrary.clear();
        EmbeddedData.groundFiles = new Array();
        EmbeddedData.objectFiles = new Array();
        EmbeddedData.regionFiles = new Array();

        if (Parameters.data.selectedAssetsDir == null){
            AssetLoader.load();
            return;
        }

        AddNecessaryAssets(); // Make sure we load assets the editor needs first

        var assetsDir:String = Parameters.data.selectedAssetsDir.split("?")[1];
        var assetsCfgFile:File = new File(assetsDir + "\\assetsConfig.cfg");
        var assetsCfgData:ByteArray = ReadFileBytes(assetsCfgFile); // Load assetsConfig.cfg file
        if (assetsCfgData == null){ // Failed to load directory
            PendingNotifs += "|Failed to load assets directory: missing cfg file.";
            return;
        }

        var assetsCfg:String = assetsCfgData.readUTFBytes(assetsCfgData.length);
        ReadAssetsCfg(assetsCfg, assetsDir);

        if (FailedAssets != null){
            PendingNotifs += "|Failed to load asset files: " + DynamicAssetLoader.FailedAssets;
        }

        var directory:File = new File(assetsDir);
        var files:Array = directory.getDirectoryListing();
        for each (var file:File in files) { // Load xml data
            if (file.name.indexOf("EmbeddedAssets") != -1 || (file.name.indexOf(".xml") == -1 && file.name.indexOf(".dat") == -1)) {
                continue;
            }

            var xml:XML = XML(ReadFileBytes(file));
            GroundLibrary.parseFromXML(xml);
            ObjectLibrary.parseFromXML(xml);
            RegionLibrary.parseFromXML(xml);
        }
    }

    private static function AddNecessaryAssets():void {
        AssetLibrary.addImageSet("invisible", new BitmapData(8, 8, true, 0), 8, 8);
        AssetLibrary.addImageSet("cursorsEmbed", new EmbeddedAssets.cursorsEmbed_().bitmapData, 32, 32); // Editor assets
        AssetLibrary.addImageSet("editorTools", new EmbeddedAssets.editorToolsEmbed_().bitmapData, 16, 16);
    }

    private static function ReadAssetsCfg(assetsCfg:String, assetsDir:String):void {
        var version:int = int(assetsCfg.charAt(0)); // Backwards-compatibility
        assetsCfg = assetsCfg.substr(1); // Skip version character

        for each (var fileConfig:String in assetsCfg.split('\n')) { // Each line is config for an assets file
            if (fileConfig == ""){
                continue;
            }

            var barCuts:Array = fileConfig.split('|');
            var assetsType:String = barCuts[0];
            var assetName:String = barCuts[1];
            var fileName:String = barCuts[2];
            var settings:String = barCuts[3];

            var file:File = new File(assetsDir + "\\" + fileName + ".png");
            if (!file.exists){
                if (FailedAssets == null){
                    FailedAssets = fileName;
                }
                else {
                    FailedAssets += ", " + fileName;
                }
                continue;
            }

            switch (assetsType) {
                case "spriteSheet": // e.g.: spriteSheet|lofiChar8x8|EmbeddedAssets_lofiCharEmbed_|8:8
                    var settingsCut:Array = settings.split(':');
                    var spriteW:int = settingsCut[0];
                    var spriteH:int = settingsCut[1];
                    AssetLibrary.addImageSet(assetName, BitmapData.decode(ReadFileBytes(file)), spriteW, spriteH);
                    break;
                case "animatedSpriteSheet": // e.g. animatedSpriteSheet|players|EmbeddedAssets_playersEmbed_|8:8:56:24:0:EmbeddedAssets_playersMaskEmbed_
                    settingsCut = settings.split(':');
                    spriteW = settingsCut[0];
                    spriteH = settingsCut[1];
                    var sheetW:int = settingsCut[2];
                    var sheetH:int = settingsCut[3];
                    var firstDir:int = int(settingsCut[4]);
                    var maskPath:String = settingsCut[5];
                    if (maskPath == "") {
                        maskPath = null;
                    }

                    AnimatedChars.add(assetName, BitmapData.decode(ReadFileBytes(file)), maskPath == null ? null : BitmapData.decode(ReadFileBytes(new File(maskPath))), spriteW, spriteH, sheetW, sheetH, firstDir);
                    break;
                default:
                    trace("Unknown assets type:", assetsType);
                    break;
            }
        }
    }

    private static function ReadFileBytes(file:File):ByteArray {
        try {
            var fs:FileStream = new FileStream();
            fs.open(file, FileMode.READ);
            var ret:ByteArray = new ByteArray();
            fs.readBytes(ret);
            fs.close();
            return ret;
        } catch (e:Error) {
            trace(e.getStackTrace());
            return null;
        }
    }
}
}
