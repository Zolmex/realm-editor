package realmeditor.editor.ui.elements {

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.text.Font;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.text.TextLineMetrics;

import editor.ui.embed.fonts.MyriadPro;

import editor.ui.embed.fonts.MyriadProBold;
import editor.ui.embed.fonts.MyriadProBoldCFF;
import editor.ui.embed.fonts.MyriadProCFF;

import realmeditor.editor.ui.embed.fonts.AurusenthialClassic;
import realmeditor.editor.ui.embed.fonts.AurusenthialClassicBold;
import realmeditor.editor.ui.embed.fonts.AurusenthialClassicBoldCFF;
import realmeditor.editor.ui.embed.fonts.AurusenthialClassicCFF;

import realmeditor.editor.ui.embed.fonts.MyriadPro;
import realmeditor.editor.ui.embed.fonts.MyriadProBold;
import realmeditor.editor.ui.embed.fonts.MyriadProBoldCFF;
import realmeditor.editor.ui.embed.fonts.MyriadProCFF;

public class SimpleText extends TextField {

    private static const GUTTER:int = 16;

//    public static const _MyriadPro:Class = MyriadPro;
//    public static const _MyriadProBold:Class = MyriadProBold;
//    public static const _MyriadProCFF:Class = MyriadProCFF;
//    public static const _MyriadProBoldCFF:Class = MyriadProBoldCFF;
    public static const _AurusenthialClassic:Class = AurusenthialClassic;
    public static const _AurusenthialClassicBold:Class = AurusenthialClassicBold;
    public static const _AurusenthialClassicCFF:Class = AurusenthialClassicCFF;
    public static const _AurusenthialClassicBoldCFF:Class = AurusenthialClassicBoldCFF;
    public static var _Font:Font;
    public static var _FontRegistered:Boolean = false;

    public var inputWidth_:int;
    public var inputHeight_:int;
    public var actualWidth_:int;
    public var actualHeight_:int;
    public var autoResize:Boolean;

    public function SimpleText(textSize:int, color:uint, makeSelectable:Boolean = false, widthParam:int = 0, heightParam:int = 0, isLink:Boolean = false, stopKeyPropagation:Boolean = false) {
        if (!_FontRegistered) {
//            Font.registerFont(_MyriadPro);
//            Font.registerFont(_MyriadProBold);
//            Font.registerFont(_MyriadProCFF);
//            Font.registerFont(_MyriadProBoldCFF);
//            _Font = new _MyriadPro();
            Font.registerFont(_AurusenthialClassic);
            Font.registerFont(_AurusenthialClassicBold);
            Font.registerFont(_AurusenthialClassicCFF);
            Font.registerFont(_AurusenthialClassicBoldCFF);
            _Font = new _AurusenthialClassic();
            _FontRegistered = true;
        }

        super();
        this.inputWidth_ = widthParam;
        if (this.inputWidth_ != 0) {
            width = widthParam;
        }
        this.inputHeight_ = heightParam;
        if (this.inputHeight_ != 0) {
            height = heightParam;
        }
        var format:TextFormat = defaultTextFormat;
        format.font = _Font.fontName;
        format.bold = false;
        format.size = textSize;
        format.color = color;
        embedFonts = true;
        defaultTextFormat = format;
        if (makeSelectable) {
            selectable = true;
            mouseEnabled = true;
            type = TextFieldType.INPUT;
            border = true;
            borderColor = color;
            addEventListener(Event.CHANGE, this.onChange);
            if (stopKeyPropagation) {
                addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
            }
        } else {
            selectable = false;
            mouseEnabled = false;
        }

        if (isLink) {
            mouseEnabled = true;
        }
    }

    private static function onKeyUp(e:Event):void {
        e.stopImmediatePropagation();
    }

    public function setSize(size:int):SimpleText {
        var format:TextFormat = defaultTextFormat;
        format.size = size;
        this.applyFormat(format);
        return this;
    }

    public function setColor(color:uint):SimpleText {
        var format:TextFormat = defaultTextFormat;
        format.color = color;
        this.applyFormat(format);
        return this;
    }

    public function setBold(bold:Boolean):SimpleText {
        var format:TextFormat = defaultTextFormat;
        format.bold = bold;
        this.applyFormat(format);
        return this;
    }

    public function setItalic(italic:Boolean):SimpleText {
        var format:TextFormat = defaultTextFormat;
        format.italic = italic;
        this.applyFormat(format);
        return this;
    }

    public function setAlignment(alignment:String):SimpleText {
        var format:TextFormat = defaultTextFormat;
        format.align = alignment;
        this.applyFormat(format);
        return this;
    }

    public function setText(text:String):SimpleText {
        this.text = text;
        return this;
    }

    private function applyFormat(format:TextFormat):void {
        setTextFormat(format);
        defaultTextFormat = format;
    }

    private function onChange(event:Event):void {
        this.updateMetrics();
    }

    public function updateMetrics():SimpleText {
        var textMetrics:TextLineMetrics = null;
        var textWidth:int = 0;
        var textHeight:int = 0;
        this.actualWidth_ = 0;
        this.actualHeight_ = 0;
        for (var i:int = 0; i < numLines; i++) {
            textMetrics = getLineMetrics(i);
            textWidth = textMetrics.width + 4;
            textHeight = textMetrics.height + 4;
            if (textWidth > this.actualWidth_) {
                this.actualWidth_ = textWidth;
            }
            this.actualHeight_ = this.actualHeight_ + textHeight;
        }
        width = this.inputWidth_ == 0 ? this.actualWidth_ : this.inputWidth_;
        height = this.inputHeight_ == 0 ? this.actualHeight_ : this.inputHeight_;
        if (this.autoResize)
            this.resize();
        return this;
    }

    public function useTextDimensions():void {
        width = this.inputWidth_ == 0 ? (textWidth + 4) : (this.inputWidth_);
        height = this.inputHeight_ == 0 ? (textHeight + 4) : (this.inputHeight_);
        if (this.autoResize)
            this.resize();
    }

    public function setAutoSize(aSize:String):void {
        autoSize = aSize;
        if (this.inputWidth_ != 0 || this.inputHeight_ != 0)
            this.autoResize = true;
    }

    private function resize():void {
        while ((this.inputWidth_ > 0 && width > this.inputWidth_) || (this.inputHeight_ > 0 && height > this.inputHeight_)) {
            scaleX -= 0.05;
            scaleY -= 0.05;
        }
    }
}
}
