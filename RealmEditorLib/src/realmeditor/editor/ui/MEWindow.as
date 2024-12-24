package realmeditor.editor.ui {
import editor.ui.elements.SimpleCloseButton;
import editor.ui.elements.SimpleOkButton;
import editor.ui.elements.SimpleText;
import editor.ui.elements.SimpleTextInput;

import flash.display.Graphics;

import flash.display.Shape;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

import realmeditor.editor.ui.elements.SimpleCloseButton;

import realmeditor.editor.ui.elements.SimpleOkButton;

import realmeditor.editor.ui.elements.SimpleText;

public class MEWindow extends Sprite {

    protected var background:Shape;
    protected var title:SimpleText;
    protected var okButton:SimpleOkButton;
    protected var closeButton:SimpleCloseButton;

    public function MEWindow(title:String) {
        this.background = new Shape();
        addChild(this.background);

        this.title = new SimpleText(20, 0xFFFFFF);
        this.title.setText(title);
        this.title.setBold(true);
        this.title.updateMetrics();
        this.title.filters = Constants.SHADOW_FILTER_1;
        addChild(this.title);

        this.okButton = new SimpleOkButton();
        this.okButton.addEventListener(MouseEvent.CLICK, this.onOkClick);
        addChild(this.okButton);

        this.closeButton = new SimpleCloseButton();
        this.closeButton.addEventListener(MouseEvent.CLICK, this.onCloseClick);
        addChild(this.closeButton);

        this.addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);

        filters = Constants.SHADOW_FILTER_1;
    }

    protected virtual function onAddedToStage(e:Event):void {
        this.updatePositions();
        this.drawBackground();
    }

    protected virtual function drawBackground():void{
        var g:Graphics = this.background.graphics;
        g.clear();
        g.beginFill(Constants.BACK_COLOR_2);
        g.drawRoundRect(0, -2, width + 15, height + 7, 10, 10);
        g.endFill();
    }

    protected virtual function updatePositions():void {
        this.title.x = 5;
        this.okButton.x = 5;
        this.okButton.y = this.title.y + this.title.height + 5;
        this.closeButton.x = this.okButton.x + this.okButton.width + 10;
        this.closeButton.y = this.okButton.y;
    }

    protected virtual function onOkClick(e:Event):void {
        e.stopImmediatePropagation();
    }

    protected virtual  function onCloseClick(e:Event):void {
        e.stopImmediatePropagation();
    }
}
}
