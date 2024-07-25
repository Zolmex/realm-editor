package editor {
public class AutoMapSaver {

    private static const COOLDOWN_MS:int = 30000; // Save map every 30 seconds

    private var cooldown:int;
    public var disabled:Boolean;

    public function reset():void {
        this.cooldown = COOLDOWN_MS;
    }

    public function trySaveMap(mapData:MapData, deltaTime:int):void {
        this.cooldown -= deltaTime;
        if (this.cooldown <= 0) {
            this.reset();

            if (!this.disabled) {
                mapData.save(true, true); // Wmap is faster so save with that
            }
        }
    }
}
}
