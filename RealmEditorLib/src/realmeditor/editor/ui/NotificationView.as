package realmeditor.editor.ui {
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

import realmeditor.editor.ui.elements.SimpleText;

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
        this.text.text = text;
        this.text.multiline = true;
        this.text.wordWrap = true;
        this.text.updateMetrics();

        var g:Graphics = this.background.graphics;
        g.clear();
        g.beginFill(Constants.BACK_COLOR_1, 0.8);
        g.drawRoundRect(-2, 0, this.text.actualWidth_ + 6, this.text.actualHeight_ + 4, 5, 5);
        g.endFill();

        this.updatePosition();

        this.startAnimation(duration);
    }

    public function updatePosition():void {
        this.x = (MainView.StageWidth - this.background.width) / 2;
        this.y = 60;
    }

    private function startAnimation(duration:Number):void {
        if (this.tween != null){
            this.tween.end();
        }

        alpha = 1;
        visible = true;
        if (duration == -1){ // Infinite, must manually clear notification
            return;
        }

        this.tween = new GTween(this, duration, {"alpha": 0});
        this.tween.onComplete = this.endAnimation;
    }

    private function endAnimation(tween:GTween):void {
        alpha = 1;
        visible = false;
    }

    public function clear():void {
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
