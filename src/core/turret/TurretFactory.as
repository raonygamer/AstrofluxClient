package core.turret
{
	import core.boss.Boss;
	import core.scene.Game;
	import core.ship.ShipFactory;
	import core.weapon.Weapon;
	import core.weapon.WeaponFactory;
	import data.DataLocator;
	import data.IDataManager;
	import generics.Util;
	
	public class TurretFactory
	{
		public function TurretFactory()
		{
			super();
		}
		
		public static function createTurret(obj:Object, key:String, g:Game, b:Boss = null) : Turret
		{
			var _loc6_:Number = NaN;
			var _loc7_:Weapon = null;
			var _loc8_:IDataManager = DataLocator.getService();
			var _loc9_:Object = _loc8_.loadKey("Turrets",key);
			var _loc5_:Turret = g.turretManager.getTurret();
			if(_loc9_.aimArc == 6 * 60)
			{
				_loc5_.aimArc = 3.141592653589793 * 2;
			}
			else
			{
				_loc5_.aimArc = Util.degreesToRadians(_loc9_.aimArc);
			}
			_loc5_.aimSkill = _loc9_.aimSkill;
			_loc5_.rotationSpeed = _loc9_.rotationSpeed;
			_loc5_.name = _loc9_.name;
			_loc5_.xp = _loc9_.xp;
			_loc5_.level = _loc9_.level;
			_loc5_.isHostile = true;
			if(obj.hasOwnProperty("AIFaction1") && obj.AIFaction1 != "")
			{
				_loc5_.factions.push(obj.AIFaction1);
			}
			if(obj.hasOwnProperty("AIFaction2") && obj.AIFaction2 != "")
			{
				_loc5_.factions.push(obj.AIFaction2);
			}
			_loc5_.forcedRotation = _loc9_.forcedRotation;
			if(_loc5_.forcedRotation)
			{
				_loc5_.forcedRotationSpeed = _loc9_.forcedRotationSpeed;
				_loc5_.forcedRotationAim = _loc9_.forcedRotationAim;
			}
			ShipFactory.createBody(_loc9_.body,g,_loc5_);
			if(g.isSystemTypeSurvival() && b != null)
			{
				_loc5_.level = b.level;
			}
			if(g.isSystemTypeSurvival() && _loc5_.level < g.hud.uberStats.uberLevel)
			{
				_loc6_ = g.hud.uberStats.CalculateUberRankFromLevel(_loc5_.level);
				_loc5_.uberDifficulty = g.hud.uberStats.CalculateUberDifficultyFromRank(g.hud.uberStats.uberRank - _loc6_,_loc5_.level);
				_loc5_.uberLevelFactor = 1 + (g.hud.uberStats.uberLevel - _loc5_.level) / 100;
				if(b != null)
				{
					_loc5_.uberDifficulty *= g.hud.uberStats.uberRank / 2 + 1;
				}
				_loc5_.xp *= _loc5_.uberLevelFactor;
				_loc5_.level = g.hud.uberStats.uberLevel;
				_loc5_.hp = _loc5_.hpMax = _loc5_.hpMax * _loc5_.uberDifficulty;
				_loc5_.shieldHp = _loc5_.shieldHpMax = _loc5_.shieldHpMax * _loc5_.uberDifficulty;
			}
			_loc5_.pos.x = 1000000;
			_loc5_.pos.y = 1000000;
			if(_loc9_.hasOwnProperty("weapon"))
			{
				_loc7_ = WeaponFactory.create(_loc9_.weapon,g,_loc5_,0);
				_loc5_.weapon = _loc7_;
			}
			return _loc5_;
		}
	}
}

