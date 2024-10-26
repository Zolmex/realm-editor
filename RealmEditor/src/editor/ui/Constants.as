package editor.ui {
import flash.filters.DropShadowFilter;
import flash.filters.GlowFilter;

public class Constants {

    public static const BACK_COLOR_1:uint = 0x888888;
    public static const BACK_COLOR_2:uint = 0x565656;
    public static const BACK_COLOR_3:uint = 0x282828;
    public static const SHADOW_FILTER_1:Array = [new DropShadowFilter(0,0,0,0.5,12,12)];
    public static const OUTLINE_FILTER_1:Array = [new GlowFilter(0, 1, 2, 2, 10, 1)];
}
}
