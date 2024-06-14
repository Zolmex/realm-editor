package editor {

public class MEBrush {

    public var drawType:int;
    public var brushType:int;
    public var groundType:int = -1;
    public var objType:int = 0;
    public var regType:int = 0;
    public var size:int = 0;

    public function MEBrush(drawType:int, brushType:int) {
        this.drawType = drawType;
        this.brushType = brushType;
    }

    public function setGroundType(groundType:int):void{
        this.groundType = groundType;
    }

    public function setObjectType(objType:int):void{
        this.objType = objType;
    }

    public function setRegionType(regType:int):void{
        this.regType = regType;
    }
}
}
