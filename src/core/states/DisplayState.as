package core.states {
import core.hud.components.Button;
import core.scene.Game;
import core.states.menuStates.ArtifactState2;

import starling.display.DisplayObject;
import starling.display.Sprite;
import starling.events.TouchEvent;

import textures.ITextureManager;
import textures.TextureLocator;

public class DisplayState implements IDisplayState {
    public function DisplayState(g:Game, rootState:Class, isRoot:Boolean = false) {
        super();
        this.g = g;
        this.isRoot = isRoot;
        this.rootState = rootState;
        textureManager = TextureLocator.getService();
    }
    public var backButton:Button;
    protected var sm:DisplayStateMachine;
    protected var g:Game;
    protected var textureManager:ITextureManager;
    protected var container:Sprite;
    private var rootState:Class;
    private var isRoot:Boolean;
    private var parent:Sprite;

    public function set stateMachine(sm:DisplayStateMachine):void {
        this.sm = sm;
    }

    public function get type():String {
        return "DisplayState";
    }

    public function enter():void {
        g.messageLog.visible = false;
        parent = sm.parent;
        container = new Sprite();
        backButton = new Button(back, "Back");
        backButton.x = 45;
        backButton.y = 50;
        if (sm.inState(rootState) || isRoot || this is ArtifactState2) {
            backButton.visible = false;
        } else {
            backButton.visible = true;
        }
        parent.addChild(container);
        parent.addChild(backButton);
    }

    public function execute():void {
    }

    public function exit():void {
        container.removeChildren(0, container.numChildren, true);
        if (parent.contains(container)) {
            parent.removeChild(container, true);
        }
        if (parent.contains(backButton)) {
            parent.removeChild(backButton, true);
        }
        container = null;
        parent = null;
    }

    protected function addChild(child:DisplayObject):void {
        if (container != null) {
            container.addChild(child);
        }
    }

    protected function removeChild(child:DisplayObject, dispose:Boolean = false):void {
        if (container != null && container.contains(child)) {
            container.removeChild(child, dispose);
        }
    }

    private function back(e:TouchEvent):void {
        sm.revertState();
    }
}
}

