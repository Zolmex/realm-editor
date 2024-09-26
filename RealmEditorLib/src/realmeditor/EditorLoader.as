package realmeditor {
import assets.AnimatedChars;
import assets.AssetLibrary;
import assets.GroundLibrary;
import assets.ObjectLibrary;
import assets.RegionLibrary;

import editor.Parameters;
import editor.ui.Keybinds;
import editor.ui.MainView;
import editor.ui.embed.Cursors;
import editor.ui.embed.EditorTools;

import flash.display.BitmapData;

import flash.display.Sprite;
import flash.utils.Dictionary;

import realmeditor.assets.AnimatedChars;

import realmeditor.assets.AssetLibrary;

import realmeditor.assets.GroundLibrary;
import realmeditor.assets.ObjectLibrary;
import realmeditor.assets.RegionLibrary;
import realmeditor.editor.Parameters;
import realmeditor.editor.ui.Keybinds;
import realmeditor.editor.ui.MainView;
import realmeditor.editor.ui.embed.UIAssetLoader;
import realmeditor.editor.ui.embed.Cursors;
import realmeditor.editor.ui.embed.EditorTools;

public class EditorLoader {

    private static var readyCount:int = 0;

    public static function loadGround(xmls:Dictionary):void {
        GroundLibrary.load(xmls);
        readyCount++;
    }

    public static function loadObjects(xmls:Dictionary):void {
        ObjectLibrary.load(xmls);
        readyCount++;
    }

    public static function loadRegions(xmls:Dictionary):void {
        RegionLibrary.load(xmls);
        readyCount++;
    }

    public static function loadAssets(images:Dictionary, imageSets:Dictionary, imageLookup:Dictionary):void {
        AssetLibrary.load(images, imageSets, imageLookup);
        AssetLibrary.addImageSet("invisible", new BitmapData(8, 8, true, 0), 8, 8);
        AssetLibrary.addImageSet("cursorsEmbed", new Cursors().bitmapData, 32, 32); // Editor assets
        AssetLibrary.addImageSet("editorTools", new EditorTools().bitmapData, 16, 16);
        readyCount++;
    }

    public static function loadAnimChars(chars:Dictionary):void {
        AnimatedChars.load(chars);
        readyCount++;
    }

    public static function load(main:Sprite, embedded:Boolean = true):Sprite {
        if (readyCount < 5){
            throw new Error("RealmEditor: " + readyCount + " out of 5 asset libraries weren't loaded.");
        }

        UIAssetLoader.load();
        Parameters.load();
        Keybinds.loadKeys();

        var view:MainView = new MainView(main, embedded);
        main.addChild(view);
        return view;
    }
}
}
