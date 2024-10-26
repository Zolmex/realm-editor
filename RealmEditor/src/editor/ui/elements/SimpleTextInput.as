package editor.ui.elements {
import editor.ui.Constants;

import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.filters.DropShadowFilter;
import flash.text.TextFieldAutoSize;

public class SimpleTextInput extends Sprite {

    private var background:Shape;
    private var titleText:SimpleText;
    public var inputText:SimpleText;

    private var fixedWidth:int;
    private var fixedHeight:int;
    private var inline:Boolean;

    public function SimpleTextInput(title:String, inline:Boolean = false, inputText:String = "", titleSize:int = 18, titleColor:uint = 0xFFFFFF, inputSize:int = 15, inputColor:uint = 0xEAEAEA, stopKeyPropagation:Boolean = false, w:int = -1, h:int = -1) {
        this.background = new Shape();
        addChild(this.background);

        this.fixedWidth = w;
        this.fixedHeight = h;
        this.inline = inline;

        this.titleText = new SimpleText(titleSize, titleColor, false);
        this.titleText.x = 2;
        this.titleText.y = 2;
        this.titleText.text = title;
        this.titleText.filters = Constants.SHADOW_FILTER_1;
        this.titleText.updateMetrics();
        addChild(this.titleText);

        this.inputText = new SimpleText(inputSize, inputColor, true, 0,0, false, stopKeyPropagation);
        this.inputText.autoSize = TextFieldAutoSize.LEFT;
        this.inputText.text = inputText;
        if (inline){
            this.inputText.x = this.titleText.x + this.titleText.width;
            this.inputText.y = this.titleText.y + (this.titleText.height - this.inputText.height) / 2;
        }
        else {
            this.inputText.x = this.titleText.x;
            this.inputText.y = this.titleText.y + this.titleText.height - 1;
        }
        this.inputText.border = false;
        this.inputText.updateMetrics();
        addChild(this.inputText);

        this.drawBackground();
    }

    public function setWidth(newWidth:int):void {
        this.inputText.inputWidth_ = newWidth;
        this.inputText.updateMetrics();

        this.drawBackground();
    }

    private function drawBackground():void {
        var bgWidth:int = this.fixedWidth != -1 ? this.fixedWidth : width + 5;
        var bgHeight:int = this.fixedHeight != -1 ? this.fixedHeight : height + 3;
        bgHeight = this.inline ? bgHeight + 3 : bgHeight;

        var bg:Graphics = this.background.graphics;
        bg.clear();
        bg.beginFill(Constants.BACK_COLOR_1, 0.9);
        bg.drawRoundRect(0, 0, bgWidth, bgHeight, 5, 5);
        bg.endFill();
    }
}
}
