package core.ship {
	import core.engine.EngineFactory;
	import core.player.EliteTechs;
	import core.player.FleetObj;
	import core.player.Player;
	import core.player.TechSkill;
	import core.scene.Game;
	import core.turret.Turret;
	import core.unit.Unit;
	import core.weapon.Weapon;
	import core.weapon.WeaponFactory;
	import data.DataLocator;
	import data.IDataManager;
	import generics.Random;
	import sound.ISound;
	import sound.SoundLocator;
	import starling.filters.ColorMatrixFilter;
	
	public class ShipFactory {
		public function ShipFactory() {
			super();
		}
		
		public static function createPlayer(g:Game, player:Player, ship:PlayerShip, weapons:Array) : PlayerShip {
			var _local5:ColorMatrixFilter = null;
			var _local11:IDataManager = DataLocator.getService();
			var _local10:Object = _local11.loadKey("Skins",player.activeSkin);
			var _local7:FleetObj = player.getActiveFleetObj();
			ship.hideShadow = _local10.hideShadow;
			createBody(_local10.ship,g,ship);
			ship = PlayerShip(ship);
			ship.name = player.name;
			ship.setIsHostile(player.isHostile);
			ship.group = player.group;
			ship.factions = player.factions;
			ship.hpBase = ship.hpMax;
			ship.shieldHpBase = ship.shieldHpMax;
			ship.activeWeapons = 0;
			ship.unlockedWeaponSlots = player.unlockedWeaponSlots;
			ship.player = player;
			ship.aritfact_convAmount = 0;
			ship.aritfact_cooldownReduction = 0;
			ship.aritfact_speed = 0;
			ship.aritfact_poweReg = 0;
			ship.aritfact_powerMax = 0;
			ship.aritfact_refire = 0;
			var _local8:Number = !!_local7.shipHue ? _local7.shipHue : 0;
			var _local9:Number = !!_local7.shipBrightness ? _local7.shipBrightness : 0;
			if(_local8 != 0 || _local9 != 0) {
				_local5 = createPlayerShipColorMatrixFilter(_local7);
				ship.movieClip.filter = _local5;
				ship.originalFilter = _local5;
			}
			ship.engine = EngineFactory.create(_local10.engine,g,ship);
			var _local6:Number = !!_local7.engineHue ? _local7.engineHue : 0;
			addEngineTechToShip(player,ship);
			ship.engine.colorHue = _local6;
			CreatePlayerShipWeapon(g,player,0,weapons,ship);
			addArmorTechToShip(player,ship);
			addShieldTechToShip(player,ship);
			addPowerTechToShip(player,ship);
			addLevelBonusToShip(g,player.level,ship);
			ship.hp = ship.hpMax;
			ship.shieldHp = ship.shieldHpMax;
			return ship;
		}
		
		public static function createPlayerShipColorMatrixFilter(fleetObj:FleetObj) : ColorMatrixFilter {
			if(RymdenRunt.isBuggedFlashVersion) {
				return null;
			}
			var _local2:ColorMatrixFilter = new ColorMatrixFilter();
			var _local5:Number = !!fleetObj.shipHue ? fleetObj.shipHue : 0;
			var _local6:Number = !!fleetObj.shipBrightness ? fleetObj.shipBrightness : 0;
			var _local4:Number = !!fleetObj.shipSaturation ? fleetObj.shipSaturation : 0;
			var _local3:Number = !!fleetObj.shipContrast ? fleetObj.shipContrast : 0;
			_local2.resolution = 2;
			_local2.adjustHue(_local5);
			_local2.adjustBrightness(_local6);
			_local2.adjustSaturation(_local4);
			_local2.adjustContrast(_local3);
			return _local2;
		}
		
		public static function CreatePlayerShipWeapon(g:Game, player:Player, i:int, weapons:Array, ship:PlayerShip) : void {
			var _local8:int = 0;
			var _local10:TechSkill = null;
			var _local9:Weapon = null;
			var _local7:Object = weapons[i];
			var _local6:int = 0;
			var _local12:int = -1;
			var _local13:String = "";
			if(player != null && player.techSkills != null && _local7 != null) {
				_local8 = 0;
				while(_local8 < player.techSkills.length) {
					_local10 = player.techSkills[_local8];
					if(_local10.tech == _local7.weapon) {
						_local6 = _local10.level;
						_local12 = _local10.activeEliteTechLevel;
						_local13 = _local10.activeEliteTech;
					}
					_local8++;
				}
			}
			var _local11:Weapon = WeaponFactory.create(_local7.weapon,g,ship,_local6,_local12,_local13);
			_local11.setActive(ship,player.weaponsState[i]);
			_local11.hotkey = player.weaponsHotkeys[i];
			addLevelBonusToWeapon(g,player.level,_local11,player);
			if(i < ship.weapons.length) {
				_local9 = ship.weapons[i];
				ship.weapons[i] = _local11;
				_local9.destroy();
			} else {
				ship.weapons.push(_local11);
			}
			if(i == weapons.length - 1) {
				player.saveWeaponData(ship.weapons);
			} else {
				i += 1;
				CreatePlayerShipWeapon(g,player,i,weapons,ship);
			}
		}
		
		private static function addArmorTechToShip(player:Player, s:PlayerShip) : void {
			var _local5:int = 0;
			var _local7:TechSkill = null;
			var _local6:Object = null;
			var _local10:int = 0;
			_local5 = 0;
			while(_local5 < player.techSkills.length) {
				_local7 = player.techSkills[_local5];
				if(_local7.tech == "m4yG1IRPIUeyRQHrC3h5kQ") {
					break;
				}
				_local5++;
			}
			var _local11:IDataManager = DataLocator.getService();
			var _local4:Object = _local11.loadKey("BasicTechs",_local7.tech);
			var _local3:int = _local7.level;
			_local10 = 0;
			while(_local10 < _local3) {
				_local6 = _local4.techLevels[_local10];
				s.armorThreshold += _local6.dmgThreshold;
				s.armorThresholdBase += _local6.dmgThreshold;
				s.hpBase += _local6.hpBonus;
				if(_local10 == _local3 - 1) {
					if(_local6.armorConvGain > 0) {
						s.hasArmorConverter = true;
						s.convCD = _local6.cooldown * 1000;
						s.convCost = _local6.armorConvCost;
						s.convGain = _local6.armorConvGain;
					}
				}
				_local10++;
			}
			s.hpMax = s.hpBase;
			var _local9:int = -1;
			var _local8:String = "";
			_local9 = _local7.activeEliteTechLevel;
			_local8 = _local7.activeEliteTech;
			EliteTechs.addEliteTechs(s,_local4,_local9,_local8);
		}
		
		private static function addShieldTechToShip(player:Player, s:PlayerShip) : void {
			var _local5:int = 0;
			var _local7:TechSkill = null;
			var _local6:Object = null;
			var _local10:int = 0;
			_local5 = 0;
			while(_local5 < player.techSkills.length) {
				_local7 = player.techSkills[_local5];
				if(_local7.tech == "QgKEEj8a-0yzYAJ06eSLqA") {
					break;
				}
				_local5++;
			}
			var _local11:IDataManager = DataLocator.getService();
			var _local4:Object = _local11.loadKey("BasicTechs",_local7.tech);
			var _local3:int = _local7.level;
			_local10 = 0;
			while(_local10 < _local3) {
				_local6 = _local4.techLevels[_local10];
				s.shieldHpBase += _local6.hpBonus;
				s.shieldRegenBase += _local6.regen;
				if(_local10 == _local3 - 1) {
					if(_local6.hardenMaxDmg > 0) {
						s.hasHardenedShield = true;
						s.hardenMaxDmg = _local6.hardenMaxDmg;
						s.hardenCD = _local6.cooldown * 1000;
						s.hardenDuration = _local6.duration * 1000;
					}
				}
				_local10++;
			}
			s.shieldRegen = s.shieldRegenBase;
			s.shieldHpMax = s.shieldHpBase;
			var _local9:int = -1;
			var _local8:String = "";
			_local9 = _local7.activeEliteTechLevel;
			_local8 = _local7.activeEliteTech;
			EliteTechs.addEliteTechs(s,_local4,_local9,_local8);
		}
		
		private static function addEngineTechToShip(player:Player, s:PlayerShip) : void {
			var _local6:int = 0;
			var _local7:TechSkill = null;
			var _local10:Object = null;
			var _local8:int = 0;
			_local6 = 0;
			while(_local6 < player.techSkills.length) {
				_local7 = player.techSkills[_local6];
				if(_local7.tech == "rSr1sn-_oUOY6E0hpAhh0Q") {
					break;
				}
				_local6++;
			}
			var _local11:IDataManager = DataLocator.getService();
			var _local9:Object = _local11.loadKey("BasicTechs",_local7.tech);
			var _local4:int = _local7.level;
			var _local3:int = 100;
			var _local5:int = 100;
			_local8 = 0;
			while(_local8 < _local4) {
				_local10 = _local9.techLevels[_local8];
				_local3 += _local10.acceleration;
				_local5 += _local10.maxSpeed;
				if(_local8 == _local4 - 1) {
					if(_local10.boost > 0) {
						s.hasBoost = true;
						s.boostBonus = _local10.boost;
						s.boostCD = _local10.cooldown * 1000;
						s.boostDuration = _local10.duration * 1000;
						s.totalTicksOfBoost = s.boostDuration / 33;
						s.ticksOfBoost = 0;
					}
				}
				_local8++;
			}
			s.engine.acceleration = s.engine.acceleration * _local3 / 100;
			s.engine.speed = s.engine.speed * _local5 / 100;
			var _local12:int = -1;
			var _local13:String = "";
			_local12 = _local7.activeEliteTechLevel;
			_local13 = _local7.activeEliteTech;
			EliteTechs.addEliteTechs(s,_local9,_local12,_local13);
		}
		
		private static function addPowerTechToShip(player:Player, s:PlayerShip) : void {
			var _local5:int = 0;
			var _local7:TechSkill = null;
			var _local6:Object = null;
			var _local10:int = 0;
			_local5 = 0;
			while(_local5 < player.techSkills.length) {
				_local7 = player.techSkills[_local5];
				if(_local7.tech == "kwlCdExeJk-oEJZopIz5kg") {
					break;
				}
				_local5++;
			}
			var _local11:IDataManager = DataLocator.getService();
			var _local4:Object = _local11.loadKey("BasicTechs",_local7.tech);
			var _local3:int = _local7.level;
			s.maxPower = 1;
			s.powerRegBonus = 1;
			_local10 = 0;
			while(_local10 < _local3) {
				_local6 = _local4.techLevels[_local10];
				s.maxPower += 0.01 * Number(_local6.maxPower);
				s.powerRegBonus += 0.01 * Number(_local6.powerReg);
				if(_local10 == _local3 - 1) {
					if(_local6.boost > 0) {
						s.hasDmgBoost = true;
						s.dmgBoostCD = _local6.cooldown * 1000;
						s.dmgBoostDuration = _local6.duration * 1000;
						s.dmgBoostCost = 0.01 * Number(_local6.boostCost);
						s.dmgBoostBonus = 0.01 * Number(_local6.boost);
						s.totalTicksOfBoost = s.boostDuration / 33;
						s.ticksOfBoost = 0;
					}
				}
				_local10++;
			}
			s.weaponHeat.setBonuses(s.maxPower,s.powerRegBonus);
			var _local9:int = -1;
			var _local8:String = "";
			_local9 = _local7.activeEliteTechLevel;
			_local8 = _local7.activeEliteTech;
			EliteTechs.addEliteTechs(s,_local4,_local9,_local8);
		}
		
		private static function addLevelBonusToShip(g:Game, level:Number, s:PlayerShip) : void {
			if(g.solarSystem.isPvpSystemInEditor) {
				level = 100;
			}
			var _local4:Number = s.player.troons;
			var _local5:Number = _local4 / 200000;
			level += _local5;
			s.hpBase = s.hpBase * (100 + 8 * (level - 1)) / 100;
			s.hpMax = s.hpBase;
			s.hp = s.hpMax;
			s.armorThresholdBase = s.armorThresholdBase * (100 + 2.5 * 8 * (level - 1)) / 100;
			s.shieldHpBase = s.shieldHpBase * (100 + 8 * (level - 1)) / 100;
			s.armorThreshold = s.armorThresholdBase;
			s.shieldHpMax = s.shieldHpBase;
			s.shieldHp = s.shieldHpMax;
			s.shieldRegenBase = s.shieldRegenBase * (100 + 1 * (level - 1)) / 100;
			s.shieldRegen = s.shieldRegenBase;
		}
		
		private static function addLevelBonusToWeapon(g:Game, level:Number, w:Weapon, p:Player) : void {
			if(g.solarSystem.isPvpSystemInEditor) {
				level = 100;
			}
			var _local5:Number = p.troons;
			var _local6:Number = _local5 / 200000;
			level += _local6;
			w.dmg.addLevelBonus(level,8);
			if(w.debuffValue != null) {
				w.debuffValue.addLevelBonus(level,8);
				w.debuffValue2.addLevelBonus(level,8);
			}
		}
		
		public static function createEnemy(g:Game, key:String, rareType:int = 0) : EnemyShip {
			var _local7:Number = NaN;
			var _local6:Random = null;
			var _local8:IDataManager = DataLocator.getService();
			var _local5:Object = _local8.loadKey("Enemies",key);
			if(g.isLeaving) {
				return null;
			}
			var _local4:EnemyShip = g.shipManager.getEnemyShip();
			_local4.name = _local5.name;
			_local4.xp = _local5.xp;
			_local4.level = _local5.level;
			_local4.rareType = rareType;
			_local4.aggroRange = _local5.aggroRange;
			_local4.chaseRange = _local5.chaseRange;
			_local4.observer = _local5.observer;
			if(_local4.observer) {
				_local4.visionRange = _local5.visionRange;
			} else {
				_local4.visionRange = _local4.aggroRange;
			}
			if(g.isSystemTypeSurvival() && _local4.level < g.hud.uberStats.uberLevel) {
				_local7 = g.hud.uberStats.CalculateUberRankFromLevel(_local4.level);
				_local4.uberDifficulty = g.hud.uberStats.CalculateUberDifficultyFromRank(g.hud.uberStats.uberRank - _local7,_local4.level);
				_local4.uberLevelFactor = 1 + (g.hud.uberStats.uberLevel - _local4.level) / 100;
				_local4.aggroRange *= _local4.uberLevelFactor;
				_local4.chaseRange *= _local4.uberLevelFactor;
				_local4.visionRange *= _local4.uberLevelFactor;
				_local6 = new Random(_local4.id);
				if(_local4.aggroRange > 2000) {
					_local4.aggroRange = 10000;
				} else if(g.hud.uberStats.uberRank >= 9) {
					_local4.aggroRange = 50 * 60 + _local6.random(10000);
				} else if(g.hud.uberStats.uberRank >= 6) {
					_local4.aggroRange = 2000 + _local6.random(10000);
				} else if(g.hud.uberStats.uberRank >= 3) {
					_local4.aggroRange = 25 * 60 + _local6.random(10000);
				} else if(_local4.aggroRange < 50 * 60) {
					_local4.aggroRange = 1000 + _local6.random(10000);
				}
				_local4.chaseRange = _local4.aggroRange;
				_local4.visionRange = _local4.aggroRange;
				_local4.xp *= _local4.uberLevelFactor;
				_local4.level = g.hud.uberStats.uberLevel;
			}
			_local4.orbitSpawner = _local5.orbitSpawner;
			if(_local4.orbitSpawner) {
				_local4.hpRegen = _local5.hpRegen;
			}
			_local4.aimSkill = _local5.aimSkill;
			if(_local5.hasOwnProperty("stopWhenClose")) {
				_local4.stopWhenClose = _local5.stopWhenClose;
			}
			if(_local5.hasOwnProperty("AIFaction1") && _local5.AIFaction1 != "") {
				_local4.factions.push(_local5.AIFaction1);
			}
			if(_local5.hasOwnProperty("AIFaction2") && _local5.AIFaction2 != "") {
				_local4.factions.push(_local5.AIFaction2);
			}
			if(_local5.hasOwnProperty("teleport")) {
				_local4.teleport = _local5.teleport;
			}
			_local4.kamikaze = _local5.kamikaze;
			if(_local4.kamikaze) {
				_local4.kamikazeLifeTreshhold = _local5.kamikazeLifeTreshhold;
				_local4.kamikazeHoming = _local5.kamikazeHoming;
				_local4.kamikazeTtl = _local5.kamikazeTtl;
				_local4.kamikazeDmg = _local5.kamikazeDmg;
				_local4.kamikazeRadius = _local5.kamikazeRadius;
				_local4.kamikazeWhenClose = _local5.kamikazeWhenClose;
			}
			if(_local5.hasOwnProperty("alwaysFire")) {
				_local4.alwaysFire = _local5.alwaysFire;
			} else {
				_local4.alwaysFire = false;
			}
			_local4.forcedRotation = _local5.forcedRotation;
			if(_local4.forcedRotation) {
				_local4.forcedRotationSpeed = _local5.forcedRotationSpeed;
				_local4.forcedRotationAim = _local5.forcedRotationAim;
			}
			_local4.melee = _local5.melee;
			if(_local4.melee) {
				_local4.meleeCharge = _local5.charge;
				_local4.meleeChargeSpeedBonus = Number(_local5.chargeSpeedBonus) / 100;
				_local4.meleeChargeDuration = _local5.chargeDuration;
				_local4.meleeCanGrab = _local5.grab;
			}
			_local4.flee = _local5.flee;
			if(_local4.flee) {
				_local4.fleeLifeTreshhold = _local5.fleeLifeTreshhold;
				_local4.fleeDuration = _local5.fleeDuration;
				if(_local5.hasOwnProperty("fleeClose")) {
					_local4.fleeClose = _local5.fleeClose;
				} else {
					_local4.fleeClose = 0;
				}
			}
			_local4.aiCloak = false;
			if(_local5.hasOwnProperty("hardenShield")) {
				_local4.aiHardenShield = false;
				_local4.aiHardenShieldDuration = _local5.hardenShieldDuration;
			} else {
				_local4.aiHardenShield = false;
				_local4.aiHardenShieldDuration = 0;
			}
			if(_local5.hasOwnProperty("sniper")) {
				_local4.sniper = _local5.sniper;
				if(_local4.sniper) {
					_local4.sniperMinRange = _local5.sniperMinRange;
				}
			}
			_local4.isHostile = true;
			_local4.group = null;
			createBody(_local5.ship,g,_local4);
			_local4.engine = EngineFactory.create(_local5.engine,g,_local4);
			if(_local4.uberDifficulty > 0) {
				_local4.hp = _local4.hpMax *= _local4.uberDifficulty;
				_local4.shieldHp = _local4.shieldHpMax *= _local4.uberDifficulty;
				_local4.engine.speed *= _local4.uberLevelFactor;
				if(_local4.engine.speed > 380) {
					_local4.engine.speed = 380;
				}
			}
			if(rareType == 1) {
				_local4.hp = _local4.hpMax *= 3;
				_local4.shieldHp = _local4.shieldHpMax *= 3;
			}
			if(rareType == 4) {
				_local4.hp = _local4.hpMax *= 3;
				_local4.shieldHp = _local4.shieldHpMax *= 3;
				_local4.engine.speed *= 1.1;
			}
			if(rareType == 5) {
				_local4.color = 0xff8811;
				_local4.hp = _local4.hpMax *= 10;
				_local4.shieldHp = _local4.shieldHpMax *= 10;
				_local4.engine.speed *= 1.3;
			}
			if(rareType == 3) {
				_local4.engine.speed *= 1.4;
			}
			if(_local5.hasOwnProperty("startHp")) {
				_local4.hp = 0.01 * _local5.startHp * _local4.hp;
			}
			CreateEnemyShipWeapon(g,0,_local5.weapons,_local4);
			CreateEnemyShipExtraWeapon(g,_local4.weapons.length,_local5.fleeWeaponItem,_local4,0);
			CreateEnemyShipExtraWeapon(g,_local4.weapons.length,_local5.antiProjectileWeaponItem,_local4,1);
			if(!g.isLeaving) {
				g.shipManager.activateEnemyShip(_local4);
			}
			return _local4;
		}
		
		private static function CreateEnemyShipWeapon(g:Game, i:int, weapons:Array, ship:EnemyShip) : void {
			var _local6:Weapon = null;
			if(weapons.length == 0) {
				return;
			}
			var _local7:Object = weapons[i];
			var _local5:Weapon = WeaponFactory.create(_local7.weapon,g,ship,0);
			ship.weaponRanges.push(new WeaponRange(_local7.minRange,_local7.maxRange));
			if(i < ship.weapons.length) {
				_local6 = ship.weapons[i];
				ship.weapons[i] = _local5;
				_local6.destroy();
			} else {
				ship.weapons.push(_local5);
			}
			if(i != weapons.length - 1) {
				i += 1;
				CreateEnemyShipWeapon(g,i,weapons,ship);
			}
		}
		
		private static function CreateEnemyShipExtraWeapon(g:Game, i:int, weaponObj:Object, ship:EnemyShip, type:int) : void {
			var _local7:Weapon = null;
			if(weaponObj == null) {
				return;
			}
			var _local6:Weapon = WeaponFactory.create(weaponObj.weapon,g,ship,0);
			ship.weaponRanges.push(new WeaponRange(0,0));
			if(type == 0) {
				ship.escapeWeapon = _local6;
			} else {
				ship.antiProjectileWeapon = _local6;
			}
			if(i < ship.weapons.length) {
				_local7 = ship.weapons[i];
				ship.weapons[i] = _local6;
				_local7.destroy();
			} else {
				ship.weapons.push(_local6);
			}
		}
		
		public static function createBody(key:String, g:Game, s:Unit) : void {
			var _local6:IDataManager = DataLocator.getService();
			var _local4:Object = _local6.loadKey("Ships",key);
			s.switchTexturesByObj(_local4);
			if(_local4.blendModeAdd) {
				s.movieClip.blendMode = "add";
			}
			s.obj = _local4;
			s.bodyName = _local4.name;
			s.collisionRadius = _local4.collisionRadius;
			s.hp = _local4.hp;
			s.hpMax = _local4.hp;
			s.shieldHp = _local4.shieldHp;
			s.shieldHpMax = _local4.shieldHp;
			s.armorThreshold = _local4.armor;
			s.armorThresholdBase = _local4.armor;
			s.shieldRegenBase = 1.5 * _local4.shieldRegen;
			s.shieldRegen = s.shieldRegenBase;
			if(s is Ship) {
				s.enginePos.x = _local4.enginePosX;
				s.enginePos.y = _local4.enginePosY;
				s.weaponPos.x = _local4.weaponPosX;
				s.weaponPos.y = _local4.weaponPosY;
			} else {
				s is Turret;
			}
			s.weaponPos.x = _local4.weaponPosX;
			s.weaponPos.y = _local4.weaponPosY;
			s.explosionEffect = _local4.explosionEffect;
			s.explosionSound = _local4.explosionSound;
			var _local5:ISound = SoundLocator.getService();
			if(s.explosionSound != null) {
				_local5.preCacheSound(s.explosionSound);
			}
		}
	}
}

