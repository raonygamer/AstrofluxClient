package core.hud.components.hotkeys {
import core.hud.components.ToolTip;
import core.player.Player;
import core.scene.Game;
import core.ship.PlayerShip;
import core.weapon.Beam;
import core.weapon.Weapon;

import data.DataLocator;

import debug.Console;

import starling.display.DisplayObjectContainer;

import textures.ITextureManager;
import textures.TextureLocator;

public class WeaponHotkeys extends DisplayObjectContainer {
    public function WeaponHotkeys(g:Game) {
        super();
        this.g = g;
        textureManager = TextureLocator.getService();
        hotkeys = new Vector.<WeaponHotkey>();
    }
    public var selectedHotkey:WeaponHotkey;
    private var g:Game;
    private var hotkeys:Vector.<WeaponHotkey>;
    private var player:Player;
    private var textureManager:ITextureManager;

    public function load():void {
        var _loc3_:Object = null;
        var _loc2_:WeaponHotkey = null;
        var ship:core.ship.PlayerShip = g.me.ship;
        player = g.me;
        if (ship == null) {
            Console.write("No ship for weapon hotkeys.");
            return;
        }
        if (ship.weapons.length == 0) {
            Console.write("No weapons for hotkeys");
            return;
        }
        for each(var _loc1_ in ship.weapons) {
            if (_loc1_.active) {
                _loc3_ = DataLocator.getService().loadKey("Images", _loc1_.techIconFileName);
                _loc2_ = new WeaponHotkey(clickedHotkey, textureManager.getTextureGUIByTextureName(_loc3_.textureName), textureManager.getTextureGUIByTextureName(_loc3_.textureName + "_inactive"), _loc1_.hotkey);
                hotkeys.push(_loc2_);
                addChild(_loc2_);
                _loc1_.fireCallback = _loc2_.initiateCooldown;
                new ToolTip(g, _loc2_, createWeaponToolTip(_loc1_), null, "WeaponHotkeys", 5 * 60);
                _loc2_.cooldownTime = _loc1_.reloadTime;
                _loc2_.x = 17 + (_loc1_.hotkey - 1) * 50;
                _loc2_.y = 22;
            }
        }
        highlightWeapon(ship.weapons[player.selectedWeaponIndex].hotkey);
    }

    public function reloadWeapon():void {
    }

    public function highlightWeapon(i:int):void {
        for each(var _loc2_ in hotkeys) {
            if (_loc2_.key == i) {
                selectedHotkey = _loc2_;
                _loc2_.active = true;
            } else {
                _loc2_.active = false;
            }
        }
    }

    public function update():void {
        for each(var _loc1_ in hotkeys) {
            _loc1_.update();
        }
    }

    public function refresh():void {
        ToolTip.disposeType("WeaponHotkeys");
        for each(var _loc1_ in hotkeys) {
            removeChild(_loc1_, true);
        }
        hotkeys.length = 0;
        load();
    }

    private function createWeaponToolTip(w:Weapon):String {
        return w.getDescription(w is Beam);
    }

    private function clickedHotkey(hotkey:WeaponHotkey):void {
        player.sendChangeWeapon(hotkey.key);
        selectedHotkey = hotkey;
    }
}
}

