package editor.ui {
import assets.ground.GroundLibrary;
import assets.objects.ObjectLibrary;
import assets.regions.RegionLibrary;

import editor.MEDrawType;
import editor.ui.elements.*;
import editor.ui.Constants;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Matrix;
import flash.utils.Dictionary;

public class MapDrawElementListView extends Sprite {

    public static const WIDTH:int = 130;
    private static const ELEMENT_SIZE:int = 35;

    private var background:Shape;
    private var listMask:Shape;
    private var listContainer:Sprite;
    private var selectionSquare:Shape;
    public var selectedElement:MapDrawElement;
    public var totalHeight:int;
    private var searchInputBox:SimpleInputBox;
    private var listYLimit:Number;
    private var drawType:int;
    private var elementTypes:Dictionary;

    private var elementFilters:Vector.<IDrawElementFilter>;
    private var searchFilter:DrawListSearchFilter;
    private var objectFilter:DrawListObjectFilter;

    public function MapDrawElementListView() {
        this.totalHeight = Main.StageHeight - 80;

        this.elementFilters = new Vector.<IDrawElementFilter>();
        this.searchFilter = new DrawListSearchFilter();
        this.objectFilter = new DrawListObjectFilter();
        this.loadElementFilters();

        this.background = new Shape();
        this.drawBackground();
        addChild(this.background);

        this.listContainer = new Sprite();
        addChild(this.listContainer);

        this.searchInputBox = new SimpleInputBox(WIDTH - 10, 25, "", 18, 0xFFFFFF, true);
        this.searchInputBox.x = 5;
        this.searchInputBox.y = 7.5;
        this.searchInputBox.inputText.addEventListener(Event.CHANGE, this.onInputChange);
        addChild(this.searchInputBox);
        this.listYLimit = this.searchInputBox.y + this.searchInputBox.height + 2.5;

        this.listMask = new Shape();
        this.drawListMask();
        this.listContainer.mask = this.listMask;
        addChild(this.listMask);

        this.selectionSquare = new Shape();
        var squareSize:int = ELEMENT_SIZE + 5;
        var g:Graphics = this.selectionSquare.graphics;
        g.lineStyle(1, 0xFFFFFF);
        g.lineTo(squareSize, 0);
        g.lineTo(squareSize, squareSize);
        g.lineTo(0, squareSize);
        g.lineTo(0, 0);
        g.lineStyle();
        this.selectionSquare.visible = false;

        this.addEventListener(MouseEvent.MOUSE_WHEEL, this.onScroll);

        filters = Constants.SHADOW_FILTER_1;
    }

    public function addPropertyFilter(propName:String, value:*):void {
        this.objectFilter.addProp(propName, value);
        this.setContent(this.drawType);
    }

    public function removePropertyFilter(propName:String):void {
        this.objectFilter.removeProp(propName);
        this.setContent(this.drawType);
    }

    private function loadElementFilters():void {
        this.elementFilters.push(this.searchFilter);
        this.elementFilters.push(this.objectFilter);
    }

    public function resetFilters():void {
        this.searchFilter.reset();
    }

    private function onInputChange(e:Event):void {
        this.searchFilter.setSearch(this.searchInputBox.inputText.text);
        this.setContent(this.drawType);
    }

    public function setContent(drawType:int):void {
        this.listContainer.removeChildren(); // Clear elements from container
        this.listContainer.y = this.listYLimit;

        this.drawType = drawType;
        var textureDict:Dictionary;
        switch(drawType){
            case MEDrawType.GROUND:
                textureDict = GroundLibrary.typeToTextureData_;
                break;
            case MEDrawType.OBJECTS:
                textureDict = ObjectLibrary.typeToTextureData_;
                break;
            case MEDrawType.REGIONS:
                textureDict = RegionLibrary.typeToTextureData_;
                break;
        }

        for each (var filter:IDrawElementFilter in this.elementFilters) {
            filter.setDrawType(drawType);
        }

        this.elementTypes = new Dictionary();

        var i:int = 0;
        for (var key:int in textureDict) {
            var filterPass:int = 0;
            for each (filter in this.elementFilters) {
                if (filter.filter(key)) {
                    filterPass++;
                }
            }

            if (filterPass < this.elementFilters.length) { // All filters must pass
                continue;
            }

            var element:MapDrawElement = new MapDrawElement(key, textureDict[key].getTexture(0), drawType);
            element.addEventListener(MouseEvent.CLICK, this.onElementClick);

            this.elementTypes[key] = element;
            this.drawElement(i, element);
            i++;
        }

        this.selectionSquare.visible = false;
        this.listContainer.addChild(this.selectionSquare);
    }

    private function onElementClick(e:Event):void {
        var targetElement:MapDrawElement = e.target as MapDrawElement;
        if (this.selectedElement != null && targetElement == this.selectedElement) {
            this.selectedElement = null;
            this.selectionSquare.visible = false;
            return;
        }

        this.selectedElement = targetElement;
        this.selectionSquare.x = this.selectedElement.x - 2.5;
        this.selectionSquare.y = this.selectedElement.y - 2.5;
        this.selectionSquare.visible = true;

        this.dispatchEvent(new Event(Event.SELECT));
    }

    public function setSelected(elementType:int):void {
        var element:MapDrawElement = this.elementTypes[elementType];
        if (element == null){
            return;
        }

        this.selectedElement = element;
        this.selectionSquare.x = this.selectedElement.x - 2.5;
        this.selectionSquare.y = this.selectedElement.y - 2.5;
        this.selectionSquare.visible = true;

        this.listContainer.y = this.listYLimit - this.selectionSquare.y + 2.5;
        this.fixListPosition();
    }

    private function onScroll(e:MouseEvent):void {
        e.stopImmediatePropagation(); // Make sure we don't zoom in/out the map
        var scroll:Number = e.delta * 10;
        this.listContainer.y += scroll;
        this.fixListPosition();
    }

    private function fixListPosition():void {
        if (this.listContainer.y > this.listYLimit) { // Top limit
            this.listContainer.y = this.listYLimit;
        }
        if (this.listContainer.height < this.totalHeight) { // If the elements container is smaller than the view, don't scroll
            this.listContainer.y = this.listYLimit;
        } else if (this.listContainer.y < -this.listContainer.height + this.totalHeight) { // Bottom limit
            this.listContainer.y = -this.listContainer.height + this.totalHeight;
        }
    }

    private function drawBackground():void {
        var g:Graphics = this.background.graphics;
        g.clear();
        g.beginFill(Constants.BACK_COLOR_2, 0.8);
        g.drawRoundRect(0, 0, WIDTH, this.totalHeight, 15, 15);
        g.endFill();
    }

    private function drawListMask():void {
        var yPos:Number = this.searchInputBox.y + this.searchInputBox.height + 5;
        var g:Graphics = this.listMask.graphics;
        g.clear();
        g.beginFill(0);
        g.drawRect(2.5, yPos, WIDTH - 5, this.totalHeight - yPos - 2.5);
        g.endFill();
    }

    public function onScreenResize():void {
        this.totalHeight = Main.StageHeight - 60;

        this.drawBackground();
        this.drawListMask();
    }

    private function drawElement(id:int, element:MapDrawElement):void {
        if (element.texture == null) {
            trace("null element texture");
            return;
        }

        element.scaleX = ELEMENT_SIZE / element.texture.width;
        element.scaleY = ELEMENT_SIZE / element.texture.height;
        element.x = 6.5 + int(id % 3) * (ELEMENT_SIZE + 6.5);
        element.y = 6.5 + int(id / 3) * (ELEMENT_SIZE + 6.5);
        this.listContainer.addChild(element);
    }
}
}
