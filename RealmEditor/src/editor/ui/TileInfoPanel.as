package editor.ui {
import assets.ground.GroundLibrary;
import assets.ground.GroundProperties;
import assets.objects.ObjectLibrary;
import assets.regions.RegionLibrary;

import editor.MapTileData;
import editor.ui.elements.SimpleText;

import flash.display.Bitmap;
import flash.display.BitmapData;

import flash.display.BitmapData;
import flash.display.Graphics;

import flash.display.Shape;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.geom.Rectangle;

public class TileInfoPanel extends Sprite {

    private static const IMAGE_SIZE:int = 20;

    private var background:Shape;

    private var tile:MapTileData;
    private var posText:SimpleText;

    private var groundText:SimpleText;
    private var groundTexture:BitmapData;
    private var groundImage:Bitmap;

    private var objectText:SimpleText;
    private var objectTexture:BitmapData;
    private var objectImage:Bitmap;

    private var regionText:SimpleText;
    private var regionTexture:BitmapData;
    private var regionImage:Bitmap;

    public function TileInfoPanel() {
        this.background = new Shape();
        addChild(this.background);

        this.posText = new SimpleText(12, 0xFFFFFF);
        this.posText.filters = Constants.SHADOW_FILTER_1;
        addChild(this.posText);

        this.groundText = new SimpleText(13, 0xFFFFFF);
        this.groundText.setBold(true);
        this.groundText.filters = Constants.SHADOW_FILTER_1;
        addChild(this.groundText);

        this.objectText = new SimpleText(13, 0xFFFFFF);
        this.objectText.setBold(true);
        this.objectText.filters = Constants.SHADOW_FILTER_1;
        addChild(this.objectText);

        this.regionText = new SimpleText(13, 0xFFFFFF);
        this.regionText.setBold(true);
        this.regionText.filters = Constants.SHADOW_FILTER_1;
        addChild(this.regionText);

        filters = Constants.SHADOW_FILTER_1;
    }

    public function setInfo(x:int, y:int, tileData:MapTileData):void {
        if (tileData == null || (tileData.groundType == -1 && tileData.objType == 0 && tileData.regType == 0) || tileData == this.tile) {
            return;
        }

        this.tile = tileData;

        this.posText.setText("X: " + x.toString() + " Y: " + y.toString());
        this.posText.useTextDimensions();

        if (tileData.groundType != -1) {
            var groundId:String = GroundLibrary.getIdFromType(tileData.groundType);
            this.groundText.setText(groundId == null ? "" : groundId);
            this.groundText.useTextDimensions();

            if (!contains(this.groundText)){
                addChild(this.groundText);
            }
        } else if (contains(this.groundText)) {
            removeChild(this.groundText);
        }

        if (tileData.objType > 0) {
            var objectId:String = ObjectLibrary.getIdFromType(tileData.objType);
            this.objectText.setText(objectId == null ? "" : objectId);
            this.objectText.useTextDimensions();

            if (!contains(this.objectText)){
                addChild(this.objectText);
            }
        } else if (contains(this.objectText)) {
            removeChild(this.objectText);
        }

        if (tileData.regType > 0) {
            var regionId:String = RegionLibrary.getIdFromType(tileData.regType);
            this.regionText.setText(regionId == null ? "" : regionId);
            this.regionText.useTextDimensions();

            if (!contains(this.regionText)){
                addChild(this.regionText);
            }
        } else if (contains(this.regionText)) {
            removeChild(this.regionText);
        }

        this.drawTextures(tileData);

        this.fixPositions();

        this.drawBackground();
    }

    private function drawTextures(tileData:MapTileData):void {
        if (this.groundImage) {
            this.groundTexture.dispose();
            removeChild(this.groundImage);

            this.groundImage = null;
        }
        if (this.objectImage) {
            this.objectTexture.dispose();
            removeChild(this.objectImage);

            this.objectImage = null;
        }
        if (this.regionImage) {
            this.regionTexture.dispose();
            removeChild(this.regionImage);

            this.regionImage = null;
        }

        if (tileData.groundType != -1) {
            var groundText:BitmapData = GroundLibrary.getBitmapData(tileData.groundType);
            var groundMatrix:Matrix = new Matrix();
            groundMatrix.scale(IMAGE_SIZE / groundText.width, IMAGE_SIZE / groundText.height);
            this.groundTexture = new BitmapData(IMAGE_SIZE, IMAGE_SIZE, true, 0);
            this.groundTexture.draw(groundText, groundMatrix);
            this.groundImage = new Bitmap(this.groundTexture);
            addChild(this.groundImage);
        }

        if (tileData.objType > 0) {
            var objectText:BitmapData = ObjectLibrary.getTextureFromType(tileData.objType);
            var objectMatrix:Matrix = new Matrix();
            objectMatrix.scale(IMAGE_SIZE / objectText.width, IMAGE_SIZE / objectText.height);
            this.objectTexture = new BitmapData(IMAGE_SIZE, IMAGE_SIZE, true, 0);
            this.objectTexture.draw(objectText, objectMatrix);
            this.objectImage = new Bitmap(this.objectTexture);
            addChild(this.objectImage);
        }

        if (tileData.regType > 0) {
            var regColor:uint = RegionLibrary.getColor(tileData.regType);
            this.regionTexture = new BitmapData(IMAGE_SIZE, IMAGE_SIZE, true, 0);
            this.regionTexture.fillRect(new Rectangle(0, 0, IMAGE_SIZE, IMAGE_SIZE), 1593835520 | regColor);
            this.regionImage = new Bitmap(this.regionTexture);
            addChild(this.regionImage);
        }
    }

    private function fixPositions():void {
        this.posText.x = 0;
        this.posText.y = 0;

        if (this.groundImage) {
            this.groundImage.x = this.posText.x;
            this.groundImage.y = this.posText.y + this.posText.height + 5;

            this.groundText.x = this.groundImage.x + this.groundImage.width + 5;
            this.groundText.y = this.groundImage.y + (this.groundImage.height - this.groundText.height) / 2;
        }

        if (this.objectImage) {
            this.objectImage.x = this.posText.x;
            if (this.groundImage) {
                this.objectImage.y = this.groundImage.y + this.groundImage.height + 5;
            } else {
                this.objectImage.y = this.posText.y + this.posText.height + 5;
            }

            this.objectText.x = this.objectImage.x + this.objectImage.width + 5;
            this.objectText.y = this.objectImage.y + (this.objectImage.height - this.objectText.height) / 2;
        }

        if (this.regionImage) {
            this.regionImage.x = this.posText.x;
            if (this.objectImage) {
                this.regionImage.y = this.objectImage.y + this.objectImage.height + 5;
            } else if (this.groundImage) {
                this.regionImage.y = this.groundImage.y + this.groundImage.height + 5;
            } else {
                this.regionImage.y = this.posText.y + this.posText.height + 5;
            }

            this.regionText.x = this.regionImage.x + this.regionImage.width + 5;
            this.regionText.y = this.regionImage.y + (this.regionImage.height - this.regionText.height) / 2;
        }
    }

    private function drawBackground():void {
        var g:Graphics = this.background.graphics;
        g.clear();
        g.beginFill(Constants.BACK_COLOR_2, 0.8);
        g.drawRoundRect(-4, -4, width + 8, height + 8, 10, 10);
        g.endFill();
    }
}
}
