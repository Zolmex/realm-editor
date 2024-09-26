package editor.ui {
import assets.AssetLoader;
import assets.DynamicAssetLoader;
import assets.embed.Background;
import assets.ground.GroundLibrary;
import assets.objects.ObjectLibrary;
import assets.regions.RegionLibrary;

import editor.AutoMapSaver;

import editor.MEBrush;
import editor.MEClipboard;
import editor.MEDrawType;

import editor.MEEvent;
import editor.MapHistory;
import editor.TimeControl;
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
import editor.ui.elements.ResizeAnchor;
import editor.ui.elements.SimpleCheckBox;
import editor.ui.elements.SimpleTextInput;

import flash.desktop.NativeApplication;

import flash.display.Graphics;
import flash.display.NativeWindow;
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
import flash.utils.getTimer;

import util.IntPoint;

public class MainView extends Sprite {

    private static const MAX_ZOOM:Number = 1000.0;

    private var mapSelector:MapSelectorView;
    public var mapViewContainer:MapViewContainer;
    public var mapView:MapView;
    private var mapData:MapData;
    private var nextMapId:int;

    private var background:Background;
    private var assetsButton:SimpleTextButton;
    private var loadButton:SimpleTextButton;
    private var newButton:SimpleTextButton;
    private var saveButton:SimpleTextButton;
    private var saveWmapButton:SimpleTextButton;
    private var mapCreateWindow:CreateMapWindow;
    private var assetsWindow:AssetsWindow;
    private var closePrompt:ClosePromptWindow;
    private var resizeAnchor:ResizeAnchor;

    public var inputHandler:MapInputHandler;
    public var notifications:NotificationView;
    private var brushInput:SimpleTextInput;
    private var zoomInput:SimpleTextInput;
    private var toolBoxBackground:Sprite;
    private var tileInfoPanel:TileInfoPanel;
    private var gridCheckbox:SimpleCheckBox;
    private var autoSaveCheckbox:SimpleCheckBox;
    private var drawTypeSwitch:MultiOptionalSwitch;
    private var editNameView:EditTileNameView;
    private var objectFilterView:ObjectFilterOptionsView;
    private var debugView:DebugView;

    private var drawElementsList:MapDrawElementListView;
    private var toolBar:MapToolbar;

    public var userBrush:MEBrush;
    public var selectedTool:METool;
    private var lastMousePos:Point;
    private var clipBoard:MEClipboard;
    public var timeControl:TimeControl; // Controls actions done/undone in each map

    private var lastUpdate:int;
    private var autoSaver:AutoMapSaver;
    private var window:NativeWindow;

    public function MainView() {
        this.userBrush = new MEBrush(MEDrawType.GROUND, 0);
        this.clipBoard = new MEClipboard();
        this.timeControl = new TimeControl();
        this.selectedTool = new MESelectTool(this);
        this.autoSaver = new AutoMapSaver();
        this.window = Main.STAGE.nativeWindow;

        this.background = new Background();
        addChild(this.background);

        this.mapViewContainer = new MapViewContainer();
        this.mapViewContainer.addChild(this.background);
        addChild(this.mapViewContainer);

        this.setupInput();

        this.toolBoxBackground = new Sprite();
        this.toolBoxBackground.filters = Constants.SHADOW_FILTER_1;
        this.toolBoxBackground.x = 15;
        addChild(this.toolBoxBackground);

        this.zoomInput = new SimpleTextInput("Zoom", false, "100", 16, 0xFFFFFF, 14, 0xEAEAEA, true, 74);
        this.zoomInput.inputText.restrict = "0-9";
        this.zoomInput.inputText.maxChars = 3;
        this.zoomInput.inputText.addEventListener(Event.CHANGE, this.onZoomInputChange);
        this.zoomInput.x = this.zoomInput.y = 3;
        this.toolBoxBackground.addChild(this.zoomInput);

        this.drawTypeSwitch = new MultiOptionalSwitch(74);
        this.drawTypeSwitch.addOption("Ground");
        this.drawTypeSwitch.addOption("Objects");
        this.drawTypeSwitch.addOption("Regions");
        this.drawTypeSwitch.addEventListener(MEEvent.OPTION_SWITCH, this.onDrawTypeSwitch);
        this.drawTypeSwitch.x = 3;
        this.drawTypeSwitch.y = this.zoomInput.y + this.zoomInput.height + 3;
        this.toolBoxBackground.addChild(this.drawTypeSwitch);

        var g:Graphics = this.toolBoxBackground.graphics;
        g.beginFill(Constants.BACK_COLOR_2, 0.8);
        g.drawRoundRect(0, 0,
                80, // Add here all of the things that are supposed to go inside of the toolbox
                127,
                10, 10);
        g.endFill();

        this.tileInfoPanel = new TileInfoPanel();
        this.tileInfoPanel.visible = false;
        addChild(this.tileInfoPanel);

        this.drawElementsList = new MapDrawElementListView();
        this.drawElementsList.setContent(MEDrawType.GROUND);
        this.drawElementsList.addEventListener(Event.SELECT, this.onDrawElementSelected);
        this.drawElementsList.y = 45;
        addChild(this.drawElementsList);

        this.toolBar = new MapToolbar(this);
        addChild(this.toolBar);

        this.assetsButton = new SimpleTextButton("Import assets..", 14);
        this.assetsButton.setBold(true);
        this.assetsButton.setAlpha(0.8);
        this.assetsButton.hideBackground();
        this.assetsButton.addEventListener(MouseEvent.CLICK, this.onAssetsClick);
        this.assetsButton.x = 5;
        addChild(this.assetsButton);

        this.loadButton = new SimpleTextButton("Open", 14);
        this.loadButton.setBold(true);
        this.loadButton.setAlpha(0.8)
        this.loadButton.hideBackground();
        this.loadButton.addEventListener(MouseEvent.CLICK, this.onLoadClick);
        this.loadButton.x = 5;
        addChild(this.loadButton);

        this.newButton = new SimpleTextButton("New", 14);
        this.newButton.setBold(true);
        this.newButton.setAlpha(0.8)
        this.newButton.hideBackground();
        this.newButton.addEventListener(MouseEvent.CLICK, this.onNewClick);
        this.newButton.x = 5;
        addChild(this.newButton);

        this.saveButton = new SimpleTextButton("Save .jm", 14);
        this.saveButton.setBold(true);
        this.saveButton.setAlpha(0.8);
        this.saveButton.hideBackground();
        this.saveButton.addEventListener(MouseEvent.CLICK, this.onSaveClick);
        this.saveButton.x = 5;
        addChild(this.saveButton);

        this.saveWmapButton = new SimpleTextButton("Save .wmap", 14);
        this.saveWmapButton.setBold(true);
        this.saveWmapButton.setAlpha(0.8);
        this.saveWmapButton.hideBackground();
        this.saveWmapButton.addEventListener(MouseEvent.CLICK, this.onSaveWmapClick);
        this.saveWmapButton.x = 5;
        addChild(this.saveWmapButton);

        this.mapSelector = new MapSelectorView();
        this.mapSelector.alpha = 0.8;
        this.mapSelector.addEventListener(MEEvent.MAP_SELECT, this.onMapSelected);
        this.mapSelector.addEventListener(MEEvent.MAP_CLOSED, this.onMapClosed);
        this.mapSelector.addEventListener(MouseEvent.MOUSE_OVER, this.onTaskbarHover);
        this.mapSelector.addEventListener(MouseEvent.MOUSE_DOWN, this.onTaskbarClick);
        addChild(this.mapSelector);

        this.gridCheckbox = new SimpleCheckBox("Grid", false);
        this.gridCheckbox.visible = false;
        this.gridCheckbox.addEventListener(Event.CHANGE, this.onGridClick);
        addChild(this.gridCheckbox);

        this.autoSaveCheckbox = new SimpleCheckBox("Autosave", true);
        this.autoSaveCheckbox.visible = false;
        this.autoSaveCheckbox.addEventListener(Event.CHANGE, this.onAutoSaveClick);
        addChild(this.autoSaveCheckbox);

        this.objectFilterView = new ObjectFilterOptionsView(this.drawElementsList);
        addChild(this.objectFilterView);

        this.notifications = new NotificationView();
        this.notifications.y = 40;
        addChild(this.notifications);

        this.resizeAnchor = new ResizeAnchor();
        this.resizeAnchor.alpha = 0.4;
        this.resizeAnchor.addEventListener(MouseEvent.MOUSE_OVER, this.onAnchorOver);
        this.resizeAnchor.addEventListener(MouseEvent.MOUSE_DOWN, this.onGrabAnchor);
        addChild(this.resizeAnchor);

        Main.STAGE.addEventListener(Event.ENTER_FRAME, this.update);
        Main.STAGE.addEventListener(Event.RESIZE, this.onStageResize);
        Main.STAGE.addEventListener(MouseEvent.MOUSE_UP, onReleaseAnchor);
        Main.STAGE.addEventListener(MouseEvent.MOUSE_WHEEL, this.onMouseWheel);
        this.window.addEventListener(Event.CLOSING, this.onExiting);

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
        this.inputHandler.addEventListener(MEEvent.TOGGLE_DEBUG, this.onToggleDebug);
    }

    private function updateScale():void {
        this.background.scaleX = Main.ScaleX;
        this.background.scaleY = Main.ScaleY;
    }

    public function updateNotifPosition():void {
        this.notifications.x = Main.StageWidth / 2 - this.notifications.width / 2;
        this.notifications.y = 60 - this.notifications.height / 2;
    }

    public function updatePositions():void {
        this.mapSelector.updatePosition();

        this.notifications.x = Main.StageWidth / 2 - this.notifications.width / 2;

        this.assetsButton.y = Main.StageHeight - this.assetsButton.height - 5;
        this.saveWmapButton.y = this.assetsButton.y - this.saveWmapButton.height + 2;
        this.saveButton.y = this.saveWmapButton.y - this.saveButton.height + 2;
        this.loadButton.y = this.saveButton.y - this.loadButton.height + 2;
        this.newButton.y = this.loadButton.y - this.newButton.height + 2;

        this.toolBoxBackground.y = (Main.StageHeight - this.toolBoxBackground.height) / 2;

        this.gridCheckbox.x = Main.StageWidth - 115;
        this.autoSaveCheckbox.x = this.gridCheckbox.x - this.autoSaveCheckbox.width - 2;

        this.drawElementsList.x = Main.StageWidth - MapDrawElementListView.WIDTH - 15;

        this.tileInfoPanel.x = this.drawElementsList.x - this.tileInfoPanel.width - 15;
        this.tileInfoPanel.y = Main.StageHeight - this.tileInfoPanel.height - 15;

        this.toolBar.x = this.drawElementsList.x - this.toolBar.width - 8;
        this.toolBar.y = (Main.StageHeight - this.toolBar.height) / 2;

        this.objectFilterView.x = this.drawElementsList.x - 20;
        this.objectFilterView.y = this.drawElementsList.y;

        this.resizeAnchor.x = Main.StageWidth - this.resizeAnchor.width - 5;
        this.resizeAnchor.y = Main.StageHeight - this.resizeAnchor.height - 5;

        if (this.mapView) {
            this.mapView.x = (Main.StageWidth - (this.mapData.mapWidth * TileMapView.TILE_SIZE) * this.mapView.scaleX) / 2;
            this.mapView.y = (Main.StageHeight - (this.mapData.mapHeight * TileMapView.TILE_SIZE) * this.mapView.scaleY) / 2;
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

        if (this.debugView != null && this.debugView.visible){
            this.debugView.x = 10;
            this.debugView.y = 35;
        }

        if (this.closePrompt != null && this.closePrompt.visible){
            this.closePrompt.x = (Main.StageWidth - this.closePrompt.width) / 2;
            this.closePrompt.y = (Main.StageHeight - this.closePrompt.height) / 2;
        }
    }

    public function toggleOptions():void {
        this.autoSaveCheckbox.visible = !this.autoSaveCheckbox.visible;
        this.gridCheckbox.visible = !this.gridCheckbox.visible;
    }

    private function onMouseWheel(e:MouseEvent):void {
        if (this.mapView == null) {
            return;
        }

        if (e.ctrlKey && (this.selectedTool.id == METool.PENCIL_ID || this.selectedTool.id == METool.ERASER_ID)) { // We're increasing/decreasing the brush size
            var val:int = Math.min(Math.max(int(Math.ceil(e.delta)), -1), 1);
            this.userBrush.size += val;
            if (this.userBrush.size < 0) {
                this.userBrush.size = 0;
            }

            this.onBrushSizeChanged();
            return;
        }

        var zoomLevel:int = this.mapView.zoomLevel + (this.mapView.zoomLevel / e.delta + 1); // + 1 for divisions that result in less than 1
        zoomLevel = Math.max(1, Math.min(zoomLevel, MAX_ZOOM));

        if (this.mapView.zoomLevel != zoomLevel){
            this.mapView.zoomLevel = zoomLevel;
            var deltaX:Number = Main.StageWidth / 2 - Main.STAGE.mouseX; // Figure out how far from the middle the mouse is
            var deltaY:Number = Main.StageHeight / 2 - Main.STAGE.mouseY;
            if (e.delta < 0){ // Invert the order if we're zooming out
                deltaX *= -1;
                deltaY *= -1;
            }

            var zoom:Number = Math.max(1, Math.min(MAX_ZOOM, MAX_ZOOM / this.mapView.zoomLevel));
            this.mapView.mapOffset.x_ += deltaX * (zoom * 0.5);
            this.mapView.mapOffset.y_ += deltaY * (zoom * 0.5);

            this.updateZoomLevel();
        }
    }

    private function onStageResize(e:Event):void {
        this.updateScale();
        this.updatePositions();

        this.drawElementsList.onScreenResize();
    }

    private function update(e:Event):void { // Runs every frame
        var time:int = getTimer();
        var deltaTime:int = time - this.lastUpdate;
        this.lastUpdate = time;

        if (this.debugView != null && this.debugView.visible){
            this.debugView.updateStats(time, deltaTime);
        }

        if (this.mapData != null) {
            this.autoSaver.trySaveMap(this.mapData, deltaTime);
        }
    }

    private static function closeWindow():void {
        fscommand("quit"); // For Flash
        NativeApplication.nativeApplication.exit(); // For AIR
    }

    public function onExiting(e:Event = null):void {
        if (e != null)
            e.preventDefault();
        var unsavedChanges:Boolean = false;
        for each (var view:MapView in this.mapViewContainer.maps){ // Find out if we have unsaved changes
            if (!view.mapData.savedChanges){
                unsavedChanges = true;
                break;
            }
        }

        if (!unsavedChanges){
            onExit(null);
            return;
        }

        if (this.closePrompt == null) {
            this.closePrompt = new ClosePromptWindow();
            this.closePrompt.x = (Main.StageWidth - this.closePrompt.width) / 2;
            this.closePrompt.y = (Main.StageHeight - this.closePrompt.height) / 2;
            this.closePrompt.addEventListener(MEEvent.CLOSE_NO_SAVE, onExit);
            addChild(this.closePrompt);
        } else {
            this.closePrompt.visible = true;
        }
        this.updatePositions();
    }

    private static function onExit(e:Event):void {
        closeWindow();
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
            this.notifications.showNotification("<b>Assets have been loaded!</b>");
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
            this.mapCreateWindow = new CreateMapWindow(); // Window where user inputs name, width and height of the map
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
        this.mapViewContainer.trySaveMap(e.mapId);
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
            this.mapData.addEventListener(MEEvent.MAP_SAVED, this.onJsonSaved);
            this.mapData.save(false);
        }
    }

    private function onSaveWmapClick(e:Event):void {
        if (this.mapData != null) {
            this.mapData.addEventListener(MEEvent.MAP_SAVED, this.onWmapSaved);
            this.mapData.save(true);
        }
    }

    private function onJsonSaved(e:Event):void {
        this.mapData.removeEventListener(MEEvent.MAP_SAVED, this.onJsonSaved);
        this.notifications.showNotification("Map saved as a <b>.jm</b>");
    }

    private function onWmapSaved(e:Event):void {
        this.mapData.removeEventListener(MEEvent.MAP_SAVED, this.onWmapSaved);
        this.notifications.showNotification("Map saved as a <b>.wmap</b>");
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

        var mapId:int = this.mapViewContainer.addMapView(this.mapView);
        this.mapSelector.addMap(mapId, this.mapData.mapName, this.mapData.fileExt);
        this.mapSelector.selectMap(mapId);

        this.mapViewContainer.viewMap(mapId);
        this.timeControl.createHistory(this.mapView.id);
    }

    private function onGridClick(e:Event):void {
        if (this.mapView) {
            this.mapView.toggleGrid();
        }
    }

    private function onAutoSaveClick(e:Event):void {
        this.autoSaver.disabled = !this.autoSaver.disabled;
    }

    private function onGridEnable(e:Event):void {
        if (this.mapView) {
            var value:Boolean = this.mapView.toggleGrid();
            this.gridCheckbox.setValue(value);
        }
    }

    private function onZoomInputChange(e:Event):void {
        var zoomLevel:int = int(this.zoomInput.inputText.text);
        if (this.mapView.zoomLevel == zoomLevel){
            return;
        }

        this.mapView.zoomLevel = zoomLevel;
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
        if (this.mapView == null)
            return;

        this.selectedTool.mouseDrag(tilePos, this.timeControl.getHistory(this.mapView.id));
    }

    private function onMiddleMouseDrag(e:Event):void {
        if (this.lastMousePos == null) {
            this.lastMousePos = new Point(Main.STAGE.mouseX, Main.STAGE.mouseY);
        }

        this.dragMap();
    }

    private function dragMap():void {
        if (this.mapView == null)
            return;
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
        var tilePos:IntPoint = this.getMouseTilePosition();
        if (this.mapView == null)
            return;

        this.selectedTool.mouseDragEnd(tilePos, this.timeControl.getHistory(this.mapView.id));
    }

    private function onMiddleMouseDragEnd(e:Event):void {
        this.lastMousePos = null;
    }

    private function onTileClick(e:Event):void { // Perform select/draw/erase actions here
        var tilePos:IntPoint = this.getMouseTilePosition();
        if (this.mapView == null)
            return;

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
        var tilePos:IntPoint = this.getMouseTilePosition();
        if (this.mapView == null)
            return;

        if (tilePos == null) {
            this.tileInfoPanel.visible = false;
            return;
        }

        this.updateTileInfoPanel(tilePos);

        this.mapView.hideOverlays();

        this.selectedTool.mouseMoved(tilePos, this.timeControl.getHistory(this.mapView.id));
    }

    private function updateTileInfoPanel(tilePos:IntPoint):void {
        var tileData:MapTileData = this.mapView.tileMap.getTileData(tilePos.x_, tilePos.y_);
        if (tileData == null) {
            this.tileInfoPanel.visible = false;
            return;
        }

        this.tileInfoPanel.visible = true;
        this.tileInfoPanel.setInfo(tilePos.x_, tilePos.y_, tileData);
        this.updatePositions();
    }

    private function getMouseTilePosition():IntPoint { // Not to handle null value
        if (this.mapView == null)
            return null;

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

        var tilePos:IntPoint = this.getMouseTilePosition();
        if (this.mapView == null){
            return;
        }

        this.mapView.hideOverlays();
        this.selectedTool.init(tilePos, this.timeControl.getHistory(this.mapView.id));
    }

    private function onUndoAction(e:Event):void {
        if (this.mapView == null){
            return;
        }

        this.timeControl.undoLastAction(this.mapView.id); // Undo last action done in the current map
        this.notifications.showNotification("<b>Undo</b>", 18, 1);
    }

    private function onRedoAction(e:Event):void {
        if (this.mapView == null){
            return;
        }

        this.timeControl.redoLastUndoneAction(this.mapView.id); // Redo last undone action in the current map
        this.notifications.showNotification("<b>Redo</b>", 18, 1);
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

        var tilePos:IntPoint = this.getMouseTilePosition();
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

        var tilePos:IntPoint = this.getMouseTilePosition();
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
        if (this.mapView == null || this.selectedTool.id != METool.SELECT_ID){
            return;
        }

        var selectTool:MESelectTool = METool.GetTool(METool.SELECT_ID, this) as MESelectTool;
        selectTool.dragSelection(0, -1, this.timeControl.getHistory(this.mapView.id));
    }

    private function onMoveSelectionDown(e:Event):void {
        if (this.mapView == null || this.selectedTool.id != METool.SELECT_ID){
            return;
        }

        var selectTool:MESelectTool = METool.GetTool(METool.SELECT_ID, this) as MESelectTool;
        selectTool.dragSelection(0, 1, this.timeControl.getHistory(this.mapView.id));
    }

    private function onMoveSelectionLeft(e:Event):void {
        if (this.mapView == null || this.selectedTool.id != METool.SELECT_ID){
            return;
        }

        var selectTool:MESelectTool = METool.GetTool(METool.SELECT_ID, this) as MESelectTool;
        selectTool.dragSelection(-1, 0, this.timeControl.getHistory(this.mapView.id));
    }

    private function onMoveSelectionRight(e:Event):void {
        if (this.mapView == null || this.selectedTool.id != METool.SELECT_ID){
            return;
        }

        var selectTool:MESelectTool = METool.GetTool(METool.SELECT_ID, this) as MESelectTool;
        selectTool.dragSelection(1, 0, this.timeControl.getHistory(this.mapView.id));
    }

    private function onBrushSizeChanged():void {
        var tilePos:IntPoint = this.getMouseTilePosition();
        if (tilePos == null) {
            return;
        }

        if (this.selectedTool.id == METool.ERASER_ID){
            this.mapView.drawBrushOutline(tilePos.x_, tilePos.y_, this.userBrush);
        }
        else {
            this.mapView.drawBrushTiles(tilePos.x_, tilePos.y_, this.userBrush);
        }
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

    private function onToggleDebug(e:Event):void {
        if (this.debugView == null){
            this.debugView = new DebugView();
            addChild(this.debugView);
        }
        else {
            this.debugView.show(!this.debugView.visible);
        }

        this.updatePositions();
    }

    private function resize(event:MouseEvent):void {
        if (!this.resizeAnchor.isResizing)
            return;
        this.window.width = mouseX + 10;
        this.window.height = mouseY + 10;
    }

    private function onGrabAnchor(event:MouseEvent):void {
        this.resizeAnchor.isResizing = true;
        Main.STAGE.addEventListener(MouseEvent.MOUSE_MOVE, resize);
    }

    private function onReleaseAnchor(event:MouseEvent):void {
        this.resizeAnchor.isResizing = false;
        Main.STAGE.removeEventListener(MouseEvent.MOUSE_MOVE, resize);
    }

    private function onTaskbarHover(event:MouseEvent):void {
        this.mapSelector.addEventListener(MouseEvent.MOUSE_OUT, this.onTaskbarOut);
        this.mapSelector.removeEventListener(MouseEvent.MOUSE_OVER, this.onTaskbarHover);
        this.mapSelector.alpha = 1;
    }

    private function onTaskbarOut(event:MouseEvent):void {
        this.mapSelector.removeEventListener(MouseEvent.MOUSE_OUT, this.onTaskbarOut);
        this.mapSelector.addEventListener(MouseEvent.MOUSE_OVER, this.onTaskbarHover);
        this.mapSelector.alpha = 0.8;
    }

    private function onTaskbarClick(event:MouseEvent):void {
        this.mapSelector.addEventListener(MouseEvent.MOUSE_UP, onTaskbarRelease);
        this.window.startMove();
    }

    private function onTaskbarRelease(event:MouseEvent):void {
        this.mapSelector.removeEventListener(MouseEvent.MOUSE_UP, onTaskbarRelease);
    }

    private function onAnchorOver(e:Event):void {
        this.resizeAnchor.removeEventListener(MouseEvent.MOUSE_OVER, this.onAnchorOver);
        this.resizeAnchor.addEventListener(MouseEvent.MOUSE_OUT, this.onAnchorOut);
        this.resizeAnchor.alpha = 0.7;
    }

    private function onAnchorOut(e:Event):void {
        this.resizeAnchor.addEventListener(MouseEvent.MOUSE_OVER, this.onAnchorOver);
        this.resizeAnchor.removeEventListener(MouseEvent.MOUSE_OUT, this.onAnchorOut);
        this.resizeAnchor.alpha = 0.4;
    }
}
}
