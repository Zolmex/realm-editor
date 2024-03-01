package editor {
import flash.events.Event;

public class ToolSwitchEvent extends Event{

    public var toolId:int;

    public function ToolSwitchEvent(str:String, toolId:int) {
        super(str);
        this.toolId = toolId;
    }
}
}
