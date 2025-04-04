package core.states.AIStates
{
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
	
	public class AIChase implements IState
	{
		private var g:Game;
		private var s:EnemyShip;
		private var sm:StateMachine;
		private var closeRangeSQ:Number;
		private var speedRotFactor:Number;
		private var rollPeriod:Number;
		private var rollPeriodFactor:Number;
		
		public function AIChase(g:Game, s:EnemyShip, t:Unit, targetPosition:Heading, nextTurnDirection:int)
		{
			super();
			s.target = t;
			if(!s.aiCloak)
			{
				s.setConvergeTarget(targetPosition);
			}
			s.nextTurnDir = nextTurnDirection;
			this.s = s;
			this.g = g;
			if(!(s.target is PlayerShip) && s.factions.length == 0)
			{
				s.factions.push("tempFaction");
			}
		}
		
		public function enter() : void
		{
			var _loc1_:Random = new Random(1 / s.id);
			_loc1_.stepTo(5);
			closeRangeSQ = 66 + 0.8 * _loc1_.random(80) + s.collisionRadius;
			closeRangeSQ *= closeRangeSQ;
			if(_loc1_.random(2) == 0)
			{
				s.rollDir = -1;
			}
			else
			{
				s.rollDir = 1;
			}
			s.rollSpeed = (0.1 + 0.001 * _loc1_.random(501)) * s.engine.speed;
			s.rollPassive = 0.1 + 0.001 * _loc1_.random(301);
			rollPeriod = 10000 + _loc1_.random(10000);
			rollPeriodFactor = 0.25 + 0.001 * _loc1_.random(501);
			s.rollMod = g.time % rollPeriod > rollPeriodFactor * rollPeriod ? 1 : -1;
			speedRotFactor = s.engine.speed / (0.5 * s.engine.rotationSpeed);
			s.accelerate = true;
			s.roll = false;
			s.engine.accelerate();
		}
		
		public function execute() : void
		{
			var _loc4_:Point = null;
			var _loc1_:Point = null;
			var _loc2_:Number = NaN;
			var _loc5_:Number = NaN;
			var _loc6_:Number = NaN;
			var _loc3_:Number = NaN;
			if(s.target != null)
			{
				_loc4_ = s.course.pos;
				_loc1_ = s.target.pos;
				s.setAngleTargetPos(_loc1_);
				_loc2_ = _loc4_.x - _loc1_.x;
				_loc5_ = _loc4_.y - _loc1_.y;
				_loc6_ = _loc2_ * _loc2_ + _loc5_ * _loc5_;
				if(s.sniper && _loc6_ < s.sniperMinRange * s.sniperMinRange)
				{
					s.accelerate = false;
					s.roll = true;
				}
				else if(s.stopWhenClose && _loc6_ < closeRangeSQ)
				{
					s.accelerate = false;
					s.roll = true;
				}
				else
				{
					s.accelerate = true;
					s.roll = false;
				}
			}
			s.rollMod = g.time % rollPeriod > rollPeriodFactor * rollPeriod ? 1 : -1;
			if(!s.aiCloak)
			{
				s.runConverger();
			}
			s.regenerateShield();
			s.updateHealthBars();
			s.engine.update();
			if(s.target != null)
			{
				_loc3_ = s.rotation;
				s.updateBeamWeapons();
				s.rotation = aim();
				s.updateNonBeamWeapons();
				s.rotation = _loc3_;
			}
		}
		
		public function aim() : Number
		{
			var _loc3_:int = 0;
			var _loc10_:Number = NaN;
			var _loc9_:Number = NaN;
			var _loc14_:Number = NaN;
			var _loc15_:Number = NaN;
			var _loc12_:Number = NaN;
			var _loc11_:Number = NaN;
			var _loc13_:Weapon = null;
			var _loc4_:Number = s.target.pos.x;
			var _loc2_:Number = s.target.pos.y;
			var _loc8_:Number = s.course.pos.x;
			var _loc1_:Number = s.course.pos.y;
			var _loc6_:Number = 0;
			var _loc5_:Number = 0;
			var _loc7_:int = int(s.weapons.length);
			_loc3_ = 0;
			while(_loc3_ < _loc7_)
			{
				_loc13_ = s.weapons[_loc3_];
				if(_loc13_.fire && _loc13_ is Blaster)
				{
					if(s.aimSkill == 0)
					{
						return s.course.rotation;
					}
					_loc6_ = _loc4_ - _loc8_;
					_loc5_ = _loc2_ - _loc1_;
					_loc10_ = Math.sqrt(_loc6_ * _loc6_ + _loc5_ * _loc5_);
					_loc6_ /= _loc10_;
					_loc5_ /= _loc10_;
					_loc9_ = 0.991;
					_loc14_ = _loc13_.speed - Util.dotProduct(s.target.speed.x,s.target.speed.y,_loc6_,_loc5_) * _loc9_;
					if(Math.abs(_loc14_) < 0.001)
					{
						_loc14_ = 0.001;
					}
					_loc15_ = _loc10_ / _loc14_;
					_loc12_ = _loc4_ + s.target.speed.x * _loc15_ * _loc9_ * s.aimSkill;
					_loc11_ = _loc2_ + s.target.speed.y * _loc15_ * _loc9_ * s.aimSkill;
					return Math.atan2(_loc11_ - _loc1_,_loc12_ - _loc8_);
				}
				_loc3_++;
			}
			return s.course.rotation;
		}
		
		public function exit() : void
		{
			s.rollPassive = 0;
			s.rollSpeed = 0;
			s.rollMod = 0;
			s.rollDir = 0;
		}
		
		public function set stateMachine(sm:StateMachine) : void
		{
			this.sm = sm;
		}
		
		public function get type() : String
		{
			return "AIChase";
		}
	}
}

