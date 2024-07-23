package editor.ui {
import editor.ui.elements.SimpleText;

import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.system.System;
import flash.utils.getTimer;

public class DebugView extends Sprite {

    private var background:Shape;
    private var fpsText:SimpleText;
    private var memoryText:SimpleText;

    private var statsCooldown:int;

    public function DebugView() {
        this.background = new Shape();
        addChild(this.background);

        this.fpsText = new SimpleText(16, 0xFFFFFF);
        this.fpsText.setText("FPS: 0");
        this.fpsText.updateMetrics();
        addChild(this.fpsText);
        this.memoryText = new SimpleText(16, 0xFFFFFF);
        this.memoryText.setText("Memory: 0 MB");
        this.memoryText.updateMetrics();
        addChild(this.memoryText);

        this.updatePositions();
        this.drawBackground();
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
            this.fpsText.setText("FPS: " + fps);
            var memory:Number = System.privateMemory / 1000000.0;
            this.memoryText.setText("Memory: " + memory.toFixed(2) + " MB");

            this.fpsText.updateMetrics();
            this.memoryText.updateMetrics();
            this.drawBackground();

            this.statsCooldown = 1000;
        } else {
            this.statsCooldown -= deltaTime;
            if (this.statsCooldown < 0){
                this.statsCooldown = 0;
            }
        }
    }

    private function updatePositions():void {
        this.fpsText.x = 0;
        this.fpsText.y = 0;
        this.memoryText.x = this.fpsText.x;
        this.memoryText.y = this.fpsText.y + this.fpsText.height + 5;
    }

    private function drawBackground():void {
        var g:Graphics = this.background.graphics;
        g.clear();
        g.beginFill(0x888888, 0.6);
        g.drawRect(0, 0, width + 3, height + 3);
        g.endFill();
    }
}
}
