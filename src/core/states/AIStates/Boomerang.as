package core.states.AIStates
{
	import core.GameObject;
	import core.particle.Emitter;
	import core.projectile.Projectile;
	import core.scene.Game;
	import core.states.IState;
	import core.states.StateMachine;
	import core.unit.Unit;
	import generics.Util;
	
	public class Boomerang extends ProjectileBullet implements IState
	{
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
		
		public function Boomerang(g:Game, p:Projectile)
		{
			this.g = g;
			this.p = p;
			p.convergenceCounter = 0;
			p.convergenceTime = 0;
			p.error = null;
			super(g,p);
		}
		
		override public function enter() : void
		{
			super.enter();
		}
		
		override public function execute() : void
		{
			var _loc6_:Number = NaN;
			var _loc2_:Number = NaN;
			var _loc3_:Number = NaN;
			var _loc4_:Number = NaN;
			for each(var _loc5_ in p.thrustEmitters)
			{
				_loc5_.target = engine;
			}
			var _loc1_:Number = 33;
			var _loc7_:int = (p.convergenceTime - p.convergenceCounter) / p.convergenceTime;
			if(_loc7_ <= 0)
			{
				p.error = null;
			}
			if(p.error != null)
			{
				p.course.pos.x += p.error.x * _loc7_;
				p.course.pos.y += p.error.y * _loc7_;
			}
			if(elapsedTime > p.boomerangReturnTime)
			{
				p.boomerangReturning = true;
			}
			if(p.boomerangReturning == true)
			{
				if(startTime == 0)
				{
					startTime = g.time;
				}
				_loc6_ = p.unit.pos.y - p.course.pos.y;
				_loc2_ = p.unit.pos.x - p.course.pos.x;
				if(startTime + 100 < g.time)
				{
					_loc3_ = Math.atan2(_loc6_,_loc2_);
					_loc4_ = Util.angleDifference(p.course.rotation,_loc3_ + 3.141592653589793);
					if(_loc4_ > 0 && _loc4_ < 0.95 * 3.141592653589793)
					{
						p.direction = 1;
					}
					else if(_loc4_ < 0 && _loc4_ > -0.95 * 3.141592653589793)
					{
						p.direction = 2;
					}
					else
					{
						p.direction = 3;
					}
				}
				if(p.direction == 1)
				{
					p.course.rotation += p.rotationSpeedMax * _loc1_ / 1000;
					p.course.rotation = Util.clampRadians(p.course.rotation);
				}
				else if(p.direction == 2)
				{
					p.course.rotation -= p.rotationSpeedMax * _loc1_ / 1000;
					p.course.rotation = Util.clampRadians(p.course.rotation);
				}
				if(_loc6_ * _loc6_ + _loc2_ * _loc2_ < 2500)
				{
					p.destroy(false);
				}
			}
			super.execute();
			elapsedTime += _loc1_;
		}
		
		override public function exit() : void
		{
		}
		
		override public function set stateMachine(sm:StateMachine) : void
		{
			this.sm = sm;
		}
		
		override public function get type() : String
		{
			return "Boomerang";
		}
	}
}

