package core.states.AIStates
{
	import core.GameObject;
	import core.scene.Game;
	import core.ship.EnemyShip;
	import core.spawner.Spawner;
	import core.states.IState;
	import core.states.StateMachine;
	import flash.geom.Point;
	import generics.Util;
	import movement.Heading;
	
	public class AIReturnOrbit implements IState
	{
		private var g:Game;
		private var s:EnemyShip;
		private var sm:StateMachine;
		private var target:Point;
		
		public function AIReturnOrbit(g:Game, s:EnemyShip, angle:Number, startTime:Number, t:Heading, nextTurnDirection:int)
		{
			super();
			s.target = null;
			s.ellipseAlpha = Util.clampRadians(angle);
			s.orbitStartTime = startTime;
			if(s.getConverger() == null)
			{
				g.client.errorLog.writeError("converger == null in AiReturn, enemy: " + s.name,"","",{});
				return;
			}
			if(!s.aiCloak)
			{
				s.setConvergeTarget(t);
			}
			s.setNextTurnDirection(nextTurnDirection);
			this.g = g;
			this.s = s;
			if(s.factions.length == 1 && s.factions[0] == "tempFaction")
			{
				s.factions.splice(0,1);
			}
		}
		
		public function enter() : void
		{
			var _loc2_:Number = s.orbitRadius * s.ellipseFactor * Math.cos(s.orbitAngle);
			var _loc4_:Number = s.orbitRadius * Math.sin(s.orbitAngle);
			var _loc1_:Spawner = s.spawner;
			if(_loc1_ == null)
			{
				g.client.errorLog.writeError("Spawner == null in AiReturn, enemy: " + s.name,"","",{});
				return;
			}
			var _loc5_:GameObject = _loc1_.parentObj;
			if(_loc5_ == null)
			{
				g.client.errorLog.writeError("Parent Obj == null in AiReturn, enemy: " + s.name,"","",{});
				return;
			}
			if(_loc5_.pos == null)
			{
				g.client.errorLog.writeError("Parent Obj pos == null in AiReturn, enemy: " + s.name,"","",{});
				return;
			}
			var _loc3_:Point = new Point(_loc5_.pos.x,_loc5_.pos.y);
			target = new Point();
			target.x = _loc2_ * Math.cos(s.ellipseAlpha) - _loc4_ * Math.sin(s.ellipseAlpha) + _loc3_.x;
			target.y = _loc2_ * Math.sin(s.ellipseAlpha) + _loc4_ * Math.cos(s.ellipseAlpha) + _loc3_.y;
			s.accelerate = false;
			s.setAngleTargetPos(target);
			s.target = null;
			s.stopShooting();
			if(s.course == null)
			{
				g.client.errorLog.writeError("course == null in AiReturn, enemy: " + s.name,"","",{});
				return;
			}
			s.course.speed.x = s.course.speed.y = 0;
		}
		
		public function execute() : void
		{
			var _loc1_:Number = NaN;
			var _loc2_:Number = NaN;
			if(s.isFacingAngleTarget())
			{
				s.accelerate = true;
			}
			if(!s.aiCloak)
			{
				s.runConverger();
			}
			if(g.time > s.orbitStartTime)
			{
				_loc1_ = s.pos.x - target.x;
				_loc2_ = s.pos.y - target.y;
				if(_loc1_ * _loc1_ + _loc2_ * _loc2_ < 400)
				{
					s.stateMachine.changeState(new AIOrbit(g,s,true));
					return;
				}
			}
			if(!s.isAddedToCanvas)
			{
				return;
			}
			s.regenerateShield();
			s.updateHealthBars();
			s.engine.update();
			s.updateWeapons();
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
			return "AIReturn";
		}
	}
}

