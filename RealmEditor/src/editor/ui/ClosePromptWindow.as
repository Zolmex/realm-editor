package editor.ui {
import editor.MEEvent;
import editor.ui.elements.SimpleText;
import editor.ui.elements.SimpleTextButton;

import flash.display.Graphics;

import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

public class ClosePromptWindow extends Sprite {

    private var background:Shape;
    private var title:SimpleText;
    private var goBackButton:SimpleTextButton;
    private var closeButton:SimpleTextButton;

    public function ClosePromptWindow() {
        this.background = new Shape();
        addChild(this.background);

        this.title = new SimpleText(20, 0xFFFFFF);
        this.title.setText("You have unsaved changes");
        this.title.setBold(true);
        this.title.updateMetrics();
        this.title.filters = Constants.SHADOW_FILTER_1;
        addChild(this.title);

        this.goBackButton = new SimpleTextButton("Go back");
        this.goBackButton.addEventListener(MouseEvent.CLICK, this.onSaveClick);
        addChild(this.goBackButton);

        this.closeButton = new SimpleTextButton("Close without saving");
        this.closeButton.addEventListener(MouseEvent.CLICK, this.onExitClick);
        addChild(this.closeButton);

        this.addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);

        filters = Constants.SHADOW_FILTER_1;
    }

    private function onAddedToStage(e:Event):void {
        this.updatePositions();
        this.drawBackground();
    }

    protected virtual function drawBackground():void{
        var g:Graphics = this.background.graphics;
        g.clear();
        g.beginFill(Constants.BACK_COLOR_2);
        g.drawRoundRect(0, 0, width + 15, height + 5, 10, 10);
        g.endFill();
    }

    protected virtual function updatePositions():void {
        this.title.x = 5;
        this.goBackButton.x = 5;
        this.goBackButton.y = this.title.y + this.title.height + 5;
        this.closeButton.x = this.goBackButton.x + this.goBackButton.width + 10;
        this.closeButton.y = this.goBackButton.y;
    }

    private function onSaveClick(e:Event):void {
        // Can't actually save the maps automatically (fuck as3) so just let user save the maps manually
        this.visible = false;
    }

    private function onExitClick(e:Event):void {
        this.dispatchEvent(new Event(MEEvent.CLOSE_NO_SAVE));
    }
}
}
