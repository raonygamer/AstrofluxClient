package core.projectile
{
	import core.GameObject;
	import core.particle.Emitter;
	import core.particle.EmitterFactory;
	import core.scene.Game;
	import core.ship.PlayerShip;
	import core.states.StateMachine;
	import core.unit.Unit;
	import core.weapon.Weapon;
	import extensions.RibbonSegment;
	import extensions.RibbonTrail;
	import flash.geom.Point;
	import movement.Heading;
	import sound.ISound;
	import sound.SoundLocator;
	import starling.core.Starling;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class Projectile extends GameObject
	{
		private static const DT:Number = 33;
		
		private static const DTxDT_HALF:Number = Math.pow(33,2) * 0.5;
		
		public var numberOfHits:int;
		
		public var alive:Boolean;
		
		public var ttl:int;
		
		public var ttlMax:int;
		
		public var speed:Point = new Point();
		
		public var speedMax:Number;
		
		public var rotationSpeedMax:Number;
		
		public var acceleration:Number;
		
		public var stateMachine:StateMachine;
		
		public var unit:Unit;
		
		public var weapon:Weapon;
		
		public var dmgRadius:int;
		
		public var wave:Boolean;
		
		public var waveDirection:int;
		
		public var waveAmplitude:Number;
		
		public var waveFrequency:Number;
		
		public var clusterProjectile:String;
		
		public var clusterNrOfSplits:int;
		
		public var clusterNrOfProjectiles:int;
		
		public var clusterAngle:Number;
		
		public var aiAlwaysExplode:Boolean;
		
		public var oldPos:Point = new Point();
		
		public var boomerangReturnTime:int;
		
		public var boomerangReturning:Boolean;
		
		public var direction:int;
		
		public var ps:PlayerShip;
		
		public var range:Number;
		
		public var debuffType:int;
		
		public var target:Unit;
		
		public var targetProjectile:Projectile;
		
		public var error:Point;
		
		public var convergenceTime:int;
		
		public var convergenceCounter:int;
		
		public var collisionRadius:Number;
		
		public var useShipSystem:Boolean;
		
		public var course:Heading = new Heading();
		
		public var thrustEmitters:Vector.<Emitter>;
		
		public var randomAngle:Boolean;
		
		public var explosionEffect:String;
		
		public var explosionSound:String;
		
		public var isVisible:Boolean = false;
		
		public var isEnemy:Boolean;
		
		public var isHeal:Boolean;
		
		public var aiStuck:Boolean;
		
		public var aiStuckDuration:int;
		
		public var aiTargetSelf:Boolean;
		
		public var aiDelayedAcceleration:Boolean;
		
		public var aiDelayedAccelerationTime:int = 0;
		
		private var g:Game;
		
		public var ai:String;
		
		public var errorRot:Number;
		
		public var hasRibbonTrail:Boolean = false;
		
		public var useRibbonOffset:Boolean = false;
		
		public var ribbonThickness:Number = 0;
		
		public var ribbonTrail:RibbonTrail;
		
		private var followingRibbonSegment:RibbonSegment = new RibbonSegment();
		
		public var followingRibbonSegmentLine:Vector.<RibbonSegment> = new <RibbonSegment>[followingRibbonSegment];
		
		private var hasDoneFirstUpdate:Boolean = false;
		
		private var tempVx:Number = 0;
		
		private var tempVy:Number = 0;
		
		public function Projectile(g:Game)
		{
			super();
			canvas = g.canvasProjectiles;
			target = null;
			stateMachine = new StateMachine();
			this.g = g;
			alive = false;
			ttl = 0;
			thrustEmitters = new Vector.<Emitter>();
		}
		
		override public function update() : void
		{
			var _loc2_:Point = null;
			var _loc1_:* = false;
			stateMachine.update();
			if(weapon.maxProjectiles == 0)
			{
				ttl -= 33;
				if(ttl <= 0 && !aiAlwaysExplode)
				{
					destroy(false);
				}
			}
			else if((unit == null || !unit.alive) && !isEnemy)
			{
				destroy(false);
			}
			if(alive)
			{
				_pos.x = course.pos.x;
				_pos.y = course.pos.y;
				if(!randomAngle)
				{
					_rotation = course.rotation;
				}
				_loc2_ = g.camera.getCameraCenter();
				distanceToCameraX = _pos.x - _loc2_.x;
				distanceToCameraY = _pos.y - _loc2_.y;
				_loc1_ = distanceToCameraX * distanceToCameraX + distanceToCameraY * distanceToCameraY < g.stage.stageWidth * g.stage.stageWidth;
				if(isVisible && !_loc1_)
				{
					isVisible = false;
					if(ribbonTrail != null)
					{
						ribbonTrail.isPlaying = false;
					}
				}
				else if(!isVisible && _loc1_)
				{
					isVisible = true;
					if(ribbonTrail != null)
					{
						ribbonTrail.isPlaying = true;
					}
				}
				updateRibbonTrail();
			}
			if(!hasDoneFirstUpdate)
			{
				draw();
				hasDoneFirstUpdate = true;
			}
			super.update();
		}
		
		private function updateRibbonTrail() : void
		{
			var _loc5_:Number = NaN;
			var _loc4_:Number = NaN;
			var _loc7_:* = NaN;
			var _loc6_:Number = NaN;
			var _loc1_:Number = NaN;
			var _loc3_:Number = NaN;
			if(!ribbonTrail)
			{
				return;
			}
			if(!ribbonTrail.isPlaying)
			{
				return;
			}
			if(!isVisible)
			{
				return;
			}
			var _loc2_:Number = Math.atan2(course.speed.y,course.speed.x) + 3.141592653589793;
			if(useRibbonOffset)
			{
				_loc5_ = 0;
				_loc7_ = _loc4_ = -radius;
				_loc6_ = 0;
				if(_loc4_ != 0)
				{
					_loc6_ = Math.atan(_loc5_ / _loc4_);
				}
				_loc1_ = Math.cos(_rotation + _loc6_) * _loc7_;
				_loc3_ = Math.sin(_rotation + _loc6_) * _loc7_;
				followingRibbonSegment.setTo2(_pos.x + _loc1_,_pos.y + _loc3_,ribbonThickness,_loc2_);
			}
			else
			{
				followingRibbonSegment.setTo2(_pos.x,_pos.y,ribbonThickness,_loc2_);
			}
			ribbonTrail.advanceTime(33);
		}
		
		public function fastforward() : void
		{
			if(course.time + 10000 >= g.time)
			{
				while(course.time < g.time && alive)
				{
					stateMachine.update();
					ttl -= 33;
					if(alive)
					{
						_pos.x = course.pos.x;
						_pos.y = course.pos.y;
						_rotation = course.rotation;
					}
				}
			}
		}
		
		public function updateHeading(heading:Heading) : void
		{
			var _loc2_:Number = NaN;
			var _loc3_:Number = NaN;
			if(!useShipSystem)
			{
				if(acceleration != 0)
				{
					tempVx = heading.speed.x;
					tempVy = heading.speed.y;
					if(wave)
					{
						_loc2_ = waveAmplitude / 3 * Math.sin(waveFrequency * (ttlMax - ttl)) * waveDirection;
						tempVx += Math.cos(heading.rotation + _loc2_) * acceleration * DTxDT_HALF;
						tempVy += Math.sin(heading.rotation + _loc2_) * acceleration * DTxDT_HALF;
					}
					else
					{
						tempVx += Math.cos(heading.rotation) * acceleration * DTxDT_HALF;
						tempVy += Math.sin(heading.rotation) * acceleration * DTxDT_HALF;
					}
					if(tempVx * tempVx + tempVy * tempVy <= speedMax * speedMax)
					{
						heading.speed.x = tempVx;
						heading.speed.y = tempVy;
					}
					else
					{
						_loc3_ = Math.sqrt(tempVx * tempVx + tempVy * tempVy);
						heading.speed.x = speedMax * tempVx / _loc3_;
						heading.speed.y = speedMax * tempVy / _loc3_;
					}
				}
				heading.speed.x -= weapon.friction * heading.speed.x + 0.009 * heading.speed.x;
				heading.speed.y -= weapon.friction * heading.speed.y + 0.009 * heading.speed.y;
			}
			heading.pos.x += 0.001 * heading.speed.x * 33;
			heading.pos.y += 0.001 * heading.speed.y * 33;
			heading.time += 33;
		}
		
		public function explode(forceExplode:Boolean = false, followTarget:Unit = null) : void
		{
			var _loc3_:* = undefined;
			var _loc5_:* = null;
			var _loc4_:ISound = null;
			if(forceExplode || g.camera.isCircleOnScreen(pos.x,pos.y,radius))
			{
				if(explosionEffect != null)
				{
					if(dmgRadius > 25 || unit != null && unit.nextHitEffectReady < g.time && Game.highSettings)
					{
						unit.nextHitEffectReady = g.time + 50;
						_loc3_ = EmitterFactory.create(explosionEffect,g,pos.x,pos.y,followTarget,true);
						if(forceExplode)
						{
							for each(_loc5_ in _loc3_)
							{
								_loc5_.global = true;
							}
						}
						if(explosionSound != null)
						{
							_loc4_ = SoundLocator.getService();
							_loc4_.play(explosionSound);
						}
					}
				}
			}
		}
		
		public function destroy(explode:Boolean = true) : void
		{
			var _loc3_:int = 0;
			if(weapon.maxProjectiles > 0)
			{
				_loc3_ = int(weapon.projectiles.indexOf(this));
				weapon.projectiles.splice(_loc3_,1);
			}
			if(explode)
			{
				this.explode(false,null);
			}
			for each(var _loc2_ in thrustEmitters)
			{
				_loc2_.killEmitter();
			}
			alive = false;
			if(stateMachine.inState("Instant"))
			{
				stateMachine.update();
			}
		}
		
		public function ignite() : void
		{
			var _loc1_:int = 0;
			_loc1_ = 0;
			while(_loc1_ < thrustEmitters.length)
			{
				thrustEmitters[_loc1_].play();
				_loc1_++;
			}
		}
		
		public function disable() : void
		{
			if(ai == "mine")
			{
				switchTextures(imgObj.textureName.replace("active","disabled"));
			}
		}
		
		public function activate() : void
		{
			if(ai == "mine")
			{
				switchTextures(imgObj.textureName);
				Starling.juggler.add(_mc);
			}
		}
		
		private function switchTextures(textureName:String) : void
		{
			var _loc2_:ITextureManager = TextureLocator.getService();
			_textures = _loc2_.getTexturesMainByTextureName(textureName);
			swapFrames(_mc,_textures);
		}
		
		public function tryAddRibbonTrail() : void
		{
			if(hasRibbonTrail)
			{
				ribbonTrail.resetAllTo(_pos.x,_pos.y,_pos.x,_pos.y,0.85);
				updateRibbonTrail();
			}
		}
		
		override public function addToCanvas() : void
		{
			isAddedToCanvas = true;
			if(imgObj == null)
			{
				return;
			}
		}
		
		override public function removeFromCanvas() : void
		{
			isAddedToCanvas = false;
			if(imgObj == null)
			{
				return;
			}
		}
		
		override public function reset() : void
		{
			g.emitterManager.clean(this);
			id = 0;
			ttl = 0;
			numberOfHits = 0;
			ttlMax = 0;
			speedMax = 0;
			dmgRadius = 0;
			oldPos.x = 0;
			oldPos.y = 0;
			isEnemy = false;
			isHeal = false;
			aiAlwaysExplode = false;
			course.reset();
			speed.x = 0;
			speed.y = 0;
			name = null;
			rotationSpeedMax = 0;
			acceleration = 0;
			unit = null;
			target = null;
			thrustEmitters = null;
			explosionEffect = "";
			explosionSound = "";
			useShipSystem = false;
			randomAngle = false;
			boomerangReturning = false;
			boomerangReturnTime = 0;
			debuffType = -1;
			direction = 0;
			aiTargetSelf = false;
			aiStuck = false;
			aiStuckDuration = 0;
			errorRot = 0;
			aiDelayedAcceleration = false;
			aiDelayedAccelerationTime = 0;
			wave = false;
			waveDirection = 1;
			waveAmplitude = 0;
			waveFrequency = 0;
			hasRibbonTrail = false;
			ribbonThickness = 0;
			useRibbonOffset = false;
			if(ribbonTrail)
			{
				g.ribbonTrailPool.removeRibbonTrail(ribbonTrail);
				ribbonTrail.resetAllTo(0,0,0,0,0);
				ribbonTrail.isPlaying = false;
				ribbonTrail.visible = false;
				ribbonTrail = null;
			}
			clusterProjectile = "";
			clusterNrOfProjectiles = 0;
			clusterNrOfSplits = 0;
			clusterAngle = 0;
			hasDoneFirstUpdate = false;
			isVisible = false;
			ai = null;
			weapon = null;
			collisionRadius = 0;
			alive = false;
			error = null;
			errorRot = 0;
			stateMachine.exitCurrent();
			ps = null;
			super.reset();
		}
	}
}

