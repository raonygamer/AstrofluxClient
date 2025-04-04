package core.states.AIStates
{
	import core.particle.Emitter;
	import core.particle.EmitterFactory;
	import core.scene.Game;
	import core.ship.EnemyShip;
	import core.states.IState;
	import core.states.StateMachine;
	import core.unit.Unit;
	import generics.Util;
	
	public class AITeleport implements IState
	{
		private var g:Game;
		private var s:EnemyShip;
		private var sm:StateMachine;
		private var target:Unit;
		private var targetX:Number;
		private var targetY:Number;
		private var duration:Number;
		private var emitters1:Vector.<Emitter>;
		private var emitters2:Vector.<Emitter>;
		
		public function AITeleport(g:Game, s:EnemyShip, target:Unit, duration:int = 1, targetX:Number = 0, targetY:Number = 0)
		{
			super();
			this.g = g;
			this.s = s;
			this.target = target;
			this.targetX = targetX;
			this.targetY = targetY;
			this.duration = duration;
		}
		
		public function enter() : void
		{
			s.invulnerable = true;
			emitters1 = EmitterFactory.create("UZ3AiNHAEUmBD4ev0Itu0A",g,s.pos.x,s.pos.y,s,true);
			emitters2 = EmitterFactory.create("5BSaDIEYj0mEuVkMVp1JGw",g,targetX,targetY,null,true);
		}
		
		public function execute() : void
		{
			if(target == null && s.target == null && g.time > s.orbitStartTime && g.time - 2000 < s.orbitStartTime)
			{
				s.stateMachine.changeState(new AIOrbit(g,s,true));
				s.course.pos.x = targetX;
				s.course.pos.y = targetY;
				s.clearConvergeTarget();
			}
		}
		
		public function exit() : void
		{
			var _loc1_:Number = NaN;
			var _loc3_:Number = NaN;
			for each(var _loc2_ in emitters1)
			{
				_loc2_.killEmitter();
			}
			for each(_loc2_ in emitters2)
			{
				_loc2_.killEmitter();
			}
			if(target != null)
			{
				_loc1_ = target.pos.x - targetX;
				_loc3_ = target.pos.y - targetY;
				if(_loc3_ != 0 || _loc1_ != 0)
				{
					s.rotation = Util.clampRadians(Math.atan2(_loc3_,_loc1_));
				}
			}
			else if(s.target != null)
			{
				_loc1_ = s.target.pos.x - targetX;
				_loc3_ = s.target.pos.y - targetY;
				if(_loc3_ != 0 || _loc1_ != 0)
				{
					s.rotation = Util.clampRadians(Math.atan2(_loc3_,_loc1_) - 3.141592653589793);
				}
				s.target = null;
			}
			s.course.pos.x = targetX;
			s.course.pos.y = targetY;
			s.clearConvergeTarget();
			s.invulnerable = false;
			if(s.shieldRegenCounter > -3000)
			{
				s.shieldRegenCounter = -3000;
			}
		}
		
		public function set stateMachine(sm:StateMachine) : void
		{
			this.sm = sm;
		}
		
		public function get type() : String
		{
			return "AITeleport";
		}
	}
}

