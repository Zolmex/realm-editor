package editor.ui {
import assets.embed.Background;
import assets.ground.GroundLibrary;
import assets.objects.ObjectLibrary;
import assets.regions.RegionLibrary;

import editor.MEBrush;
import editor.MEClipboard;
import editor.MEDrawType;

import editor.MEEvent;
import editor.METool;
import editor.MapData;
import editor.MapTileData;
import editor.ToolSwitchEvent;
import editor.ui.MapDrawElementListView;
import editor.ui.elements.IDrawElementFilter;
import editor.ui.elements.MultiOptionalSwitch;
import editor.ui.elements.SimpleCheckBox;
import editor.ui.elements.SimpleTextInput;

import flash.desktop.NativeApplication;

import flash.display.Graphics;
import flash.display.Shape;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.Event;

import editor.ui.elements.SimpleTextButton;

import flash.events.KeyboardEvent;

import flash.events.MouseEvent;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Vector3D;
import flash.system.fscommand;
import flash.ui.Keyboard;
import flash.ui.Mouse;
import flash.utils.Dictionary;

import util.IntPoint;

public class MainView extends Sprite {

    private static const MAX_ZOOM:Number = 1000.0;

    private var mapSelector:MapSelectorView;
    public var mapViewContainer:MapViewContainer;
    public var mapView:MapView;
    private var mapData:MapData;

    private var background:Background;
    private var exitButton:SimpleTextButton;
    private var loadButton:SimpleTextButton;
    private var newButton:SimpleTextButton;
    private var saveButton:SimpleTextButton;
    private var saveWmapButton:SimpleTextButton;
    private var mapCreateWindow:MapCreateWindow;

    private var inputHandler:MapInputHandler;
    public var notifications:NotificationView;
    private var zoomInput:SimpleTextInput;
    private var toolBoxBackground:Shape;
    private var tileInfoPanel:TileInfoPanel;
    private var gridCheckbox:SimpleCheckBox;
    private var drawTypeSwitch:MultiOptionalSwitch;
    private var editNameView:EditTileNameView;
    private var objectFilterView:ObjectFilterOptionsView;

    private var drawElementsList:MapDrawElementListView;
    private var toolBar:MapToolbar;

    private var lastMousePos:Point;
    private var selectionStart:IntPoint;
    private var draggingSelection:Boolean;

    public var userBrush:MEBrush;
    public var selectedTool:int;

    private var clipBoard:MEClipboard;

    public function MainView() {
        this.userBrush = new MEBrush(MEDrawType.GROUND, 0);
        this.clipBoard = new MEClipboard();

        this.background = new Background();
        addChild(this.background);

        this.mapViewContainer = new MapViewContainer();
        addChild(this.mapViewContainer);

        this.setupInput();

        this.toolBoxBackground = new Shape();
        this.toolBoxBackground.filters = Constants.SHADOW_FILTER_1;
        addChild(this.toolBoxBackground);

        this.zoomInput = new SimpleTextInput("Zoom", false, "100", 18, 0xFFFFFF, 15, 0xEAEAEA, true);
        this.zoomInput.inputText.restrict = "0-9";
        this.zoomInput.inputText.maxChars = 3;
        this.zoomInput.inputText.addEventListener(Event.CHANGE, this.onZoomInputChange);
        addChild(this.zoomInput);

        this.gridCheckbox = new SimpleCheckBox("Grid", false);
        this.gridCheckbox.addEventListener(Event.CHANGE, this.onGridClick);
        addChild(this.gridCheckbox);

        this.drawTypeSwitch = new MultiOptionalSwitch();
        this.drawTypeSwitch.addOption("Ground");
        this.drawTypeSwitch.addOption("Objects");
        this.drawTypeSwitch.addOption("Regions");
        this.drawTypeSwitch.addEventListener(MEEvent.OPTION_SWITCH, this.onDrawTypeSwitch);
        addChild(this.drawTypeSwitch);

        var g:Graphics = this.toolBoxBackground.graphics;
        g.beginFill(Constants.BACK_COLOR_2, 0.8);
        g.drawRoundRect(0, 0,
                this.gridCheckbox.width + 15, // Add here all of the things that are supposed to go inside of the toolbox
                this.zoomInput.height + this.gridCheckbox.height + this.drawTypeSwitch.height + 25,
                10, 10);
        g.endFill();

        this.tileInfoPanel = new TileInfoPanel();
        this.tileInfoPanel.visible = false;
        addChild(this.tileInfoPanel);

        this.drawElementsList = new MapDrawElementListView();
        this.drawElementsList.setContent(MEDrawType.GROUND);
        this.drawElementsList.addEventListener(Event.SELECT, this.onDrawElementSelected);
        addChild(this.drawElementsList);

        this.toolBar = new MapToolbar(this);
        addChild(this.toolBar);

        this.notifications = new NotificationView();
        addChild(this.notifications);

        this.exitButton = new SimpleTextButton("Exit");
        this.exitButton.addEventListener(MouseEvent.CLICK, onExitClick);
        addChild(this.exitButton);

        this.loadButton = new SimpleTextButton("Load");
        this.loadButton.addEventListener(MouseEvent.CLICK, this.onLoadClick);
        addChild(this.loadButton);

        this.newButton = new SimpleTextButton("New");
        this.newButton.addEventListener(MouseEvent.CLICK, this.onNewClick);
        addChild(this.newButton);

        this.saveButton = new SimpleTextButton("Save");
        this.saveButton.addEventListener(MouseEvent.CLICK, this.onSaveClick);
        addChild(this.saveButton);

        this.saveWmapButton = new SimpleTextButton("Save Wmap");
        this.saveWmapButton.addEventListener(MouseEvent.CLICK, this.onSaveWmapClick);
        addChild(this.saveWmapButton);

        this.mapSelector = new MapSelectorView();
        this.mapSelector.addEventListener(MEEvent.MAP_SELECT, this.onMapSelected);
        this.mapSelector.addEventListener(MEEvent.MAP_CLOSED, this.onMapClosed);
        addChild(this.mapSelector);

        this.objectFilterView = new ObjectFilterOptionsView(this.drawElementsList);
        addChild(this.objectFilterView);

        Main.STAGE.addEventListener(MouseEvent.MOUSE_WHEEL, this.onMouseWheel);
        Main.STAGE.addEventListener(Event.RESIZE, this.onStageResize);
        this.updateScale();
        this.updatePositions();
    }

    private function setupInput():void {
        this.inputHandler = new MapInputHandler(this);
        this.inputHandler.addEventListener(MEEvent.GRID_ENABLE, this.onGridEnable);
        this.inputHandler.addEventListener(MEEvent.TILE_CLICK, this.onTileClick);
        this.inputHandler.addEventListener(MEEvent.MOUSE_DRAG, this.onMouseDrag);
        this.inputHandler.addEventListener(MEEvent.MIDDLE_MOUSE_DRAG, this.onMiddleMouseDrag);
        this.inputHandler.addEventListener(MEEvent.MOUSE_DRAG_END, this.onMouseDragEnd);
        this.inputHandler.addEventListener(MEEvent.MIDDLE_MOUSE_DRAG_END, this.onMiddleMouseDragEnd);
        this.inputHandler.addEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMoved);
        this.inputHandler.addEventListener(MEEvent.TOOL_SWITCH, this.onToolSwitch);
        this.inputHandler.addEventListener(MEEvent.UNDO, this.onUndoAction);
        this.inputHandler.addEventListener(MEEvent.REDO, this.onRedoAction);
        this.inputHandler.addEventListener(MEEvent.DRAW_TYPE_SWITCH, this.onDrawTypeSwitchKey);
        this.inputHandler.addEventListener(MEEvent.COPY, this.onCopy);
        this.inputHandler.addEventListener(MEEvent.PASTE, this.onPaste);
        this.inputHandler.addEventListener(MEEvent.CLEAR_SELECTION, this.onClearSelection);
        this.inputHandler.addEventListener(MEEvent.MOVE_SELECTION_UP, this.onMoveSelectionUp);
        this.inputHandler.addEventListener(MEEvent.MOVE_SELECTION_DOWN, this.onMoveSelectionDown);
        this.inputHandler.addEventListener(MEEvent.MOVE_SELECTION_LEFT, this.onMoveSelectionLeft);
        this.inputHandler.addEventListener(MEEvent.MOVE_SELECTION_RIGHT, this.onMoveSelectionRight);
    }

    private function updateScale():void {
        this.background.scaleX = Main.ScaleX;
        this.background.scaleY = Main.ScaleY;
    }

    private function updatePositions():void {
        this.exitButton.x = Main.StageWidth - this.exitButton.width - 15;
        this.exitButton.y = 15;

        this.loadButton.x = 15;
        this.loadButton.y = 15;

        this.newButton.x = this.loadButton.x + this.loadButton.width + 10;
        this.newButton.y = this.loadButton.y;

        this.saveButton.x = this.newButton.x + this.newButton.width + 10;
        this.saveButton.y = this.loadButton.y;

        this.saveWmapButton.x = this.saveButton.x + this.saveButton.width + 10;
        this.saveWmapButton.y = this.loadButton.y;

        this.mapSelector.x = this.loadButton.x;
        this.mapSelector.y = this.loadButton.y + this.loadButton.height + 10;

        this.toolBoxBackground.x = 15;
        this.toolBoxBackground.y = (Main.StageHeight - this.toolBoxBackground.height) / 2;

        this.zoomInput.x = this.toolBoxBackground.x + (this.toolBoxBackground.width - this.zoomInput.width) / 2;
        this.zoomInput.y = this.toolBoxBackground.y + 7.5;

        this.gridCheckbox.x = this.toolBoxBackground.x + (this.toolBoxBackground.width - this.gridCheckbox.width) / 2;
        this.gridCheckbox.y = this.zoomInput.y + this.zoomInput.height + 6;

        this.drawTypeSwitch.x = this.toolBoxBackground.x + (this.toolBoxBackground.width - this.drawTypeSwitch.width) / 2;
        this.drawTypeSwitch.y = this.gridCheckbox.y + this.gridCheckbox.height + 6;

        this.drawElementsList.x = Main.StageWidth - MapDrawElementListView.WIDTH - 15;
        this.drawElementsList.y = this.exitButton.y + this.exitButton.height + 15;

        this.tileInfoPanel.x = this.drawElementsList.x - this.tileInfoPanel.width - 15;
        this.tileInfoPanel.y = Main.StageHeight - this.tileInfoPanel.height - 15;

        this.toolBar.x = this.drawElementsList.x - this.toolBar.width - 8;
        this.toolBar.y = (Main.StageHeight - this.toolBar.height) / 2;

        this.objectFilterView.x = this.drawElementsList.x - 20;
        this.objectFilterView.y = this.drawElementsList.y;

        if (this.mapView) {
            this.mapView.x = (Main.StageWidth - this.mapView.width) / 2;
            this.mapView.y = (Main.StageHeight - this.mapView.height) / 2;
            this.mapView.x += this.mapView.mapOffset.x_ * this.mapView.zoomLevel / MAX_ZOOM;
            this.mapView.y += this.mapView.mapOffset.y_ * this.mapView.zoomLevel / MAX_ZOOM;
        }

        if (this.mapCreateWindow != null && this.mapCreateWindow.visible) {
            this.mapCreateWindow.x = (Main.StageWidth - this.mapCreateWindow.width) / 2;
            this.mapCreateWindow.y = (Main.StageHeight - this.mapCreateWindow.height) / 2;
        }

        if (this.editNameView != null && this.editNameView.visible) {
            this.editNameView.x = (Main.StageWidth - this.editNameView.width) / 2;
            this.editNameView.y = (Main.StageHeight - this.editNameView.height) / 2;
        }
    }

    private function onMouseWheel(e:MouseEvent):void {
        if (this.mapView == null) {
            return;
        }

        this.mapView.zoomLevel += this.mapView.zoomLevel / e.delta + 1; // + 1 for divisions that result in less than 1
        this.mapView.zoomLevel = Math.max(1, Math.min(this.mapView.zoomLevel, MAX_ZOOM));

        this.updateZoomLevel();
    }

    private function onStageResize(e:Event):void {
        this.updateScale();
        this.updatePositions();

        this.drawElementsList.onScreenResize();
    }

    private static function onExitClick(e:Event):void {
        fscommand("quit"); // For Flash
        NativeApplication.nativeApplication.exit(); // For AIR
    }

    private function onLoadClick(e:Event):void {
        var newData:MapData = new MapData();
        var newMap:MapView = new MapView(newData);
        this.mapView = newMap;
        this.mapData = newData;
        this.mapData.addEventListener(MEEvent.MAP_LOAD_BEGIN, this.onMapLoadBegin);
        this.mapData.addEventListener(MEEvent.MAP_LOAD_END, this.onMapLoadEnd);

        this.mapData.load(newMap.tileMap);
    }

    private function onNewClick(e:Event):void {
        if (this.mapCreateWindow == null) {
            this.mapCreateWindow = new MapCreateWindow(); // Window where user inputs name, width and height of the map
            this.mapCreateWindow.x = (Main.StageWidth - this.mapCreateWindow.width) / 2;
            this.mapCreateWindow.y = (Main.StageHeight - this.mapCreateWindow.height) / 2;
            this.mapCreateWindow.addEventListener(MEEvent.MAP_CREATE, this.onCreateMap); // Dispatched when user clicks OK
            addChild(this.mapCreateWindow);
        } else {
            this.mapCreateWindow.visible = true;
        }
    }

    private function onCreateMap(e:Event):void {
        var newData:MapData = new MapData();
        var newMap:MapView = new MapView(newData);
        this.mapView = newMap;
        this.mapData = newData;
        this.mapData.addEventListener(MEEvent.MAP_LOAD_BEGIN, this.onMapLoadBegin);
        this.mapData.addEventListener(MEEvent.MAP_LOAD_END, this.onMapLoadEnd);

        newData.newMap(newMap.tileMap, this.mapCreateWindow.mapName, this.mapCreateWindow.mapWidth, this.mapCreateWindow.mapHeight);
    }

    private function onMapSelected(e:Event):void {
        this.mapView = this.mapViewContainer.viewMap(this.mapSelector.selectedMap);
        this.mapData = this.mapView.mapData;

        this.updateZoomLevel();
        this.gridCheckbox.setValue(this.mapView.gridEnabled);
    }

    private function onMapClosed(e:MapClosedEvent):void {
        this.mapViewContainer.removeMapView(e.mapId);

        var nextId:int = this.mapSelector.selectedMap - 1 < 0 ? 0 : this.mapSelector.selectedMap - 1;
        this.mapSelector.selectMap(nextId);

        this.mapView = this.mapViewContainer.viewMap(nextId);

        if (this.mapView) {
            this.mapData = this.mapView.mapData;

            this.updateZoomLevel();
            this.gridCheckbox.setValue(this.mapView.gridEnabled);
        }
    }

    private function onSaveClick(e:Event):void {
        if (this.mapData != null) {
            this.mapData.save(false);
        }
    }

    private function onSaveWmapClick(e:Event):void {
        if (this.mapData != null) {
            this.mapData.save(true);
        }
    }

    private function onMapLoadBegin(e:Event):void {
        this.mapData.removeEventListener(MEEvent.MAP_LOAD_BEGIN, this.onMapLoadBegin);

        this.mapView.onMapLoadBegin();
        this.updatePositions();
    }

    private function onMapLoadEnd(e:Event):void {
        this.mapData.removeEventListener(MEEvent.MAP_LOAD_END, this.onMapLoadEnd);

        this.mapView.onMapLoadEnd();

        this.updateZoomLevel();

        var id:int = this.mapViewContainer.addMapView(this.mapView);
        this.mapSelector.addMap(id, this.mapData.mapName);
        this.mapSelector.selectMap(id);

        this.mapViewContainer.viewMap(id);
    }

    private function onGridClick(e:Event):void {
        if (this.mapView) {
            this.mapView.toggleGrid();
        }
    }

    private function onGridEnable(e:Event):void {
        if (this.mapView) {
            var value:Boolean = this.mapView.toggleGrid();
            this.gridCheckbox.setValue(value);
        }
    }

    private function onZoomInputChange(e:Event):void {
        this.mapView.zoomLevel = int(this.zoomInput.inputText.text);
        this.updateZoomLevel();
    }

    private function updateZoomLevel():void {
        this.zoomInput.inputText.setText(this.mapView.zoomLevel.toString());

        if (this.mapView) {
            this.mapView.scaleX = this.mapView.zoomLevel / 100;
            this.mapView.scaleY = this.mapView.zoomLevel / 100;
            if (this.mapView.scaleX < 0.01 || this.mapView.scaleY < 0.01) {
                this.mapView.scaleX = 0.01;
                this.mapView.scaleY = 0.01;
            }

            this.updatePositions();
        }
    }

    private function onMouseDrag(e:Event):void {
        var tilePos:IntPoint = getMouseTilePosition();
        if (tilePos == null) {
            return;
        }

        switch (this.selectedTool) {
            case METool.SELECT_ID:
                if (this.selectionStart == null) {
                    if (this.draggingSelection || this.mapView.isInsideSelection(tilePos.x_, tilePos.y_, true)) {
                        this.draggingSelection = true;
                        this.mapView.dragSelection(tilePos);
                        return;
                    }

                    if (!this.mapView.isInsideSelection(tilePos.x_, tilePos.y_, true)) {
                        this.draggingSelection = false;
                        this.selectionStart = null;
                        this.mapView.clearTileSelection();
                    }

                    this.selectionStart = tilePos;
                }

                this.mapView.selectTileArea(this.selectionStart.x_, this.selectionStart.y_, tilePos.x_, tilePos.y_);
                break;
            case METool.ERASER_ID:
            case METool.PENCIL_ID:
                this.mapView.useTool(this.selectedTool, tilePos.x_, tilePos.y_);
                break;
        }
    }

    private function onMiddleMouseDrag(e:Event):void {
        if (this.lastMousePos == null) {
            this.lastMousePos = new Point(Main.STAGE.mouseX, Main.STAGE.mouseY);
        }

        this.dragMap();
    }

    private function dragMap():void {
        var deltaX:Number = Main.STAGE.mouseX - this.lastMousePos.x;
        var deltaY:Number = Main.STAGE.mouseY - this.lastMousePos.y;
        var zoom:Number = Math.max(1, Math.min(MAX_ZOOM, MAX_ZOOM / this.mapView.zoomLevel));
        this.mapView.mapOffset.x_ += deltaX * zoom;
        this.mapView.mapOffset.y_ += deltaY * zoom;
        this.lastMousePos.x = Main.STAGE.mouseX;
        this.lastMousePos.y = Main.STAGE.mouseY;
        this.updatePositions();
    }

    private function onMouseDragEnd(e:Event):void {
        this.draggingSelection = false;
        this.mapView.lastDragPos = null;
        this.selectionStart = null;
    }

    private function onMiddleMouseDragEnd(e:Event):void {
        this.lastMousePos = null;
    }

    private function onTileClick(e:Event):void { // Perform select/draw/erase actions here
        var tilePos:IntPoint = getMouseTilePosition();
        if (tilePos == null) {
            return;
        }

        switch (this.selectedTool) {
            case METool.SELECT_ID:
                this.mapView.clearTileSelection();

                this.mapView.selectSingleTile(tilePos.x_, tilePos.y_);
                break;
            case METool.ERASER_ID:
            case METool.PENCIL_ID:
            case METool.BUCKET_ID:
                this.mapView.useTool(this.selectedTool, tilePos.x_, tilePos.y_);
                break;
            case METool.EDIT_ID:
                var tileData:MapTileData = this.mapData.getTile(tilePos.x_, tilePos.y_);
                if (tileData == null || tileData.objType == 0) {
                    return;
                }

                this.showEditNameView(tilePos.x_, tilePos.y_, tileData.objName);
                break;
            case METool.PICKER_ID:
                tileData = this.mapData.getTile(tilePos.x_, tilePos.y_);
                if (tileData == null) {
                    return;
                }

                if (tileData.groundType != -1) {
                    this.userBrush.groundType = tileData.groundType;
                }
                if (tileData.objType != 0) {
                    this.userBrush.objType = tileData.objType;
                }
                if (tileData.regType != 0) {
                    this.userBrush.regType = tileData.regType;
                }

                switch (this.userBrush.drawType) {
                    case MEDrawType.GROUND:
                        this.drawElementsList.setSelected(this.userBrush.groundType);
                        break;
                    case MEDrawType.OBJECTS:
                        this.drawElementsList.setSelected(this.userBrush.objType);
                        break;
                    case MEDrawType.REGIONS:
                        this.drawElementsList.setSelected(this.userBrush.regType);
                        break;
                }
                break;
        }
    }

    private function showEditNameView(x:int, y:int, objName:String):void {
        if (this.editNameView == null) {
            this.editNameView = new EditTileNameView(x, y, objName);
            this.editNameView.x = (Main.StageWidth - this.editNameView.width) / 2;
            this.editNameView.y = (Main.StageHeight - this.editNameView.height) / 2;
            this.editNameView.addEventListener(MEEvent.EDIT_OBJ_NAME, this.onEditName);
            addChild(this.editNameView);
        } else {
            this.editNameView.showNew(x, y, objName);
        }
    }

    private function onEditName(e:Event):void {
        this.mapView.editTileName(this.editNameView.tileX, this.editNameView.tileY, this.editNameView.objName);
    }

    private function onMouseMoved(e:Event):void {
        var tilePos:IntPoint = getMouseTilePosition();
        if (tilePos == null) {
            this.tileInfoPanel.visible = false;
            return;
        }

        this.updateTileInfoPanel(tilePos);

        this.mapView.highlightTile(-1, -1); // Clear the highlight in case we switched tools
        switch (this.selectedTool) {
            case METool.SELECT_ID:
                if (!this.mapView.isInsideSelection(tilePos.x_, tilePos.y_, true)) {
                    this.mapView.highlightTile(tilePos.x_, tilePos.y_);
                }
                break;
        }
    }

    private function updateTileInfoPanel(tilePos:IntPoint):void {
        var tileData:MapTileData = this.mapView.tileMap.getTileData(tilePos.x_, tilePos.y_);
        if (tileData == null || (tileData.groundType == -1 && tileData.objType == 0 && tileData.regType == 0)) {
            this.tileInfoPanel.visible = false;
            return;
        }

        this.tileInfoPanel.visible = true;
        this.tileInfoPanel.setInfo(tilePos.x_, tilePos.y_, tileData);
        this.updatePositions();
    }

    private function getMouseTilePosition():IntPoint {
        var mouseX:Number = Main.STAGE.mouseX;
        var mouseY:Number = Main.STAGE.mouseY;
        var x:int = (mouseX - this.mapView.x) / (TileMapView.TILE_SIZE * this.mapView.scaleX);
        var y:int = (mouseY - this.mapView.y) / (TileMapView.TILE_SIZE * this.mapView.scaleY);
        if (x < 0 || y < 0 || x >= this.mapData.mapWidth || y >= this.mapData.mapHeight) {
            return null;
        }
        return new IntPoint(x, y);
    }

    private function onToolSwitch(e:ToolSwitchEvent):void {
        this.setSelectedTool(e.toolId);
        this.toolBar.setSelected(e.toolId);
    }

    public function setSelectedTool(toolId:int):void {
        this.lastMousePos = null;
        this.selectionStart = null;

        this.selectedTool = toolId;
    }

    private function onUndoAction(e:Event):void {
        this.mapView.undo();
    }

    private function onRedoAction(e:Event):void {
        this.mapView.redo();
    }

    private function onDrawTypeSwitch(e:Event):void {
        this.userBrush.drawType = this.drawTypeSwitch.selected;

        this.drawElementsList.resetFilters();
        this.drawElementsList.setContent(this.userBrush.drawType);
        switch (this.userBrush.drawType) {
            case MEDrawType.GROUND:
                this.drawElementsList.setSelected(this.userBrush.groundType);
                break;
            case MEDrawType.OBJECTS:
                this.drawElementsList.setSelected(this.userBrush.objType);
                break;
            case MEDrawType.REGIONS:
                this.drawElementsList.setSelected(this.userBrush.regType);
                break;
        }
    }

    private function onDrawTypeSwitchKey(e:Event):void {
        this.drawTypeSwitch.selectNext(); // The switch will dispatch an OPTION_SWITCH event and we'll handle that
    }

    private function onDrawElementSelected(e:Event):void {
        var elementType:int = this.drawElementsList.selectedElement == null ? -1 : this.drawElementsList.selectedElement.elementType;
        switch (this.userBrush.drawType) {
            case MEDrawType.GROUND:
                this.userBrush.groundType = elementType;
                break;
            case MEDrawType.OBJECTS:
                this.userBrush.objType = elementType;
                break;
            case MEDrawType.REGIONS:
                this.userBrush.regType = elementType;
                break;
        }
    }

    private function onCopy(e:Event):void {
        if (this.mapView == null) {
            return;
        }

        this.clipBoard.clear();
        this.mapView.copySelectionToClipboard(this.clipBoard);
    }

    private function onPaste(e:Event):void {
        if (this.mapView == null) {
            return;
        }

        var tilePos:IntPoint = getMouseTilePosition();
        if (tilePos == null) {
            return;
        }

        this.mapView.pasteFromClipboard(this.clipBoard, tilePos.x_, tilePos.y_);
    }

    private function onClearSelection(e:Event):void {
        this.draggingSelection = false;
        this.selectionStart = null;
        this.mapView.clearTileSelection();
    }

    private function onMoveSelectionUp(e:Event):void {
        this.mapView.moveSelection(0, -1);
    }

    private function onMoveSelectionDown(e:Event):void {
        this.mapView.moveSelection(0, 1);
    }

    private function onMoveSelectionLeft(e:Event):void {
        this.mapView.moveSelection(-1, 0);
    }

    private function onMoveSelectionRight(e:Event):void {
        this.mapView.moveSelection(1, 0);
    }
}
}
