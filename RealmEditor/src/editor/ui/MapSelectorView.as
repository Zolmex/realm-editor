package editor.ui {
import editor.MEEvent;

import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.utils.Dictionary;

public class MapSelectorView extends Sprite {

    public static const WIDTH:int = 150;
    private static const HEIGHT:int = 150;

    private var background:Shape;
    private var mapSlotsContainer:Sprite;
    private var mapSlots:Vector.<MapSelectorSlot>;

    public var selectedMap:int;

    public function MapSelectorView() {
        this.mapSlots = new Vector.<MapSelectorSlot>();

        this.background = new Shape();
        var g:Graphics = this.background.graphics;
        g.beginFill(Constants.BACK_COLOR_2, 0.8);
        g.drawRoundRect(0, 0, WIDTH, HEIGHT, 10, 10);
        g.endFill();
        addChild(this.background);

        var slotsMask:Shape = new Shape();
        g = slotsMask.graphics;
        g.beginFill(0);
        g.drawRoundRect(0, 0, WIDTH, HEIGHT, 10, 10);
        g.endFill();
        addChild(slotsMask);

        this.mapSlotsContainer = new Sprite();
        this.mapSlotsContainer.mask = slotsMask;
        addChild(this.mapSlotsContainer);

        this.addEventListener(MouseEvent.MOUSE_WHEEL, this.onScroll);

        filters = Constants.SHADOW_FILTER_1;
    }

    private function onScroll(e:MouseEvent):void {
        e.stopImmediatePropagation(); // Make sure we don't zoom in/out the map

        var scroll:Number = e.delta * 10;
        this.mapSlotsContainer.y += scroll;
        if (this.mapSlotsContainer.y > 0) { // Top limit
            this.mapSlotsContainer.y = 0;
        }
        if (this.mapSlotsContainer.height < HEIGHT) { // If the elements container is smaller than the view, don't scroll
            this.mapSlotsContainer.y = 0;
        } else if (this.mapSlotsContainer.y < -this.mapSlotsContainer.height + HEIGHT) { // Bottom limit
            this.mapSlotsContainer.y = -this.mapSlotsContainer.height + HEIGHT;
        }
    }

    public function addMap(id:int, name:String):void {
        var slot:MapSelectorSlot = new MapSelectorSlot(id, name);
        slot.addEventListener(MouseEvent.CLICK, this.onSlotClick);
        this.mapSlotsContainer.addChild(slot);

        this.mapSlots.push(slot);

        this.positionSlots();
    }

    public function removeMap(slot:MapSelectorSlot):void {
        slot.removeEventListener(MouseEvent.CLICK, this.onSlotClick);
        this.mapSlotsContainer.removeChild(slot);

        this.mapSlots.splice(slot.id, 1);
        this.updateIds();

        this.positionSlots();

        this.dispatchEvent(new MapClosedEvent(MEEvent.MAP_CLOSED, slot.id));
    }

    private function updateIds():void {
        for (var i:int = 0; i < this.mapSlots.length; i++){
            this.mapSlots[i].setId(i);
        }
    }

    private function positionSlots():void {
        for (var i:int = 0; i < this.mapSlots.length; i++){
            this.mapSlots[i].y = i * MapSelectorSlot.HEIGHT + i * 2; // 2 pixels separation between each slot
        }
    }

    private function onSlotClick(e:Event):void {
        for (var i:int = 0; i < this.mapSlots.length; i++){
            this.mapSlots[i].setSelected(false);
        }

        var slot:MapSelectorSlot = e.target as MapSelectorSlot;
        slot.setSelected(true);

        this.selectedMap = this.mapSlots.indexOf(slot);

        this.dispatchEvent(new Event(MEEvent.MAP_SELECT));
    }

    public function selectMap(id:int):void {
        if (id < 0 || id >= this.mapSlots.length){
            return;
        }

        for (var i:int = 0; i < this.mapSlots.length; i++){
            this.mapSlots[i].setSelected(false);
        }

        this.mapSlots[id].setSelected(true);
        this.selectedMap = id;
    }
}
}

import editor.ui.Constants;
import editor.ui.MapSelectorView;
import editor.ui.elements.TextTooltip;
import editor.ui.elements.SimpleText;

import flash.display.Graphics;

import flash.display.Shape;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

import util.MoreColorUtil;

class MapSelectorSlot extends Sprite {

    private static const WIDTH:int = MapSelectorView.WIDTH;
    public static const HEIGHT:int = 25;

    public var id:int;
    private var mapName:String;

    private var background:Shape;
    private var text:SimpleText;
    private var selected:Boolean;
    private var cross:Sprite;
    private var closeTooltip:TextTooltip;

    public function MapSelectorSlot(id:int, name:String){
        this.id = id;
        this.mapName = name;

        this.background = new Shape();
        addChild(this.background);

        this.text = new SimpleText(16, 0xFFFFFF, false, WIDTH);
        this.text.setText(id.toString() + ". " + name);
        this.text.updateMetrics();
        this.text.x = 3;
        this.text.filters = Constants.SHADOW_FILTER_1;
        addChild(this.text);

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

        this.closeTooltip = new TextTooltip(this.cross, "Close", 18, 0xFFFFFF, true);
        this.closeTooltip.addSubText("Save map before closing!");
        Main.STAGE.addChild(this.closeTooltip);

        this.addEventListener(MouseEvent.ROLL_OVER, this.onRollOver);
        this.addEventListener(MouseEvent.ROLL_OUT, this.onRollOut);
    }

    private function onCrossClick(e:Event):void {
        e.stopImmediatePropagation(); // Don't let the slot click trigger

        (parent.parent as MapSelectorView).removeMap(this);
    }

    private function onRollOver(e:Event):void {
        if (!this.selected) {
            this.transform.colorTransform.redMultiplier += 0.1;
            this.transform.colorTransform.greenMultiplier += 0.1;
            this.transform.colorTransform.blueMultiplier += 0.1;
        }
    }

    private function onRollOut(e:Event):void {
        if (!this.selected) {
            this.transform.colorTransform.redMultiplier -= 0.1;
            this.transform.colorTransform.greenMultiplier -= 0.1;
            this.transform.colorTransform.blueMultiplier -= 0.1;
        }
    }

    public function setSelected(val:Boolean):void {
        this.selected = val;
        this.transform.colorTransform = val ? MoreColorUtil.identity : MoreColorUtil.darkCT;
    }

    public function setId(id:int):void {
        this.id = id;
        this.text.setText(id + ". " + this.mapName);
        this.text.updateMetrics();
    }
}
