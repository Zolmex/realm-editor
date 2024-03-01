package editor.ui.elements {

public interface IDrawElementFilter {
    function setDrawType(drawType:int):void;
    function filter(elementType:int):Boolean;
}
}
