package realmeditor.editor.ui.elements {
import editor.ui.*;

import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.text.TextField;

import realmeditor.editor.ui.Constants;
import realmeditor.util.FilterUtil;

import util.FilterUtil;

public class SimpleTextButton extends Sprite {

    private var shape:Shape;
    private var textField:SimpleText;
    private var background:Boolean;

    public function SimpleTextButton(textStr:String, size:int = 18, color:uint = 0xFFFFFF, background:Boolean = true) {
        this.shape = new Shape();
        addChild(this.shape);

        this.textField = new SimpleText(size, color);
        this.textField.htmlText = textStr;
        this.textField.filters = Constants.SHADOW_FILTER_1;
        this.textField.updateMetrics();
        addChild(this.textField);

        this.background = background;
        if (background) {
            var shapeW:int = this.width + 10;
            var shapeH:int = this.height + 5;
            var gShape:Graphics = this.shape.graphics;
            gShape.beginFill(Constants.BACK_COLOR_1, 0.8);
            gShape.drawRoundRect(0, 0, shapeW, shapeH, 5, 5);
            gShape.endFill();
            this.textField.x = (this.width - this.textField.width) / 2;
            this.textField.y = (this.height - this.textField.height) / 2;
        }

        filters = Constants.SHADOW_FILTER_1;

        this.addEventListener(MouseEvent.ROLL_OVER, this.onMouseRollOver);
        this.addEventListener(MouseEvent.ROLL_OUT, this.onMouseRollOut);
    }

    public function setText(htmlText:String):void {
        this.textField.htmlText = htmlText;
        this.textField.updateMetrics();
    }

    private function onMouseRollOver(e:Event):void {
        this.shape.filters = FilterUtil.GREY_COLOR_FILTER_1;
    }

    private function onMouseRollOut(e:Event):void {
        this.shape.filters = null;
    }
}
}
