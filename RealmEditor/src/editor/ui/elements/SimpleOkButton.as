package editor.ui.elements {
import editor.ui.Constants;

import flash.display.Graphics;

import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

import util.MoreColorUtil;

public class SimpleOkButton extends Sprite {

    private var okText:SimpleText;

    public function SimpleOkButton() {
        this.okText = new SimpleText(20, 0xFFFFFF);
        this.okText.setText("Ok");
        this.okText.setBold(true);
        this.okText.updateMetrics();
        this.okText.x = 3;
        this.okText.y = 3;
        this.okText.filters = Constants.SHADOW_FILTER_1;
        addChild(this.okText);

        this.addEventListener(MouseEvent.ROLL_OVER, this.onRollOver);
        this.addEventListener(MouseEvent.ROLL_OUT, this.onRollOut);
    }

    private function onRollOver(e:Event):void {
        this.transform.colorTransform = MoreColorUtil.darkCT;
    }

    private function onRollOut(e:Event):void {
        this.transform.colorTransform = MoreColorUtil.identity;
    }
}
}
