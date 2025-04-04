package core.weapon
{
	import core.GameObject;
	import core.player.EliteTechs;
	import core.projectile.Projectile;
	import core.scene.Game;
	import core.ship.EnemyShip;
	import core.ship.PlayerShip;
	import core.unit.Unit;
	import flash.errors.IllegalOperationError;
	import flash.geom.Point;
	import generics.Localize;
	import generics.Util;
	import sound.ISound;
	import sound.SoundLocator;
	
	public class Weapon extends GameObject
	{
		public static const TYPE_FLEE:int = 0;
		public static const TYPE_ANTIPROJECTILE:int = 1;
		public var type:String;
		public var dmg:Damage;
		public var debuffType:int;
		public var debuffDuration:int;
		public var debuffValue:Damage;
		public var debuffEffect:String;
		public var debuffType2:int;
		public var debuffDuration2:int;
		public var debuffValue2:Damage;
		public var debuffEffect2:String;
		public var fireEffect:String;
		public var dmgRadius:int;
		public var numberOfHits:int;
		public var reloadTime:Number;
		public var speed:Number;
		public var acceleration:Number;
		public var ttl:int;
		
		public var projectileFunction:String;
		public var range:Number;
		public var friction:Number;
		public var angleVariance:Number;
		public var positionYVariance:Number;
		public var positionXVariance:Number;
		public var sideShooter:Boolean;
		public var positionOffsetX:Number;
		public var positionOffsetY:Number;
		public var maxProjectiles:int;
		public var projectiles:Vector.<Projectile>;
		public var multiNrOfP:int;
		public var multiOffset:Number;
		public var multiAngleOffset:Number;
		public var multiSpreadStart:Boolean;
		public var fireSound:String;
		public var alive:Boolean;
		public var fireNextTime:Number;
		public var rotationSpeed:Number;
		public var unit:Unit;
		public var target:Unit;
		public var hasTechTree:Boolean;
		public var key:String;
		public var useShipSystem:Boolean;
		public var randomAngle:Boolean;
		public var techIconFileName:String;
		public var specialCondition:String;
		public var specialBonusPercentage:Number;
		public var waveDirection:int;
		public var isMissileWeapon:Boolean;
		public var fireBackwards:Boolean;
		public var aimArc:Number;
		public var level:int;
		public var heatCost:Number;
		public var shieldVamp:Number;
		public var healthVamp:Number;
		public var burst:int;
		public var burstDelay:Number;
		public var burstCurrent:int;
		public var active:Boolean;
		public var hotkey:int;
		public var hasChargeUp:Boolean;
		public var chargeUpTimeMax:Number;
		protected var g:Game;
		protected var _fire:Boolean;
		public var chargeUpTime:Number;
		public var lastFire:Number = 0;
		public var global:Boolean = false;
		public var triggerMeleeAnimation:Boolean = false;
		
		public var fireCallback:Function;
		
		public function Weapon(g:Game)
		{
			super();
			chargeUpTime = 0;
			heatCost = 0;
			this.g = g;
		}
		
		public function init(obj:Object, techLevel:int, eliteTechLevel:int = -1, eliteTech:String = "") : void
		{
			var _loc6_:int = 0;
			var _loc5_:ISound = null;
			this.type = obj.type;
			name = obj.name;
			if(obj.hasOwnProperty("damageType"))
			{
				_loc6_ = int(obj.damageType);
			}
			dmg = new Damage(obj.dmg,_loc6_);
			if(obj.hasOwnProperty("shieldVamp"))
			{
				shieldVamp = obj.shieldVamp;
			}
			else
			{
				shieldVamp = 0;
			}
			if(obj.hasOwnProperty("healthVamp"))
			{
				healthVamp = obj.healthVamp;
			}
			else
			{
				healthVamp = 0;
			}
			if(obj.hasOwnProperty("burst"))
			{
				burst = obj.burst;
			}
			else
			{
				burst = 1;
			}
			if(obj.hasOwnProperty("burstDelay"))
			{
				burstDelay = obj.burstDelay;
			}
			else
			{
				burstDelay = 30;
			}
			if(obj.hasOwnProperty("debuffType") && Boolean(obj.hasOwnProperty("dot")) && Boolean(obj.hasOwnProperty("dotDamageType")) && Boolean(obj.hasOwnProperty("dotDuration")))
			{
				debuffType = obj.debuffType;
				debuffValue = new Damage(obj.dot,obj.dotDamageType);
				debuffDuration = obj.dotDuration;
				if(obj.hasOwnProperty("dotEffect"))
				{
					debuffEffect = obj.dotEffect;
				}
			}
			else if(this is Cloak)
			{
				debuffType = -1;
				debuffDuration = obj.dotDuration;
				debuffValue = new Damage(0,0);
				debuffEffect = "";
			}
			else
			{
				debuffType = -1;
				debuffValue = new Damage(0,1);
				debuffDuration = 0;
			}
			debuffType2 = -1;
			debuffValue2 = new Damage(0,1);
			debuffDuration2 = 0;
			if(obj.hasOwnProperty("heatCost"))
			{
				heatCost = Number(obj.heatCost) / 1000;
			}
			else
			{
				heatCost = 0;
			}
			if(obj.hasOwnProperty("numberOfHits"))
			{
				numberOfHits = obj.numberOfHits;
			}
			else
			{
				numberOfHits = 1;
			}
			speed = obj.speed;
			reloadTime = obj.reloadTime;
			ttl = obj.ttl;
			acceleration = obj.acceleration;
			rotationSpeed = obj.rotationSpeed;
			positionYVariance = obj.positionVariance;
			if(obj.hasOwnProperty("positionXVariance"))
			{
				positionXVariance = obj.positionXVariance;
			}
			else
			{
				positionXVariance = 0;
			}
			if(obj.hasOwnProperty("multiSideFire"))
			{
				sideShooter = obj.multiSideFire;
			}
			else
			{
				sideShooter = false;
			}
			if(obj.hasOwnProperty("positionOffset"))
			{
				positionOffsetX = obj.positionOffset;
			}
			if(obj.hasOwnProperty("positionOffsetY"))
			{
				positionOffsetY = obj.positionOffsetY;
			}
			if(obj.hasOwnProperty("friction"))
			{
				friction = obj.friction;
			}
			maxProjectiles = obj.maxProjectiles;
			if(maxProjectiles > 0)
			{
				ttl = 2 * 60 * 1000;
			}
			multiNrOfP = obj.multiNrOfP;
			multiOffset = obj.multiOffset;
			multiAngleOffset = Util.degreesToRadians(obj.multiAngleOffset);
			angleVariance = obj.angleVariance;
			if(obj.hasOwnProperty("aimArc"))
			{
				aimArc = obj.aimArc;
			}
			fireSound = obj.fireSound;
			if(fireSound != null)
			{
				_loc5_ = SoundLocator.getService();
				_loc5_.preCacheSound(fireSound);
			}
			hasTechTree = obj.hasTechTree;
			if(obj.hasOwnProperty("multiSpreadStart"))
			{
				multiSpreadStart = obj.multiSpreadStart;
			}
			else
			{
				multiSpreadStart = false;
			}
			if(obj.hasOwnProperty("radius"))
			{
				dmgRadius = obj.radius;
			}
			else
			{
				dmgRadius = 0;
			}
			range = obj.range;
			if(hasTechTree)
			{
				techIconFileName = obj.techIcon;
				level = techLevel;
				if(techLevel > 0)
				{
					addTechStats(obj,techLevel);
				}
				if(eliteTechLevel > 0)
				{
					addEliteTechStats(obj,eliteTechLevel,eliteTech);
				}
				triggerMeleeAnimation = obj.triggerMeleeAnimation;
			}
			if(this is Cloak)
			{
				reloadTime += 3 * debuffDuration * 1000;
				trace("weapon init cloak reloadtime: " + reloadTime);
			}
			global = obj.global;
		}
		
		public function addDebuff(type:int, duration:int, value:Damage, effect:String) : void
		{
			if(debuffType == -1)
			{
				debuffType = type;
				debuffDuration = duration;
				debuffEffect = effect;
				debuffValue = value;
				return;
			}
			if(debuffType == type && debuffValue.type == value.type)
			{
				debuffEffect = effect;
				debuffValue.addBaseDmg(value.dmg());
				return;
			}
			if(debuffType2 == -1)
			{
				debuffType2 = type;
				debuffDuration2 = duration;
				debuffEffect2 = effect;
				debuffValue2 = value;
			}
		}
		
		public function removeDebuff(type:int, value:Damage) : void
		{
			if(debuffType == type && debuffValue.type == value.type)
			{
				if(Math.abs(debuffValue.dmg() - value.dmg()) < 0.01)
				{
					debuffType = -1;
					debuffDuration = 0;
					debuffEffect = "";
					debuffValue = new Damage(0,1);
				}
				else
				{
					debuffValue.addBaseDmg(-value.dmg());
				}
			}
			if(debuffType2 == type && debuffValue2.type == value.type)
			{
				debuffType2 = -1;
				debuffDuration2 = 0;
				debuffEffect2 = "";
				debuffValue2 = new Damage(0,1);
			}
		}
		
		public function getDescription(isBeam:Boolean) : String
		{
			var _loc3_:String = null;
			var _loc2_:PetSpawner = null;
			_loc3_ = Localize.t("<FONT COLOR=\'#8888ff\'>[name], lvl [level]</FONT>\n").replace("[name]",name).replace("[level]",level);
			_loc3_ += dmg.damageText();
			if(multiNrOfP > 1)
			{
				_loc3_ += Localize.t("Fires <FONT COLOR=\'#eeeeee\'>[nrp]</FONT>x projectiles\n").replace("[nrp]",multiNrOfP);
			}
			if(!isBeam && name != "Acid Spray" && name != "Flamethrower")
			{
				_loc3_ += Localize.t("Fires <FONT COLOR=\'#eeeeee\'>[rps]</FONT> rounds per second.\n").replace("[rps]",(1000 * multiNrOfP / reloadTime).toFixed(1));
			}
			if(multiNrOfP == 0)
			{
				_loc3_ += Localize.t("Damage per second: <FONT COLOR=\'#eeeeee\'>[dps]</FONT>\n").replace("[dps]",(dmg.dmg() * burst * 1000 / (reloadTime + (burst - 1) * 33)).toFixed(1));
			}
			else
			{
				_loc3_ += Localize.t("Damage per second: <FONT COLOR=\'#eeeeee\'>[dps]</FONT>\n").replace("[dps]",(dmg.dmg() * burst * multiNrOfP * 1000 / (reloadTime + (burst - 1) * 33)).toFixed(1));
			}
			if(shieldVamp > 0 || healthVamp > 0)
			{
				_loc3_ += "\n";
				if(shieldVamp > 0)
				{
					_loc3_ += Localize.t("<FONT COLOR=\'#4444ff\'>Steals [shieldVamp]% of damage done to enemy shields</FONT>\n").replace("[shieldVamp]",shieldVamp.toFixed(1));
				}
				if(healthVamp > 0)
				{
					_loc3_ += Localize.t("<FONT COLOR=\'#ff4444\'>Steals [healthVamp]% of damage done to enemy health</FONT>\n").replace("[healthVamp]",healthVamp.toFixed(1));
				}
			}
			if(debuffType > -1 || debuffType2 > -1)
			{
				_loc3_ += Localize.t("\nDebuff:\n");
				if(debuffDuration > 0)
				{
					_loc3_ += Debuff.debuffText(debuffType,debuffDuration,debuffValue);
				}
				if(debuffDuration2 > 0)
				{
					_loc3_ += Debuff.debuffText(debuffType2,debuffDuration2,debuffValue2);
				}
			}
			if(this is PetSpawner)
			{
				_loc2_ = this as PetSpawner;
				_loc3_ += Localize.t("\nMax number of Pets: [maxPets]").replace("[maxPets]",_loc2_.maxPets);
			}
			if(specialCondition != null && specialCondition != "")
			{
				_loc3_ += Localize.t("\nDeals <FONT COLOR=\'#eeeeee\'>" + specialBonusPercentage.toString() + "%</FONT> more damage if target is afflicted by " + specialCondition + ".");
			}
			return _loc3_;
		}
		
		private function addTechStats(obj:Object, techLevel:int) : void
		{
			var _loc12_:Object = null;
			var _loc6_:int = 0;
			if(techLevel > 6)
			{
				techLevel = 6;
			}
			var _loc5_:int = 100;
			var _loc10_:int = 100;
			var _loc3_:int = 100;
			var _loc4_:int = 100;
			var _loc11_:int = 100;
			var _loc9_:int = 100;
			var _loc7_:int = 100;
			var _loc8_:int = 100;
			_loc6_ = 0;
			while(_loc6_ < techLevel)
			{
				_loc12_ = obj.techLevels[_loc6_];
				_loc5_ += _loc12_.incDmg;
				if(debuffValue != null && Boolean(_loc12_.hasOwnProperty("dot")))
				{
					debuffValue.addBaseDmg(_loc12_.dot);
				}
				if(_loc12_.hasOwnProperty("dotDuration"))
				{
					debuffDuration += _loc12_.dotDuration;
				}
				_loc10_ += _loc12_.incReloadRate;
				_loc3_ += _loc12_.incRange;
				_loc4_ += _loc12_.incSpeed;
				_loc11_ += _loc12_.incAcceleration;
				_loc9_ += _loc12_.incSpread;
				_loc7_ += _loc12_.incRotationSpeed;
				if(_loc12_.hasOwnProperty("incAimArc"))
				{
					_loc8_ += _loc12_.incAimArc;
				}
				if(_loc12_.hasOwnProperty("radius"))
				{
					dmgRadius += _loc12_.radius;
				}
				if(_loc12_.hasOwnProperty("radius"))
				{
					maxProjectiles += _loc12_.incMaxProjectiles;
				}
				if(_loc6_ == techLevel - 1)
				{
					if(_loc12_.hasOwnProperty("heatCost"))
					{
						heatCost = Number(_loc12_.heatCost) / 1000;
					}
					if(_loc12_.hasOwnProperty("numberOfHits"))
					{
						numberOfHits = _loc12_.numberOfHits;
					}
					if(_loc12_.hasOwnProperty("shieldVamp"))
					{
						shieldVamp = _loc12_.shieldVamp;
					}
					if(_loc12_.hasOwnProperty("healthVamp"))
					{
						healthVamp = _loc12_.healthVamp;
					}
					positionYVariance = _loc12_.positionVariance;
				}
				multiNrOfP += _loc12_.incMultiNrOfP;
				multiOffset += _loc12_.incMultiOffset;
				multiAngleOffset += Util.degreesToRadians(_loc12_.incMultiAngleOffset);
				_loc6_++;
			}
			dmg.setBaseDmg(dmg.dmg() * _loc5_ / 100);
			speed = speed * _loc4_ / 100;
			range = range * _loc3_ / 100;
			reloadTime = reloadTime * 100 / _loc10_;
			ttl = ttl * _loc3_ / 100;
			acceleration = acceleration * _loc11_ / 100;
			aimArc = aimArc * _loc8_ / 100;
			rotationSpeed = rotationSpeed * _loc7_ / 100;
		}
		
		private function addEliteTechStats(obj:Object, eliteTechLevel:int, eliteTech:String) : void
		{
			EliteTechs.addWeaponEliteTechs(this,obj,eliteTechLevel,eliteTech);
		}
		
		override public function update() : void
		{
			if(_fire && unit.isAddedToCanvas)
			{
				if(fireCallback != null && this.hasChargeUp == false)
				{
					fireCallback();
				}
				pos.x = unit.x;
				pos.y = unit.y;
				shoot();
			}
		}
		
		protected function shoot() : void
		{
			throw new IllegalOperationError("Abstract method must be overriden");
		}
		
		public function set fire(value:Boolean) : void
		{
			var _loc2_:PlayerShip = null;
			if(hasChargeUp && chargeUpTime > 0 && unit is PlayerShip)
			{
				_loc2_ = unit as PlayerShip;
				_loc2_.killChargeUpEffect();
				if(_loc2_.player.isMe)
				{
					g.hud.powerBar.updateLoadBar(0);
				}
			}
			if(g.time - lastFire > reloadTime)
			{
				lastFire = 0;
				burstCurrent = 0;
			}
			chargeUpTime = 0;
			_fire = value;
		}
		
		public function get fire() : Boolean
		{
			return _fire;
		}
		
		public function destroy() : void
		{
			alive = false;
		}
		
		public function playFireSound() : void
		{
			var _loc1_:Point = g.camera.getCameraCenter();
			var _loc4_:Number = _loc1_.x - unit.x;
			var _loc3_:Number = _loc1_.y - unit.y;
			if(_loc4_ * _loc4_ + _loc3_ * _loc3_ > 250000)
			{
				return;
			}
			var _loc2_:ISound = SoundLocator.getService();
			_loc2_.play(fireSound);
		}
		
		public function inRange(target:Unit) : Boolean
		{
			if(target == null)
			{
				return false;
			}
			if(!inAimAngle(target))
			{
				return false;
			}
			var _loc3_:Number = unit.pos.x - target.pos.x;
			var _loc2_:Number = unit.pos.y - target.pos.y;
			var _loc4_:Number = _loc3_ * _loc3_ + _loc2_ * _loc2_ - target.collisionRadius;
			return _loc4_ <= range * range;
		}
		
		public function aim() : Number
		{
			var _loc8_:EnemyShip = null;
			if(target == null || unit == null)
			{
				return 0;
			}
			if(unit == target)
			{
				return unit.rotation;
			}
			var _loc5_:Point = target.speed;
			if(target is EnemyShip)
			{
				_loc8_ = target as EnemyShip;
				if(_loc8_.stateMachine.inState("AIOrbit"))
				{
					_loc5_ = _loc8_.calculateOrbitSpeed();
				}
			}
			var _loc6_:Number = target.pos.x - unit.pos.x;
			var _loc3_:Number = target.pos.y - unit.pos.y;
			var _loc1_:Number = Math.sqrt(_loc6_ * _loc6_ + _loc3_ * _loc3_);
			_loc6_ /= _loc1_;
			_loc3_ /= _loc1_;
			var _loc7_:Number = _loc1_ / (speed - Util.dotProduct(target.speed.x,target.speed.y,_loc6_,_loc3_));
			var _loc4_:Number = target.pos.x + _loc5_.x * _loc7_;
			var _loc2_:Number = target.pos.y + _loc5_.y * _loc7_;
			return Math.atan2(_loc2_ - unit.pos.y,_loc4_ - unit.pos.x) - unit.rotation;
		}
		
		private function inAimAngle(target:Unit) : Boolean
		{
			var _loc3_:Number = NaN;
			var _loc7_:int = 0;
			var _loc2_:Number = NaN;
			var _loc4_:Number = NaN;
			var _loc5_:Number = NaN;
			var _loc6_:Number = NaN;
			if(this is SmartGun)
			{
				_loc3_ = aimArc;
			}
			else
			{
				_loc3_ = angleVariance;
			}
			_loc7_ = 0;
			while(_loc7_ < 4)
			{
				_loc2_ = 0;
				_loc4_ = 0;
				if(_loc7_ == 0)
				{
					_loc4_ = -target.collisionRadius;
				}
				if(_loc7_ == 1)
				{
					_loc4_ = target.collisionRadius;
				}
				if(_loc7_ == 2)
				{
					_loc2_ = -target.collisionRadius;
				}
				if(_loc7_ == 3)
				{
					_loc2_ = target.collisionRadius;
				}
				_loc5_ = Math.atan2(target.pos.y - unit.pos.y + _loc2_,target.pos.x - unit.pos.x + _loc4_);
				_loc6_ = Util.angleDifference(unit.rotation,_loc5_);
				if(Math.abs(_loc6_) < _loc3_)
				{
					return true;
				}
				_loc7_++;
			}
			return false;
		}
		
		override public function draw() : void
		{
		}
		
		public function setActive(s:PlayerShip, value:Boolean) : Boolean
		{
			if(value && s.activeWeapons < s.unlockedWeaponSlots)
			{
				active = value;
				s.activeWeapons++;
				return true;
			}
			if(!value)
			{
				active = value;
				s.activeWeapons--;
				return true;
			}
			return false;
		}
		
		override public function reset() : void
		{
			projectileFunction = null;
			active = true;
			hotkey = 0;
			unit = null;
			dmg = null;
			dmgRadius = 0;
			debuffValue = null;
			debuffDuration = 0;
			debuffType = -1;
			debuffValue2 = null;
			debuffDuration2 = 0;
			debuffType2 = -1;
			fireBackwards = false;
			specialCondition = null;
			specialBonusPercentage = 0;
			numberOfHits = 0;
			reloadTime = 0;
			fireNextTime = 0;
			speed = 0;
			acceleration = 0;
			friction = 0;
			range = 0;
			ttl = 0;
			rotation = 0;
			heatCost = 0;
			maxProjectiles = 0;
			projectiles = new Vector.<Projectile>();
			multiNrOfP = 1;
			sideShooter = false;
			multiOffset = 0;
			multiAngleOffset = 0;
			name = null;
			type = null;
			angleVariance = 0;
			positionYVariance = 0;
			positionXVariance = 0;
			positionOffsetX = 0;
			positionOffsetY = 0;
			rotationSpeed = 0;
			aimArc = 0;
			fireSound = "";
			_fire = false;
			target = null;
			debuffEffect = null;
			useShipSystem = false;
			randomAngle = false;
			isMissileWeapon = false;
			waveDirection = 1;
			global = false;
			super.reset();
		}
	}
}

