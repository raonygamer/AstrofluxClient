package core.states.AIStates
{
	import core.scene.Game;
	import core.ship.EnemyShip;
	import core.states.IState;
	import core.states.StateMachine;
	import flash.geom.Point;
	import movement.Heading;
	
	public class AIFlee implements IState
	{
		private var g:Game;
		private var s:EnemyShip;
		private var sm:StateMachine;
		private var startTime:Number;
		private var startDelay:Number = 1000;
		
		public function AIFlee(g:Game, s:EnemyShip, targetPos:Point, target:Heading, nextTurnDirection:int)
		{
			super();
			s.target = null;
			s.setAngleTargetPos(targetPos);
			if(!s.aiCloak)
			{
				s.setConvergeTarget(target);
			}
			s.setNextTurnDirection(nextTurnDirection);
			this.g = g;
			this.s = s;
		}
		
		public function enter() : void
		{
			s.stopShooting();
			s.accelerate = true;
			startTime = g.time;
		}
		
		public function execute() : void
		{
			if(!s.aiCloak)
			{
				s.runConverger();
			}
			s.regenerateShield();
			s.updateHealthBars();
			s.engine.update();
			s.updateWeapons();
		}
		
		public function exit() : void
		{
			s.rollPassive = 0;
			s.rollSpeed = 0;
			s.rollMod = 0;
			s.rollDir = 0;
			s.setAngleTargetPos(null);
		}
		
		public function set stateMachine(sm:StateMachine) : void
		{
			this.sm = sm;
		}
		
		public function get type() : String
		{
			return "AIFlee";
		}
	}
}

