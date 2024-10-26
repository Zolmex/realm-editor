package editor.ui {
import editor.MEEvent;
import editor.Parameters;
import editor.ui.elements.AssetBrowseSlot;
import editor.ui.elements.AssetDirectorySlot;
import editor.ui.elements.SimpleTextButton;
import editor.ui.elements.SimpleTextInput;

import flash.display.Shape;
import flash.display.Sprite;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.filesystem.File;

public class AssetsWindow extends MEWindow {

    public var assetsId:String;
    public var assetsDir:String;

    private var origSelected:AssetDirectorySlot;
    private var selectedSlot:AssetDirectorySlot;
    private var newDirectorySlot:AssetBrowseSlot; // This slot will always appear and there'll only be one of it so you can only add one directory at a time
    private var directorySlots:Vector.<AssetDirectorySlot>;
    private var slotsContainer:Sprite;

    public function AssetsWindow() {
        super("Import Assets");

        this.slotsContainer = new Sprite();
        this.directorySlots = new Vector.<AssetDirectorySlot>();
        for each (var dirStr:String in Parameters.getAssetDirs()) {
            var dirSlot:AssetDirectorySlot = new AssetDirectorySlot(dirStr);
            dirSlot.setSelected(false);
            if (Parameters.data.selectedAssetsDir == dirStr) {
                this.origSelected = dirSlot;
                this.selectedSlot = dirSlot;
                dirSlot.setSelected(true);
            }
            dirSlot.addEventListener(MouseEvent.CLICK, this.onDirectorySelected);
            dirSlot.addEventListener(MEEvent.ASSETS_DIR_REMOVED, this.onDirectoryRemoved);
            this.slotsContainer.addChild(dirSlot);
            this.directorySlots.push(dirSlot);
        }
        addChild(this.slotsContainer);

        this.newDirectorySlot = new AssetBrowseSlot();
        this.newDirectorySlot.addEventListener(MEEvent.ASSETS_DIR_ADDED, this.onDirectoryAdded);
        addChild(this.newDirectorySlot);
    }

    public function resetOriginal():void {
        this.origSelected = this.selectedSlot;
    }

    private function onDirectoryRemoved(e:Event):void {
        var slot:AssetDirectorySlot = e.target as AssetDirectorySlot;
        Parameters.deleteAssetsDir(slot.assetsId + "?" + slot.assetsDir);

        if (slot == this.selectedSlot){
            Parameters.data.selectedAssetsDir = null;
            Parameters.save();

            this.selectedSlot = null;
            this.assetsId = null;
            this.assetsDir = null;
        }

        this.slotsContainer.removeChild(slot);
        var idx:int = this.directorySlots.indexOf(slot);
        this.directorySlots.splice(idx, 1);

        this.updatePositions();
        this.drawBackground();
    }

    private function onDirectorySelected(e:Event):void {
        var slot:AssetDirectorySlot = e.target as AssetDirectorySlot;
        if (this.selectedSlot){
            if (this.selectedSlot == slot){
                return;
            }

            this.selectedSlot.setSelected(false);
        }

        slot.setSelected(true);

        Parameters.data.selectedAssetsDir = slot.assetsId + "?" + slot.assetsDir;
        Parameters.save();

        this.selectedSlot = slot;
        this.assetsId = slot.assetsId;
        this.assetsDir = slot.assetsDir;
    }

    private function onDirectoryAdded(e:Event):void {
        var browseSlot:AssetBrowseSlot = e.target as AssetBrowseSlot;
        var name:String = browseSlot.inputName.inputText.text;
        var dir:String = browseSlot.selectedDir;
        if (name == "" || dir == null){
            return;
        }

        if (this.selectedSlot){
            this.selectedSlot.setSelected(false);
        }

        var slot:AssetDirectorySlot = new AssetDirectorySlot(name + "?" + dir);
        slot.setSelected(true);
        slot.addEventListener(MouseEvent.CLICK, this.onDirectorySelected);
        slot.addEventListener(MEEvent.ASSETS_DIR_REMOVED, this.onDirectoryRemoved);

        Parameters.data.selectedAssetsDir = slot.assetsId + "?" + slot.assetsDir;
        Parameters.saveAssetsDir(name + "?" + dir);

        this.selectedSlot = slot;
        this.assetsId = slot.assetsId;
        this.assetsDir = slot.assetsDir;

        this.slotsContainer.addChild(slot);
        this.directorySlots.push(slot);

        this.updatePositions();
        this.drawBackground();
    }

    private function positionSlots():void {
        for (var i:int = 0; i < this.directorySlots.length; i++){
            var slot:AssetDirectorySlot = this.directorySlots[i];
            slot.y = i * (slot.height + 5);
        }
    }

    protected override function updatePositions():void {
        super.updatePositions();

        this.positionSlots();

        this.slotsContainer.x = 3;
        this.slotsContainer.y = this.title.y + this.title.height + 5;

        this.newDirectorySlot.x = this.slotsContainer.x;
        this.newDirectorySlot.y = this.slotsContainer.y + this.slotsContainer.height;

        this.okButton.x = this.slotsContainer.x;
        this.okButton.y = this.newDirectorySlot.y + this.newDirectorySlot.height;
        this.closeButton.x = this.okButton.x + this.okButton.width + 10;
        this.closeButton.y = this.okButton.y;

        Main.View.updatePositions();
    }

    protected override function onOkClick(e:Event):void {
        super.onOkClick(e);

        if (this.origSelected != this.selectedSlot) {
            this.dispatchEvent(new Event(MEEvent.ASSETS_DIR_SELECT));
        }

        this.visible = false;
    }

    protected override function onCloseClick(e:Event):void {
        super.onCloseClick(e);

        this.visible = false;
    }
}
}
