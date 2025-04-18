package core.states.gameStates {
import core.hud.components.ButtonExpandableHud;
import core.scene.Game;
import core.scene.SceneBase;

import data.Settings;

import generics.Localize;

import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;

public class SettingsState extends PlayState {
    public function SettingsState(g:Game, goTo:String = "") {
        super(g);
        this.goTo = goTo;
        this.settings = SceneBase.settings;
        bg = new Image(textureManager.getTextureGUIByTextureName("map_bgr.png"));
        generalButton = new ButtonExpandableHud(function ():void {
            show(SettingsGeneral, generalButton);
        }, "General");
        bindingsButton = new ButtonExpandableHud(function ():void {
            show(SettingsBindings, bindingsButton);
        }, "Key bindings");
        chatButton = new ButtonExpandableHud(function ():void {
            show(SettingsChat, chatButton);
        }, "Chat");
        closeButton = new ButtonExpandableHud(close, Localize.t("close"));
    }
    private var goTo:String;
    private var settings:Settings;
    private var bg:Image;
    private var closeButton:ButtonExpandableHud;
    private var generalButton:ButtonExpandableHud;
    private var bindingsButton:ButtonExpandableHud;
    private var chatButton:ButtonExpandableHud;
    private var activeButton:ButtonExpandableHud;
    private var activePage:Sprite;

    override public function enter():void {
        super.enter();
        g.hud.show = false;
        drawBlackBackground();
        addChild(bg);
        g.addChildToMenu(generalButton);
        g.addChildToMenu(bindingsButton);
        g.addChildToMenu(chatButton);
        g.addChildToMenu(closeButton);
        resize();
        show(SettingsGeneral, generalButton);
    }

    override public function execute():void {
        updateInput();
        super.execute();
    }

    private function updateInput():void {
        if (!loaded) {
            return;
        }
        checkAccelerate(true);
        if (keybinds.isEscPressed || keybinds.isInputPressed(8)) {
            close();
        }
    }

    private function show(Page:Class, button:ButtonExpandableHud):void {
        if (activeButton == button) {
            activeButton.enabled = true;
            return;
        }
        if (activePage) {
            container.removeChild(activePage, true);
        }
        activePage = new Page(g);
        container.addChild(activePage);
        updateButtons(button);
    }

    private function updateButtons(button:ButtonExpandableHud):void {
        generalButton.select = button == generalButton;
        bindingsButton.select = button == bindingsButton;
        chatButton.select = button == chatButton;
        activeButton = button;
        activeButton.enabled = true;
    }

    private function close():void {
        g.removeChildFromMenu(generalButton);
        g.removeChildFromMenu(bindingsButton);
        g.removeChildFromMenu(chatButton);
        g.removeChildFromMenu(closeButton);
        if (activePage) {
            container.removeChild(activePage, true);
        }
        clearBackground();
        g.me.rotationSpeedMod = settings.rotationSpeed;
        SceneBase.settings.save();
        sm.revertState();
    }

    override public function resize(e:Event = null):void {
        super.resize();
        container.x = g.stage.stageWidth / 2 - bg.width / 2;
        container.y = g.stage.stageHeight / 2 - bg.height / 2;
        generalButton.x = container.x + 40;
        generalButton.y = container.y;
        bindingsButton.x = generalButton.x + generalButton.width + 5;
        bindingsButton.y = generalButton.y;
        chatButton.x = bindingsButton.x + bindingsButton.width + 5;
        chatButton.y = bindingsButton.y;
        closeButton.y = container.y;
        closeButton.x = container.x + 760 - 46 - closeButton.width;
    }
}
}

