package core.states.AIStates
{
	import core.scene.Game;
	import core.ship.EnemyShip;
	import core.states.IState;
	import core.states.StateMachine;
	import flash.geom.Point;
	import generics.Util;
	import movement.Heading;
	
	public class AIOrbit implements IState
	{
		private static const HALF_PI:Number = 1.5707963267948966;
		private static const TICK_LENGTH_MS:Number = 0.033;
		private static const TICK_LENGTH_W:Number = 30.303030303030305;
		private var g:Game;
		private var s:EnemyShip;
		private var sm:StateMachine;
		private var lastCourse:Heading;
		private var error:Point;
		private var errorAngle:Number;
		private var convergeTime:Number = 1000;
		private var convergeStartTime:Number;
		
		public function AIOrbit(g:Game, s:EnemyShip, useConverger:Boolean = false)
		{
			super();
			this.g = g;
			this.s = s;
			error = new Point();
			errorAngle = 0;
			if(useConverger && s.course != null)
			{
				lastCourse = s.course.clone();
			}
			else
			{
				lastCourse = null;
			}
		}
		
		public function enter() : void
		{
			s.target = null;
			s.setAngleTargetPos(null);
			s.stopShooting();
			s.accelerate = true;
			s.forceupdate = true;
		}
		
		public function execute() : void
		{
			var _loc3_:Number = NaN;
			var _loc1_:Number = NaN;
			var _loc11_:Point = null;
			if(s.spawner == null || s.spawner.parentObj == null)
			{
				return;
			}
			if(!s.isAddedToCanvas && !s.forceupdate && !s.spawner.isBossUnit)
			{
				return;
			}
			s.forceupdate = false;
			var _loc8_:Point = s.spawner.parentObj.pos;
			var _loc7_:Number = g.time;
			var _loc9_:Number = s.orbitAngle + 0.001 * s.angleVelocity * 33 * (_loc7_ - s.orbitStartTime);
			var _loc2_:Number = s.orbitRadius * s.ellipseFactor * Math.cos(_loc9_);
			var _loc4_:Number = s.orbitRadius * Math.sin(_loc9_);
			var _loc6_:Number = s.ellipseAlpha;
			var _loc10_:Number = _loc2_ * Math.cos(_loc6_) - _loc4_ * Math.sin(_loc6_) + _loc8_.x;
			var _loc12_:Number = _loc2_ * Math.sin(_loc6_) + _loc4_ * Math.cos(_loc6_) + _loc8_.y;
			var _loc5_:Number = 0.5 * (1 - s.orbitRadius / 500);
			if(_loc5_ > 0.5)
			{
				_loc5_ = 0.5;
			}
			else if(_loc5_ < 0)
			{
				_loc5_ = 0;
			}
			var _loc13_:* = 0;
			_loc3_ = -Math.atan2(_loc10_ - _loc8_.x,_loc12_ - _loc8_.y) - 1.5707963267948966 - Util.sign(s.angleVelocity) * (1.5707963267948966 - _loc5_);
			if(!s.aiCloak)
			{
				if(lastCourse != null)
				{
					error.x = lastCourse.pos.x - _loc10_;
					error.y = lastCourse.pos.y - _loc12_;
					_loc13_ = lastCourse.rotation;
					errorAngle = Util.angleDifference(_loc13_,_loc3_);
					convergeStartTime = _loc7_;
					lastCourse = null;
				}
				if(error.x != 0 || error.y != 0)
				{
					_loc1_ = (convergeTime - (_loc7_ - convergeStartTime)) / convergeTime;
					if(_loc1_ > 0)
					{
						_loc10_ += _loc1_ * error.x;
						_loc12_ += _loc1_ * error.y;
						_loc3_ = Util.lerpAngle(_loc13_,_loc3_,1 - _loc1_);
					}
					else
					{
						error.x = 0;
						error.y = 0;
					}
				}
				_loc11_ = s.pos;
				_loc11_.x = _loc10_;
				_loc11_.y = _loc12_;
			}
			s.rotation = _loc3_;
			s.engine.update();
			s.updateWeapons();
			s.updateHealthBars();
			s.regenerateShield();
			s.regenerateHP();
		}
		
		public function exit() : void
		{
			var _loc1_:Heading = null;
			if(!s.aiCloak)
			{
				_loc1_ = new Heading();
				_loc1_.rotation = s.rotation;
				_loc1_.pos = s.pos;
				_loc1_.speed = s.calculateOrbitSpeed();
				_loc1_.time = g.time;
				s.course = _loc1_;
			}
		}
		
		public function set stateMachine(sm:StateMachine) : void
		{
			this.sm = sm;
		}
		
		public function get type() : String
		{
			return "AIOrbit";
		}
	}
}

