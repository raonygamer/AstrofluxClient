package core.engine {
	import core.GameObject;
	import core.particle.Emitter;
	import core.particle.EmitterFactory;
	import core.scene.Game;
	import core.ship.Ship;
	import extensions.RibbonSegment;
	import extensions.RibbonTrail;
	import flash.geom.Point;
	import generics.Color;
	
	public class Engine extends GameObject {
		public var thrustEmitters:Vector.<Emitter>;
		public var idleThrustEmitters:Vector.<Emitter>;
		public var speed:Number;
		private var _rotationSpeed:Number;
		public var rotationMod:Number;
		public var acceleration:Number;
		public var accelerating:Boolean;
		private var g:Game;
		public var ship:Ship;
		public var alive:Boolean;
		public var dual:Boolean = false;
		public var dualDistance:int = 0;
		public var obj:Object;
		public var colorHue:Number = 0;
		public var ribbonBaseMovingRatio:Number = 1;
		public var hasRibbonTrail:Boolean = false;
		public var ribbonThickness:Number = 0;
		public var ribbonTrail:RibbonTrail;
		private var followingRibbonSegment:RibbonSegment = new RibbonSegment();
		public var followingRibbonSegmentLine:Vector.<RibbonSegment> = new <RibbonSegment>[followingRibbonSegment];
		
		public function Engine(g:Game) {
			super();
			this.g = g;
			acceleration = 0;
			speed = 0;
			rotationSpeed = 0;
			rotationMod = 1;
			rotation = 0;
			alive = true;
			ship = null;
			accelerating = false;
		}
		
		override public function update() : void {
			var _local6:Point = null;
			var _local4:Number = NaN;
			var _local1:Number = NaN;
			var _local7:Number = NaN;
			var _local8:Number = NaN;
			var _local5:Number = NaN;
			var _local3:Number = NaN;
			var _local2:Number = NaN;
			if(alive && ship != null && ship.alive) {
				_local6 = ship.enginePos;
				_local4 = _local6.y;
				_local1 = _local6.x;
				_local7 = Math.sqrt(_local1 * _local1 + _local4 * _local4);
				_local8 = 0;
				if(_local1 != 0) {
					_local8 = Math.atan(_local4 / _local1);
				}
				_rotation = ship.rotation + 3.141592653589793;
				_local5 = Math.cos(_rotation + _local8) * _local7;
				_local3 = Math.sin(_rotation + _local8) * _local7;
				_pos.x = ship.x + _local5;
				_pos.y = ship.y + _local3;
				if(ribbonTrail && ribbonTrail.isPlaying) {
					if(ship.speed.x != 0 || ship.speed.y != 0) {
						_local2 = Math.atan2(ship.speed.y,ship.speed.x) + 3.141592653589793;
					} else {
						_local2 = ship.rotation + 3.141592653589793;
					}
					followingRibbonSegment.setTo2(_pos.x,_pos.y,ribbonThickness,_local2,1);
					ribbonTrail.advanceTime(33);
				}
			}
		}
		
		public function accelerate() : void {
			var _local2:int = 0;
			var _local1:int = 0;
			if(accelerating) {
				return;
			}
			if(ribbonTrail) {
				ribbonTrail.movingRatio = ribbonBaseMovingRatio;
			}
			accelerating = true;
			if(!thrustEmitters) {
				return;
			}
			_local2 = 0;
			while(_local2 < thrustEmitters.length) {
				thrustEmitters[_local2].play();
				_local2++;
			}
			if(idleThrustEmitters != null) {
				_local1 = 0;
				while(_local1 < idleThrustEmitters.length) {
					idleThrustEmitters[_local1].stop();
					_local1++;
				}
			}
		}
		
		public function idle() : void {
			var _local2:int = 0;
			var _local1:int = 0;
			if(!accelerating) {
				return;
			}
			if(ribbonTrail) {
				ribbonTrail.movingRatio = ribbonBaseMovingRatio * 1.5;
			}
			accelerating = false;
			if(!thrustEmitters) {
				return;
			}
			_local2 = 0;
			while(_local2 < thrustEmitters.length) {
				thrustEmitters[_local2].stop();
				_local2++;
			}
			if(idleThrustEmitters != null) {
				_local1 = 0;
				while(_local1 < idleThrustEmitters.length) {
					idleThrustEmitters[_local1].play();
					_local1++;
				}
			}
		}
		
		public function stop() : void {
			var _local2:int = 0;
			var _local1:int = 0;
			if(ribbonTrail) {
				ribbonTrail.movingRatio = ribbonBaseMovingRatio * 1.5;
			}
			accelerating = false;
			if(!thrustEmitters) {
				return;
			}
			_local2 = 0;
			while(_local2 < thrustEmitters.length) {
				thrustEmitters[_local2].stop();
				_local2++;
			}
			if(idleThrustEmitters != null) {
				_local1 = 0;
				while(_local1 < idleThrustEmitters.length) {
					idleThrustEmitters[_local1].stop();
					_local1++;
				}
			}
		}
		
		public function destroy() : void {
			hide();
			reset();
		}
		
		public function hide() : void {
			var _local2:int = 0;
			var _local1:int = 0;
			if(hasRibbonTrail) {
				ribbonTrail.isPlaying = false;
			}
			if(!thrustEmitters) {
				return;
			}
			_local2 = 0;
			while(_local2 < thrustEmitters.length) {
				thrustEmitters[_local2].alive = false;
				_local2++;
			}
			if(idleThrustEmitters != null) {
				_local1 = 0;
				while(_local1 < idleThrustEmitters.length) {
					idleThrustEmitters[_local1].alive = false;
					_local1++;
				}
			}
			thrustEmitters = null;
			idleThrustEmitters = null;
		}
		
		public function show() : void {
			var _local5:* = undefined;
			var _local4:Emitter = null;
			var _local2:* = undefined;
			var _local1:* = undefined;
			var _local6:* = undefined;
			if(hasRibbonTrail) {
				ribbonTrail.isPlaying = true;
				resetTrail();
			}
			if(!obj.useEffects || obj.effect == null) {
				return;
			}
			if(thrustEmitters != null) {
				return;
			}
			var _local8:int = 0;
			thrustEmitters = new Vector.<Emitter>();
			if(dual) {
				_local5 = EmitterFactory.create(obj.effect,g,x,y,this,accelerating);
				_local8 = 0;
				while(_local8 < _local5.length) {
					_local4 = _local5[_local8];
					_local4.yOffset = dualDistance / 2;
					thrustEmitters.push(_local4);
					_local8++;
				}
				_local2 = EmitterFactory.create(obj.effect,g,x,y,this,accelerating);
				_local8 = 0;
				while(_local8 < _local2.length) {
					_local4 = _local2[_local8];
					_local4.yOffset = -dualDistance / 2;
					thrustEmitters.push(_local4);
					_local8++;
				}
			} else {
				thrustEmitters = EmitterFactory.create(obj.effect,g,x,y,this,accelerating);
			}
			if(obj.changeThrustColors) {
				for each(var _local7:* in thrustEmitters) {
					_local7.startColor = Color.HEXHue(obj.thrustStartColor,colorHue);
					_local7.finishColor = Color.HEXHue(obj.thrustFinishColor,colorHue);
				}
			} else {
				for each(_local7 in thrustEmitters) {
					_local7.changeHue(colorHue);
				}
			}
			idleThrustEmitters = new Vector.<Emitter>();
			if(dual) {
				_local1 = EmitterFactory.create(obj.idleEffect,g,x,y,this,!accelerating);
				_local8 = 0;
				while(_local8 < _local1.length) {
					_local1[_local8].yOffset = dualDistance / 2;
					idleThrustEmitters.push(_local1[_local8]);
					_local8++;
				}
				_local6 = EmitterFactory.create(obj.idleEffect,g,x,y,this,!accelerating);
				_local8 = 0;
				while(_local8 < _local6.length) {
					_local6[_local8].yOffset = -dualDistance / 2;
					idleThrustEmitters.push(_local6[_local8]);
					_local8++;
				}
			} else {
				idleThrustEmitters = EmitterFactory.create(obj.idleEffect,g,x,y,this,!accelerating);
			}
			if(obj.changeIdleThrustColors) {
				for each(var _local3:* in idleThrustEmitters) {
					_local3.startColor = Color.HEXHue(obj.idleThrustStartColor,colorHue);
					_local3.finishColor = Color.HEXHue(obj.idleThrustFinishColor,colorHue);
				}
			} else {
				for each(_local3 in idleThrustEmitters) {
					_local3.changeHue(colorHue);
				}
			}
		}
		
		public function get rotationSpeed() : Number {
			return _rotationSpeed * rotationMod;
		}
		
		public function set rotationSpeed(value:Number) : void {
			_rotationSpeed = value;
		}
		
		public function resetTrail() : void {
			if(hasRibbonTrail) {
				followingRibbonSegment.setTo2(ship.pos.x,ship.pos.y,2,0,1);
				ribbonTrail.resetAllTo(ship.pos.x,ship.pos.y,ship.pos.x,ship.pos.y,0.85);
				ribbonTrail.advanceTime(33);
			}
		}
		
		override public function reset() : void {
			thrustEmitters = null;
			idleThrustEmitters = null;
			_rotationSpeed = 0;
			acceleration = 0;
			speed = 0;
			rotationSpeed = 0;
			rotationMod = 1;
			rotation = 0;
			alive = true;
			ship = null;
			accelerating = false;
			ribbonBaseMovingRatio = 1;
			hasRibbonTrail = false;
			ribbonThickness = 0;
			if(ribbonTrail) {
				g.ribbonTrailPool.removeRibbonTrail(ribbonTrail);
				ribbonTrail.isPlaying = false;
				ribbonTrail.resetAllTo(0,0,0,0,0);
				ribbonTrail = null;
			}
		}
	}
}

