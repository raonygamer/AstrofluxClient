package core.states.AIStates {
	import core.GameObject;
	import core.particle.Emitter;
	import core.projectile.Projectile;
	import core.scene.Game;
	import core.states.IState;
	import core.states.StateMachine;
	import core.unit.Unit;
	import generics.Util;
	
	public class Boomerang extends ProjectileBullet implements IState {
		private var g:Game;
		private var globalInterval:Number = 1000;
		private var localTargetList:Vector.<Unit>;
		private var nextGlobalUpdate:Number;
		private var nextLocalUpdate:Number;
		private var localRangeSQ:Number;
		private var firstUpdate:Boolean;
		private var engine:GameObject = new GameObject();
		private var elapsedTime:Number = 0;
		private var startTime:Number = 0;
		
		public function Boomerang(g:Game, p:Projectile) {
			this.g = g;
			this.p = p;
			p.convergenceCounter = 0;
			p.convergenceTime = 0;
			p.error = null;
			super(g,p);
		}
		
		override public function enter() : void {
			super.enter();
		}
		
		override public function execute() : void {
			var _local7:Number = NaN;
			var _local5:Number = NaN;
			var _local6:Number = NaN;
			var _local4:Number = NaN;
			for each(var _local3 in p.thrustEmitters) {
				_local3.target = engine;
			}
			var _local1:Number = 33;
			var _local2:int = (p.convergenceTime - p.convergenceCounter) / p.convergenceTime;
			if(_local2 <= 0) {
				p.error = null;
			}
			if(p.error != null) {
				p.course.pos.x += p.error.x * _local2;
				p.course.pos.y += p.error.y * _local2;
			}
			if(elapsedTime > p.boomerangReturnTime) {
				p.boomerangReturning = true;
			}
			if(p.boomerangReturning == true) {
				if(startTime == 0) {
					startTime = g.time;
				}
				_local7 = p.unit.pos.y - p.course.pos.y;
				_local5 = p.unit.pos.x - p.course.pos.x;
				if(startTime + 100 < g.time) {
					_local6 = Math.atan2(_local7,_local5);
					_local4 = Util.angleDifference(p.course.rotation,_local6 + 3.141592653589793);
					if(_local4 > 0 && _local4 < 0.95 * 3.141592653589793) {
						p.direction = 1;
					} else if(_local4 < 0 && _local4 > -0.95 * 3.141592653589793) {
						p.direction = 2;
					} else {
						p.direction = 3;
					}
				}
				if(p.direction == 1) {
					p.course.rotation += p.rotationSpeedMax * _local1 / 1000;
					p.course.rotation = Util.clampRadians(p.course.rotation);
				} else if(p.direction == 2) {
					p.course.rotation -= p.rotationSpeedMax * _local1 / 1000;
					p.course.rotation = Util.clampRadians(p.course.rotation);
				}
				if(_local7 * _local7 + _local5 * _local5 < 2500) {
					p.destroy(false);
				}
			}
			super.execute();
			elapsedTime += _local1;
		}
		
		override public function exit() : void {
		}
		
		override public function set stateMachine(sm:StateMachine) : void {
			this.sm = sm;
		}
		
		override public function get type() : String {
			return "Boomerang";
		}
	}
}

