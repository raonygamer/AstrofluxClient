package core.states.AIStates {
	import core.player.Player;
	import core.scene.Game;
	import core.ship.PlayerShip;
	import core.states.IState;
	import core.states.StateMachine;
	import core.turret.Turret;
	import core.weapon.Blaster;
	import core.weapon.Weapon;
	import flash.geom.Point;
	import generics.Util;
	
	public class AITurret implements IState {
		private var g:Game;
		private var t:Turret;
		private var sm:StateMachine;
		private var me:Player;
		
		public function AITurret(g:Game, t:Turret) {
			super();
			this.g = g;
			this.t = t;
			this.me = g.me;
		}
		
		public function enter() : void {
		}
		
		public function execute() : void {
			if(me == null) {
				me = g.me;
				return;
			}
			if(me.isLanded) {
				return;
			}
			if(!t.isAddedToCanvas && !t.forceupdate && !t.isBossUnit) {
				return;
			}
			t.forceupdate = false;
			t.regenerateShield();
			t.updateHealthBars();
			if(t.target != null && t.target.alive) {
				t.angleTargetPos = t.target.pos;
				if(!(t.target is PlayerShip) && t.factions.length == 0) {
					t.factions.push("tempFaction");
				}
			} else {
				if(t.weapon != null) {
					t.weapon.fire = false;
				}
				t.angleTargetPos = null;
			}
			t.updateRotation();
			var _local1:Number = t.rotation;
			aim();
			t.updateWeapons();
			t.rotation = _local1;
		}
		
		public function aim() : void {
			var _local11:Point = null;
			var _local5:Number = NaN;
			var _local6:Number = NaN;
			var _local8:Point = null;
			var _local9:Point = null;
			var _local10:Number = NaN;
			var _local7:Number = NaN;
			var _local2:Number = NaN;
			var _local4:Number = NaN;
			var _local3:Number = NaN;
			var _local1:Weapon = t.weapon;
			if(_local1 != null && _local1.fire && _local1 is Blaster && t.target != null) {
				_local11 = t.pos;
				_local5 = 0;
				_local6 = 0;
				_local8 = t.target.pos;
				_local9 = t.target.speed;
				_local5 = _local8.x - _local11.x;
				_local6 = _local8.y - _local11.y;
				_local10 = Math.sqrt(_local5 * _local5 + _local6 * _local6);
				_local5 /= _local10;
				_local6 /= _local10;
				_local7 = 0.991;
				_local2 = _local10 / (_local1.speed - Util.dotProduct(_local9.x,_local9.y,_local5,_local6) * _local7);
				_local4 = _local8.x + _local9.x * _local2 * _local7 * t.aimSkill;
				_local3 = _local8.y + _local9.y * _local2 * _local7 * t.aimSkill;
				t.rotation = Math.atan2(_local3 - _local11.y,_local4 - _local11.x);
			}
		}
		
		public function exit() : void {
		}
		
		public function set stateMachine(sm:StateMachine) : void {
			this.sm = sm;
		}
		
		public function get type() : String {
			return "AITurret";
		}
	}
}

