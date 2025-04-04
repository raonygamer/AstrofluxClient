package core.spawner
{
	import com.greensock.TweenMax;
	import core.boss.Boss;
	import core.boss.Trigger;
	import core.particle.Emitter;
	import core.particle.EmitterFactory;
	import core.scene.Game;
	import core.solarSystem.Body;
	import core.states.AIStates.AITurret;
	import core.turret.Turret;
	import core.turret.TurretFactory;
	import core.unit.Unit;
	import flash.geom.Point;
	import generics.Util;
	import sound.ISound;
	import sound.SoundLocator;
	import starling.core.Starling;
	import starling.textures.Texture;
	import textures.ITextureManager;
	import textures.TextureLocator;
	import textures.TextureManager;
	
	public class Spawner extends Unit
	{
		public static const TYPE_ORGANIC:String = "organic";
		public static const TYPE_MECH:String = "mech";
		public static const TYPE_ABSTRACT:String = "abstract";
		public var spawnerType:String;
		public var orbitRadius:int;
		public var orbitAngle:Number = 0;
		public var angleVelocity:Number = 0;
		public var rotationSpeed:Number = 0;
		public var angleOffset:Number = 0;
		public var hidden:Boolean;
		public var innerRadius:int;
		public var outerRadius:int;
		public var key:String;
		public var objKey:String;
		public var offset:Point;
		public var turrets:Vector.<Turret>;
		public var imageOffset:Point;
		public var imageScale:Number;
		public var initialHardenedShield:Boolean = false;
		private var aiHardenedShieldEffect:Vector.<Emitter> = new Vector.<Emitter>();
		private var deadTextures:Vector.<Texture>;
		
		public function Spawner(g:Game)
		{
			canvas = g.canvasSpawners;
			super(g);
			alive = false;
			turrets = new Vector.<Turret>();
			dotTimers = new Vector.<TweenMax>();
			deadTextures = TextureManager.BASIC_TEXTURES;
		}
		
		override public function update() : void
		{
			if(hp <= 0)
			{
				alive = false;
			}
			var _loc1_:* = parentObj is Boss;
			if(_loc1_)
			{
				_pos.x = offset.x * Math.cos(parentObj.rotation) - offset.y * Math.sin(parentObj.rotation) + parentObj.pos.x;
				_pos.y = offset.x * Math.sin(parentObj.rotation) + offset.y * Math.cos(parentObj.rotation) + parentObj.pos.y;
				rotation = parentObj.rotation + angleOffset;
			}
			if(alive && active)
			{
				if(_loc1_)
				{
					for each(var _loc4_ in triggers)
					{
						_loc4_.tryActivateTrigger(this,Boss(parentObj));
					}
				}
				if(parentObj is Body)
				{
					super.updateHealthBars();
				}
				super.regenerateShield();
				for each(var _loc2_ in turrets)
				{
					_loc2_.update();
				}
				if(lastDmgText != null)
				{
					lastDmgText.x = _pos.x;
					lastDmgText.y = _pos.y - 25 + lastDmgTextOffset;
					lastDmgTextOffset += lastDmgText.speed.y * 33 / 1000;
					if(lastDmgTime < g.time - 1000)
					{
						lastDmgTextOffset = 0;
						lastDmgText = null;
					}
				}
				if(!_loc1_)
				{
					if(initialHardenedShield && aiHardenedShieldEffect.length == 0)
					{
						hardenShield();
					}
					if(!initialHardenedShield && aiHardenedShieldEffect.length > 0)
					{
						for each(var _loc3_ in aiHardenedShieldEffect)
						{
							_loc3_.killEmitter();
						}
						aiHardenedShieldEffect.splice(0,aiHardenedShieldEffect.length);
					}
				}
				if(lastHealText != null)
				{
					lastHealText.x = _pos.x;
					lastHealText.y = _pos.y - 10 + lastHealTextOffset;
					lastHealTextOffset += lastHealText.speed.y * 33 / 1000;
					if(lastHealTime < g.time - 1000)
					{
						lastHealTextOffset = 0;
						lastHealText = null;
					}
				}
				super.update();
			}
		}
		
		public function updatePos(startTime:Number) : void
		{
			var _loc2_:Number = g.time;
			var _loc3_:Number = orbitAngle + angleVelocity * 33 / 1000 * (_loc2_ - startTime);
			var _loc4_:Number = orbitRadius * Math.cos(_loc3_);
			var _loc5_:Number = orbitRadius * Math.sin(_loc3_);
			_pos.x = _loc4_ + parentObj.x;
			_pos.y = _loc5_ + parentObj.y;
			rotation = -rotationSpeed * Math.atan2(_pos.x - parentObj.x,_pos.y - parentObj.y) + 3.141592653589793 / 2 + Util.sign(angleVelocity) * 3.141592653589793 / 2;
		}
		
		public function addTurrets(obj:Object) : void
		{
			var _loc3_:* = this;
			var _loc2_:Array = obj.turrets;
			if(_loc2_.length > 0)
			{
				for each(var _loc4_ in _loc2_)
				{
					createTurret(_loc4_,_loc3_);
				}
			}
		}
		
		private function createTurret(turretObj:Object, s:Spawner) : void
		{
			if(this.parentObj is Boss)
			{
				return;
			}
			var _loc3_:Turret = TurretFactory.createTurret(turretObj,turretObj.turret,g);
			_loc3_.offset = new Point(turretObj.xpos,turretObj.ypos);
			_loc3_.startAngle = Util.degreesToRadians(turretObj.angle);
			_loc3_.syncId = turretObj.id;
			_loc3_.parentObj = s;
			_loc3_.alive = true;
			_loc3_.rotation = _loc3_.startAngle;
			_loc3_.name = turretObj.name;
			_loc3_.factions = factions;
			g.unitManager.add(_loc3_,g.canvasTurrets,false);
			s.turrets.push(_loc3_);
			_loc3_.stateMachine.changeState(new AITurret(g,_loc3_));
		}
		
		override public function destroy(explode:Boolean = true) : void
		{
			var _loc3_:ISound = null;
			if(imgObj != null)
			{
				changeStateTextures(deadTextures);
			}
			if(this.parentObj is Boss)
			{
				super.destroy(explode);
				return;
			}
			for each(var _loc2_ in turrets)
			{
				_loc2_.destroy(_loc2_.alive);
			}
			super.destroy(explode);
			if(parentObj is Body)
			{
				if(g.camera.isCircleOnScreen(x,y,radius))
				{
					_loc3_ = SoundLocator.getService();
					if(explode)
					{
						if(isMech())
						{
							_loc3_.play("5psyX2Y9e0m39q43L_uEGg");
						}
						else
						{
							_loc3_.play(explosionSound);
						}
					}
				}
				Body(parentObj).setSpawnersCleared(explode);
			}
		}
		
		public function rebuild() : void
		{
			hp = hpMax;
			shieldHp = shieldHpMax;
			if(parentObj is Boss)
			{
				tryAdjustUberStats(parentObj as Boss);
			}
			else
			{
				tryAdjustUberStats(null);
			}
			if(imgObj != null)
			{
				changeStateTextures(_textures,imgObj.animateOnStart);
			}
			for each(var _loc1_ in turrets)
			{
				_loc1_.rebuild();
			}
			if(parentObj != null && parentObj is Body)
			{
				Body(parentObj).spawnersCleared = false;
			}
			alive = true;
		}
		
		public function tryAdjustUberStats(b:Boss) : void
		{
			var _loc2_:Number = NaN;
			var _loc3_:Object = g.dataManager.loadKey("Spawners",objKey);
			level = _loc3_.level;
			if(b != null)
			{
				level = b.level;
			}
			if(g.isSystemTypeSurvival() && !hidden && level < g.hud.uberStats.uberLevel)
			{
				_loc2_ = g.hud.uberStats.CalculateUberRankFromLevel(level);
				uberDifficulty = g.hud.uberStats.CalculateUberDifficultyFromRank(g.hud.uberStats.uberRank - _loc2_,level);
				uberLevelFactor = 1 + (g.hud.uberStats.uberLevel - level) / 100;
				if(b != null)
				{
					uberDifficulty *= g.hud.uberStats.uberRank / 2 + 1;
				}
				hp = hpMax = _loc3_.hp * uberDifficulty;
				shieldHp = shieldHpMax = _loc3_.shieldHp * uberDifficulty;
				xp = _loc3_.xp * uberLevelFactor;
				level = g.hud.uberStats.uberLevel;
			}
		}
		
		public function hardenShield() : void
		{
			aiHardenedShieldEffect = EmitterFactory.create("uWIxfxRAgUm6ThgrRFnixw",g,pos.x,pos.y,this,true);
		}
		
		override public function switchTexturesByObj(obj:Object, textureAtlas:String = "texture_main_NEW.png") : void
		{
			super.switchTexturesByObj(obj,textureAtlas);
			var _loc3_:ITextureManager = TextureLocator.getService();
			if(imgObj != null)
			{
				deadTextures = _loc3_.getTexturesMainByTextureName(imgObj.textureName.replace("active","dead"));
			}
		}
		
		protected function changeStateTextures(textures:Vector.<Texture>, animate:Boolean = false) : void
		{
			if(textures == null)
			{
				throw new TypeError("Texture can not be null.");
			}
			Starling.juggler.remove(_mc);
			swapFrames(_mc,textures);
			_mc.fps = imgObj.animationDelay;
			_mc.readjustSize();
			if(animate)
			{
				Starling.juggler.add(_mc);
			}
			_mc.pivotX = _mc.texture.width / 2;
			_mc.pivotY = _mc.texture.height / 2;
		}
		
		public function isMech() : Boolean
		{
			return spawnerType == "mech";
		}
		
		override public function get type() : String
		{
			return "spawner";
		}
	}
}

