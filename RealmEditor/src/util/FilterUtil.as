package util {
import flash.filters.ColorMatrixFilter;

public class FilterUtil {
    public static const GREY_COLOR_FILTER_1:Array = [new ColorMatrixFilter(MoreColorUtil.singleColorFilterMatrix(0x666666))];
    public static const GREY_COLOR_FILTER_2:Array = [new ColorMatrixFilter(MoreColorUtil.singleColorFilterMatrix(0x444444))];
}
}
