package {

import assets.AssetLoader;
import assets.DynamicAssetLoader;

import editor.Parameters;

import editor.ui.Keybinds;

import editor.ui.MapInputHandler;

import flash.display.Sprite;
import flash.display.Stage;
import flash.display.StageAlign;
import flash.display.StageDisplayState;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.text.TextField;

import editor.ui.MainView;

import flash.ui.Keyboard;

[SWF(frameRate="144", backgroundColor="#000000", width="800", height="600")]
public class Main extends Sprite {

    public static var STAGE:Stage;
    public static var View:MainView;
    public static var StageWidth:int = 800;
    public static var StageHeight:int = 600;
    public static var ScaleX:Number;
    public static var ScaleY:Number;

    public function Main() {
        if (stage) {
            stage.addEventListener(Event.RESIZE, this.onStageResize);
            this.setup();
        }
        else {
            addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
        }
    }

    private function onAddedToStage(e:Event):void {
        stage.removeEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
        stage.addEventListener(Event.RESIZE, this.onStageResize);
        this.setup();
    }

    private function onStageResize(e:Event):void {
        StageWidth = stage.stageWidth;
        StageHeight = stage.stageHeight;
        ScaleX = stage.stageWidth / 800;
        ScaleY = stage.stageHeight / 600;
    }

    private function setup():void {
        STAGE = stage;

        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.align = StageAlign.TOP_LEFT;

        Parameters.load();
        Keybinds.loadKeys();

        if (Parameters.data.selectedAssetsDir != null){
            if (Parameters.getAssetDirs().length == 0){
                Parameters.data.selectedAssetsDir = null;
                Parameters.save();

                AssetLoader.load(); // Load from embedded assets if there are no selected directories
            }
            else {
                DynamicAssetLoader.load();
            }
        }
        else {
            AssetLoader.load();
        }

        View = new MainView(this);
        addChild(View);
    }
}
}
