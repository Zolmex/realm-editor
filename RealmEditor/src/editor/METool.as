package editor {

public class METool {

    public static const SELECT_ID:int = 0;
    public static const PENCIL_ID:int = 1;
    public static const LINE_ID:int = 2;
    public static const SHAPE_ID:int = 3;
    public static const BUCKET_ID:int = 4;
    public static const PICKER_ID:int = 5;
    public static const ERASER_ID:int = 6;
    public static const EDIT_ID:int = 7;
    public static const SELECT:String = "Select";
    public static const PENCIL:String = "Pencil";
    public static const LINE:String = "Line";
    public static const SHAPE:String = "Shape";
    public static const BUCKET:String = "Bucket";
    public static const PICKER:String = "Picker";
    public static const ERASER:String = "Eraser";
    public static const EDIT:String = "Edit";

    public static function ToolEventToId(eventStr:String):int {
        switch (eventStr){
            case MEEvent.TOOL_SWITCH_SELECT:
                return SELECT_ID;
            case MEEvent.TOOL_SWITCH_PENCIL:
                return PENCIL_ID;
            case MEEvent.TOOL_SWITCH_LINE:
                return LINE_ID;
            case MEEvent.TOOL_SWITCH_SHAPE:
                return SHAPE_ID;
            case MEEvent.TOOL_SWITCH_BUCKET:
                return BUCKET_ID;
            case MEEvent.TOOL_SWITCH_PICKER:
                return PICKER_ID;
            case MEEvent.TOOL_SWITCH_ERASER:
                return ERASER_ID;
            case MEEvent.TOOL_SWITCH_EDIT:
                return EDIT_ID;
            default:
                trace("Unknown tool id for tool event:", eventStr);
                return -1;
        }
    }

    public static function ToolIdToName(id:int):String {
        switch (id){
            case SELECT_ID:
                return SELECT;
            case PENCIL_ID:
                return PENCIL;
            case LINE_ID:
                return LINE;
            case SHAPE_ID:
                return SHAPE;
            case BUCKET_ID:
                return BUCKET;
            case PICKER_ID:
                return PICKER;
            case ERASER_ID:
                return ERASER;
            case EDIT_ID:
                return EDIT;
            default:
                trace("Unknown tool name for tool id:", id.toString());
                return null;
        }
    }

    public static function ToolTextureIdToName(id:int):String {
        switch (id){
            case 0:
                return SELECT;
            case 1:
                return PENCIL;
            case 2:
                return ERASER;
            case 3:
                return PICKER;
            case 5:
                return BUCKET;
            case 6:
                return LINE;
            case 7:
                return SHAPE;
            case 9:
                return EDIT;
            default:
                trace("Unknown tool name for tool id:", id.toString());
                return null;
        }
    }
}
}
