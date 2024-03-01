package editor.ui {
import editor.ui.elements.SimpleText;
import editor.ui.elements.SimpleTextButton;
import editor.ui.elements.SimpleTextInput;

import flash.display.Graphics;

import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.utils.Dictionary;

public class ObjectFilterOptionsView extends Sprite {

    private static const LETTERS:String = "abcdefghijklmopuqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";

    private var listView:MapDrawElementListView;
    private var background:Shape;
    private var arrowText:SimpleText;
    private var propInput:SimpleTextInput;
    private var valueInput:SimpleTextInput;
    private var addButton:SimpleTextButton;
    private var options:Dictionary;

    public function ObjectFilterOptionsView(listView:MapDrawElementListView) {
        this.listView = listView;
        this.options = new Dictionary();

        this.background = new Shape();
        this.background.visible = false;
        addChild(this.background);

        this.arrowText = new SimpleText(20, 0xFFFFFF);
        this.arrowText.setText("<");
        this.arrowText.setBold(true);
        this.arrowText.useTextDimensions();
        this.arrowText.mouseEnabled = true;
        this.arrowText.filters = Constants.SHADOW_FILTER_1;
        this.arrowText.addEventListener(MouseEvent.CLICK, this.onArrowClick);
        addChild(this.arrowText);

        this.drawPanel();

        filters = Constants.SHADOW_FILTER_1;
    }

    private function drawPanel():void {
        this.propInput = new SimpleTextInput("Property:", true, "", 18, 0xFFFFFF, 15, 0xEAEAEA, true);
        this.propInput.inputText.restrict = "a-z A-Z 0-9";
        this.propInput.x = this.arrowText.x - this.propInput.width - 5;
        this.propInput.y = 5;
        this.propInput.filters = Constants.SHADOW_FILTER_1;

        this.valueInput = new SimpleTextInput("Value:", true, "", 18, 0xFFFFFF, 15, 0xEAEAEA, true);
        this.valueInput.inputText.restrict = "a-z A-Z 0-9";
        this.valueInput.x = this.propInput.x;
        this.valueInput.y = this.propInput.y + this.propInput.height + 2;
        this.valueInput.filters = Constants.SHADOW_FILTER_1;

        this.addButton = new SimpleTextButton("Add");
        this.addButton.addEventListener(MouseEvent.CLICK, this.onAddClick);
        this.addButton.x = this.propInput.x;
        this.addButton.y = this.valueInput.y + this.valueInput.height + 5;

        this.drawBackground();
    }

    private function drawBackground():void {
        var g:Graphics = this.background.graphics;
        g.clear();
        g.beginFill(Constants.BACK_COLOR_2, 0.8);
        g.drawRoundRect(-(width - this.arrowText.width) - 5, 0, width + 5, height + 10, 10, 10);
        g.endFill();
    }

    private function onArrowClick(e:Event):void {
        var val:Boolean = !this.background.visible;
        this.arrowText.setText(val ? ">" : "<");
        this.arrowText.useTextDimensions();

        if (val) {
            addChild(this.propInput);
            addChild(this.valueInput);
            addChild(this.addButton);
        } else {
            removeChild(this.propInput);
            removeChild(this.valueInput);
            removeChild(this.addButton);
        }

        this.background.visible = val;
        this.drawBackground();
        this.optionsVisible(val);
    }

    private function onAddClick(e:Event):void {
        var propName:String = this.propInput.inputText.text;
        var valueStr:String = this.valueInput.inputText.text;
        if (propName == "" || this.options.hasOwnProperty(propName)) {
            return;
        }

        var val:*;
        if (valueStr == "") {
            val = true;
        } else if (IsNumber(valueStr)) {
            val = int(valueStr);
        } else if (valueStr == "true") {
            val = true;
        } else if (valueStr == "false") {
            val = false;
        } else {
            val = valueStr;
        }

        this.listView.addPropertyFilter(propName, val);

        var option:FilterOption = new FilterOption(propName, val);
        addChild(option);

        this.options[propName] = option;
        this.positionOptions();

        this.drawBackground();
    }

    public function removeOption(option:FilterOption):void {
        if (!this.options.hasOwnProperty(option.propName)) {
            return;
        }

        this.listView.removePropertyFilter(option.propName);

        removeChild(option);
        delete this.options[option.propName];

        this.positionOptions();

        this.drawBackground();
    }

    private function positionOptions():void {
        var i:int = 0;
        for (var propName:String in this.options) {
            this.options[propName].x = this.propInput.x;
            this.options[propName].y = this.addButton.y + this.addButton.height + 5;
            this.options[propName].y += i * FilterOption.HEIGHT + i * 2; // 2 pixels separation between each slot
            i++;
        }
    }

    private function optionsVisible(val:Boolean):void {
        for (var propName:String in this.options) {
            this.options[propName].visible = val;
        }
    }

    private static function IsNumber(str:String):Boolean {
        for (var i:int = 0; i < LETTERS.length; i++) {
            var c:String = LETTERS.charAt(i);
            if (str.indexOf(c) != -1) {
                return false;
            }
        }
        return true;
    }
}
}

import editor.ui.Constants;
import editor.ui.ObjectFilterOptionsView;
import editor.ui.elements.SimpleText;

import flash.display.Graphics;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

class FilterOption extends Sprite {

    public static const HEIGHT:int = 30;

    public var propName:String;
    private var propText:SimpleText;
    private var valText:SimpleText;
    private var cross:Sprite;

    public function FilterOption(propName:String, val:*) {
        this.propName = propName;

        this.propText = new SimpleText(18, 0xFFFFFF);
        this.propText.setText(propName + ":");
        this.propText.useTextDimensions();
        this.propText.filters = Constants.SHADOW_FILTER_1;
        addChild(this.propText);

        this.valText = new SimpleText(18, 0xFFFFFF);
        this.valText.setText(val.toString());
        this.valText.useTextDimensions();
        this.valText.x = this.propText.x + this.propText.width + 3;
        this.valText.filters = Constants.SHADOW_FILTER_1;
        addChild(this.valText);

        this.cross = new Sprite();
        this.cross.addEventListener(MouseEvent.CLICK, this.onCrossClick);
        addChild(this.cross);

        var crossSize:int = HEIGHT - 20;
        var g:Graphics = this.cross.graphics;
        g.lineStyle(4, 0xFFFFFF);
        g.lineTo(crossSize, crossSize);
        g.moveTo(crossSize, 0);
        g.lineTo(0, crossSize);
        g.lineStyle();

        this.cross.x = width + 3;
        this.cross.y = (height - crossSize) / 2;
    }

    private function onCrossClick(e:Event):void {
        e.stopImmediatePropagation();

        (parent as ObjectFilterOptionsView).removeOption(this);
    }
}