package core.states.AIStates {
	import core.particle.Emitter;
	import core.scene.Game;
	import core.ship.EnemyShip;
	import core.ship.PlayerShip;
	import core.states.IState;
	import core.states.StateMachine;
	import core.unit.Unit;
	import core.weapon.Blaster;
	import core.weapon.Weapon;
	import flash.geom.Point;
	import generics.Random;
	import generics.Util;
	import movement.Heading;
	
	public class AIMelee implements IState {
		private var g:Game;
		private var s:EnemyShip;
		private var sm:StateMachine;
		private var targetAngleDiff:Number;
		private var targetStartAngle:Number;
		private var error:Point;
		private var errorAngle:Number;
		private var convergeTime:Number = 400;
		private var convergeStartTime:Number;
		private var speedRotFactor:Number;
		private var closeRangeSQ:Number;
		
		public function AIMelee(g:Game, s:EnemyShip, t:Unit, targetPosition:Heading, nextTurnDirection:int) {
			super();
			s.target = t;
			if(!s.aiCloak) {
				s.setConvergeTarget(targetPosition);
			}
			s.nextTurnDir = nextTurnDirection;
			this.s = s;
			this.g = g;
			if(!(s.target is PlayerShip) && s.factions.length == 0) {
				s.factions.push("tempFaction");
			}
		}
		
		public function enter() : void {
			s.accelerate = true;
			s.meleeStuck = false;
			error = null;
			errorAngle = 0;
			var _local1:Random = new Random(1 / s.id);
			_local1.stepTo(5);
			closeRangeSQ = 66 + 0.8 * _local1.random(80) + s.collisionRadius;
			closeRangeSQ *= closeRangeSQ;
			speedRotFactor = s.engine.speed / (0.5 * s.engine.rotationSpeed);
		}
		
		public function execute() : void {
			var _local3:Point = null;
			var _local1:Number = NaN;
			var _local5:Point = null;
			var _local4:Number = NaN;
			var _local8:Number = NaN;
			var _local6:Number = NaN;
			var _local7:Number = NaN;
			if(s.target != null && s.target.alive) {
				s.setAngleTargetPos(s.target.pos);
				_local3 = new Point(s.pos.x - s.target.pos.x,s.pos.y - s.target.pos.y);
				_local1 = _local3.x * _local3.x + _local3.y * _local3.y;
				if(s.meleeCanGrab && _local1 < s.chaseRange && s.meleeChargeEndTime != 0 && s.meleeCanGrab) {
					s.meleeChargeEndTime = 1;
				}
				if(s.meleeChargeEndTime < g.time && s.meleeChargeEndTime != 0) {
					s.engine.speed = s.oldSpeed;
					s.engine.rotationSpeed = s.oldTurningSpeed;
					s.meleeChargeEndTime = 0;
					for each(var _local2:Emitter in s.chargeEffect) {
						_local2.killEmitter();
					}
				}
				if(s.meleeStuck) {
					if(error == null) {
						_local5 = s.pos.clone();
						errorAngle = s.target.rotation + s.meleeTargetAngleDiff - s.rotation;
					}
					s.speed.x = 0;
					s.speed.y = 0;
					s.rotation = s.target.rotation + s.meleeTargetAngleDiff;
					_local4 = Util.clampRadians(s.target.rotation - s.meleeTargetStartAngle);
					s.pos.x = s.target.pos.x + Math.cos(_local4) * s.meleeOffset.x - Math.sin(_local4) * s.meleeOffset.y;
					s.pos.y = s.target.pos.y + Math.sin(_local4) * s.meleeOffset.x + Math.cos(_local4) * s.meleeOffset.y;
					s.accelerate = false;
					if(error == null) {
						convergeStartTime = g.time;
						error = new Point(_local5.x - s.pos.x,_local5.y - s.pos.y);
						convergeTime = error.length / s.engine.speed * 1000;
					}
					if(error != null) {
						_local8 = (convergeTime - (g.time - convergeStartTime)) / convergeTime;
						if(_local8 > 0) {
							s.pos.x += _local8 * error.x;
							s.pos.y += _local8 * error.y;
							s.rotation += _local8 * errorAngle;
						}
					}
				} else {
					if(s.stopWhenClose && _local1 < closeRangeSQ) {
						s.accelerate = false;
					} else if(s.meleeChargeEndTime < g.time && _local1 < speedRotFactor * speedRotFactor) {
						_local6 = Math.atan2(s.course.pos.y - s.target.pos.y,s.course.pos.x - s.target.pos.x);
						_local4 = Util.angleDifference(s.course.rotation,_local6 + 3.141592653589793);
						if(_local4 > 0.4 * 3.141592653589793 && _local4 < 0.65 * 3.141592653589793 || _local4 < -0.4 * 3.141592653589793 && _local4 > -0.65 * 3.141592653589793) {
							s.accelerate = false;
						} else {
							s.accelerate = true;
						}
					} else {
						s.accelerate = true;
					}
					error = null;
					if(!s.aiCloak) {
						s.runConverger();
					}
				}
			}
			if(isNaN(s.pos.x)) {
				trace("NaN Melee");
			}
			s.regenerateShield();
			s.updateHealthBars();
			s.engine.update();
			if(s.target != null) {
				_local7 = s.rotation;
				s.updateBeamWeapons();
				s.rotation = aim();
				s.updateNonBeamWeapons();
				s.rotation = _local7;
			}
		}
		
		public function aim() : Number {
			var _local7:int = 0;
			var _local3:Number = NaN;
			var _local4:Number = NaN;
			var _local6:Number = NaN;
			var _local2:Number = NaN;
			var _local5:Point = null;
			var _local1:Weapon = null;
			_local7 = 0;
			while(_local7 < s.weapons.length) {
				_local1 = s.weapons[_local7];
				if(_local1.fire && _local1 is Blaster) {
					if(s.aimSkill == 0) {
						return s.course.rotation;
					}
					_local3 = s.target.pos.x - s.course.pos.x;
					_local4 = s.target.pos.y - s.course.pos.y;
					_local6 = Math.sqrt(_local3 * _local3 + _local4 * _local4);
					_local3 /= _local6;
					_local4 /= _local6;
					_local2 = _local6 / (_local1.speed - Util.dotProduct(s.target.speed.x,s.target.speed.y,_local3,_local4));
					_local5 = new Point(s.target.pos.x + s.target.speed.x * _local2 * s.aimSkill,s.target.pos.y + s.target.speed.y * _local2 * s.aimSkill);
					return Math.atan2(_local5.y - s.course.pos.y,_local5.x - s.course.pos.x);
				}
				_local7++;
			}
			return s.course.rotation;
		}
		
		public function exit() : void {
			if(s.meleeChargeEndTime != 0) {
				s.engine.speed = s.oldSpeed;
				s.engine.rotationSpeed = s.oldTurningSpeed;
				s.meleeChargeEndTime = 0;
				for each(var _local1:Emitter in s.chargeEffect) {
					_local1.killEmitter();
				}
			}
		}
		
		public function set stateMachine(sm:StateMachine) : void {
			this.sm = sm;
		}
		
		public function get type() : String {
			return "AIMelee";
		}
	}
}

