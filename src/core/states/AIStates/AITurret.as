package core.states.AIStates
{
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
	
	public class AITurret implements IState
	{
		private var g:Game;
		
		private var t:Turret;
		
		private var sm:StateMachine;
		
		private var me:Player;
		
		public function AITurret(g:Game, t:Turret)
		{
			super();
			this.g = g;
			this.t = t;
			this.me = g.me;
		}
		
		public function enter() : void
		{
		}
		
		public function execute() : void
		{
			if(me == null)
			{
				me = g.me;
				return;
			}
			if(me.isLanded)
			{
				return;
			}
			if(!t.isAddedToCanvas && !t.forceupdate && !t.isBossUnit)
			{
				return;
			}
			t.forceupdate = false;
			t.regenerateShield();
			t.updateHealthBars();
			if(t.target != null && t.target.alive)
			{
				t.angleTargetPos = t.target.pos;
				if(!(t.target is PlayerShip) && t.factions.length == 0)
				{
					t.factions.push("tempFaction");
				}
			}
			else
			{
				if(t.weapon != null)
				{
					t.weapon.fire = false;
				}
				t.angleTargetPos = null;
			}
			t.updateRotation();
			var _loc1_:Number = t.rotation;
			aim();
			t.updateWeapons();
			t.rotation = _loc1_;
		}
		
		public function aim() : void
		{
			var _loc4_:Point = null;
			var _loc9_:Number = NaN;
			var _loc8_:Number = NaN;
			var _loc1_:Point = null;
			var _loc2_:Point = null;
			var _loc3_:Number = NaN;
			var _loc11_:Number = NaN;
			var _loc10_:Number = NaN;
			var _loc6_:Number = NaN;
			var _loc5_:Number = NaN;
			var _loc7_:Weapon = t.weapon;
			if(_loc7_ != null && _loc7_.fire && _loc7_ is Blaster && t.target != null)
			{
				_loc4_ = t.pos;
				_loc9_ = 0;
				_loc8_ = 0;
				_loc1_ = t.target.pos;
				_loc2_ = t.target.speed;
				_loc9_ = _loc1_.x - _loc4_.x;
				_loc8_ = _loc1_.y - _loc4_.y;
				_loc3_ = Math.sqrt(_loc9_ * _loc9_ + _loc8_ * _loc8_);
				if(_loc3_ < 0.0001)
				{
					return;
				}
				_loc9_ /= _loc3_;
				_loc8_ /= _loc3_;
				_loc11_ = 0.991;
				_loc10_ = _loc3_ / (_loc7_.speed - Util.dotProduct(_loc2_.x,_loc2_.y,_loc9_,_loc8_) * _loc11_);
				_loc6_ = _loc1_.x + _loc2_.x * _loc10_ * _loc11_ * t.aimSkill;
				_loc5_ = _loc1_.y + _loc2_.y * _loc10_ * _loc11_ * t.aimSkill;
				t.rotation = Math.atan2(_loc5_ - _loc4_.y,_loc6_ - _loc4_.x);
			}
		}
		
		public function exit() : void
		{
		}
		
		public function set stateMachine(sm:StateMachine) : void
		{
			this.sm = sm;
		}
		
		public function get type() : String
		{
			return "AITurret";
		}
	}
}

