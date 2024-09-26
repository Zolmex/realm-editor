package editor.ui {
import editor.ui.elements.SimpleText;

import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.system.System;
import flash.utils.getTimer;

public class DebugView extends Sprite {

    private var background:Shape;
    private var fpsText:SimpleText;
    private var memoryText:SimpleText;

    private var statsCooldown:int;
    private var isHovered:Boolean;

    public function DebugView() {
        this.background = new Shape();
        addChild(this.background);

        this.fpsText = new SimpleText(14, 0xFFFFFF);
        this.fpsText.setText("0 FPS");
        this.fpsText.setBold(true);
        this.fpsText.filters = Constants.OUTLINE_FILTER_1;
        this.fpsText.alpha = 0.4;
        this.fpsText.updateMetrics();
        addChild(this.fpsText);
        this.memoryText = new SimpleText(14, 0xFFFFFF);
        this.memoryText.setText("0 MB");
        this.memoryText.setBold(true);
        this.memoryText.filters = Constants.OUTLINE_FILTER_1;
        this.memoryText.alpha = 0.4;
        this.memoryText.updateMetrics();
        addChild(this.memoryText);

        this.updatePositions();
        this.drawBackground(0.4);
        addEventListener(MouseEvent.MOUSE_OVER, onHover);
    }

    private function onHover(e:MouseEvent):void {
        this.isHovered = true;
        this.fpsText.alpha = 0.7;
        this.memoryText.alpha = 0.7;
        this.fpsText.updateMetrics();
        this.memoryText.updateMetrics();
        this.drawBackground(0.7);

        removeEventListener(MouseEvent.MOUSE_OVER, onHover);
        addEventListener(MouseEvent.MOUSE_OUT, onOut);
    }

    private function onOut(e:MouseEvent):void {
        this.isHovered = false;
        this.fpsText.alpha = 0.4;
        this.memoryText.alpha = 0.4;
        this.fpsText.updateMetrics();
        this.memoryText.updateMetrics();
        this.drawBackground(0.4);

        addEventListener(MouseEvent.MOUSE_OVER, onHover);
        removeEventListener(MouseEvent.MOUSE_OUT, onOut);
    }

    public function show(val:Boolean):void {
        this.visible = val;
        if (!val) {
            this.statsCooldown = 0;
        }
    }

    public function updateStats(time:int, deltaTime:int):void {
        if (this.statsCooldown == 0) {
            var fps:int = int(1000.0 / deltaTime);
            this.fpsText.setText(fps + " FPS");
            var memory:Number = System.privateMemory / 1000000.0;
            this.memoryText.setText(memory.toFixed(0) + " MB");

            this.fpsText.updateMetrics();
            this.memoryText.updateMetrics();
            this.drawBackground(this.isHovered ? 0.7 : 0.4);

            this.statsCooldown = 1000;
        } else {
            this.statsCooldown -= deltaTime;
            if (this.statsCooldown < 0){
                this.statsCooldown = 0;
            }
        }
    }

    private function updatePositions():void {
        this.fpsText.x = 3;
        this.fpsText.y = 3;
        this.memoryText.x = this.fpsText.x;
        this.memoryText.y = this.fpsText.y + this.fpsText.height - 3;
    }

    private function drawBackground(alpha:Number):void {
        var g:Graphics = this.background.graphics;
        g.clear();
        g.beginFill(0x888888, alpha);
        g.drawRect(0, 0, width + 6, height + 4);
        g.endFill();
    }
}
}
