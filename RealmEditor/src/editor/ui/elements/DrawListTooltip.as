package editor.ui.elements {
import editor.ui.*;
import editor.MEDrawType;
import editor.ui.elements.SimpleText;
import editor.ui.elements.Tooltip;

import flash.display.Bitmap;

import flash.display.BitmapData;

import flash.display.DisplayObject;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormatAlign;

import util.TextureRedrawer;

public class DrawListTooltip extends Tooltip {

    private static const ICON_SIZE:int = 80;

    private var drawType:int;
    private var iconTexture:BitmapData;
    private var xml:XML;

    private var icon:Bitmap;
    private var id:String;
    private var idText:SimpleText;
    private var properties:String = "";
    private var propertiesText:SimpleText;

    public function DrawListTooltip(target:DisplayObject, iconTexture:BitmapData, xml:XML, drawType:int) {
        this.drawType = drawType;
        this.iconTexture = iconTexture;
        this.xml = xml;

        this.drawIcon();
        this.drawElementId();
        if (this.drawType == MEDrawType.GROUND) {
            this.addTileProperties();
        }
        if (this.drawType == MEDrawType.OBJECTS) {
            this.addObjectProperties();
        }
        if (this.properties != "") {
            this.drawProperties();
        }

        super(target);
    }

    protected override function addChildren():void {
        addChild(this.icon);
        addChild(this.idText);
        if (this.propertiesText) {
            if (this.propertiesText.htmlText != "")
                addChild(this.propertiesText);
        }
    }

    protected override function positionChildren():void {
        this.icon.x = 0;
        this.icon.y = 0;
        this.idText.x = this.icon.x + this.icon.width;
        this.idText.y = (this.icon.height - this.idText.height) / 2;
        if (this.propertiesText) {
            this.propertiesText.x = 10;
            this.propertiesText.y = this.icon.y + this.icon.height - 3;
        }
    }

    private function drawIcon():void {
        var size:Number = this.iconTexture ? ICON_SIZE * (8 / this.iconTexture.width) : 1;
        var redrawnTexture:BitmapData = TextureRedrawer.redraw(this.iconTexture, size, true, 0);
        this.icon = new Bitmap(redrawnTexture);
    }

    private function drawElementId():void {
        this.id = this.xml.@id;
        this.idText = new SimpleText(18, 0xFFFFFF);
        this.idText.setText(this.id);
        this.idText.setBold(true);
        this.idText.filters = Constants.SHADOW_FILTER_1;
        this.idText.useTextDimensions();
    }

    private function addTileProperties():void {
        if (this.xml.hasOwnProperty("Damage")) {
            this.addProperty("<b>Damage:</b> " + this.xml.Damage);
        }
        if (this.xml.hasOwnProperty("CompositePriority")) {
            this.addProperty("<b>Composite priority:</b> " + this.xml.CompositePriority);
        }
        if (this.xml.hasOwnProperty("Speed")) {
            this.addProperty("<b>Speed:</b> " + this.xml.Speed);
        }
        if (this.xml.hasOwnProperty("BlendPriority")) {
            this.addProperty("<b>Blend priority:</b> " + this.xml.BlendPriority);
        }
        if (this.xml.hasOwnProperty("Color")) {
            this.addProperty("<b>Color:</b> " + this.xml.Color);
        }
        if (this.xml.hasOwnProperty("XOffset")) {
            this.addProperty("<b>X offset:</b> " + this.xml.XOffset);
        }
        if (this.xml.hasOwnProperty("YOffset")) {
            this.addProperty("<b>Y offset:</b> " + this.xml.YOffset);
        }
        if (this.xml.hasOwnProperty("Push")) {
            this.addProperty("Push");
        }
        if (this.xml.hasOwnProperty("Sink")) {
            this.addProperty("Sink");
        }
        if (this.xml.hasOwnProperty("Sinking")) {
            this.addProperty("Sinking");
        }
        if (this.xml.hasOwnProperty("NoWalk")) {
            this.addProperty("Unwalkable");
        }
        if (this.xml.hasOwnProperty("RandomOffset")) {
            this.addProperty("Random offset");
        }
        if (this.xml.hasOwnProperty("SameTypeEdgeMode")) {
            this.addProperty("Same type edge mode");
        }
    }

    private function addObjectProperties():void {
        if (this.xml.hasOwnProperty("DisplayId")) {
            this.addProperty("<b>Display ID:</b> " + this.xml.DisplayId);
        }
        if (this.xml.hasOwnProperty("Group")) {
            this.addProperty("<b>Group:</b> " + this.xml.Group);
        }
        if (this.xml.hasOwnProperty("Class")) {
            this.addProperty("<b>Class:</b> " + this.xml.Class);
        }
        if (this.xml.hasOwnProperty("Model")) {
            this.addProperty("<b>Model:</b> " + this.xml.Model);
        }
        if (this.xml.hasOwnProperty("Effect")) {
            this.addProperty("<b>Effect:</b> " + this.xml.Effect);
        }
        if (this.xml.hasOwnProperty("MaxHitPoints")) {
            this.addProperty("<b>Max HP:</b> " + this.xml.MaxHitPoints);
        }
        if (this.xml.hasOwnProperty("Defense")) {
            this.addProperty("<b>Defense:</b> " + this.xml.Defense);
        }
        if (this.xml.hasOwnProperty("XpMult")) {
            this.addProperty("<b>XP mult:</b> " + this.xml.XpMult);
        }
        if (this.xml.hasOwnProperty("Size")) {
            this.addProperty("<b>Size:</b> " + this.xml.Size);
        }
        if (this.xml.hasOwnProperty("Terrain")) {
            this.addProperty("<b>Terrain:</b> " + this.xml.Terrain);
        }
        if (this.xml.hasOwnProperty("SpawnProb")) {
            this.addProperty("<b>Spawn prob:</b> " + this.xml.SpawnProb);
        }
        if (this.xml.hasOwnProperty("Static")) {
            this.addProperty("Static");
        }
        if (this.xml.hasOwnProperty("DrawOnGround")) {
            this.addProperty("Draws on ground");
        }
        if (this.xml.hasOwnProperty("Enemy")) {
            this.addProperty("Enemy");
        }
        if (this.xml.hasOwnProperty("God")) {
            this.addProperty("God");
        }
        if (this.xml.hasOwnProperty("Encounter")) {
            this.addProperty("Encounter");
        }
        if (this.xml.hasOwnProperty("Quest")) {
            this.addProperty("Quest");
        }
        if (this.xml.hasOwnProperty("Oryx")) {
            this.addProperty("Oryx");
        }
    }

    private function addProperty(str:String):void {
        if (this.properties == "") {
            this.properties = str;
        } else {
            this.properties += "\n" + str;
        }
        trace(str);
    }

    private function drawProperties():void {
        this.propertiesText = new SimpleText(14, 0xB2B2B2, false);
        this.propertiesText.htmlText = this.properties;
        this.propertiesText.autoSize = TextFieldAutoSize.LEFT;
        this.propertiesText.useTextDimensions();
        this.propertiesText.filters = Constants.SHADOW_FILTER_1;
    }
}
}
