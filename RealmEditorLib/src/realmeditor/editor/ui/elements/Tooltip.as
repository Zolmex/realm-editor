package realmeditor.editor.ui.elements {
import editor.ui.*;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.events.MouseEvent;

import realmeditor.editor.ui.Constants;

import realmeditor.editor.ui.MainView;

public class Tooltip extends Sprite {

    private var target:DisplayObject;
    private var background:Shape;

    // Tooltips should always be instantiated on roll over
    public function Tooltip(target:DisplayObject) {
        this.background = new Shape();
        addChild(this.background);

        this.target = target;
        target.addEventListener(MouseEvent.ROLL_OUT, this.onTargetOut);
        target.addEventListener(MouseEvent.ROLL_OVER, this.onTargetOver);
        target.addEventListener(Event.ENTER_FRAME, this.onEnterFrame);

        this.addChildren();
        this.positionChildren();
        this.drawBackground();
        this.fixPosition();
    }

    private function onTargetOver(e:Event):void {
        this.target.addEventListener(MouseEvent.ROLL_OUT, this.onTargetOut);
        this.target.addEventListener(Event.ENTER_FRAME, this.onEnterFrame);
        this.fixPosition();
        this.visible = true;
    }

    private function onTargetOut(e:Event):void {
        this.target.removeEventListener(MouseEvent.ROLL_OUT, this.onTargetOut);
        this.target.removeEventListener(Event.ENTER_FRAME, this.onEnterFrame);
        this.visible = false;
    }

    private function onEnterFrame(e:Event):void {
        this.fixPosition();
    }

    protected virtual function addChildren():void {
    }

    protected virtual function positionChildren():void {
    }

    protected virtual function drawBackground():void {
        var g:Graphics = this.background.graphics;
        g.clear();
        g.beginFill(Constants.BACK_COLOR_2, 0.8);
        g.drawRoundRect(0, 0, width + 10, height + 10, 15, 15);
        g.endFill();
    }

    protected function updateChildren():void {
        this.addChildren();
        this.positionChildren();
        this.drawBackground();
    }

    public function fixPosition():void {
        this.x = this.getXPos();
        this.y = this.getYPos();
    }

    private function getXPos():Number {
        var mouseX:Number = MainView.Main.stage.mouseX;
        if (mouseX < MainView.StageWidth / 2) { // Center orientation: right
            if (mouseX < 0) { // Left limit
                return 0;
            }
            if (mouseX + width > MainView.StageWidth) { // When tooltip touches screen right
                return MainView.StageWidth - width;
            }
            return mouseX;
        }

        if (mouseX >= MainView.StageWidth / 2) { // Center orientation: left
            if (mouseX > MainView.StageWidth) { // Right limit
                return MainView.StageWidth - width;
            }
            if (mouseX - width < 0) { // When tooltip touches screen left
                return 0;
            }
            return mouseX - width;
        }
        return mouseX;
    }

    private function getYPos():Number {
        var mouseY:Number = MainView.Main.stage.mouseY;
        if (mouseY < MainView.StageHeight / 2) { // Center orientation: up
            if (mouseY < 0) { // Top limit
                return 0;
            }
            if (mouseY + height > MainView.StageHeight) { // When tooltip touches screen bottom
                return MainView.StageHeight - height;
            }
            return mouseY;
        }

        if (mouseY >= MainView.StageHeight / 2) { // Center orientation: left
            if (mouseY > MainView.StageHeight) { // Right limit
                return MainView.StageHeight - height;
            }
            if (mouseY - height < 0) { // When tooltip touches screen top
                return 0;
            }
            return mouseY - height;
        }
        return mouseY;
    }
}
}
