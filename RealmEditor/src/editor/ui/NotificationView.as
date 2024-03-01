package editor.ui {
import com.gskinner.motion.GTween;
import com.gskinner.motion.GTween;

import editor.ui.elements.SimpleText;

import flash.display.Graphics;

import flash.display.Shape;

import flash.display.Sprite;
import flash.filters.DropShadowFilter;
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
    }

    public function showNotification(text:String):void {
        this.text.text = text;
        this.text.multiline = true;
        this.text.wordWrap = true;
        this.text.updateMetrics();

        var totalWidth:int = this.text.textWidth + 10;
        var g:Graphics = this.background.graphics;
        g.clear();
        g.beginFill(Constants.BACK_COLOR_1, 0.8);
        g.drawRoundRect(-2, 0, this.text.textWidth + 6, this.text.textHeight + 4, 5, 5);
        g.endFill();

        this.x = (Main.StageWidth - totalWidth) / 2;
        this.y = 20;

        this.startAnimation();
    }

    private function startAnimation():void {
        if (this.tween != null){
            this.tween.end();
        }

        alpha = 1;
        visible = true;
        this.tween = new GTween(this, 2, {"alpha": 0});
        this.tween.onComplete = this.endAnimation;
    }

    private function endAnimation(tween:GTween):void {
        alpha = 1;
        visible = false;
    }
}
}
