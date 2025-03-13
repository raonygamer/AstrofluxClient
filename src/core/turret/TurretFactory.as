package core.turret {
	import core.boss.Boss;
	import core.scene.Game;
	import core.ship.ShipFactory;
	import core.weapon.Weapon;
	import core.weapon.WeaponFactory;
	import data.DataLocator;
	import data.IDataManager;
	import generics.Util;
	
	public class TurretFactory {
		public function TurretFactory() {
			super();
		}
		
		public static function createTurret(obj:Object, key:String, g:Game, b:Boss = null) : Turret {
			var _local8:Number = NaN;
			var _local5:Weapon = null;
			var _local9:IDataManager = DataLocator.getService();
			var _local7:Object = _local9.loadKey("Turrets",key);
			var _local6:Turret = g.turretManager.getTurret();
			if(_local7.aimArc == 6 * 60) {
				_local6.aimArc = 3.141592653589793 * 2;
			} else {
				_local6.aimArc = Util.degreesToRadians(_local7.aimArc);
			}
			_local6.aimSkill = _local7.aimSkill;
			_local6.rotationSpeed = _local7.rotationSpeed;
			_local6.name = _local7.name;
			_local6.xp = _local7.xp;
			_local6.level = _local7.level;
			_local6.isHostile = true;
			if(obj.hasOwnProperty("AIFaction1") && obj.AIFaction1 != "") {
				_local6.factions.push(obj.AIFaction1);
			}
			if(obj.hasOwnProperty("AIFaction2") && obj.AIFaction2 != "") {
				_local6.factions.push(obj.AIFaction2);
			}
			_local6.forcedRotation = _local7.forcedRotation;
			if(_local6.forcedRotation) {
				_local6.forcedRotationSpeed = _local7.forcedRotationSpeed;
				_local6.forcedRotationAim = _local7.forcedRotationAim;
			}
			ShipFactory.createBody(_local7.body,g,_local6);
			if(g.isSystemTypeSurvival() && b != null) {
				_local6.level = b.level;
			}
			if(g.isSystemTypeSurvival() && _local6.level < g.hud.uberStats.uberLevel) {
				_local8 = g.hud.uberStats.CalculateUberRankFromLevel(_local6.level);
				_local6.uberDifficulty = g.hud.uberStats.CalculateUberDifficultyFromRank(g.hud.uberStats.uberRank - _local8,_local6.level);
				_local6.uberLevelFactor = 1 + (g.hud.uberStats.uberLevel - _local6.level) / 100;
				if(b != null) {
					_local6.uberDifficulty *= g.hud.uberStats.uberRank / 2 + 1;
				}
				_local6.xp *= _local6.uberLevelFactor;
				_local6.level = g.hud.uberStats.uberLevel;
				_local6.hp = _local6.hpMax = _local6.hpMax * _local6.uberDifficulty;
				_local6.shieldHp = _local6.shieldHpMax = _local6.shieldHpMax * _local6.uberDifficulty;
			}
			_local6.pos.x = 1000000;
			_local6.pos.y = 1000000;
			if(_local7.hasOwnProperty("weapon")) {
				_local5 = WeaponFactory.create(_local7.weapon,g,_local6,0);
				_local6.weapon = _local5;
			}
			return _local6;
		}
	}
}

