package realmeditor.editor.ui {
import assets.GroundLibrary;
import assets.ObjectLibrary;
import assets.RegionLibrary;

import editor.MEDrawType;
import editor.ui.elements.IDrawElementFilter;

import realmeditor.assets.GroundLibrary;
import realmeditor.assets.ObjectLibrary;
import realmeditor.assets.RegionLibrary;
import realmeditor.editor.MEDrawType;

import realmeditor.editor.ui.elements.IDrawElementFilter;

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
