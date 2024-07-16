package editor.ui.elements {
import editor.ui.Constants;

import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.filters.DropShadowFilter;

public class SimpleTextInput extends Sprite {

    private var background:Shape;
    private var titleText:SimpleText;
    public var inputText:SimpleText;

    public function SimpleTextInput(title:String, inline:Boolean = false, inputText:String = "", titleSize:int = 18, titleColor:uint = 0xFFFFFF, inputSize:int = 15, inputColor:uint = 0xEAEAEA, stopKeyPropagation:Boolean = false) {
        this.background = new Shape();
        addChild(this.background);

        this.titleText = new SimpleText(titleSize, titleColor);
        this.titleText.x = 2;
        this.titleText.y = 2;
        this.titleText.text = title;
        this.titleText.filters = Constants.SHADOW_FILTER_1;
        this.titleText.updateMetrics();
        addChild(this.titleText);

        this.inputText = new SimpleText(inputSize, inputColor, true, this.titleText.textWidth, this.titleText.textHeight, false, stopKeyPropagation);
        this.inputText.text = inputText;
        if (inline){
            this.inputText.x = this.titleText.x + this.titleText.width;
            this.inputText.y = this.titleText.y + (this.titleText.height - this.inputText.height) / 2;
        }
        else {
            this.inputText.x = this.titleText.x;
            this.inputText.y = this.titleText.y + this.titleText.height;
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
        var bgWidth:int = width + 5;
        var bgHeight:int = height;
        var bg:Graphics = this.background.graphics;
        bg.clear();
        bg.beginFill(Constants.BACK_COLOR_1, 0.9);
        bg.drawRoundRect(0, 0, bgWidth, bgHeight, 5, 5);
        bg.endFill();
    }
}
}
