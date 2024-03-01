package editor.ui {
import assets.ground.GroundLibrary;
import assets.objects.ObjectLibrary;
import assets.regions.RegionLibrary;

import editor.MEDrawType;
import editor.ui.elements.IDrawElementFilter;

public class DrawListSearchFilter implements IDrawElementFilter {

    private var drawType:int;
    private var searchText:String;
    private var matches:Vector.<int>;

    public function reset():void {
        this.searchText = null;
        this.matches = null;
    }

    public function setSearch(text:String):void {
        this.searchText = text;
        this.updateMatches();
    }

    public function setDrawType(drawType:int):void {
        this.drawType = drawType;
        this.updateMatches();
    }

    private function updateMatches():void {
        if (this.searchText == null || this.searchText == ""){
            this.matches = null; // If search is null, so are the matches
            return;
        }

        switch (this.drawType) {
            case MEDrawType.GROUND:
                this.matches = GroundLibrary.search(this.searchText);
                break;
            case MEDrawType.OBJECTS:
                this.matches = ObjectLibrary.search(this.searchText);
                break;
            case MEDrawType.REGIONS:
                this.matches = RegionLibrary.search(this.searchText);
                break;
        }
    }

    public function filter(elementType:int):Boolean {
        if (this.matches == null){
            return true;
        }

        return this.matches.indexOf(elementType) != -1;
    }
}
}
