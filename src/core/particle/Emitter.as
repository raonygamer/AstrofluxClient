package core.particle
{
	import core.GameObject;
	import core.scene.Game;
	import flash.geom.Point;
	import generics.Color;
	import generics.GUID;
	import starling.display.Sprite;
	import starling.textures.Texture;
	
	public class Emitter
	{
		public static var POOL_SIZE_MIN:int = 5;
		public static var POOL_SIZE_MAX:int = 100;
		public static var IS_HIGH_GRAPHICS:Boolean = true;
		public var name:String;
		private var _txt:Texture;
		public var speed:Number;
		public var speedVariance:Number;
		public var sourceVarianceX:Number = 0;
		public var sourceVarianceY:Number = 0;
		public var gravityX:Number = 0;
		public var gravityY:Number = 0;
		public var useFriction:Boolean;
		public var alive:Boolean;
		public var angle:Number;
		public var posX:Number = 0;
		public var posY:Number = 0;
		public var steadyStream:Boolean;
		public var followEmitter:Boolean;
		public var followTarget:Boolean;
		public var target:GameObject;
		public var targetPosX:Number = 0;
		public var targetPosY:Number = 0;
		public var global:Boolean;
		public var delay:Number;
		public var ttl:int;
		public var ttlVariance:int;
		private var _startSize:Number;
		public var startSizeVariance:Number;
		private var _finishSize:Number;
		public var finishSizeVariance:Number;
		public var angleVariance:Number;
		public var uniformDistribution:Boolean;
		public var centralGravity:Boolean;
		private var maxRadius:Number;
		private var maxSize:Number;
		public var startAlpha:Number;
		public var startAlphaVariance:Number;
		public var finishAlpha:Number;
		public var startBlendMode:String;
		public var finishBlendMode:String;
		public var shakeIntensity:Number = 0;
		public var shakeDuration:Number = 0;
		public var key:String;
		public var guid:String;
		public var xOffset:int = 0;
		public var yOffset:int = 0;
		public var canvasTarget:Sprite;
		public var oldImageKey:String = "";
		private var _maxParticles:int;
		private var _duration:int;
		public var isEmitting:Boolean;
		private var timeElapsed:int = 0;
		private var emittAccum:Number = 0;
		private var g:Game;
		public var particles:Vector.<Particle>;
		private var inactiveParticles:Vector.<Particle>;
		public var collectiveMeshBatch:CollectiveMeshBatch;
		public var isOnScreen:Boolean = false;
		public var forceUpdate:Boolean;
		public var distanceToCamera:int = 0;
		public var distanceToCameraX:int = 0;
		public var distanceToCameraY:int = 0;
		public var nextDistanceCalculation:int = -1;
		private var MAX_CALC_DELAY:int = 5000;
		private var _startColor:uint = 0;
		private var _originalStartColor:uint = 0;
		private var _finishColor:uint = 0;
		private var _originalFinishColor:uint = 0;
		
		public function Emitter(g:Game)
		{
			var _loc2_:int = 0;
			particles = new Vector.<Particle>();
			inactiveParticles = new Vector.<Particle>();
			this.g = g;
			super();
			guid = GUID.create();
			_loc2_ = 0;
			while(_loc2_ < POOL_SIZE_MIN)
			{
				inactiveParticles.push(new Particle());
				_loc2_++;
			}
		}
		
		public static function setLowGraphics() : void
		{
			POOL_SIZE_MIN = 2;
			POOL_SIZE_MAX = 6;
			IS_HIGH_GRAPHICS = false;
		}
		
		public static function setHighGraphics() : void
		{
			POOL_SIZE_MIN = 5;
			POOL_SIZE_MAX = 100;
			IS_HIGH_GRAPHICS = true;
		}
		
		public function set startSize(value:Number) : void
		{
			_startSize = value;
			maxSize = Math.max(_startSize,_finishSize);
		}
		
		public function get startSize() : Number
		{
			return _startSize;
		}
		
		public function set finishSize(value:Number) : void
		{
			_finishSize = value;
			maxSize = Math.max(_startSize,_finishSize);
		}
		
		public function get finishSize() : Number
		{
			return _finishSize;
		}
		
		public function play() : void
		{
			var _loc1_:Number = NaN;
			var _loc3_:Number = NaN;
			var _loc4_:Number = NaN;
			var _loc5_:Number = NaN;
			var _loc7_:Number = NaN;
			var _loc2_:Number = NaN;
			var _loc6_:int = 0;
			timeElapsed = 0;
			isEmitting = true;
			nextDistanceCalculation = -1;
			if(shakeIntensity > 0 && shakeDuration > 0)
			{
				if(g.me == null || g.me.ship == null)
				{
					return;
				}
				_loc1_ = posX - g.me.ship.pos.x;
				_loc3_ = posY - g.me.ship.pos.y;
				_loc4_ = _loc1_ * _loc1_ + _loc3_ * _loc3_;
				_loc5_ = 10000;
				if(_loc4_ > _loc5_)
				{
					return;
				}
				_loc7_ = _loc4_ == 0 ? 1 : _loc4_ / _loc5_;
				_loc2_ = (shakeIntensity - shakeIntensity * _loc7_) / 10;
				_loc6_ = shakeDuration;
				if(_loc2_ > 0.0015)
				{
					g.camera.shake(_loc2_,_loc6_);
				}
			}
		}
		
		public function stop() : void
		{
			isEmitting = false;
			isOnScreen = false;
			setParticlesInactive();
		}
		
		public function get radius() : Number
		{
			return maxRadius * maxSize;
		}
		
		private function updatePosition() : void
		{
			var _loc2_:Number = NaN;
			var _loc1_:Number = NaN;
			if(!followTarget || target == null)
			{
				return;
			}
			targetPosX = target.pos.x;
			targetPosY = target.pos.y;
			if(yOffset != 0)
			{
				_loc2_ = Math.abs(yOffset);
				_loc1_ = Math.atan(yOffset);
				posX = targetPosX + Math.cos(angle + _loc1_) * _loc2_;
				posY = targetPosY + Math.sin(angle + _loc1_) * _loc2_;
				angle = target.rotation + 3.141592653589793;
			}
			else
			{
				posX = targetPosX;
				posY = targetPosY;
				angle = target.rotation;
			}
		}
		
		private function updateOnScreen() : void
		{
			forceUpdate = false;
			isOnScreen = canvasTarget != null;
			if(isOnScreen)
			{
				nextDistanceCalculation = 1000;
				return;
			}
			isOnScreen = g.camera.isCircleOnScreen(this.posX,this.posY,100);
			if(isOnScreen)
			{
				nextDistanceCalculation = 1000;
				return;
			}
			var _loc1_:Point = g.camera.getCameraCenter();
			distanceToCameraX = posX - _loc1_.x;
			distanceToCameraY = posY - _loc1_.y;
			distanceToCamera = Math.sqrt(distanceToCameraX * distanceToCameraX + distanceToCameraY * distanceToCameraY);
			nextDistanceCalculation = distanceToCamera;
			if(nextDistanceCalculation > MAX_CALC_DELAY)
			{
				nextDistanceCalculation = MAX_CALC_DELAY + Math.random() * 200;
			}
			isOnScreen = false;
		}
		
		public function update() : void
		{
			var _loc2_:int = 0;
			if(constantEmitter && !isEmitting)
			{
				return;
			}
			var _loc1_:int = 33;
			nextDistanceCalculation -= _loc1_;
			if(nextDistanceCalculation <= 0)
			{
				updatePosition();
				updateOnScreen();
			}
			else if(isOnScreen || forceUpdate)
			{
				updatePosition();
			}
			if(!isOnScreen && !global)
			{
				setParticlesInactive();
				updateTime();
				return;
			}
			if(isEmitting && timeElapsed >= delay)
			{
				updateParticleCount();
			}
			drawParticels();
			setBatchParent();
			updateTime();
		}
		
		private function updateTime() : void
		{
			if(constantEmitter)
			{
				return;
			}
			if(isEmitting)
			{
				timeElapsed += 33;
			}
			if(timeElapsed >= _duration + delay)
			{
				isEmitting = false;
				if(particles.length == 0)
				{
					alive = false;
				}
			}
		}
		
		private function get constantEmitter() : Boolean
		{
			return _duration == -1;
		}
		
		private function updateParticleCount() : void
		{
			var _loc4_:int = 0;
			var _loc5_:int = 0;
			var _loc2_:int = 0;
			var _loc1_:int = 33;
			if(!constantEmitter || steadyStream)
			{
				emittAccum += ppms * _loc1_;
				if(emittAccum >= 1)
				{
					_loc2_ = emittAccum;
					emittAccum = 0;
				}
			}
			else
			{
				_loc2_ = 1;
			}
			var _loc3_:int = int(particles.length);
			var _loc6_:int = int(inactiveParticles.length);
			if(_loc2_ > _loc6_ && _loc3_ + _loc6_ < POOL_SIZE_MAX)
			{
				_loc5_ = _loc2_ - _loc6_;
				if(_loc5_ + _loc3_ + _loc6_ > POOL_SIZE_MAX)
				{
					_loc5_ = POOL_SIZE_MAX - (_loc3_ + _loc6_);
				}
				if(_loc5_ > 0)
				{
					_loc4_ = 0;
					while(_loc4_ < _loc5_)
					{
						inactiveParticles.push(new Particle());
						_loc4_++;
					}
				}
			}
			_loc5_ = maxParticles - _loc3_;
			_loc4_ = 1;
			while(_loc4_ <= _loc2_)
			{
				add(_loc4_,_loc5_);
				_loc4_++;
			}
		}
		
		public function drawParticels() : void
		{
			var _loc2_:Particle = null;
			var _loc8_:Number = NaN;
			var _loc4_:Number = NaN;
			var _loc12_:Number = NaN;
			var _loc6_:Number = NaN;
			var _loc9_:int = 0;
			var _loc11_:Number = NaN;
			var _loc10_:Number = NaN;
			var _loc5_:Number = NaN;
			collectiveMeshBatch.clear();
			var _loc1_:int = 33;
			var _loc7_:Number = _loc1_ * 0.001;
			var _loc3_:int = int(particles.length);
			_loc9_ = _loc3_ - 1;
			while(_loc9_ > -1)
			{
				_loc2_ = particles[_loc9_];
				if(_loc2_.ttl - _loc1_ <= 0)
				{
					remove(_loc2_,_loc9_);
				}
				else
				{
					_loc4_ = _loc2_.rotation;
					_loc12_ = _loc2_.speed * _loc7_;
					_loc11_ = _loc2_.ttl / _loc2_.totalTtl;
					if(!followEmitter)
					{
						_loc6_ = _loc2_.x;
						_loc8_ = _loc2_.y;
						_loc6_ += Math.cos(_loc4_) * _loc12_;
						_loc8_ += Math.sin(_loc4_) * _loc12_;
						_loc6_ += gravityX * _loc7_;
						_loc8_ += gravityY * _loc7_;
						if(centralGravity)
						{
							_loc6_ = (_loc6_ - posX) * _loc11_ + posX;
							_loc8_ = (_loc8_ - posY) * _loc11_ + posY;
						}
					}
					else
					{
						if(centralGravity)
						{
							_loc2_.localPosX *= _loc11_;
							_loc2_.localPosY *= _loc11_;
						}
						_loc2_.localPosX += Math.cos(_loc4_) * _loc12_;
						_loc2_.localPosY += Math.sin(_loc4_) * _loc12_;
						_loc6_ = _loc2_.localPosX + posX;
						_loc8_ = _loc2_.localPosY + posY;
						_loc2_.rotation = angle;
					}
					_loc2_.x = _loc6_;
					_loc2_.y = _loc8_;
					_loc10_ = (_loc2_.startSize - _loc2_.finishSize) * _loc11_ + _loc2_.finishSize;
					_loc2_.scaleX = _loc10_;
					_loc2_.scaleY = _loc10_;
					if(_loc2_.ticks % 3 == 0)
					{
						_loc2_.color = Color.interpolateColor(_startColor,_finishColor,1 - _loc11_);
					}
					_loc2_.ticks++;
					_loc5_ = (_loc2_.startAlpha - _loc2_.finishAlpha) * _loc11_ + _loc2_.finishAlpha;
					if(useFriction)
					{
						_loc2_.speed *= 0.98;
					}
					_loc2_.ttl -= _loc1_;
					if(isOnScreen)
					{
						collectiveMeshBatch.addMesh(_loc2_,null,_loc5_);
					}
					if(IS_HIGH_GRAPHICS && collectiveMeshBatch.numVertices > 800)
					{
						POOL_SIZE_MIN = 2;
						POOL_SIZE_MAX = 10;
					}
					else if(IS_HIGH_GRAPHICS && collectiveMeshBatch.numVertices < 400)
					{
						setHighGraphics();
					}
				}
				_loc9_--;
			}
		}
		
		public function setBatchParent() : void
		{
			if(collectiveMeshBatch.parent != null)
			{
				return;
			}
			if(canvasTarget)
			{
				canvasTarget.addChild(collectiveMeshBatch);
			}
			else
			{
				g.canvasEffects.addChild(collectiveMeshBatch);
			}
		}
		
		private function add(i:int = 0, maxNewParts:int = 1) : void
		{
			if(particles.length > maxParticles || inactiveParticles.length == 0)
			{
				return;
			}
			var _loc3_:Particle = inactiveParticles.pop();
			if(_loc3_.texture != _txt)
			{
				_loc3_.texture = _txt;
			}
			var _loc7_:Number = sourceVarianceY - Math.random() * sourceVarianceY * 2;
			var _loc6_:Number = sourceVarianceX - Math.random() * sourceVarianceX * 2;
			var _loc10_:Number = Math.sqrt(_loc6_ * _loc6_ + _loc7_ * _loc7_);
			var _loc9_:Number = Math.atan2(_loc7_,_loc6_);
			if(uniformDistribution && maxNewParts > 0)
			{
				_loc3_.rotation = angle + (angleVariance - (i / maxNewParts + 0.01 - 0.02 * Math.random()) * angleVariance * 2);
			}
			else
			{
				_loc3_.rotation = angle + (angleVariance - Math.random() * angleVariance * 2);
			}
			var _loc8_:Number = angle + _loc9_;
			var _loc4_:Number = Math.cos(_loc8_) * _loc10_;
			var _loc5_:Number = Math.sin(_loc8_) * _loc10_;
			_loc3_.x = posX + _loc4_;
			_loc3_.y = posY + _loc5_;
			_loc3_.localPosX = _loc4_;
			_loc3_.localPosY = _loc5_;
			_loc3_.totalTtl = ttl + (ttlVariance - Math.random() * ttlVariance * 2);
			_loc3_.ttl = _loc3_.totalTtl;
			_loc3_.speed = speed + (speedVariance - Math.random() * speedVariance * 2);
			_loc3_.startSize = startSize + (startSizeVariance - Math.random() * startSizeVariance * 2);
			_loc3_.finishSize = finishSize + (finishSizeVariance - Math.random() * finishSizeVariance * 2);
			_loc3_.startAlpha = startAlpha + (startAlphaVariance - Math.random() * startAlphaVariance * 2);
			_loc3_.finishAlpha = finishAlpha;
			_loc3_.visible = true;
			_loc3_.ticks = 0;
			particles.push(_loc3_);
		}
		
		private function remove(p:Particle, index:int) : void
		{
			inactiveParticles.push(p);
			if(index == particles.length - 1)
			{
				particles.pop();
			}
			else
			{
				particles[index] = particles.pop();
			}
		}
		
		private function setParticlesInactive() : void
		{
			var _loc1_:int = 0;
			if(particles.length == 0)
			{
				return;
			}
			_loc1_ = 0;
			while(_loc1_ < particles.length)
			{
				inactiveParticles.push(particles[_loc1_]);
				_loc1_++;
			}
			particles.length = 0;
		}
		
		public function killEmitter() : void
		{
			var _loc1_:int = 0;
			isEmitting = false;
			alive = false;
			_loc1_ = 0;
			while(_loc1_ < particles.length)
			{
				inactiveParticles.push(particles[_loc1_]);
				_loc1_++;
			}
			particles.length = 0;
			removeFromCollectiveMeshBatch();
		}
		
		private function removeFromCollectiveMeshBatch() : void
		{
			if(collectiveMeshBatch == null)
			{
				return;
			}
			collectiveMeshBatch.remove(this);
		}
		
		public function dispose() : void
		{
			sourceVarianceX = 0;
			sourceVarianceY = 0;
			ttl = 200;
			duration = -1;
			maxParticles = 100;
			speed = 0;
			speedVariance = 0;
			gravityX = 0;
			gravityY = 0;
			useFriction = true;
			ttlVariance = 0;
			startSize = 1;
			startSizeVariance = 0;
			finishSize = 0;
			finishSizeVariance = 0;
			angleVariance = 0;
			startColor = 0xffffff;
			finishColor = 0xffffff;
			startAlpha = 1;
			finishAlpha = 0;
			startAlphaVariance = 0;
			startBlendMode = "add";
			finishBlendMode = "add";
			steadyStream = false;
			followEmitter = false;
			followTarget = false;
			global = false;
			delay = 0;
			canvasTarget = null;
			target = null;
			targetPosX = 0;
			targetPosY = 0;
			shakeIntensity = 0;
			shakeDuration = 0;
			distanceToCamera = 0;
			distanceToCameraX = 0;
			distanceToCameraY = 0;
			isOnScreen = false;
			nextDistanceCalculation = -1;
			xOffset = 0;
			yOffset = 0;
			isEmitting = false;
			alive = false;
			angle = 0;
			collectiveMeshBatch = null;
		}
		
		public function set startColor(c:uint) : void
		{
			_startColor = c;
			_originalStartColor = c;
		}
		
		public function changeHue(r:Number) : void
		{
			_startColor = Color.HEXHue(_originalStartColor,r);
			_finishColor = Color.HEXHue(_originalFinishColor,r);
		}
		
		public function set finishColor(c:uint) : void
		{
			_finishColor = c;
			_originalFinishColor = c;
		}
		
		private function get ppms() : Number
		{
			if(duration != -1)
			{
				return _maxParticles / duration;
			}
			if(duration == -1 && steadyStream)
			{
				return _maxParticles / ttl;
			}
			return 1;
		}
		
		public function set duration(d:int) : void
		{
			_duration = d;
		}
		
		public function get duration() : int
		{
			return _duration;
		}
		
		public function set maxParticles(count:int) : void
		{
			if(count > POOL_SIZE_MAX)
			{
				_maxParticles = POOL_SIZE_MAX;
			}
			else
			{
				_maxParticles = count;
			}
		}
		
		public function get maxParticles() : int
		{
			return _maxParticles;
		}
		
		public function fastForward(ticks:int) : void
		{
			var _loc2_:int = 0;
			if(!alive)
			{
				return;
			}
			_loc2_ = 0;
			while(_loc2_ < ticks)
			{
				update();
				_loc2_++;
			}
		}
		
		public function set txt(t:Texture) : void
		{
			_txt = t;
			if(t != null)
			{
				maxRadius = Math.max(t.width,t.height);
			}
		}
		
		public function get txt() : Texture
		{
			return _txt;
		}
	}
}

