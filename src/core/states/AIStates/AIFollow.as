package core.states.AIStates
{
	import core.scene.Game;
	import core.ship.EnemyShip;
	import core.states.IState;
	import core.states.StateMachine;
	import core.unit.Unit;
	import flash.geom.Point;
	import movement.Heading;
	
	public class AIFollow implements IState
	{
		private var g:Game;
		
		private var s:EnemyShip;
		
		private var sm:StateMachine;
		
		private var closeRangeSQ:Number;
		
		private var speedRotFactor:Number;
		
		private var rollPeriod:Number;
		
		private var target:Unit;
		
		public function AIFollow(g:Game, s:EnemyShip, t:Unit, targetPosition:Heading, nextTurnDirection:int)
		{
			super();
			target = t;
			s.setConvergeTarget(targetPosition);
			s.nextTurnDir = nextTurnDirection;
			this.s = s;
			this.g = g;
		}
		
		public function enter() : void
		{
			closeRangeSQ = 40000;
			s.course.roll = false;
			s.roll = false;
			s.accelerate = false;
		}
		
		public function execute() : void
		{
			if(target == null || !target.alive)
			{
				s.engine.accelerating = false;
				s.accelerate = false;
				return;
			}
			var _loc3_:Point = s.course.pos;
			var _loc1_:Point = target.pos;
			s.setAngleTargetPos(_loc1_);
			var _loc2_:Number = _loc3_.x - _loc1_.x;
			var _loc4_:Number = _loc3_.y - _loc1_.y;
			var _loc5_:Number = _loc2_ * _loc2_ + _loc4_ * _loc4_;
			if(_loc5_ > closeRangeSQ)
			{
				s.accelerate = true;
				s.engine.accelerating = true;
			}
			else
			{
				s.engine.accelerating = false;
				s.accelerate = false;
			}
			s.runConverger();
			s.regenerateShield();
			s.updateHealthBars();
			s.engine.update();
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
			return "AIFollow";
		}
	}
}

