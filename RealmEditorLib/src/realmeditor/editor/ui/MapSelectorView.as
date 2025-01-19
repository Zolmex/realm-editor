package realmeditor.editor.ui {
import editor.MEEvent;

import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.utils.Dictionary;

import realmeditor.editor.MEEvent;

public class MapSelectorView extends Sprite {

    public static const WIDTH:int = 150;
    private static const HEIGHT:int = 150;

    private var background:Shape;
    private var mapSlotsContainer:Sprite;
    private var mapSlots:Dictionary;

    public var selectedMap:int;

    public function MapSelectorView() {
        this.mapSlots = new Dictionary();

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

    public function addMap(mapId:int, name:String):void {
        var slot:MapSelectorSlot = new MapSelectorSlot(mapId, name);
        slot.addEventListener(MouseEvent.CLICK, this.onSlotClick);
        this.mapSlotsContainer.addChild(slot);

        this.mapSlots[mapId] = slot;

        this.positionSlots();
    }

    public function removeMap(slot:MapSelectorSlot):void {
        slot.removeEventListener(MouseEvent.CLICK, this.onSlotClick);
        this.mapSlotsContainer.removeChild(slot);

        delete this.mapSlots[slot.mapId];

        this.positionSlots();

        this.dispatchEvent(new MapClosedEvent(MEEvent.MAP_CLOSED, slot.mapId));
    }

    private function positionSlots():void {
        var i:int = 0;
        for each (var mapSlot:MapSelectorSlot in this.mapSlots){
            mapSlot.y = i * MapSelectorSlot.HEIGHT + i * 2; // 2 pixels separation between each slot
            i++;
        }
    }

    private function onSlotClick(e:Event):void {
        for each (var mapSlot:MapSelectorSlot in this.mapSlots){
            mapSlot.setSelected(false);
        }

        var slot:MapSelectorSlot = e.target as MapSelectorSlot;
        slot.setSelected(true);

        this.selectedMap = slot.mapId;

        this.dispatchEvent(new Event(MEEvent.MAP_SELECT));
    }

    public function selectMap(mapId:int):void {
        if (this.mapSlots[mapId] == null){
            return;
        }

        for each (var mapSlot:MapSelectorSlot in this.mapSlots){
            mapSlot.setSelected(false);
        }

        this.mapSlots[mapId].setSelected(true);
        this.selectedMap = mapId;
    }

    public function selectNextMap(closedMapId:int):int {
        var minDiff:int = -1;
        var current:int = 0;
        for each (var mapSlot:MapSelectorSlot in this.mapSlots){
            var diff:int = Math.abs(closedMapId - mapSlot.mapId);
            if (minDiff == -1 || diff < minDiff) {
                minDiff = diff;
                current = mapSlot.mapId;
            }
            mapSlot.setSelected(false);
        }

        if (minDiff == -1){
            return 0;
        }

        this.mapSlots[current].setSelected(true);
        this.selectedMap = current;
        return current;
    }
}
}

import editor.MEEvent;
import editor.ui.Constants;
import editor.ui.MainView;
import editor.ui.MapSelectorView;
import editor.ui.MapView;
import editor.ui.elements.TextTooltip;
import editor.ui.elements.SimpleText;

import flash.display.Graphics;

import flash.display.Shape;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextFieldAutoSize;

import realmeditor.editor.MEEvent;
import realmeditor.editor.ui.Constants;

import realmeditor.editor.ui.MainView;

import realmeditor.editor.ui.MapSelectorView;
import realmeditor.editor.ui.MapView;
import realmeditor.editor.ui.elements.SimpleText;
import realmeditor.editor.ui.elements.TextTooltip;
import realmeditor.util.MoreColorUtil;

import util.MoreColorUtil;

class MapSelectorSlot extends Sprite {

    private static const WIDTH:int = MapSelectorView.WIDTH;
    public static const HEIGHT:int = 25;

    public var mapId:int;
    private var mapName:String;

    private var background:Shape;
    private var text:SimpleText;
    private var selected:Boolean;
    private var cross:Sprite;
    private var closeTooltip:TextTooltip;

    public function MapSelectorSlot(mapId:int, name:String){
        this.mapId = mapId;
        this.mapName = name;

        var mapView:MapView = MainView.Instance.mapViewContainer.maps[mapId] as MapView;
        mapView.tileMap.addEventListener(MEEvent.MAP_CHANGED, this.onMapChanged);
        mapView.mapData.addEventListener(MEEvent.MAP_SAVED, this.onMapSaved);

        this.background = new Shape();
        addChild(this.background);

        this.text = new SimpleText(16, 0xFFFFFF, false, WIDTH - 10);
        this.text.setAutoSize(TextFieldAutoSize.LEFT);
        this.text.setText(mapId.toString() + (!mapView.mapData.savedChanges ? "* " : "") + ". " + name);
        this.text.updateMetrics();
        this.text.x = 3;
        this.text.y = (HEIGHT - this.text.actualHeight_) / 2;
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

        this.cross.addEventListener(MouseEvent.ROLL_OVER, this.onRollOver);
    }

    private function onMapChanged(e:Event):void {
        this.text.setText(this.mapId.toString() + ". * " + this.mapName);
        this.text.updateMetrics();
        this.text.y = (HEIGHT - this.text.actualHeight_) / 2;
    }

    private function onMapSaved(e:Event):void {
        this.text.setText(this.mapId.toString() + ". " + this.mapName);
        this.text.updateMetrics();
    }

    private function onCrossClick(e:Event):void {
        e.stopImmediatePropagation(); // Don't let the slot click trigger

        (parent.parent as MapSelectorView).removeMap(this);
    }

    private function onRollOver(e:Event):void {
        if (this.closeTooltip == null) {
            this.closeTooltip = new TextTooltip(this.cross, "Close", 18, 0xFFFFFF, true);
            this.closeTooltip.addSubText("Save map before closing!");
            MainView.Main.stage.addChild(this.closeTooltip);
        }
    }

    public function setSelected(val:Boolean):void {
        this.selected = val;
        this.transform.colorTransform = val ? MoreColorUtil.identity : MoreColorUtil.darkCT;
    }
}
