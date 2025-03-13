package core.weapon {
	import core.scene.Game;
	import core.unit.Unit;
	import data.*;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class WeaponFactory {
		public function WeaponFactory() {
			super();
		}
		
		public static function create(key:String, g:Game, s:Unit, techLevel:int, eliteTechLevel:int = -1, eliteTech:String = "") : Weapon {
			var _local7:Weapon = null;
			var _local10:Object = null;
			var _local8:ITextureManager = TextureLocator.getService();
			var _local11:IDataManager = DataLocator.getService();
			var _local9:Object = _local11.loadKey("Weapons",key);
			if(!g.isLeaving) {
				_local7 = g.weaponManager.getWeapon(_local9.type);
				_local7.init(_local9,techLevel,eliteTechLevel,eliteTech);
				_local7.key = key;
				_local7.unit = s;
				if(_local9.hasOwnProperty("fireEffect")) {
					_local7.fireEffect = _local9.fireEffect;
				} else {
					_local7.fireEffect = "";
				}
				if(_local9.hasOwnProperty("useShipSystem")) {
					_local7.useShipSystem = _local9.useShipSystem;
				} else {
					_local7.useShipSystem = false;
				}
				if(_local9.hasOwnProperty("randomAngle")) {
					_local7.randomAngle = _local9.randomAngle;
				} else {
					_local7.randomAngle = false;
				}
				if(_local9.hasOwnProperty("fireBackwards")) {
					_local7.fireBackwards = _local9.fireBackwards;
				} else {
					_local7.fireBackwards = false;
				}
				if(_local9.hasOwnProperty("isMissileWeapon") || _local7 is Beam) {
					_local7.isMissileWeapon = _local9.isMissileWeapon;
				} else {
					_local7.isMissileWeapon = false;
				}
				if(_local9.hasOwnProperty("hasChargeUp")) {
					_local7.hasChargeUp = _local9.hasChargeUp;
				} else {
					_local7.hasChargeUp = false;
				}
				if(_local9.hasOwnProperty("specialCondition") && _local9.specialCondition != "") {
					_local7.specialCondition = _local9.specialCondition;
					if(_local9.hasOwnProperty("specialBonusPercentage")) {
						_local7.specialBonusPercentage = _local9.specialBonusPercentage;
					} else {
						_local7.specialBonusPercentage = 0;
					}
				}
				if(_local9.hasOwnProperty("maxChargeDuration")) {
					_local7.chargeUpTimeMax = _local9.maxChargeDuration;
				} else {
					_local7.chargeUpTimeMax = 750;
				}
				if(techLevel > 0) {
					_local10 = _local9.techLevels[techLevel - 1];
					_local7.projectileFunction = _local9.projectile == null ? "" : _local10.projectile;
				} else {
					_local7.projectileFunction = _local9.projectile == null ? "" : _local9.projectile;
				}
				_local7.alive = true;
			}
			return _local7;
		}
	}
}

