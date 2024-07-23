package editor {
public class AutoMapSaver {

    private static const COOLDOWN_MS:int = 15000; // Save map every 15 seconds

    private var cooldown:int;

    public function reset():void {
        this.cooldown = COOLDOWN_MS;
    }

    public function trySaveMap(mapData:MapData, deltaTime:int):void {
        this.cooldown -= deltaTime;
        if (this.cooldown <= 0) {
            this.reset();

            mapData.save(true, true); // Wmap is faster so save with that
        }
    }
}
}
