package editor.ui.elements {
import editor.MEEvent;
import editor.ui.Constants;

import flash.display.Graphics;

import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filesystem.File;
import flash.text.TextFormat;

import util.MoreColorUtil;

public class AssetBrowseSlot extends Sprite {

    public var inputName:SimpleTextInput;
    private var browseButton:SimpleTextButton;
    private var folderSelect:File;
    public var selectedDir:String;

    public function AssetBrowseSlot(){
        this.inputName = new SimpleTextInput("Name:", true, "", 18, 0xFFFFFF, 16, 0xEAEAEA, true, 120, 30);
        this.inputName.inputText.restrict = "a-z A-Z 0-9"; // lowercase, uppercase, and numbers allowed
        addChild(this.inputName);

        this.browseButton = new SimpleTextButton("Browse");
        this.browseButton.x = this.inputName.x + this.inputName.width + 3;
        this.browseButton.y = (this.inputName.height - this.browseButton.height) / 2;
        this.browseButton.addEventListener(MouseEvent.CLICK, this.onBrowseClick);
        addChild(this.browseButton);

        this.folderSelect = new File();
        this.folderSelect.addEventListener(Event.SELECT, this.onFolderSelect);
    }

    private function onBrowseClick(e:Event):void {
        e.stopImmediatePropagation();

        this.folderSelect.browseForDirectory("Select the path to your assets directory");
    }

    private function onFolderSelect(e:Event):void {
        this.selectedDir = this.folderSelect.nativePath;
        trace("FOLDER SELECTED", this.selectedDir);
        this.dispatchEvent(new Event(MEEvent.ASSETS_DIR_ADDED));
    }
}
}
