package editor.ui {
import assets.AssetLibrary;

import editor.MEEvent;

import flash.display.Bitmap;

import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.GradientBevelFilter;
import flash.sampler.StackFrame;
import flash.ui.Mouse;
import flash.utils.Dictionary;

public class MapSelectorView extends Sprite {

    private static const HEIGHT:int = 25;

    private var background:Shape;
    private var close:Sprite;
    private var options:Sprite;
    private var slotsMask:Shape;
    private var mapSlotsContainer:Sprite;
    public var mapSlots:Dictionary;

    public var selectedMap:int;

    public function MapSelectorView() {
        this.mapSlots = new Dictionary();

        this.background = new Shape();
        var g:Graphics = this.background.graphics;
        g.beginFill(Constants.BACK_COLOR_2, 0.8);
        g.drawRect(0, 0, Main.STAGE.stageWidth, HEIGHT);
        g.endFill();
        addChild(this.background);

        this.slotsMask = new Shape();
        g = this.slotsMask.graphics;
        g.beginFill(0);
        g.drawRoundRect(0, 0, Main.STAGE.stageWidth, HEIGHT, 10, 10);
        g.endFill();
        addChild(this.slotsMask);

        var crossSize:int = HEIGHT - 14;
        this.close = new Sprite();
        this.close.y = 7;
        g = this.close.graphics;
        g.clear();
        g.lineStyle(3, 0xffffff);
        g.lineTo(crossSize, crossSize);
        g.moveTo(crossSize, 0);
        g.lineTo(0, crossSize);
        g.lineStyle();

        this.close.addEventListener(MouseEvent.CLICK, beginClose);
        this.close.addEventListener(MouseEvent.MOUSE_OVER, onCloseOver);
        addChild(this.close);

        this.options = new Sprite();
        var b:Bitmap = new Bitmap(AssetLibrary.getImageFromSet("lofiInterfaceBig", 5));
        this.options.addChild(b);
        this.options.addEventListener(MouseEvent.CLICK, onOptionsClick);
        this.options.y = 4;
        addChild(this.options);

        this.mapSlotsContainer = new Sprite();
        this.mapSlotsContainer.mask = slotsMask;
        addChild(this.mapSlotsContainer);

        this.addEventListener(MouseEvent.MOUSE_WHEEL, this.onScroll);

        filters = Constants.SHADOW_FILTER_1;
        this.updatePosition();
    }

    private function onOptionsClick(event:MouseEvent):void {
        Main.View.toggleOptions();
    }

    private function beginClose(event:MouseEvent):void {
        Main.View.onExiting();
    }

    private function onCloseOver(event:MouseEvent):void {
        var crossSize:int = HEIGHT - 14;
        var g:Graphics = this.close.graphics;
        g.clear();
        g.lineStyle(3, 0xffe591);
        g.lineTo(crossSize, crossSize);
        g.moveTo(crossSize, 0);
        g.lineTo(0, crossSize);
        g.lineStyle();

        this.close.removeEventListener(MouseEvent.MOUSE_OVER, onCloseOver);
        this.close.addEventListener(MouseEvent.MOUSE_OUT, onCloseOut);
    }

    private function onCloseOut(event:MouseEvent):void {
        var crossSize:int = HEIGHT - 14;
        var g:Graphics = this.close.graphics;
        g.clear();
        g.lineStyle(3, 0xffffff);
        g.lineTo(crossSize, crossSize);
        g.moveTo(crossSize, 0);
        g.lineTo(0, crossSize);
        g.lineStyle();

        this.close.addEventListener(MouseEvent.MOUSE_OVER, onCloseOver);
        this.close.removeEventListener(MouseEvent.MOUSE_OUT, onCloseOut);
    }

    public function updatePosition():void {
        var g:Graphics = this.background.graphics;
        g.clear();
        g.beginFill(Constants.BACK_COLOR_2, 0.8);
        g.drawRect(0, 0, Main.STAGE.stageWidth, HEIGHT);
        g.endFill();

        g = this.slotsMask.graphics;
        g.clear();
        g.beginFill(0);
        g.drawRoundRect(0, 0, Main.STAGE.stageWidth, HEIGHT, 10, 10);
        g.endFill();

        this.close.x = Main.StageWidth - this.close.width - 7;

        this.options.x = this.close.x - this.options.width - 10;
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

    public function addMap(mapId:int, name:String, ext:String):void {
        var slot:MapSelectorSlot = new MapSelectorSlot(mapId, name, ext);
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
            mapSlot.x = i * MapSelectorSlot.WIDTH + i * 2; // 2 pixels separation between each slot
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
}
}

import editor.MEEvent;
import editor.ui.Constants;
import editor.ui.MapSelectorView;
import editor.ui.MapView;
import editor.ui.elements.TextTooltip;
import editor.ui.elements.SimpleText;

import flash.display.Graphics;

import flash.display.Shape;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

import util.MoreColorUtil;

class MapSelectorSlot extends Sprite {

    public static const WIDTH:int = 150;
    private static const HEIGHT:int = 25;

    public var mapId:int;
    private var mapName:String;
    private var extension:String;

    private var background:Shape;
    private var text:SimpleText;
    private var selected:Boolean;
    private var cross:Sprite;
    private var closeTooltip:TextTooltip;

    public function MapSelectorSlot(mapId:int, name:String, ext:String){
        this.mapId = mapId;
        this.mapName = name;
        this.extension = ext;

        var mapView:MapView = Main.View.mapViewContainer.maps[mapId] as MapView;
        mapView.tileMap.addEventListener(MEEvent.MAP_CHANGED, this.onMapChanged);
        mapView.mapData.addEventListener(MEEvent.MAP_SAVED, this.onMapSaved);

        this.background = new Shape();
        addChild(this.background);

        this.text = new SimpleText(16, 0xFFFFFF, false, WIDTH);
        this.text.setText(name + ext + (!mapView.mapData.savedChanges ? " *" : ""));
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

        this.cross.addEventListener(MouseEvent.ROLL_OVER, this.onRollOver);
    }

    private function onMapChanged(e:Event):void {
        this.text.setText(this.mapName + this.extension + " *");
        this.text.updateMetrics();
    }

    private function onMapSaved(e:Event):void {
        this.text.setText(this.mapName + this.extension);
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
            Main.STAGE.addChild(this.closeTooltip);
        }
    }

    public function setSelected(val:Boolean):void {
        this.selected = val;
        this.transform.colorTransform = val ? MoreColorUtil.identity : MoreColorUtil.darkCT;
    }
}
