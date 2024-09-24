package editor.ui.elements {
import assets.AssetLibrary;

import flash.display.Bitmap;
import flash.display.Sprite;

public class ResizeAnchor extends Sprite {
    private var icon:Bitmap;
    public var isResizing:Boolean;

    public function ResizeAnchor() {
        this.isResizing = false;
        this.icon = new Bitmap(AssetLibrary.getImageFromSet("editorTools", 10));
        addChild(this.icon);
    }
}
}
