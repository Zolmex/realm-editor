package editor.ui {
import assets.AssetLibrary;

import editor.METool;

import flash.display.Bitmap;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

import util.FilterUtil;

public class MapToolbar extends Sprite {

    private static const ICON_SIZE:int = 20;
    private static const ICON_TO_TOOL:Array = [0, 1, 6, 5, 4, 2, 3, 7];

    private var view:MainView;
    private var background:Shape;
    private var icons:Vector.<ToolIconContainer>; // 0: select, 1: pencil, 2: erase, 3: picker, 4 (skip), 5: bucket, 6: line, 7: shape, 8 (skip), 9: edit

    public function MapToolbar(view:MainView) {
        this.view = view;
        this.icons = new Vector.<ToolIconContainer>();

        this.background = new Shape();
        addChild(this.background);

        var iconCount:int = 0;
        for (var i:int = 0; i < 10; i++) {
            if (i == 4 || i == 8) {
                continue;
            }

            var container:ToolIconContainer = new ToolIconContainer(i);
            container.scaleX = ICON_SIZE / container.icon.width;
            container.scaleY = ICON_SIZE / container.icon.height;
            container.x = 5;
            container.y = 6 + iconCount * container.icon.height + 6 * iconCount;
            container.filters = FilterUtil.GREY_COLOR_FILTER_1; // Set as unselected
            container.addEventListener(MouseEvent.CLICK, this.onIconClick);
            iconCount++;

            addChild(container);
            this.icons.push(container);
        }

        this.icons[0].filters = null;

        var g:Graphics = this.background.graphics;
        g.beginFill(Constants.BACK_COLOR_2, 0.8);
        g.drawRoundRect(0, 0, width + 10, height + 12, 5, 5);
        g.endFill();

        filters = Constants.SHADOW_FILTER_1;
    }

    private function onIconClick(e:Event):void {
        e.stopImmediatePropagation();

        var icon:ToolIconContainer = e.target as ToolIconContainer;
        for (var i:int = 0; i < this.icons.length; i++) {
            this.icons[i].filters = FilterUtil.GREY_COLOR_FILTER_1;
        }
        icon.filters = null;

        var idx:int = this.icons.indexOf(icon);
        this.view.setSelectedTool(ICON_TO_TOOL[idx]);
    }

    public function setSelected(toolId:int):void {
        for (var i:int = 0; i < this.icons.length; i++) {
            this.icons[i].filters = FilterUtil.GREY_COLOR_FILTER_1;
        }

        switch (toolId) {
            case METool.SELECT_ID:
                this.icons[0].filters = null;
                break;
            case METool.PENCIL_ID:
                this.icons[1].filters = null;
                break;
            case METool.ERASER_ID:
                this.icons[2].filters = null;
                break;
            case METool.PICKER_ID:
                this.icons[3].filters = null;
                break;
            case METool.BUCKET_ID:
                this.icons[4].filters = null;
                break;
            case METool.LINE_ID:
                this.icons[5].filters = null;
                break;
            case METool.SHAPE_ID:
                this.icons[6].filters = null;
                break;
            case METool.EDIT_ID:
                this.icons[7].filters = null;
                break;
        }
    }
}
}

import assets.AssetLibrary;

import editor.METool;

import editor.ui.elements.TextTooltip;

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

class ToolIconContainer extends Sprite {

    public var icon:Bitmap;
    private var toolTextureId:int;
    private var tooltip:TextTooltip;

    public function ToolIconContainer(toolTextureId:int) {
        this.toolTextureId = toolTextureId;
        this.icon = new Bitmap(AssetLibrary.getImageFromSet("editorTools", toolTextureId));
        addChild(this.icon);

        this.addEventListener(MouseEvent.ROLL_OVER, this.onRollOver);
    }

    private function onRollOver(e:Event):void {
        this.removeEventListener(MouseEvent.ROLL_OVER, this.onRollOver);

        this.tooltip = new TextTooltip(this, METool.ToolTextureIdToName(this.toolTextureId), 18, 0xFFFFFF, true);
        Main.STAGE.addChild(this.tooltip);
    }
}