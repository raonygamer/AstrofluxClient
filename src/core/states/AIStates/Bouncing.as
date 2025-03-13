package core.states.AIStates {
	import core.projectile.Projectile;
	import core.scene.Game;
	import core.states.IState;
	import core.states.StateMachine;
	import core.unit.Unit;
	import flash.geom.Point;
	import generics.Util;
	
	public class Bouncing implements IState {
		protected var m:Game;
		protected var p:Projectile;
		private var sm:StateMachine;
		private var isEnemy:Boolean;
		private var globalInterval:Number = 1000;
		private var localTargetList:Vector.<Unit>;
		private var nextGlobalUpdate:Number;
		private var nextLocalUpdate:Number;
		private var localRangeSQ:Number;
		private var firstUpdate:Boolean;
		
		public function Bouncing(m:Game, p:Projectile) {
			super();
			this.m = m;
			this.p = p;
			p.target = null;
			if(p.isHeal || p.unit.factions.length > 0) {
				this.isEnemy = false;
			} else {
				this.isEnemy = p.unit.type == "enemyShip" || p.unit.type == "turret";
			}
		}
		
		public function enter() : void {
			if(p.ttl < globalInterval) {
				globalInterval = p.ttl;
			}
			localTargetList = new Vector.<Unit>();
			firstUpdate = true;
			nextGlobalUpdate = 0;
			nextLocalUpdate = 0;
			localRangeSQ = globalInterval * 0.001 * (p.speedMax + 400);
			localRangeSQ *= localRangeSQ;
			if(p.unit.lastBulletTargetList != null) {
				if(p.unit.lastBulletGlobal > m.time) {
					nextGlobalUpdate = p.unit.lastBulletGlobal;
					localTargetList = p.unit.lastBulletTargetList;
					firstUpdate = false;
				} else {
					p.unit.lastBulletTargetList = null;
					firstUpdate = true;
				}
				if(p.unit.lastBulletLocal > m.time + 50) {
					nextLocalUpdate = p.unit.lastBulletLocal - 50;
					firstUpdate = false;
				}
			}
		}
		
		public function execute() : void {
			var _local23:Unit = null;
			var _local15:Number = NaN;
			var _local20:Number = NaN;
			var _local6:Number = NaN;
			var _local7:Number = NaN;
			var _local19:int = 0;
			var _local22:int = 0;
			var _local12:Number = NaN;
			var _local25:* = undefined;
			var _local3:Boolean = false;
			if(p.target != null) {
				nextLocalUpdate = m.time;
				nextGlobalUpdate = m.time;
				aim(p.target);
				p.target = null;
				p.error = null;
			}
			var _local1:Number = 33;
			var _local14:int = (p.convergenceTime - p.convergenceCounter) / p.convergenceTime;
			if(_local14 <= 0) {
				p.error = null;
			}
			if(p.error != null) {
				p.course.pos.x += p.error.x * _local14;
				p.course.pos.y += p.error.y * _local14;
			}
			p.oldPos.x = p.course.pos.x;
			p.oldPos.y = p.course.pos.y;
			p.updateHeading(p.course);
			if(p.error != null) {
				p.convergenceCounter++;
				_local14 = (p.convergenceTime - p.convergenceCounter) / p.convergenceTime;
				p.course.pos.x -= p.error.x * _local14;
				p.course.pos.y -= p.error.y * _local14;
			}
			if(nextLocalUpdate > m.time) {
				return;
			}
			var _local13:* = 100000000;
			var _local4:Point = p.course.pos;
			if(_local4.y == p.oldPos.y && _local4.x == p.oldPos.x) {
				return;
			}
			var _local21:Number = -Math.atan2(_local4.y - p.oldPos.y,_local4.x - p.oldPos.x);
			var _local26:Number = Math.cos(_local21);
			var _local11:Number = Math.sin(_local21);
			var _local8:Number = p.oldPos.x * _local26 - p.oldPos.y * _local11;
			var _local18:Number = p.oldPos.x * _local11 + p.oldPos.y * _local26;
			var _local9:Number = _local4.x * _local26 - _local4.y * _local11;
			var _local16:Number = _local4.x * _local11 + _local4.y * _local26;
			var _local24:Number = p.collisionRadius;
			var _local5:Number = Math.min(_local8,_local9) - _local24;
			var _local10:Number = Math.max(_local8,_local9) + _local24;
			var _local17:Number = Math.min(_local18,_local16) - _local24;
			var _local2:Number = Math.max(_local18,_local16) + _local24;
			if(isEnemy) {
				_local19 = int(m.shipManager.players.length);
				_local22 = 0;
				while(_local22 < _local19) {
					_local23 = m.shipManager.players[_local22];
					if(!(!_local23.alive || _local23.invulnerable)) {
						_local15 = _local23.pos.x;
						_local20 = _local23.pos.y;
						_local6 = _local4.x - _local15;
						_local7 = _local4.y - _local20;
						_local12 = _local6 * _local6 + _local7 * _local7;
						if(_local13 > _local12) {
							_local13 = _local12;
						}
						if(_local12 <= 2500) {
							_local8 = _local15 * _local26 - _local20 * _local11;
							_local18 = _local15 * _local11 + _local20 * _local26;
							_local24 = _local23.collisionRadius;
							if(_local8 <= _local10 + _local24 && _local8 > _local5 - _local24 && _local18 <= _local2 + _local24 && _local18 > _local17 - _local24) {
								if(p.numberOfHits <= 1) {
									_local4.y = (_local17 * _local26 / _local11 - _local8 + (_local24 - p.collisionRadius)) / (1 * _local11 + _local26 * _local26 / _local11);
									_local4.x = (_local17 - _local4.y * _local26) / _local11;
									p.destroy();
									return;
								}
								p.explode();
								if(p.numberOfHits >= 10) {
									p.numberOfHits--;
								}
							}
						}
					}
					_local22++;
				}
				nextLocalUpdate = m.time + Math.sqrt(_local13) * 1000 / (p.speedMax + 5 * 60) - 35;
				if(firstUpdate) {
					firstUpdate = false;
					p.unit.lastBulletLocal = nextLocalUpdate;
				}
			} else {
				if(nextGlobalUpdate < m.time) {
					_local3 = true;
					_local25 = m.unitManager.units;
					localTargetList.splice(0,localTargetList.length);
					nextGlobalUpdate = m.time + 1000;
				} else {
					_local3 = false;
					_local25 = localTargetList;
				}
				_local19 = int(_local25.length);
				_local22 = 0;
				while(_local22 < _local19) {
					_local23 = _local25[_local22];
					if(!(!_local23.canBeDamage(p.unit,p) || !(p.aiTargetSelf && p.unit == _local23))) {
						_local15 = _local23.pos.x;
						_local20 = _local23.pos.y;
						_local6 = _local4.x - _local15;
						_local7 = _local4.y - _local20;
						_local12 = _local6 * _local6 + _local7 * _local7;
						if(_local3 && _local12 < localRangeSQ) {
							localTargetList.push(_local23);
						}
						if(_local13 > _local12) {
							_local13 = _local12;
						}
						if(_local12 <= 2500) {
							_local8 = _local15 * _local26 - _local20 * _local11;
							_local18 = _local15 * _local11 + _local20 * _local26;
							_local24 = _local23.collisionRadius;
							if(_local8 <= _local10 + _local24 && _local8 > _local5 - _local24 && _local18 <= _local2 + _local24 && _local18 > _local17 - _local24) {
								if(p.numberOfHits <= 1) {
									_local4.y = (_local17 * _local26 / _local11 - _local8 + (_local24 - p.collisionRadius)) / (1 * _local11 + _local26 * _local26 / _local11);
									_local4.x = (_local17 - _local4.y * _local26) / _local11;
									p.destroy();
									return;
								}
								p.explode();
								if(p.numberOfHits >= 10) {
									p.numberOfHits--;
								}
							}
						}
					}
					_local22++;
				}
				nextLocalUpdate = m.time + Math.sqrt(_local13) * 1000 / (p.speedMax + 400) - 35;
				if(nextGlobalUpdate < nextLocalUpdate) {
					nextGlobalUpdate = nextLocalUpdate;
				}
				if(firstUpdate) {
					firstUpdate = false;
					p.unit.lastBulletGlobal = nextGlobalUpdate;
					p.unit.lastBulletLocal = nextLocalUpdate;
					p.unit.lastBulletTargetList = localTargetList;
				}
			}
		}
		
		public function aim(target:Unit) : void {
			var _local6:Number = 0;
			var _local7:Number = 0;
			var _local2:Number = target.pos.x;
			var _local4:Number = target.pos.y;
			var _local5:Number = p.course.pos.x;
			var _local8:Number = p.course.pos.y;
			_local6 = _local2 - _local5;
			_local7 = _local4 - _local8;
			var _local10:Number = Math.sqrt(_local6 * _local6 + _local7 * _local7);
			_local6 /= _local10;
			_local7 /= _local10;
			var _local3:Number = _local10 / (p.course.speed.length - Util.dotProduct(target.speed.x,target.speed.y,_local6,_local7));
			var _local9:Number = _local2 + target.speed.x * _local3;
			var _local11:Number = _local4 + target.speed.y * _local3;
			p.course.rotation = Math.atan2(_local11 - _local8,_local9 - _local5);
		}
		
		public function exit() : void {
		}
		
		public function set stateMachine(sm:StateMachine) : void {
			this.sm = sm;
		}
		
		public function get type() : String {
			return "Bouncing";
		}
	}
}

