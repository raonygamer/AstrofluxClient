package core.states.AIStates {
	import core.GameObject;
	import core.particle.Emitter;
	import core.projectile.Projectile;
	import core.scene.Game;
	import core.states.IState;
	import core.states.StateMachine;
	import flash.geom.Point;
	import generics.Util;
	
	public class Missile implements IState {
		private var g:Game;
		private var p:Projectile;
		private var sm:StateMachine;
		private var isEnemy:Boolean;
		private var engine:GameObject;
		private var startTime:Number;
		
		public function Missile(g:Game, p:Projectile) {
			super();
			this.g = g;
			this.p = p;
			if(p.isHeal || p.unit.factions.length > 0) {
				this.isEnemy = false;
			} else {
				this.isEnemy = p.unit.type == "enemyShip" || p.unit.type == "turret";
			}
			p.convergenceCounter = 0;
			engine = new GameObject();
		}
		
		public function enter() : void {
			startTime = g.time;
		}
		
		public function execute() : void {
			var _local5:Point = null;
			var _local6:Number = NaN;
			var _local4:Number = NaN;
			if(p.aiStuck) {
				sm.changeState(new MissileStuck(g,p));
				return;
			}
			for each(var _local3 in p.thrustEmitters) {
				_local3.target = engine;
			}
			var _local1:Number = 33;
			var _local2:Number = (p.convergenceTime - p.convergenceCounter) / p.convergenceTime;
			if(_local2 <= 0) {
				p.error = null;
			}
			if(p.error != null) {
				p.course.pos.x += p.error.x * _local2;
				p.course.pos.y += p.error.y * _local2;
				p.course.rotation += p.errorRot * _local2;
			}
			if(p.target != null) {
				if(!p.target.alive) {
					p.target = null;
					return;
				}
				_local5 = p.target.pos;
			} else if(p.targetProjectile != null) {
				if(!p.targetProjectile.alive) {
					p.targetProjectile = null;
					return;
				}
				_local5 = p.targetProjectile.pos;
			}
			if(_local5 != null) {
				_local6 = Math.atan2(_local5.y - p.course.pos.y,_local5.x - p.course.pos.x);
				_local4 = Util.angleDifference(p.course.rotation,_local6 + 3.141592653589793);
				if(_local4 > 0 && _local4 < 3.141592653589793 - p.rotationSpeedMax * _local1 / 1000) {
					p.course.rotation += p.rotationSpeedMax * _local1 / 1000;
					p.course.rotation = Util.clampRadians(p.course.rotation);
				} else if(_local4 < 0 && _local4 > -3.141592653589793 + p.rotationSpeedMax * _local1 / 1000) {
					p.course.rotation -= p.rotationSpeedMax * _local1 / 1000;
					p.course.rotation = Util.clampRadians(p.course.rotation);
				} else {
					p.course.rotation = Util.clampRadians(_local6);
				}
			}
			if(g.time - startTime >= p.aiDelayedAccelerationTime) {
				p.updateHeading(p.course);
			} else {
				p.course.time += 33;
			}
			engine.x = p.pos.x - Math.cos(p.rotation) * p.radius;
			engine.y = p.pos.y - Math.sin(p.rotation) * p.radius;
			if(p.error != null) {
				p.convergenceCounter++;
				_local2 = (p.convergenceTime - p.convergenceCounter) / p.convergenceTime;
				p.course.pos.x -= p.error.x * _local2;
				p.course.pos.y -= p.error.y * _local2;
				p.course.rotation -= p.errorRot * _local2;
			}
		}
		
		public function exit() : void {
		}
		
		public function set stateMachine(sm:StateMachine) : void {
			this.sm = sm;
		}
		
		public function get type() : String {
			return "Missile";
		}
	}
}

