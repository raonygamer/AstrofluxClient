package core.hud.components.hotkeys {
import core.hud.components.ToolTip;
import core.scene.Game;
import core.scene.SceneBase;
import core.ship.PlayerShip;

import data.DataLocator;
import data.IDataManager;
import data.KeyBinds;

import debug.Console;

import generics.Localize;

import starling.display.Sprite;
import starling.textures.Texture;

import textures.ITextureManager;
import textures.TextureLocator;

public class Abilities extends Sprite {
    public function Abilities(g:Game) {
        super();
        this.g = g;
        dataManager = DataLocator.getService();
        textureManager = TextureLocator.getService();
    }
    private var hotkeys:Vector.<AbilityHotkey> = new Vector.<AbilityHotkey>();
    private var g:Game;
    private var dataManager:IDataManager;
    private var textureManager:ITextureManager;

    public function load():void {
        var _loc3_:Object = null;
        var _loc9_:String = null;
        var _loc1_:Boolean = false;
        var _loc11_:Function = null;
        var _loc4_:String = null;
        var _loc10_:int = 0;
        var _loc5_:Object = null;
        var _loc6_:AbilityHotkey = null;
        var keyBinds:data.KeyBinds = SceneBase.settings.keybinds;
        var _loc7_:PlayerShip = g.me.ship;
        if (_loc7_ == null) {
            Console.write("No ship for weapon hotkeys.");
            return;
        }
        var _loc8_:int = 0;
        for each(var _loc2_ in g.me.techSkills) {
            if (_loc2_.tech == "m4yG1IRPIUeyRQHrC3h5kQ" || _loc2_.tech == "QgKEEj8a-0yzYAJ06eSLqA" || _loc2_.tech == "rSr1sn-_oUOY6E0hpAhh0Q" || _loc2_.tech == "kwlCdExeJk-oEJZopIz5kg") {
                _loc3_ = dataManager.loadKey(_loc2_.table, _loc2_.tech);
                _loc9_ = "";
                _loc1_ = false;
                _loc11_ = null;
                _loc4_ = "";
                _loc10_ = 0;
                if (_loc3_.name == "Engine") {
                    _loc11_ = g.commandManager.addBoostCommand;
                    _loc9_ = "E";
                    _loc1_ = _loc7_.hasBoost;
                    if (_loc7_.artifact_cooldownReduction > 0.4) {
                        _loc10_ = _loc7_.boostCD * 0.6;
                    } else {
                        _loc10_ = _loc7_.boostCD * (1 - _loc7_.artifact_cooldownReduction);
                    }
                    _loc4_ = Localize.t("Boost your engine with <FONT COLOR=\'#ffffff\'>[boostBonus]%</FONT> over <FONT COLOR=\'#ffffff\'>[duration]</FONT> seconds.").replace("[boostBonus]", _loc7_.boostBonus).replace("[duration]", _loc7_.boostDuration / 1000);
                } else if (_loc3_.name == "Shield") {
                    _loc11_ = g.commandManager.addHardenedShieldCommand;
                    _loc9_ = "Q";
                    _loc1_ = _loc7_.hasHardenedShield;
                    if (_loc7_.artifact_cooldownReduction > 0.4) {
                        _loc10_ = _loc7_.hardenCD * 0.6;
                    } else {
                        _loc10_ = _loc7_.hardenCD * (1 - _loc7_.artifact_cooldownReduction);
                    }
                    _loc4_ = Localize.t("Creates a hardened shield that protects you from all damage over <FONT COLOR=\'#ffffff\'>[duration]</FONT> seconds.").replace("[duration]", _loc7_.hardenDuration / 1000);
                } else if (_loc3_.name == "Armor") {
                    _loc11_ = g.commandManager.addShieldConvertCommand;
                    _loc9_ = "F";
                    _loc1_ = _loc7_.hasArmorConverter;
                    if (_loc7_.artifact_cooldownReduction > 0.4) {
                        _loc10_ = _loc7_.convCD * 0.6;
                    } else {
                        _loc10_ = _loc7_.convCD * (1 - _loc7_.artifact_cooldownReduction);
                    }
                    _loc4_ = Localize.t("Use <FONT COLOR=\'#ffffff\'>[convCost]%</FONT> of your shield energy to repair ship with <FONT COLOR=\'#ffffff\'>[convGain]%</FONT> of the energy consumed.").replace("[convCost]", _loc7_.convCost).replace("[convGain]", _loc7_.convGain);
                } else if (_loc3_.name == "Power") {
                    _loc11_ = g.commandManager.addDmgBoostCommand;
                    _loc9_ = "R";
                    _loc1_ = _loc7_.hasDmgBoost;
                    if (_loc7_.artifact_cooldownReduction > 0.4) {
                        _loc10_ = _loc7_.dmgBoostCD * 0.6;
                    } else {
                        _loc10_ = _loc7_.dmgBoostCD * (1 - _loc7_.artifact_cooldownReduction);
                    }
                    _loc4_ = Localize.t("Damage is increased by <FONT COLOR=\'#ffffff\'>[damage]%</FONT> but power consumtion is increased by <FONT COLOR=\'#ffffff\'>[cost]%</FONT> over <FONT COLOR=\'#ffffff\'>[duration]</FONT> seconds.").replace("[damage]", _loc7_.dmgBoostBonus * 100).replace("[cost]", _loc7_.dmgBoostCost * 100).replace("[duration]", _loc7_.dmgBoostDuration / 1000);
                }
                _loc5_ = dataManager.loadKey("Images", _loc3_.techIcon);
                _loc6_ = new AbilityHotkey(_loc11_, textureManager.getTextureGUIByTextureName(_loc5_.textureName), textureManager.getTextureGUIByTextureName(_loc5_.textureName + "_inactive"), textureManager.getTextureGUIByTextureName(_loc5_.textureName + "_cooldown"), _loc9_);
                _loc6_.cooldownTime = _loc10_;
                _loc6_.obj = _loc3_;
                _loc6_.y = 50 * _loc8_;
                _loc6_.visible = _loc1_;
                hotkeys.push(_loc6_);
                new ToolTip(g, _loc6_, _loc4_, null, "abilities");
                addChild(_loc6_);
                _loc8_++;
            }
        }
    }

    public function update():void {
        for each(var _loc1_ in hotkeys) {
            _loc1_.update();
        }
    }

    public function initiateCooldown(name:String):void {
        for each(var _loc2_ in hotkeys) {
            if (_loc2_.obj.name == name) {
                _loc2_.initiateCooldown();
            }
        }
    }

    public function refresh():void {
        for each(var _loc1_ in hotkeys) {
            removeChild(_loc1_);
            ToolTip.disposeType("abiltites");
        }
        hotkeys.splice(0, hotkeys.length);
        load();
    }

    private function createHotkey(obj:Object, visible:Boolean, command:Function, level:int, caption:String, toolTip:String, i:int):Function {
        return function (param1:Texture):void {
        };
    }
}
}

