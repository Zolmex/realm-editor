package editor.ui {
import editor.MEEvent;
import editor.METool;
import editor.ToolSwitchEvent;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;
import flash.utils.Dictionary;

public class MapInputHandler extends EventDispatcher {

    private var view:MainView;
    private var dragging:Boolean;
    private var mouseDown:Boolean;
    private var middleMouseDown:Boolean;

    public function MapInputHandler(view:MainView) {
        this.view = view;
        Main.STAGE.addEventListener(KeyboardEvent.KEY_UP, this.onKeyUp); // Keyboard events should be catched on the stage
        Main.STAGE.addEventListener(KeyboardEvent.KEY_DOWN, this.onKeyDown);
        view.mapViewContainer.addEventListener(MouseEvent.ROLL_OVER, this.onRollOver);
    }

    private function onRollOver(e:Event):void {
        this.view.mapViewContainer.addEventListener(MouseEvent.ROLL_OUT, this.onRollOut);
        this.view.mapViewContainer.addEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
        this.view.mapViewContainer.addEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
        this.view.mapViewContainer.addEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMoved);
        this.view.mapViewContainer.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, this.onMiddleMouseDown);
        this.view.mapViewContainer.addEventListener(MouseEvent.MIDDLE_MOUSE_UP, this.onMiddleMouseUp);
    }

    private function onRollOut(e:Event):void { // If the mouse has left the map view, stop listening for mouse events
        this.dragging = false;
        this.mouseDown = false;
        this.middleMouseDown = false;

        this.view.mapViewContainer.removeEventListener(MouseEvent.ROLL_OUT, this.onRollOut);
        this.view.mapViewContainer.removeEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
        this.view.mapViewContainer.removeEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
        this.view.mapViewContainer.removeEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMoved);
        this.view.mapViewContainer.removeEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, this.onMiddleMouseDown);
        this.view.mapViewContainer.removeEventListener(MouseEvent.MIDDLE_MOUSE_UP, this.onMiddleMouseUp);
        this.view.mapViewContainer.removeEventListener(MouseEvent.MOUSE_MOVE, this.onMouseDrag);
    }

    private function onMiddleMouseDown(e:MouseEvent):void {
        this.dragging = false;
        this.middleMouseDown = true;
        this.view.mapViewContainer.addEventListener(MouseEvent.MOUSE_MOVE, this.onMouseDrag);
    }

    private function onMiddleMouseUp(e:MouseEvent):void {
        this.middleMouseDown = false;
        this.view.mapViewContainer.removeEventListener(MouseEvent.MOUSE_MOVE, this.onMouseDrag);
        if (this.dragging) {
            this.dispatchEvent(new Event(MEEvent.MIDDLE_MOUSE_DRAG_END));
        }
    }

    private function onMouseDrag(e:MouseEvent):void {
        this.dragging = true;

        var event:String;
        if (this.mouseDown) {
            event = MEEvent.MOUSE_DRAG;
        }
        else if (this.middleMouseDown) {
            event = MEEvent.MIDDLE_MOUSE_DRAG;
        }
        this.dispatchEvent(new Event(event));
    }

    private function onMouseDown(e:MouseEvent):void {
        this.dragging = false;
        this.mouseDown = true;
        this.view.mapViewContainer.addEventListener(MouseEvent.MOUSE_MOVE, this.onMouseDrag); // Only detect map movements when the mouse is down
    }

    private function onMouseUp(e:MouseEvent):void {
        this.mouseDown = false;
        this.view.mapViewContainer.removeEventListener(MouseEvent.MOUSE_MOVE, this.onMouseDrag);
        if (!this.dragging) {
            this.dispatchEvent(new Event(MEEvent.TILE_CLICK));
        } else {
            this.dragging = false;
            this.dispatchEvent(new Event(MEEvent.MOUSE_DRAG_END));
        }
    }

    private function onMouseMoved(e:MouseEvent):void {
        this.dispatchEvent(new Event(MouseEvent.MOUSE_MOVE));
    }

    private function onKeyDown(e:KeyboardEvent):void {
        var dict:Dictionary;
        if (e.ctrlKey) {
            dict = Keybinds.HELD_CTRL_KEYS;
        } else {
            dict = Keybinds.HELD_KEYS;
        }
        var eventStr:String = dict[e.keyCode];
        if (eventStr == null) {
            return;
        }
        this.dispatchEvent(new Event(eventStr));
    }

    private function onKeyUp(e:KeyboardEvent):void {
        var dict:Dictionary;
        if (e.ctrlKey) { // Love it or hate it, it's simple and it works
            dict = Keybinds.CTRL_KEYS;
        } else if (e.shiftKey) {
            dict = Keybinds.SHIFT_KEYS;
        } else if (e.altKey) {
            dict = Keybinds.ALT_KEYS;
        } else {
            dict = Keybinds.KEYS;
        }
        var eventStr:String = dict[e.keyCode];
        if (eventStr == null) {
            return;
        }
        var evt:Event;
        if (eventStr.indexOf(MEEvent.TOOL_SWITCH) != -1) {
            evt = new ToolSwitchEvent(MEEvent.TOOL_SWITCH, METool.ToolEventToId(eventStr))
        } else {
            evt = new Event(eventStr);
        }
        this.dispatchEvent(evt);
    }
}
}
