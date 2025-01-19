package realmeditor.editor.ui.elements {
import editor.ui.Constants;

import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextFieldAutoSize;

import realmeditor.editor.ui.Constants;

public class SimpleCheckBox extends Sprite {

    private static const WIDTH:int = 95;
    private static const HEIGHT:int = CHECKBOX_SIZE + 8;
    private static const CHECKBOX_SIZE:int = 15;
    private static const CHECKCROSS_SIZE:int = 10;

    public var value:Boolean;
    private var background:Shape;
    private var title:SimpleText;
    private var checkBox:Sprite;
    private var checkCross:Shape;

    public function SimpleCheckBox(title:String, defaultValue:Boolean = false) {
        this.value = defaultValue;

        this.background = new Shape();
        addChild(this.background);

        this.title = new SimpleText(18, 0xFFFFFF, false, WIDTH - CHECKBOX_SIZE - 7);
        this.title.setAutoSize(TextFieldAutoSize.LEFT);
        this.title.setText(title);
        this.title.filters = Constants.SHADOW_FILTER_1;
        this.title.updateMetrics();
        addChild(this.title);

        this.checkBox = new Sprite();
        var g:Graphics = this.checkBox.graphics;
        g.beginFill(Constants.BACK_COLOR_2);
        g.drawRoundRect(0, 0, CHECKBOX_SIZE, CHECKBOX_SIZE, 5, 5);
        g.endFill();
        addChild(this.checkBox);

        this.checkCross = new Shape();
        this.checkCross.visible = defaultValue;
        g = this.checkCross.graphics;
        g.lineStyle(3, 0xFFFFFF);
        g.lineTo(CHECKCROSS_SIZE, CHECKCROSS_SIZE);
        g.moveTo(CHECKCROSS_SIZE, 0);
        g.lineTo(0, CHECKCROSS_SIZE);
        g.lineStyle();
        addChild(this.checkCross);

        this.positionChildren();
        this.drawBackground();

        this.checkBox.addEventListener(MouseEvent.CLICK, this.onClick);
    }

    public function setValue(value:Boolean):void {
        this.value = value;
        this.checkCross.visible = value;
    }

    private function onClick(e:Event):void {
        this.value = !this.value;
        this.checkCross.visible = this.value;
        this.dispatchEvent(new Event(Event.CHANGE));
    }

    private function positionChildren():void {
        this.title.x = 2;
        this.title.y = (HEIGHT - this.title.actualHeight_) / 2;

        this.checkBox.x = this.title.x + this.title.actualWidth_ + 5;
        this.checkBox.y = (HEIGHT - this.checkBox.height) / 2;

        this.checkCross.x = this.checkBox.x + (CHECKBOX_SIZE - CHECKCROSS_SIZE) / 2;
        this.checkCross.y = this.checkBox.y + (CHECKBOX_SIZE - CHECKCROSS_SIZE) / 2;
    }

    private function drawBackground():void {
        var g:Graphics = this.background.graphics;
        g.beginFill(Constants.BACK_COLOR_1);
        g.drawRoundRect(0, 0, width + 6, HEIGHT, 10, 10);
        g.endFill();
    }
}
}
