package core.states.gameStates {
import core.hud.components.SettingsKeybind;
import core.hud.components.Text;
import core.scene.Game;
import core.scene.SceneBase;

import data.KeyBinds;

import feathers.controls.ScrollContainer;

import generics.Localize;

import starling.display.Sprite;
import starling.events.Event;

public class SettingsBindings extends Sprite {
    public function SettingsBindings(g:Game) {
        super();
        this.g = g;
        this.keybinds = SceneBase.settings.keybinds;
        scrollArea = new ScrollContainer();
        scrollArea.y = 50;
        scrollArea.x = 10;
        scrollArea.width = 700;
        scrollArea.height = 500;
        initComponents();
        addChild(scrollArea);
        g.stage.addEventListener("updateButtons", updateButtons);
    }
    private var g:Game;
    private var keybinds:KeyBinds;
    private var currentHeight:Number = 0;
    private var scrollArea:ScrollContainer;
    private var keybindList:Vector.<SettingsKeybind> = new Vector.<SettingsKeybind>();

    private function initComponents():void {
        var _loc1_:Text = new Text();
        _loc1_.htmlText = Localize.t("Movements:");
        _loc1_.size = 16;
        _loc1_.y = currentHeight;
        var currentWidth:Number = 50;
        _loc1_.x = currentWidth;
        scrollArea.addChild(_loc1_);
        currentHeight += 40;
        addKeybind(11);
        addKeybind(26);
        addKeybind(12);
        addKeybind(13);
        addKeybind(14);
        _loc1_ = new Text();
        _loc1_.htmlText = Localize.t("Abilities:");
        _loc1_.size = 16;
        _loc1_.y = currentHeight;
        _loc1_.x = currentWidth;
        scrollArea.addChild(_loc1_);
        currentHeight += 40;
        addKeybind(16);
        addKeybind(15);
        addKeybind(18);
        addKeybind(17);
        _loc1_ = new Text();
        _loc1_.htmlText = Localize.t("Weapons");
        _loc1_.size = 16;
        _loc1_.y = currentHeight;
        _loc1_.x = currentWidth;
        scrollArea.addChild(_loc1_);
        currentHeight += 40;
        addKeybind(19);
        addKeybind(20);
        addKeybind(21);
        addKeybind(22);
        addKeybind(23);
        addKeybind(24);
        _loc1_ = new Text();
        _loc1_.htmlText = Localize.t("Misc:");
        _loc1_.size = 16;
        _loc1_.y = currentHeight;
        _loc1_.x = currentWidth;
        scrollArea.addChild(_loc1_);
        currentHeight += 40;
        addKeybind(10);
        addKeybind(9);
        addKeybind(2);
        addKeybind(1);
        addKeybind(3);
        addKeybind(7);
        addKeybind(25);
        addKeybind(6);
        addKeybind(4);
        addKeybind(5);
        addKeybind(8);
        addKeybind(0);
    }

    private function addKeybind(type:int):void {
        var currentWidth:Number = 50;
        var _loc2_:SettingsKeybind = new SettingsKeybind(keybinds, type, currentWidth, currentHeight);
        keybindList.push(_loc2_);
        scrollArea.addChild(_loc2_);
        currentHeight += 62;
    }

    public function updateButtons(e:Event):void {
        for each(var _loc2_ in keybindList) {
            _loc2_.update();
        }
    }
}
}

