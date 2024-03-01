package editor.ui {
import editor.MEEvent;
import editor.ui.elements.SimpleCloseButton;
import editor.ui.elements.SimpleOkButton;
import editor.ui.elements.SimpleText;
import editor.ui.elements.SimpleTextInput;

import flash.display.Graphics;

import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

public class MapCreateWindow extends Sprite {

    public var mapName:String;
    public var mapWidth:int;
    public var mapHeight:int;

    private var background:Shape;
    private var title:SimpleText;
    private var inputName:SimpleTextInput;
    private var inputWidth:SimpleTextInput;
    private var inputHeight:SimpleTextInput;
    private var okButton:SimpleOkButton;
    private var closeButton:SimpleCloseButton;

    public function MapCreateWindow() {
        this.background = new Shape();
        addChild(this.background);

        this.title = new SimpleText(20, 0xFFFFFF);
        this.title.setText("New map");
        this.title.setBold(true);
        this.title.updateMetrics();
        this.title.x = 5;
        this.title.filters = Constants.SHADOW_FILTER_1;
        addChild(this.title);

        this.inputName = new SimpleTextInput("Name:", true, "", 18, 0xFFFFFF, 15, 0xEAEAEA, true);
        this.inputName.inputText.restrict = "a-z A-Z 0-9"; // lowercase, uppercase, and numbers allowed
        this.inputName.x = 5;
        this.inputName.y = this.title.y + this.title.height + 5;
        addChild(this.inputName);

        this.inputWidth = new SimpleTextInput("Width:", true, "", 18, 0xFFFFFF, 15, 0xEAEAEA, true);
        this.inputWidth.inputText.restrict = "0-9";
        this.inputWidth.x = this.inputName.x;
        this.inputWidth.y = this.inputName.y + this.inputName.height + 5;
        addChild(this.inputWidth);

        this.inputHeight = new SimpleTextInput("Height:", true, "", 18, 0xFFFFFF, 15, 0xEAEAEA, true);
        this.inputHeight.inputText.restrict = "0-9";
        this.inputHeight.x = this.inputWidth.x;
        this.inputHeight.y = this.inputWidth.y + this.inputWidth.height + 5;
        addChild(this.inputHeight);

        this.okButton = new SimpleOkButton();
        this.okButton.x = this.inputWidth.x;
        this.okButton.y = this.inputHeight.y + this.inputHeight.height + 5;
        this.okButton.addEventListener(MouseEvent.CLICK, this.onOkClick);
        addChild(this.okButton);

        this.closeButton = new SimpleCloseButton();
        this.closeButton.x = this.okButton.x + this.okButton.width + 10;
        this.closeButton.y = this.okButton.y;
        this.closeButton.addEventListener(MouseEvent.CLICK, this.onCloseClick);
        addChild(this.closeButton);

        var g:Graphics = this.background.graphics;
        g.beginFill(Constants.BACK_COLOR_2);
        g.drawRoundRect(0, 0, width + 15, height + 5, 10, 10);
        g.endFill();

        filters = Constants.SHADOW_FILTER_1;
    }

    private function onOkClick(e:Event):void {
        e.stopImmediatePropagation();

        this.mapName = this.inputName.inputText.text;
        this.mapWidth = int(this.inputWidth.inputText.text);
        this.mapHeight = int(this.inputHeight.inputText.text);

        if (this.mapName == "" || this.mapWidth == 0 || this.mapHeight == 0){
            return;
        }

        this.dispatchEvent(new Event(MEEvent.MAP_CREATE));

        this.visible = false;
    }

    private function onCloseClick(e:Event):void {
        e.stopImmediatePropagation();

        this.visible = false;
    }
}
}
