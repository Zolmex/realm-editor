package editor {
public class AutoMapSaver {

    private static const COOLDOWN_MS:int = 60000; // Save map every minute.

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
                mapData.save(true, true); // Saves as .wmap because it's faster.
            }
        }
    }
}
}
