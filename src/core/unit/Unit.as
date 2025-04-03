package core.unit
{
	import com.greensock.TweenMax;
	import core.GameObject;
	import core.boss.Boss;
	import core.boss.Trigger;
	import core.group.Group;
	import core.particle.Emitter;
	import core.particle.EmitterFactory;
	import core.projectile.Projectile;
	import core.scene.Game;
	import core.ship.EnemyShip;
	import core.ship.PlayerShip;
	import core.spawner.Spawner;
	import core.states.StateMachine;
	import core.text.TextParticle;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import sound.ISound;
	import sound.SoundLocator;
	import starling.display.Image;
	import starling.filters.ColorMatrixFilter;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class Unit extends GameObject
	{
		private static const HP_MAXWIDTH:int = 20;
		
		private static const HP_MINWIDTH:int = 10;
		
		private static const HP_MAXWIDTH_PVP:int = 50;
		
		private var damageFilter:ColorMatrixFilter;
		
		private var healFilter:ColorMatrixFilter;
		
		protected var hpBar:Image;
		
		protected var shieldBar:Image;
		
		private var _bodyName:String;
		
		public var syncId:int;
		
		public var parentObj:GameObject;
		
		public var disableHealEndtime:Number;
		
		public var slowDownEndtime:Number;
		
		public var slowDown:Number;
		
		public var nextHitEffectReady:Number = 0;
		
		public var lastDmgText:TextParticle;
		
		public var lastDmgTextOffset:int;
		
		public var lastDmgTime:Number;
		
		public var lastDmg:int;
		
		public var lastHealText:TextParticle;
		
		public var lastHealTextOffset:int;
		
		public var lastHealTime:Number;
		
		public var lastHeal:int;
		
		public var team:int;
		
		public var stateMachine:StateMachine;
		
		public var hasDmgBoost:Boolean;
		
		public var dmgBoostCD:int;
		
		public var dmgBoostNextRdy:Number;
		
		public var dmgBoostEndTime:Number;
		
		public var dmgBoostDuration:int;
		
		public var dmgBoostCost:Number;
		
		public var usingDmgBoost:Boolean;
		
		public var dmgBoostBonus:Number;
		
		public var alive:Boolean;
		
		public var uberDifficulty:Number;
		
		public var uberLevelFactor:Number;
		
		public var hp:int;
		
		private var _hpMax:int;
		
		public var armorThreshold:int;
		
		public var armorThresholdBase:int;
		
		public var shieldHp:int;
		
		protected var _shieldHpMax:int;
		
		public var xp:int;
		
		public var level:int;
		
		public var collisionRadius:Number;
		
		public var explosionEffect:String;
		
		public var explosionSound:String;
		
		public var shieldRegen:int;
		
		public var shieldRegenBase:int;
		
		public var shieldRegenCounter:int = 0;
		
		public var shieldRegenDuration:int = 1000;
		
		public var shieldRegenBonus:Number = 1;
		
		public var hpRegen:Number;
		
		public var hpRegenCounter:int;
		
		public var hpRegenDuration:int = 1000;
		
		public var invulnerable:Boolean = false;
		
		public var essential:Boolean = true;
		
		public var resistances:Vector.<Number>;
		
		private var barMaxWidth:int = 0;
		
		private var isFlashing:Boolean = false;
		
		protected var g:Game;
		
		private var _speed:Point;
		
		public var weaponPos:Point;
		
		public var enginePos:Point;
		
		public var group:Group;
		
		public var factions:Vector.<String>;
		
		public var isHostile:Boolean;
		
		public var dotTimers:Vector.<TweenMax>;
		
		public var dotEffect:String;
		
		public var obj:Object;
		
		public var active:Boolean = true;
		
		public var hideIfInactive:Boolean;
		
		public var triggersToActivte:int = 1;
		
		public var triggers:Vector.<Trigger>;
		
		public var lastBulletLocal:Number = 0;
		
		public var lastBulletGlobal:Number = 0;
		
		public var lastBulletTargetList:Vector.<Unit> = null;
		
		public var isBossUnit:Boolean = false;
		
		public var forceupdate:Boolean;
		
		public var originalFilter:ColorMatrixFilter;
		
		public var owner:PlayerShip = null;
		
		private var updateHealthBarTime:Number = 0;
		
		public var isInjured:Boolean = false;
		
		private var miniBarsAreAddedToCanvas:Boolean = false;
		
		public function Unit(g:Game)
		{
			var _loc2_:int = 0;
			stateMachine = new StateMachine();
			factions = new Vector.<String>();
			this.g = g;
			_speed = new Point();
			enginePos = new Point();
			weaponPos = new Point();
			resistances = new Vector.<Number>();
			_loc2_ = 0;
			while(_loc2_ < 5)
			{
				resistances.push(0);
				_loc2_++;
			}
			var _loc3_:ITextureManager = TextureLocator.getService();
			hpBar = new Image(_loc3_.getTextureMainByTextureName("scale_image"));
			hpBar.scale9Grid = new Rectangle(1,1,8,8);
			hpBar.height = 3;
			hpBar.width = 50;
			hpBar.color = 0x55ff55;
			hpBar.visible = false;
			shieldBar = new Image(_loc3_.getTextureMainByTextureName("scale_image"));
			shieldBar.scale9Grid = new Rectangle(1,1,8,8);
			shieldBar.height = 3;
			shieldBar.width = 50;
			shieldBar.color = 0x3377ff;
			shieldBar.visible = false;
			dotTimers = new Vector.<TweenMax>();
			triggers = new Vector.<Trigger>();
			if(healFilter == null)
			{
				healFilter = new ColorMatrixFilter();
				healFilter.adjustBrightness(0.5);
				damageFilter = new ColorMatrixFilter();
				damageFilter.adjustBrightness(0.5);
			}
			super();
		}
		
		override public function update() : void
		{
			if(nextDistanceCalculation <= 0)
			{
				updateIsNear();
			}
			else
			{
				nextDistanceCalculation -= 33;
			}
			super.update();
		}
		
		private function updateIsNear() : void
		{
			if(g.me.ship == null || g.me.ship == this || isBossUnit && !(this is EnemyShip))
			{
				return;
			}
			var _loc3_:Point = this.pos;
			var _loc1_:Point = g.camera.getCameraCenter();
			distanceToCameraX = _loc3_.x - _loc1_.x;
			distanceToCameraY = _loc3_.y - _loc1_.y;
			var _loc4_:Number = g.stage.stageWidth;
			distanceToCamera = Math.sqrt(distanceToCameraX * distanceToCameraX + distanceToCameraY * distanceToCameraY);
			var _loc2_:Number = distanceToCamera - _loc4_;
			nextDistanceCalculation = _loc2_ / (10 * 60) * 100;
			if(nextDistanceCalculation > 5000)
			{
				nextDistanceCalculation = 5000;
			}
			if(distanceToCamera < _loc4_)
			{
				if(isAddedToCanvas)
				{
					return;
				}
				addToCanvasForReal();
			}
			else
			{
				forceupdate = true;
				if(!isAddedToCanvas)
				{
					return;
				}
				removeFromCanvas();
			}
		}
		
		public function updateHealthBars() : void
		{
			var _loc2_:Number = NaN;
			var _loc1_:Number = NaN;
			if(miniBarsAreAddedToCanvas)
			{
				if(updateHealthBarTime > g.time)
				{
					return;
				}
				updateHealthBarTime = g.time + 33 * 5;
				hpBar.visible = true;
				shieldBar.visible = true;
				_loc2_ = barMaxWidth * hp / _hpMax;
				if(_loc2_ > barMaxWidth)
				{
					hpBar.width = barMaxWidth;
				}
				else
				{
					hpBar.width = _loc2_;
				}
				_loc1_ = barMaxWidth * shieldHp / _shieldHpMax;
				if(_loc1_ > barMaxWidth)
				{
					shieldBar.width = barMaxWidth;
				}
				else if(_loc1_ <= 0)
				{
					shieldBar.visible = false;
				}
				else
				{
					shieldBar.width = _loc1_;
				}
				hpBar.color = 0x55ff55;
				shieldBar.color = 0x3377ff;
			}
			else
			{
				updateHealthBarTime = 0;
			}
			if(hp == _hpMax && shieldHp == _shieldHpMax)
			{
				isInjured = false;
			}
		}
		
		public function set shieldHpMax(value:int) : void
		{
			_shieldHpMax = value;
			if(shieldHp > value)
			{
				shieldHp = value;
			}
			adjustMiniHealthBar();
		}
		
		public function set hpMax(value:int) : void
		{
			_hpMax = value;
			if(hp > value)
			{
				hp = value;
			}
			adjustMiniHealthBar();
		}
		
		private function adjustMiniHealthBar() : void
		{
			if(g.solarSystem.isPvpSystemInEditor)
			{
				barMaxWidth = 50;
			}
			else
			{
				barMaxWidth = 10 + 0.1 * (_hpMax + _shieldHpMax);
				if(barMaxWidth > 20)
				{
					barMaxWidth = 20;
				}
			}
		}
		
		public function get hpMax() : int
		{
			return _hpMax;
		}
		
		public function get shieldHpMax() : int
		{
			return _shieldHpMax;
		}
		
		public function regenerateShield() : void
		{
			if(alive && shieldHp < _shieldHpMax)
			{
				if(shieldRegenCounter >= shieldRegenDuration)
				{
					shieldRegenCounter = 0;
					shieldHp += int(1.5 * (shieldRegen + shieldRegenBonus));
					if(shieldHp > _shieldHpMax)
					{
						shieldHp = _shieldHpMax;
					}
				}
				shieldRegenCounter += 33;
			}
		}
		
		public function regenerateHP() : void
		{
			if(alive && hp < _hpMax)
			{
				if(hpRegenCounter >= hpRegenDuration)
				{
					hpRegenCounter = 0;
					hp += int(hpRegen);
					if(hp > hpMax)
					{
						hp = _hpMax;
					}
				}
				hpRegenCounter += 33;
			}
		}
		
		public function canBeDamage(attacker:Unit, p:Projectile) : Boolean
		{
			var _loc3_:int = 0;
			var _loc6_:int = 0;
			var _loc7_:String = null;
			var _loc4_:int = 0;
			var _loc5_:int = 0;
			var _loc9_:PlayerShip = null;
			var _loc10_:* = this;
			if(p.isHeal)
			{
				if(attacker == this)
				{
					return false;
				}
				if(_loc10_.owner != null)
				{
					_loc10_ = owner;
				}
				if(attacker.owner != null)
				{
					attacker = attacker.owner;
				}
				if(g.solarSystem.isPvpSystemInEditor && this.isHostile && attacker.isHostile && attacker.team != -1 && this.team != -1)
				{
					if(attacker.team == this.team)
					{
						return true;
					}
					return false;
				}
				if(attacker is PlayerShip && _loc10_ is PlayerShip)
				{
					return true;
				}
				_loc3_ = int(_loc10_.factions.length);
				_loc6_ = int(attacker.factions.length);
				var _loc8_:String = "";
				_loc4_ = 0;
				while(_loc4_ < _loc3_)
				{
					_loc7_ = _loc10_.factions[_loc4_];
					_loc5_ = 0;
					while(_loc5_ < _loc6_)
					{
						_loc8_ = attacker.factions[_loc5_];
						if(_loc7_ == _loc8_)
						{
							return false;
						}
						_loc5_++;
					}
					_loc4_++;
				}
				if(!(attacker is PlayerShip) && _loc10_ is PlayerShip)
				{
					return true;
				}
				return false;
			}
			if(attacker == this || this.owner != null && this.owner == attacker)
			{
				return false;
			}
			if(_loc10_.owner != null)
			{
				_loc10_ = owner;
			}
			if(attacker.owner != null)
			{
				attacker = attacker.owner;
			}
			if(g.solarSystem.isPvpSystemInEditor && this.isHostile && attacker.isHostile && attacker.team != -1 && this.team != -1)
			{
				if(attacker.team == this.team)
				{
					return false;
				}
				return true;
			}
			if(!_loc10_.alive || _loc10_.invulnerable || !_loc10_.isHostile && !attacker.isHostile || attacker.group != null && _loc10_.group != null && (attacker.group.id == _loc10_.group.id && !g.solarSystem.isPvpSystemInEditor))
			{
				return false;
			}
			if(_loc10_ is PlayerShip)
			{
				_loc9_ = _loc10_ as PlayerShip;
				if(_loc9_.player.invulnarable)
				{
					return false;
				}
				if(attacker is PlayerShip)
				{
					return true;
				}
			}
			_loc3_ = int(_loc10_.factions.length);
			_loc6_ = int(attacker.factions.length);
			_loc7_ = "";
			_loc8_ = "";
			_loc4_ = 0;
			while(_loc4_ < _loc3_)
			{
				_loc7_ = _loc10_.factions[_loc4_];
				_loc5_ = 0;
				while(_loc5_ < _loc6_)
				{
					_loc8_ = attacker.factions[_loc5_];
					if(_loc7_ == _loc8_)
					{
						return false;
					}
					_loc5_++;
				}
				_loc4_++;
			}
			return true;
		}
		
		public function takeDamage(dmg:int) : void
		{
			if(!isAddedToCanvas)
			{
				return;
			}
			if(dmg == 0)
			{
				return;
			}
			isInjured = true;
			if(dmg < 0)
			{
				damageFlash(dmg,false,true);
			}
			else if(shieldHp >= dmg)
			{
				damageFlash(dmg,false);
			}
			else
			{
				damageFlash(dmg);
			}
			g.textManager.createDmgText(dmg,this);
		}
		
		private function damageFlash(dmg:int, hpDamage:Boolean = true, heal:Boolean = false) : void
		{
			if(RymdenRunt.isBuggedFlashVersion)
			{
				return;
			}
			if(isFlashing)
			{
				return;
			}
			isFlashing = true;
			if(heal)
			{
				_mc.filter = healFilter;
			}
			else
			{
				_mc.filter = damageFilter;
			}
			_mc.filter.cache();
			TweenMax.delayedCall(0.08,function():void
			{
				isFlashing = false;
				_mc.filter = originalFilter == null ? null : originalFilter;
				if(_mc.filter)
				{
					_mc.filter.cache();
				}
			});
		}
		
		public function doDOTEffect(dotDuration:int, dotEffect:String, dotType:int = -1, dotText:String = "") : void
		{
			var _loc8_:* = undefined;
			var _loc5_:TweenMax = null;
			if(dotEffect == null || !alive || !isAddedToCanvas)
			{
				return;
			}
			if(dotType == 5)
			{
				if(shieldRegenCounter > -dotDuration * 1000)
				{
					shieldRegenCounter = -dotDuration * 1000;
				}
			}
			if(dotType == 6)
			{
				if(disableHealEndtime < g.time)
				{
					disableHealEndtime = g.time + dotDuration * 1000;
				}
			}
			if(dotType == 11)
			{
				if(disableHealEndtime < g.time)
				{
					disableHealEndtime = g.time + dotDuration * 1000;
				}
				if(shieldRegenCounter > -dotDuration * 1000)
				{
					shieldRegenCounter = -dotDuration * 1000;
				}
			}
			if(dotType == 12)
			{
				trace("Slowdown: dotDuration");
				if(!(this is PlayerShip))
				{
					if(slowDownEndtime < g.time)
					{
						slowDown = 0.5;
						slowDownEndtime = g.time + dotDuration * 1000;
					}
				}
			}
			if(dotTimers.length > 0 && dotTimers[0]._active && this.dotEffect == dotEffect)
			{
				for each(var _loc6_ in dotTimers)
				{
					_loc6_.restart();
				}
			}
			else
			{
				for each(var _loc9_ in dotTimers)
				{
					_loc9_.seek(_loc9_.totalDuration(),false);
				}
				dotTimers.splice(0,-1);
				_loc8_ = EmitterFactory.create(dotEffect,g,pos.x,pos.y,this,true);
				for each(var _loc7_ in _loc8_)
				{
					_loc5_ = TweenMax.to(_loc7_,dotDuration,{
						"startAlpha":0.1,
						"onComplete":removeDot(_loc7_)
					});
					dotTimers.push(_loc5_);
				}
				this.dotEffect = dotEffect;
			}
			if(dotText != "" && this == g.me.ship)
			{
				g.textManager.createDebuffText(dotText,this);
			}
		}
		
		override public function switchTexturesByObj(obj:Object, textureAtlas:String = "texture_main_NEW.png") : void
		{
			super.switchTexturesByObj(obj);
		}
		
		private function removeDot(e:Emitter) : Function
		{
			return function():void
			{
				e.killEmitter();
			};
		}
		
		public function activate() : void
		{
			active = true;
			alive = true;
			hp = _hpMax;
			shieldHp = _shieldHpMax;
			for each(var _loc1_ in triggers)
			{
				_loc1_.reEnable();
			}
		}
		
		public function destroy(explode:Boolean = true) : void
		{
			var _loc3_:ISound = null;
			alive = false;
			if(explode)
			{
				hp = 0;
				shieldHp = 0;
				if(g.camera.isCircleOnScreen(x,y,radius))
				{
					EmitterFactory.create(explosionEffect,g,pos.x,pos.y,null,true);
					_loc3_ = SoundLocator.getService();
					_loc3_.play(explosionSound);
				}
			}
			if(parentObj is Boss)
			{
				for each(var _loc4_ in triggers)
				{
					_loc4_.tryActivateTrigger(this,Boss(parentObj));
				}
				if(!(this is Spawner))
				{
					visible = false;
				}
			}
			for each(var _loc2_ in dotTimers)
			{
				_loc2_.seek(_loc2_.totalDuration(),false);
			}
			g.emitterManager.clean(this);
		}
		
		override public function draw() : void
		{
			var _loc1_:Number = pos.x;
			var _loc2_:Number = pos.y;
			var _loc4_:Number = _mc.pivotX * _mc.scaleX;
			var _loc3_:Number = _mc.pivotY * _mc.scaleY;
			if(alive && g.solarSystem.isPvpSystemInEditor)
			{
				hpBar.height = 3;
				hpBar.y = _loc2_ + _loc3_ + 10;
				hpBar.x = _loc1_;
				shieldBar.height = 3;
				shieldBar.x = _loc1_;
				shieldBar.y = _loc2_ + _loc3_ + 7;
				if(!miniBarsAreAddedToCanvas)
				{
					canvas.addChild(hpBar);
					canvas.addChild(shieldBar);
					miniBarsAreAddedToCanvas = true;
				}
			}
			else if(alive && isInjured)
			{
				hpBar.height = 2;
				hpBar.y = _loc2_ + _loc3_ + 9;
				hpBar.x = _loc1_;
				shieldBar.height = 2;
				shieldBar.x = _loc1_;
				shieldBar.y = _loc2_ + _loc3_ + 7;
				if(isAddedToCanvas && !miniBarsAreAddedToCanvas && !isBossUnit)
				{
					canvas.addChild(hpBar);
					canvas.addChild(shieldBar);
					miniBarsAreAddedToCanvas = true;
				}
			}
			else if(miniBarsAreAddedToCanvas)
			{
				canvas.removeChild(hpBar);
				canvas.removeChild(shieldBar);
				miniBarsAreAddedToCanvas = false;
			}
			super.draw();
		}
		
		public function get speed() : Point
		{
			return _speed;
		}
		
		public function set speed(value:Point) : void
		{
			_speed = value;
		}
		
		override public function reset() : void
		{
			var _loc1_:int = 0;
			syncId = -1;
			team = -1;
			active = true;
			hideIfInactive = false;
			alive = false;
			essential = false;
			invulnerable = false;
			owner = null;
			hp = 100;
			hpMax = 100;
			armorThreshold = 0;
			armorThresholdBase = 0;
			shieldHp = 0;
			shieldHpMax = 0;
			shieldRegen = 0;
			shieldRegenBase = 0;
			shieldRegenCounter = 0;
			shieldRegenDuration = 1000;
			shieldRegenBonus = 1;
			disableHealEndtime = 0;
			slowDownEndtime = 0;
			explosionEffect = "";
			collisionRadius = 15;
			hasDmgBoost = false;
			usingDmgBoost = false;
			dmgBoostCD = 0;
			dmgBoostDuration = 0;
			dmgBoostEndTime = 0;
			dmgBoostNextRdy = 0;
			dmgBoostCost = 0;
			dmgBoostBonus = 0;
			dotTimers.splice(0,-1);
			dotEffect = null;
			_loc1_ = 0;
			while(_loc1_ < 5)
			{
				resistances[_loc1_] = 0;
				_loc1_++;
			}
			group = null;
			factions = new Vector.<String>();
			isHostile = false;
			hpRegen = 0;
			hpRegenCounter = 0;
			hpRegenDuration = 1000;
			speed.x = 0;
			speed.y = 0;
			x = 0;
			y = 0;
			lastDmgText = null;
			lastDmgTextOffset = 0;
			lastDmgTime = 0;
			lastDmg = 0;
			lastHealText = null;
			lastHealTextOffset = 0;
			lastHealTime = 0;
			lastHeal = 0;
			_bodyName = null;
			_name = null;
			if(originalFilter != null)
			{
				originalFilter.dispose();
				originalFilter = null;
			}
			stateMachine = new StateMachine();
			enginePos.x = 0;
			enginePos.y = 0;
			weaponPos.x = 0;
			weaponPos.y = 0;
			super.reset();
			lastBulletLocal = 0;
			lastBulletGlobal = 0;
			lastBulletTargetList = new Vector.<Unit>();
			miniBarsAreAddedToCanvas = false;
			isInjured = false;
			nextDistanceCalculation = -1;
			isBossUnit = false;
			hpBar.visible = true;
			shieldBar.visible = true;
			uberDifficulty = 0;
			uberLevelFactor = 0;
			level = 0;
			xp = 0;
			g.emitterManager.clean(this);
			triggers.splice(0,-1);
			triggersToActivte = 1;
		}
		
		public function get type() : String
		{
			return "Unit, unidentified type!";
		}
		
		public function toString() : String
		{
			return "[ Name: " + _name + " Body name: " + _bodyName + " Type: " + type + " ]";
		}
		
		public function set bodyName(value:String) : void
		{
			_bodyName = value;
		}
		
		public function get bodyName() : String
		{
			return _bodyName;
		}
		
		public function addToCanvasForReal() : void
		{
			super.addToCanvas();
		}
		
		override public function removeFromCanvas() : void
		{
			if(!isAddedToCanvas)
			{
				return;
			}
			super.removeFromCanvas();
			if(miniBarsAreAddedToCanvas)
			{
				canvas.removeChild(hpBar);
				canvas.removeChild(shieldBar);
				miniBarsAreAddedToCanvas = false;
			}
		}
		
		public function hasFaction(faction:String) : Boolean
		{
			for each(var _loc2_ in factions)
			{
				if(_loc2_ == faction)
				{
					return true;
				}
			}
			return false;
		}
	}
}

