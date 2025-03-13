package core.states.AIStates {
	import core.projectile.Projectile;
	import core.scene.Game;
	import core.ship.Ship;
	import core.states.IState;
	import core.states.StateMachine;
	import core.unit.Unit;
	import flash.geom.Point;
	import generics.Util;
	
	public class MissileStuck implements IState {
		private var m:Game;
		private var p:Projectile;
		private var sm:StateMachine;
		private var isEnemy:Boolean;
		private var stuckShip:Ship = null;
		private var stuckUnit:Unit = null;
		private var stuckOffset:Point;
		private var stuckAngle:Number;
		private var startAngle:Number;
		private var pos:Point;
		
		public function MissileStuck(m:Game, p:Projectile) {
			var _local3:Number = NaN;
			super();
			this.m = m;
			this.p = p;
			pos = p.course.pos;
			stuckUnit = p.target;
			stuckAngle = stuckUnit.rotation;
			var _local5:Point = new Point(pos.x - stuckUnit.pos.x,pos.y - stuckUnit.pos.y);
			var _local4:Number = Number(_local5.length.valueOf());
			if(_local4 > stuckUnit.radius * 0.8) {
				stuckOffset = new Point(stuckUnit.radius * 0.8 * _local5.x / _local4,stuckUnit.radius * 0.8 * _local5.y / _local4);
			} else {
				stuckOffset = _local5;
			}
			startAngle = p.course.rotation;
			p.course.rotation = startAngle;
			p.course.speed.x = 0;
			p.course.speed.y = 0;
			p.acceleration = 0;
			_local5 = pos.clone();
			_local3 = Util.clampRadians(stuckUnit.rotation - stuckAngle);
			p.course.rotation = startAngle + _local3;
			pos.x = stuckUnit.pos.x + Math.cos(_local3) * stuckOffset.x - Math.sin(_local3) * stuckOffset.y;
			pos.y = stuckUnit.pos.y + Math.sin(_local3) * stuckOffset.x + Math.cos(_local3) * stuckOffset.y;
			p.error = new Point(_local5.x - pos.x,_local5.y - pos.y);
			p.convergenceCounter = 0;
			p.convergenceTime = 1000 / 33;
			if(p.isHeal || p.unit.factions.length > 0) {
				this.isEnemy = false;
			} else {
				this.isEnemy = p.unit.type == "enemyShip" || p.unit.type == "turret";
			}
		}
		
		public function enter() : void {
			p.ttl = p.ttlMax + p.aiStuckDuration * 1000;
		}
		
		public function execute() : void {
			var _local3:Number = NaN;
			var _local1:Number = NaN;
			var _local2:Number = NaN;
			if(!p.aiStuck) {
				p.target = null;
				p.ttl = p.ttlMax;
				p.numberOfHits = 1;
				p.acceleration = p.weapon.acceleration;
				sm.changeState(new Missile(m,p));
				return;
			}
			if(stuckUnit == null || !stuckUnit.alive) {
				return;
			}
			_local3 = Util.clampRadians(stuckUnit.rotation - stuckAngle);
			p.course.rotation = startAngle + _local3;
			pos.x = stuckUnit.pos.x + Math.cos(_local3) * stuckOffset.x - Math.sin(_local3) * stuckOffset.y;
			pos.y = stuckUnit.pos.y + Math.sin(_local3) * stuckOffset.x + Math.cos(_local3) * stuckOffset.y;
			_local1 = 33;
			_local2 = (p.convergenceTime - p.convergenceCounter) / p.convergenceTime;
			if(_local2 <= 0) {
				p.error = null;
			}
			if(p.error != null) {
				p.convergenceCounter++;
				_local2 = (p.convergenceTime - p.convergenceCounter) / p.convergenceTime;
				pos.x += p.error.x * _local2;
				pos.y += p.error.y * _local2;
			}
		}
		
		public function exit() : void {
		}
		
		public function set stateMachine(sm:StateMachine) : void {
			this.sm = sm;
		}
		
		public function get type() : String {
			return "MissileStuck";
		}
	}
}

