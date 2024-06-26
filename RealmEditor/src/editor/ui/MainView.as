package editor.ui {
import assets.AssetLoader;
import assets.DynamicAssetLoader;
import assets.embed.Background;
import assets.ground.GroundLibrary;
import assets.objects.ObjectLibrary;
import assets.regions.RegionLibrary;

import editor.MEBrush;
import editor.MEClipboard;
import editor.MEDrawType;

import editor.MEEvent;
import editor.actions.MapEditAction;
import editor.actions.MapSelectAction;
import editor.actions.data.MapSelectData;
import editor.tools.MESelectTool;
import editor.tools.METool;
import editor.tools.METool;
import editor.actions.MapAction;
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
    private var nextMapId:int;

    private var background:Background;
    private var exitButton:SimpleTextButton;
    private var assetsButton:SimpleTextButton;
    private var loadButton:SimpleTextButton;
    private var newButton:SimpleTextButton;
    private var saveButton:SimpleTextButton;
    private var saveWmapButton:SimpleTextButton;
    private var mapCreateWindow:MapCreateWindow;
    private var assetsWindow:AssetsWindow;

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

    public var userBrush:MEBrush;
    public var selectedTool:METool;
    private var lastMousePos:Point;
    private var clipBoard:MEClipboard;
    private var timeControl:TimeControl; // Controls actions done/undone in each map

    public function MainView() {
        this.userBrush = new MEBrush(MEDrawType.GROUND, 0);
        this.clipBoard = new MEClipboard();
        this.timeControl = new TimeControl();
        this.selectedTool = new MESelectTool(this);

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

        this.exitButton = new SimpleTextButton("Exit");
        this.exitButton.addEventListener(MouseEvent.CLICK, onExitClick);
        addChild(this.exitButton);

        this.assetsButton = new SimpleTextButton("Assets");
        this.assetsButton.addEventListener(MouseEvent.CLICK, this.onAssetsClick);
        addChild(this.assetsButton);

        this.loadButton = new SimpleTextButton("Load");
        this.loadButton.addEventListener(MouseEvent.CLICK, this.onLoadClick);
        addChild(this.loadButton);

        this.newButton = new SimpleTextButton("New");
        this.newButton.addEventListener(MouseEvent.CLICK, this.onNewClick);
        addChild(this.newButton);

        this.saveButton = new SimpleTextButton("Save JSON");
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

        this.notifications = new NotificationView();
        addChild(this.notifications);

        Main.STAGE.addEventListener(MouseEvent.MOUSE_WHEEL, this.onMouseWheel);
        Main.STAGE.addEventListener(Event.RESIZE, this.onStageResize);
        this.updateScale();
        this.updatePositions();

        this.showAssetLoaderNotifs();
    }

    private function setupInput():void {
        this.inputHandler = new MapInputHandler(this);
        this.inputHandler.addEventListener(MEEvent.GRID_ENABLE, this.onGridEnable);
        this.inputHandler.addEventListener(MEEvent.TILE_CLICK, this.onTileClick);
        this.inputHandler.addEventListener(MEEvent.MOUSE_DRAG, this.onMouseDrag);
        this.inputHandler.addEventListener(MEEvent.MOUSE_DRAG_END, this.onMouseDragEnd);
        this.inputHandler.addEventListener(MEEvent.MIDDLE_MOUSE_DRAG, this.onMiddleMouseDrag);
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

    public function updatePositions():void {
        this.notifications.updatePosition();

        this.exitButton.x = Main.StageWidth - this.exitButton.width - 15;
        this.exitButton.y = 15;

        this.assetsButton.x = this.exitButton.x - this.assetsButton.width - 10;
        this.assetsButton.y = this.exitButton.y;

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

        if (this.assetsWindow != null && this.assetsWindow.visible) {
            this.assetsWindow.x = (Main.StageWidth - this.assetsWindow.width) / 2;
            this.assetsWindow.y = (Main.StageHeight - this.assetsWindow.height) / 2;
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

        if (e.ctrlKey && (this.selectedTool.id == METool.PENCIL_ID || this.selectedTool.id == METool.ERASER_ID)) { // We're increasing/decreasing the brush size
            this.userBrush.size += int(Math.ceil(e.delta));
            if (this.userBrush.size < 0) {
                this.userBrush.size = 0;
            }

            this.onBrushSizeChanged();
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

    private function onAssetsClick(e:Event):void {
        if (this.assetsWindow == null) {
            this.assetsWindow = new AssetsWindow(); // Window where user selects assets directory
            this.assetsWindow.x = (Main.StageWidth - this.assetsWindow.width) / 2;
            this.assetsWindow.y = (Main.StageHeight - this.assetsWindow.height) / 2;
            this.assetsWindow.addEventListener(MEEvent.ASSETS_DIR_SELECT, this.onAssetsDirectorySelected); // Dispatched when user clicks OK
            addChild(this.assetsWindow);
        } else {
            this.assetsWindow.resetOriginal();
            this.assetsWindow.visible = true;
        }
        this.updatePositions();
    }

    private function onAssetsDirectorySelected(e:Event):void {
        DynamicAssetLoader.load(); // Reload asset library

        if (DynamicAssetLoader.PendingNotifs != null) {
            this.showAssetLoaderNotifs();
        } else {
            this.notifications.showNotification("Successfully loaded asset files!");
        }

        this.drawElementsList.resetFilters();
        this.drawElementsList.setContent(this.userBrush.elementType);
    }

    private function onLoadClick(e:Event):void {
        var newData:MapData = new MapData();
        var newMap:MapView = new MapView(this.nextMapId, newData);
        this.nextMapId++;

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
            this.mapCreateWindow.addEventListener(MEEvent.MAP_CREATE, this.onMapCreate); // Dispatched when user clicks OK
            addChild(this.mapCreateWindow);
        } else {
            this.mapCreateWindow.visible = true;
        }
        this.updatePositions();
    }

    private function onMapCreate(e:Event):void {
        var newData:MapData = new MapData();
        var newMap:MapView = new MapView(this.nextMapId, newData);
        this.nextMapId++;

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
        this.timeControl.eraseHistory(e.mapId);

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
            this.notifications.showNotification("Map saved in JSON format!");
        }
    }

    private function onSaveWmapClick(e:Event):void {
        if (this.mapData != null) {
            this.mapData.save(true);
            this.notifications.showNotification("Map saved in WMap format!");
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
        this.timeControl.createHistory(this.mapView.id);
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

        this.selectedTool.mouseDrag(tilePos, this.timeControl.getHistory(this.mapView.id));
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
        var tilePos:IntPoint = getMouseTilePosition();
        if (tilePos == null) {
            return;
        }

        this.selectedTool.mouseDragEnd(tilePos, this.timeControl.getHistory(this.mapView.id));
    }

    private function onMiddleMouseDragEnd(e:Event):void {
        this.lastMousePos = null;
    }

    private function onTileClick(e:Event):void { // Perform select/draw/erase actions here
        var tilePos:IntPoint = getMouseTilePosition();
        if (tilePos == null) {
            return;
        }

        this.selectedTool.tileClick(tilePos, this.timeControl.getHistory(this.mapView.id));
    }

    public function showEditNameView(x:int, y:int, objName:String):void {
        if (this.editNameView == null) {
            this.editNameView = new EditTileNameView(x, y, objName);
            this.editNameView.x = (Main.StageWidth - this.editNameView.width) / 2;
            this.editNameView.y = (Main.StageHeight - this.editNameView.height) / 2;
            this.editNameView.addEventListener(MEEvent.EDIT_OBJ_NAME, this.onEditName);
            addChild(this.editNameView);
        } else {
            this.editNameView.showNew(x, y, objName);
        }
        this.updatePositions();
    }

    private function onEditName(e:Event):void {
        var mapX:int = this.editNameView.tileX;
        var mapY:int = this.editNameView.tileY;
        var history:MapHistory = this.timeControl.getHistory(this.mapView.id);
        var prevData:MapTileData = this.mapView.tileMap.getTileData(mapX, mapY);
        if (prevData.objType == 0){
            return;
        }

        history.record(new MapEditAction(mapX, mapY, prevData.objCfg, this.editNameView.objName));
        this.mapView.editTileObjCfg(mapX, mapY, this.editNameView.objName);
    }

    private function onMouseMoved(e:Event):void {
        var tilePos:IntPoint = getMouseTilePosition();
        if (tilePos == null) {
            this.tileInfoPanel.visible = false;
            return;
        }

        this.updateTileInfoPanel(tilePos);

        this.mapView.highlightTile(-1, -1);
        this.mapView.hideBrushTiles();
        this.selectedTool.mouseMoved(tilePos, this.timeControl.getHistory(this.mapView.id));
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
        if (this.mapView == null) {
            return null;
        }

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
        if (e.toolId == this.selectedTool.id){
            return;
        }

        this.setSelectedTool(e.toolId);
        this.toolBar.setSelected(e.toolId);
    }

    public function setSelectedTool(toolId:int):void {
        this.lastMousePos = null;

        this.selectedTool.reset(); // Reset tool data
        this.selectedTool = METool.GetTool(toolId, this);

        if (this.mapView == null){
            return;
        }

        if (toolId != METool.SELECT_ID) { // Clear highlighted tile
            this.mapView.highlightTile(-1, -1);
        }

        var tilePos:IntPoint = getMouseTilePosition();
        if (tilePos == null) {
            return;
        }

        this.mapView.hideBrushTiles();
        this.selectedTool.init(tilePos, this.timeControl.getHistory(this.mapView.id));
    }

    private function onUndoAction(e:Event):void {
        if (this.mapView == null){
            return;
        }

        this.timeControl.undoLastAction(this.mapView.id); // Undo last action done in the current map
        this.notifications.showNotification("Undone", 18, 1);
    }

    private function onRedoAction(e:Event):void {
        if (this.mapView == null){
            return;
        }

        this.timeControl.redoLastUndoneAction(this.mapView.id); // Redo last undone action in the current map
        this.notifications.showNotification("Redone", 18, 1);
    }

    private function onDrawTypeSwitch(e:Event):void {
        this.userBrush.elementType = this.drawTypeSwitch.selected;

        this.drawElementsList.resetFilters();
        this.drawElementsList.setContent(this.userBrush.elementType);
        this.updateDrawElements();
    }

    public function updateDrawElements():void {
        switch (this.userBrush.elementType) {
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
        switch (this.userBrush.elementType) {
            case MEDrawType.GROUND:
                this.userBrush.setGroundType(elementType);
                break;
            case MEDrawType.OBJECTS:
                this.userBrush.setObjectType(elementType);
                break;
            case MEDrawType.REGIONS:
                this.userBrush.setRegionType(elementType);
                break;
        }

        var tilePos:IntPoint = getMouseTilePosition();
        if (tilePos == null) {
            return;
        }

        this.mapView.drawBrushTiles(tilePos.x_, tilePos.y_, this.userBrush);
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

        this.mapView.pasteFromClipboard(this.clipBoard, tilePos.x_, tilePos.y_, this.timeControl.getHistory(this.mapView.id));
    }

    private function onClearSelection(e:Event):void {
        if (this.selectedTool.id == METool.SELECT_ID){
            this.selectedTool.reset();
        }

        var history:MapHistory = this.timeControl.getHistory(this.mapView.id);
        this.mapView.recordSelectionClear(history);
        this.mapView.clearTileSelection();
    }

    private function onMoveSelectionUp(e:Event):void {
        var selectTool:MESelectTool = METool.GetTool(METool.SELECT_ID, this) as MESelectTool;
        selectTool.dragSelection(0, -1, this.timeControl.getHistory(this.mapView.id));
    }

    private function onMoveSelectionDown(e:Event):void {
        var selectTool:MESelectTool = METool.GetTool(METool.SELECT_ID, this) as MESelectTool;
        selectTool.dragSelection(0, 1, this.timeControl.getHistory(this.mapView.id));
    }

    private function onMoveSelectionLeft(e:Event):void {
        var selectTool:MESelectTool = METool.GetTool(METool.SELECT_ID, this) as MESelectTool;
        selectTool.dragSelection(-1, 0, this.timeControl.getHistory(this.mapView.id));
    }

    private function onMoveSelectionRight(e:Event):void {
        var selectTool:MESelectTool = METool.GetTool(METool.SELECT_ID, this) as MESelectTool;
        selectTool.dragSelection(1, 0, this.timeControl.getHistory(this.mapView.id));
    }

    private function onBrushSizeChanged():void {
        var tilePos:IntPoint = getMouseTilePosition();
        if (tilePos == null) {
            return;
        }

        this.mapView.drawBrushTiles(tilePos.x_, tilePos.y_, this.userBrush);
    }

    private function showAssetLoaderNotifs():void {
        if (DynamicAssetLoader.PendingNotifs != null){
            var messages:Array = DynamicAssetLoader.PendingNotifs.split("|");
            for each (var message:String in messages){
                if (message == null || message == ""){
                    continue;
                }
                this.notifications.showNotification(message, 14, 5);
            }
        }
    }
}
}
