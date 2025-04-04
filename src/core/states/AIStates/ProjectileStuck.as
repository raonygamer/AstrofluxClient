package core.states.AIStates
{
	import core.projectile.Projectile;
	import core.scene.Game;
	import core.ship.Ship;
	import core.states.IState;
	import core.states.StateMachine;
	import core.unit.Unit;
	import flash.geom.Point;
	import generics.Util;
	
	public class ProjectileStuck implements IState
	{
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
		
		public function ProjectileStuck(m:Game, p:Projectile, target:Unit)
		{
			super();
			this.m = m;
			this.p = p;
			pos = p.course.pos;
			stuckUnit = target;
			p.target = target;
			stuckAngle = stuckUnit.rotation;
			var _loc4_:Point = new Point(pos.x - stuckUnit.pos.x,pos.y - stuckUnit.pos.y);
			var _loc5_:Number = Number(_loc4_.length.valueOf());
			if(_loc5_ > stuckUnit.radius * 0.8)
			{
				stuckOffset = new Point(stuckUnit.radius * 0.8 * _loc4_.x / _loc5_,stuckUnit.radius * 0.8 * _loc4_.y / _loc5_);
			}
			else
			{
				stuckOffset = _loc4_;
			}
			startAngle = p.course.rotation;
			p.course.rotation = startAngle;
			p.course.speed.x = 0;
			p.course.speed.y = 0;
			p.acceleration = 0;
			if(p.isHeal || p.unit.factions.length > 0)
			{
				this.isEnemy = false;
			}
			else
			{
				this.isEnemy = p.unit.type == "enemyShip" || p.unit.type == "turret";
			}
		}
		
		public function enter() : void
		{
		}
		
		public function execute() : void
		{
			var _loc1_:Number = NaN;
			if(!stuckUnit.alive)
			{
				p.destroy();
			}
			_loc1_ = Util.clampRadians(stuckUnit.rotation - stuckAngle);
			p.course.rotation = startAngle + _loc1_;
			pos.x = stuckUnit.pos.x + Math.cos(_loc1_) * stuckOffset.x - Math.sin(_loc1_) * stuckOffset.y;
			pos.y = stuckUnit.pos.y + Math.sin(_loc1_) * stuckOffset.x + Math.cos(_loc1_) * stuckOffset.y;
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
			return "ProjectileStuck";
		}
	}
}

