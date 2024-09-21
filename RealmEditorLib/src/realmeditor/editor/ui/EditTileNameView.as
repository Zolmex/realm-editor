package realmeditor.editor.ui {
import editor.MEEvent;
import editor.ui.elements.SimpleCloseButton;
import editor.ui.elements.SimpleInputBox;
import editor.ui.elements.SimpleOkButton;
import editor.ui.elements.SimpleText;

import flash.display.Graphics;

import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

import realmeditor.editor.MEEvent;

import realmeditor.editor.ui.elements.SimpleCloseButton;

import realmeditor.editor.ui.elements.SimpleInputBox;
import realmeditor.editor.ui.elements.SimpleOkButton;

import realmeditor.editor.ui.elements.SimpleText;

public class EditTileNameView extends Sprite {

    private static const WIDTH:int = 150;

    public var tileX:int;
    public var tileY:int;
    public var objName:String;
    private var background:Shape;
    private var title:SimpleText;
    private var nameInput:SimpleInputBox;
    private var okButton:SimpleOkButton;
    private var closeButton:SimpleCloseButton;

    public function EditTileNameView(x:int, y:int, objName:String) {
        this.tileX = x;
        this.tileY = y;
        this.objName = objName == null ? "" : objName;

        this.background = new Shape();
        addChild(this.background);

        this.title = new SimpleText(20, 0xFFFFFF);
        this.title.setText("Name");
        this.title.setBold(true);
        this.title.updateMetrics();
        this.title.x = 5;
        this.title.y = 5;
        this.title.filters = Constants.SHADOW_FILTER_1;
        addChild(this.title);

        this.nameInput = new SimpleInputBox(WIDTH, 30, this.objName, 18, 0xFFFFFF, true);
        this.nameInput.x = this.title.x;
        this.nameInput.y = this.title.y + this.title.height + 10;
        addChild(this.nameInput);

        this.okButton = new SimpleOkButton();
        this.okButton.x = this.title.x;
        this.okButton.y = this.nameInput.y + this.nameInput.height + 5;
        this.okButton.addEventListener(MouseEvent.CLICK, this.onOkClick);
        addChild(this.okButton);

        this.closeButton = new SimpleCloseButton();
        this.closeButton.x = this.okButton.x + this.okButton.width + 10;
        this.closeButton.y = this.okButton.y;
        this.closeButton.addEventListener(MouseEvent.CLICK, this.onCloseClick);
        addChild(this.closeButton);

        var g:Graphics = this.background.graphics;
        g.beginFill(Constants.BACK_COLOR_2, 0.8);
        g.drawRoundRect(0, 0, width + 15, height + 5, 15, 15);
        g.endFill();

        filters = Constants.SHADOW_FILTER_1;
    }

    public function showNew(x:int, y:int, objName:String):void {
        this.tileX = x;
        this.tileY = y;
        this.objName = objName == null ? "" : objName;

        this.nameInput.inputText.setText(this.objName);

        this.visible = true;
    }

    private function onOkClick(e:Event):void {
        e.stopImmediatePropagation();

        this.objName = this.nameInput.inputText.text;
        if (this.objName == ""){
            return;
        }

        this.dispatchEvent(new Event(MEEvent.EDIT_OBJ_NAME));

        this.visible = false;
    }

    private function onCloseClick(e:Event):void {
        e.stopImmediatePropagation();

        this.visible = false;
    }
}
}
