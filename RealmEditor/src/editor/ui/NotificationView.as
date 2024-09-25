package editor.ui {
import com.gskinner.motion.GTween;
import com.gskinner.motion.GTween;

import editor.ui.elements.SimpleText;

import flash.display.Graphics;

import flash.display.Shape;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormatAlign;

public class NotificationView extends Sprite {

    private var background:Shape;
    private var text:SimpleText;
    private var tween:GTween;

    public function NotificationView() {
        this.background = new Shape();
        addChild(this.background);

        this.text = new SimpleText(18, 0xFFFFFF, false, 400);
        this.text.filters = Constants.SHADOW_FILTER_1;
        addChild(this.text);

        visible = false;
        filters = Constants.SHADOW_FILTER_1;

        addEventListener(MouseEvent.ROLL_OVER, this.onRollOver);
    }

    public function showNotification(text:String, size:int = 18, duration:Number = 2):void {
        this.text.setSize(size);
        this.text.setBold(true);
        this.text.text = text;
        this.text.multiline = true;
        this.text.wordWrap = true;
        this.text.updateMetrics();
        Main.View.updateNotifPosition();
        this.startAnimation(duration);
    }

    private function startAnimation(duration:Number):void {
        if (this.tween != null){
            this.tween.end();
        }

        alpha = 1;
        visible = true;
        this.tween = new GTween(this, duration, {"alpha": 0});
        this.tween.onComplete = this.endAnimation;
    }

    private function endAnimation(tween:GTween):void {
        alpha = 1;
        visible = false;
    }

    private function onRollOver(e:Event):void{
        addEventListener(MouseEvent.ROLL_OUT, this.onRollOut);
        this.tween.paused = true;
    }

    private function onRollOut(e:Event):void {
        removeEventListener(MouseEvent.ROLL_OUT, this.onRollOut);
        this.tween.paused = false;
    }
}
}
