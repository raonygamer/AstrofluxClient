package core.weapon {
import core.scene.Game;
import core.unit.Unit;

import data.*;

import textures.ITextureManager;
import textures.TextureLocator;

public class WeaponFactory {
    public static function create(key:String, g:Game, s:Unit, techLevel:int, eliteTechLevel:int = -1, eliteTech:String = ""):Weapon {
        var _loc8_:Weapon = null;
        var _loc11_:Object = null;
        var _loc9_:ITextureManager = TextureLocator.getService();
        var _loc10_:IDataManager = DataLocator.getService();
        var _loc7_:Object = _loc10_.loadKey("Weapons", key);
        if (!g.isLeaving) {
            _loc8_ = g.weaponManager.getWeapon(_loc7_.type);
            _loc8_.init(_loc7_, techLevel, eliteTechLevel, eliteTech);
            _loc8_.key = key;
            _loc8_.unit = s;
            if (_loc7_.hasOwnProperty("fireEffect")) {
                _loc8_.fireEffect = _loc7_.fireEffect;
            } else {
                _loc8_.fireEffect = "";
            }
            if (_loc7_.hasOwnProperty("useShipSystem")) {
                _loc8_.useShipSystem = _loc7_.useShipSystem;
            } else {
                _loc8_.useShipSystem = false;
            }
            if (_loc7_.hasOwnProperty("randomAngle")) {
                _loc8_.randomAngle = _loc7_.randomAngle;
            } else {
                _loc8_.randomAngle = false;
            }
            if (_loc7_.hasOwnProperty("fireBackwards")) {
                _loc8_.fireBackwards = _loc7_.fireBackwards;
            } else {
                _loc8_.fireBackwards = false;
            }
            if (_loc7_.hasOwnProperty("isMissileWeapon") || _loc8_ is Beam) {
                _loc8_.isMissileWeapon = _loc7_.isMissileWeapon;
            } else {
                _loc8_.isMissileWeapon = false;
            }
            if (_loc7_.hasOwnProperty("hasChargeUp")) {
                _loc8_.hasChargeUp = _loc7_.hasChargeUp;
            } else {
                _loc8_.hasChargeUp = false;
            }
            if (_loc7_.hasOwnProperty("specialCondition") && _loc7_.specialCondition != "") {
                _loc8_.specialCondition = _loc7_.specialCondition;
                if (_loc7_.hasOwnProperty("specialBonusPercentage")) {
                    _loc8_.specialBonusPercentage = _loc7_.specialBonusPercentage;
                } else {
                    _loc8_.specialBonusPercentage = 0;
                }
            }
            if (_loc7_.hasOwnProperty("maxChargeDuration")) {
                _loc8_.chargeUpTimeMax = _loc7_.maxChargeDuration;
            } else {
                _loc8_.chargeUpTimeMax = 750;
            }
            if (techLevel > 0) {
                _loc11_ = _loc7_.techLevels[techLevel - 1];
                _loc8_.projectileFunction = _loc7_.projectile == null ? "" : _loc11_.projectile;
            } else {
                _loc8_.projectileFunction = _loc7_.projectile == null ? "" : _loc7_.projectile;
            }
            _loc8_.alive = true;
        }
        return _loc8_;
    }

    public function WeaponFactory() {
        super();
    }
}
}

