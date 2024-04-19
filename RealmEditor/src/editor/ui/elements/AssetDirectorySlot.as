package editor.ui.elements {
import editor.MEEvent;
import editor.ui.Constants;

import flash.display.Graphics;

import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

import util.MoreColorUtil;

public class AssetDirectorySlot extends Sprite {

    private static const WIDTH:int = 180;
    public static const HEIGHT:int = 25;

    public var assetsId:String;
    public var assetsDir:String;

    private var background:Shape;
    private var idText:SimpleText;
    private var dirText:SimpleText;
    private var selected:Boolean;
    private var cross:Sprite;
    private var removeTooltip:TextTooltip;

    public function AssetDirectorySlot(dirStr:String){
        var halves:Array = dirStr.split("?");
        this.assetsId = halves[0];
        this.assetsDir = halves[1];

        this.background = new Shape();
        addChild(this.background);

        this.idText = new SimpleText(16, 0xFFFFFF, false);
        this.idText.setText(this.assetsId);
        this.idText.setBold(true);
        this.idText.updateMetrics();
        this.idText.x = 3;
        this.idText.filters = Constants.SHADOW_FILTER_1;
        addChild(this.idText);

        this.dirText = new SimpleText(11, 0xFFFFFF, false, WIDTH - this.idText.width - 10);
        var cutStart:int = this.assetsDir.length < 35 ? 0 : this.assetsDir.length - 35;
        this.dirText.setText(this.assetsDir.substr(cutStart));
        this.dirText.updateMetrics();
        this.dirText.setItalic(true);
        this.dirText.x = this.idText.x + this.idText.width;
        this.dirText.y = this.idText.y + (this.idText.height - this.dirText.height) / 2;
        this.dirText.filters = Constants.SHADOW_FILTER_1;
        addChild(this.dirText);

        this.cross = new Sprite();
        this.cross.addEventListener(MouseEvent.CLICK, this.onCrossClick);
        addChild(this.cross);

        var g:Graphics = this.background.graphics;
        g.beginFill(Constants.BACK_COLOR_1);
        g.drawRect(0, 0, WIDTH, HEIGHT);
        g.endFill();

        var crossSize:int = HEIGHT - 20;
        g = this.cross.graphics;
        g.lineStyle(3, 0xFFFFFF);
        g.lineTo(crossSize, crossSize);
        g.moveTo(crossSize, 0);
        g.lineTo(0, crossSize);
        g.lineStyle();

        this.cross.x = WIDTH - crossSize - 5;
        this.cross.y = (HEIGHT - crossSize) / 2;
        this.cross.addEventListener(MouseEvent.ROLL_OVER, this.onRollOver);
    }

    private function onRollOver(e:Event):void {
        this.cross.removeEventListener(MouseEvent.ROLL_OVER, this.onRollOver);

        this.removeTooltip = new TextTooltip(this.cross, "Remove", 18, 0xFFFFFF, true);
        this.removeTooltip.addSubText("Remove this directory from the list");
        Main.STAGE.addChild(this.removeTooltip);
    }

    private function onCrossClick(e:Event):void {
        e.stopImmediatePropagation(); // Don't let the slot click trigger

        this.dispatchEvent(new Event(MEEvent.ASSETS_DIR_REMOVED));
    }

    public function setSelected(val:Boolean):void {
        this.selected = val;
        this.transform.colorTransform = val ? MoreColorUtil.identity : MoreColorUtil.darkCT;
    }
}
}
