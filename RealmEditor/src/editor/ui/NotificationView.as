package editor.ui {
import com.gskinner.motion.GTween;
import com.gskinner.motion.easing.*;

import editor.ui.elements.SimpleText;

import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormatAlign;

public class NotificationView extends Sprite {

    private var background:Shape;
    private var text:SimpleText;
    private var tween:GTween;
    private var pulse:GTween;

    public function NotificationView() {
        this.background = new Shape();
        addChild(this.background);

        this.text = new SimpleText(18, 0xFFFFFF, false);
        this.text.filters = Constants.SHADOW_FILTER_1;
        addChild(this.text);

        visible = false;

        addEventListener(Event.ENTER_FRAME, onEnterFrame);
        addEventListener(MouseEvent.ROLL_OVER, this.onRollOver);
    }

    private function onEnterFrame(e:Event):void {
        Main.View.updateNotifPosition();
    }

    public function showNotification(text:String, size:int = 18, duration:Number = 1):void {
        this.text.setSize(size);
        this.text.setAlignment(TextFormatAlign.CENTER);
        this.text.multiline = true;
        this.text.htmlText = text;
        this.text.updateMetrics();
        this.startAnimation(duration);
    }

    private function startAnimation(duration:Number, pulse:Boolean = true):void {
        if (this.tween != null) {
            this.tween.end();
        }

        alpha = 1;
        visible = true;

        this.tween = new GTween(this, duration, { alpha: 0 }, { delay: 1, onComplete: dispose });
        if (pulse)
            this.pulse = new GTween(this, 1, { scaleX: 0.98, scaleY: 0.98 }, { onComplete: scaleUp });
    }

    private function endAnimation(t:GTween):void {
        alpha = 1;
        visible = false;
    }

    private function onRollOver(e:Event):void{
        addEventListener(MouseEvent.ROLL_OUT, this.onRollOut);
        alpha = 1;
        if (!this.tween || !this.pulse)
            return;

        this.tween.paused = true;
        this.pulse.paused = true;
    }

    private function onRollOut(e:Event):void {
        removeEventListener(MouseEvent.ROLL_OUT, this.onRollOut);
        if (!this.tween || !this.pulse)
            return;

        this.tween.paused = false;
        this.pulse.paused = false;
    }

    private function scaleUp(t:GTween):void {
        if (this.tween == null) return;
        pulse = new GTween(this, 1, { scaleX: 1, scaleY: 1 }, { onComplete: scaleDown });
    }

    private function scaleDown(t:GTween):void {
        if (this.tween == null) return;
        pulse = new GTween(this, 1, { scaleX: 0.98, scaleY: 0.98 }, { onComplete: scaleUp });
    }

    private function dispose(t:GTween):void {
        this.tween = null;
        this.pulse = null;
    }
}
}
