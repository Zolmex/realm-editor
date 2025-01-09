package realmeditor.util {
public class TimedAction {

    public var timeLeftMS:int;
    public var callback:Function;

    public function TimedAction(timeMS:int, callback:Function) {
        this.timeLeftMS = timeMS;
        this.callback = callback;
    }
}
}
