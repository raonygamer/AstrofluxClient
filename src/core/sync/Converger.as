package core.sync
{
	import core.deathLine.DeathLine;
	import core.scene.Game;
	import core.ship.EnemyShip;
	import core.ship.PlayerShip;
	import core.ship.Ship;
	import core.solarSystem.Body;
	import flash.geom.Point;
	import generics.Util;
	import movement.Heading;
	
	public class Converger
	{
		public static const PI_DIVIDED_BY_8:Number = 0.39269908169872414;
		
		private const BLIP_OFFSET:Number = 30;
		
		public var course:Heading = new Heading();
		
		private var target:Heading;
		
		private var error:Point = new Point();
		
		private var errorAngle:Number;
		
		private var convergeTime:Number = 1000;
		
		private var convergeStartTime:Number;
		
		private var errorOldTime:Number;
		
		private var ship:Ship;
		
		private var g:Game;
		
		private var angleTargetPos:Point;
		
		private var isFacingTarget:Boolean;
		
		private var nextTurnDirection:int;
		
		private const RIGHT:int = 1;
		
		private const LEFT:int = -1;
		
		private const NONE:int = 0;
		
		public function Converger(ship:Ship, g:Game)
		{
			super();
			this.ship = ship;
			this.g = g;
			angleTargetPos = null;
			nextTurnDirection = 0;
		}
		
		public function run() : void
		{
			if(course == null || course.time > g.time - 33)
			{
				return;
			}
			if(ship is EnemyShip)
			{
				aiRemoveError(course);
				updateHeading(course);
				aiAddError(course);
			}
			else
			{
				updateHeading(course);
				if(target != null)
				{
					calculateOffset();
				}
			}
		}
		
		public function calculateOffset() : void
		{
			var _loc6_:Number = NaN;
			var _loc8_:Number = NaN;
			var _loc10_:* = undefined;
			var _loc11_:int = 0;
			var _loc7_:int = 0;
			var _loc4_:DeathLine = null;
			while(target.time < course.time)
			{
				_loc6_ = target.pos.y;
				_loc8_ = target.pos.x;
				updateHeading(target);
				_loc10_ = g.deathLineManager.lines;
				_loc11_ = int(_loc10_.length);
				_loc7_ = 0;
				while(_loc7_ < _loc11_)
				{
					_loc4_ = _loc10_[_loc7_];
					if(_loc4_.lineIntersection2(course.pos.x,course.pos.y,_loc8_,_loc6_,ship.collisionRadius))
					{
						target.pos.x = _loc8_;
						target.pos.y = _loc6_;
						target.speed.x = 0;
						target.speed.y = 0;
						break;
					}
					_loc7_++;
				}
			}
			var _loc1_:Number = target.pos.x - course.pos.x;
			var _loc5_:Number = target.pos.y - course.pos.y;
			var _loc2_:Number = Math.sqrt(_loc1_ * _loc1_ + _loc5_ * _loc5_);
			var _loc3_:Number = Util.angleDifference(target.rotation,course.rotation);
			if(_loc2_ > 30)
			{
				setCourse(target);
				return;
			}
			if(_loc3_ > 0.39269908169872414 || _loc3_ < -0.39269908169872414)
			{
				course.rotation = target.rotation;
				return;
			}
			var _loc9_:Number = 0.4;
			course.speed.x = target.speed.x + _loc9_ * _loc1_;
			course.speed.y = target.speed.y + _loc9_ * _loc5_;
			course.rotation += _loc3_ * 0.05;
			course.rotation = Util.clampRadians(course.rotation);
		}
		
		private function aiAddError(heading:Heading) : void
		{
			if(error.x == 0 && error.y == 0)
			{
				return;
			}
			var _loc2_:Number = g.time;
			var _loc4_:Number = (convergeTime - (_loc2_ - convergeStartTime)) / convergeTime;
			var _loc3_:Number = 3 * _loc4_ * _loc4_ - 2 * _loc4_ * _loc4_ * _loc4_;
			if(_loc4_ > 0)
			{
				heading.pos.x += _loc3_ * error.x;
				heading.pos.y += _loc3_ * error.y;
				heading.rotation += _loc3_ * errorAngle;
				errorOldTime = _loc2_;
			}
			else
			{
				error.x = 0;
				error.y = 0;
				errorOldTime = 0;
			}
		}
		
		private function aiRemoveError(heading:Heading) : void
		{
			if(error.x == 0 && error.y == 0 || errorOldTime == 0)
			{
				return;
			}
			var _loc3_:Number = (convergeTime - (errorOldTime - convergeStartTime)) / convergeTime;
			var _loc2_:Number = 3 * _loc3_ * _loc3_ - 2 * _loc3_ * _loc3_ * _loc3_;
			heading.pos.x -= _loc2_ * error.x;
			heading.pos.y -= _loc2_ * error.y;
			heading.rotation -= _loc2_ * errorAngle;
		}
		
		public function setNextTurnDirection(value:int) : void
		{
			nextTurnDirection = value;
		}
		
		public function setConvergeTarget(value:Heading) : void
		{
			target = value;
			if(ship is EnemyShip)
			{
				error.x = course.pos.x - target.pos.x;
				error.y = course.pos.y - target.pos.y;
				errorAngle = Util.angleDifference(course.rotation,target.rotation);
				convergeStartTime = g.time;
				course.speed = target.speed;
				course.pos = target.pos;
				course.rotation = target.rotation;
				course.time = target.time;
				aiAddError(course);
			}
		}
		
		public function clearConvergeTarget() : void
		{
			target = null;
			error.x = 0;
			error.y = 0;
		}
		
		public function setCourse(heading:Heading, allowFastForward:Boolean = true) : void
		{
			if(allowFastForward)
			{
				fastforwardToServerTime(heading);
			}
			course = heading;
			target = null;
		}
		
		public function setAngleTargetPos(angleTarget:Point) : void
		{
			isFacingTarget = false;
			angleTargetPos = angleTarget;
		}
		
		public function isFacingAngleTarget() : Boolean
		{
			return isFacingTarget;
		}
		
		public function fastforwardToServerTime(heading:Heading) : void
		{
			if(heading == null)
			{
				return;
			}
			while(heading.time < g.time - 33)
			{
				updateHeading(heading);
			}
		}
		
		public function updateHeading(heading:Heading) : void
		{
			var _loc13_:Point = null;
			var _loc20_:Number = NaN;
			var _loc12_:Number = NaN;
			var _loc26_:Number = NaN;
			var _loc27_:Number = NaN;
			var _loc11_:Boolean = false;
			var _loc19_:Number = NaN;
			var _loc25_:EnemyShip = null;
			var _loc3_:Number = NaN;
			var _loc4_:Number = NaN;
			var _loc23_:Number = NaN;
			var _loc14_:Number = NaN;
			var _loc18_:Number = NaN;
			var _loc24_:Number = NaN;
			var _loc21_:Number = NaN;
			var _loc9_:Number = NaN;
			var _loc8_:Number = NaN;
			var _loc6_:* = undefined;
			var _loc15_:int = 0;
			var _loc22_:int = 0;
			var _loc17_:Body = null;
			var _loc2_:Number = NaN;
			var _loc7_:Number = NaN;
			var _loc5_:Number = NaN;
			var _loc16_:Number = NaN;
			var _loc28_:Number = NaN;
			var _loc10_:Number = 33;
			if(ship is EnemyShip)
			{
			}
			if(ship is EnemyShip && angleTargetPos != null)
			{
				_loc13_ = ship.pos;
				_loc20_ = ship.rotation;
				_loc12_ = Math.atan2(angleTargetPos.y - _loc13_.y,angleTargetPos.x - _loc13_.x);
				_loc26_ = Util.angleDifference(_loc20_,_loc12_ + 3.141592653589793);
				_loc27_ = 0.001 * ship.engine.rotationSpeed * _loc10_;
				_loc11_ = _loc26_ > 0.5 * 3.141592653589793 || _loc26_ < -0.5 * 3.141592653589793;
				_loc19_ = (angleTargetPos.y - _loc13_.y) * (angleTargetPos.y - _loc13_.y) + (angleTargetPos.x - _loc13_.x) * (angleTargetPos.x - _loc13_.x);
				_loc25_ = ship as EnemyShip;
				if(_loc19_ < 2500 && _loc25_.meleeCharge)
				{
					isFacingTarget = false;
				}
				else if(!_loc11_)
				{
					heading.accelerate = true;
					heading.roll = false;
					if(_loc26_ > 0 && _loc26_ < 3.141592653589793 - _loc27_)
					{
						heading.rotation += _loc27_;
						heading.rotation = Util.clampRadians(heading.rotation);
						isFacingTarget = false;
					}
					else if(_loc26_ <= 0 && _loc26_ > -3.141592653589793 + _loc27_)
					{
						heading.rotation -= _loc27_;
						heading.rotation = Util.clampRadians(heading.rotation);
						isFacingTarget = false;
					}
				}
				else if(_loc26_ > 0 && _loc26_ < 3.141592653589793 - _loc27_)
				{
					heading.rotation += _loc27_;
					heading.rotation = Util.clampRadians(heading.rotation);
					isFacingTarget = false;
				}
				else if(_loc26_ <= 0 && _loc26_ > -3.141592653589793 + _loc27_)
				{
					heading.rotation -= _loc27_;
					heading.rotation = Util.clampRadians(heading.rotation);
					isFacingTarget = false;
				}
				else
				{
					isFacingTarget = true;
					heading.rotation = Util.clampRadians(_loc12_);
				}
			}
			else
			{
				if(heading.rotateLeft)
				{
					heading.rotation -= 0.001 * ship.engine.rotationSpeed * _loc10_;
					heading.rotation = Util.clampRadians(heading.rotation);
				}
				if(heading.rotateRight)
				{
					heading.rotation += 0.001 * ship.engine.rotationSpeed * _loc10_;
					heading.rotation = Util.clampRadians(heading.rotation);
				}
			}
			if(heading.accelerate)
			{
				_loc3_ = heading.speed.x;
				_loc4_ = heading.speed.y;
				_loc23_ = _loc3_ * _loc3_ + _loc4_ * _loc4_;
				_loc14_ = heading.rotation + ship.rollDir * ship.rollMod * ship.rollPassive;
				_loc18_ = ship.engine.acceleration * 0.5 * Math.pow(_loc10_,2);
				if(ship is EnemyShip)
				{
					_loc3_ += Math.cos(_loc14_) * _loc18_;
					_loc4_ += Math.sin(_loc14_) * _loc18_;
				}
				else
				{
					_loc3_ += Math.cos(heading.rotation) * _loc18_;
					_loc4_ += Math.sin(heading.rotation) * _loc18_;
				}
				_loc24_ = ship.engine.speed;
				if(ship.usingBoost)
				{
					_loc24_ = 0.01 * _loc24_ * (100 + ship.boostBonus);
				}
				else if(_loc23_ > _loc24_ * _loc24_)
				{
					_loc24_ = Math.sqrt(_loc23_);
				}
				if(ship.slowDownEndtime > g.time)
				{
					_loc24_ = ship.engine.speed * (1 - ship.slowDown);
				}
				_loc23_ = _loc3_ * _loc3_ + _loc4_ * _loc4_;
				if(_loc23_ <= _loc24_ * _loc24_)
				{
					heading.speed.x = _loc3_;
					heading.speed.y = _loc4_;
				}
				else
				{
					_loc21_ = Math.sqrt(_loc23_);
					_loc9_ = _loc3_ / _loc21_ * _loc24_;
					_loc8_ = _loc4_ / _loc21_ * _loc24_;
					heading.speed.x = _loc9_;
					heading.speed.y = _loc8_;
				}
			}
			else if(heading.deaccelerate)
			{
				heading.speed.x = 0.9 * heading.speed.x;
				heading.speed.y = 0.9 * heading.speed.y;
			}
			else if(ship is EnemyShip && heading.roll)
			{
				_loc3_ = heading.speed.x;
				_loc4_ = heading.speed.y;
				_loc23_ = _loc3_ * _loc3_ + _loc4_ * _loc4_;
				if(_loc23_ <= ship.rollSpeed * ship.rollSpeed)
				{
					_loc14_ = heading.rotation + ship.rollDir * ship.rollMod * 3.141592653589793 * 0.5;
					_loc18_ = ship.engine.acceleration * 0.5 * Math.pow(_loc10_,2);
					_loc3_ += Math.cos(_loc14_) * _loc18_;
					_loc4_ += Math.sin(_loc14_) * _loc18_;
					_loc23_ = _loc3_ * _loc3_ + _loc4_ * _loc4_;
					if(_loc23_ <= ship.rollSpeed * ship.rollSpeed)
					{
						heading.speed.x = _loc3_;
						heading.speed.y = _loc4_;
					}
					else
					{
						_loc21_ = Math.sqrt(_loc23_);
						_loc9_ = _loc3_ / _loc21_ * ship.rollSpeed;
						_loc8_ = _loc4_ / _loc21_ * ship.rollSpeed;
						heading.speed.x = _loc9_;
						heading.speed.y = _loc8_;
					}
				}
				else
				{
					heading.speed.x -= 0.02 * heading.speed.x;
					heading.speed.y -= 0.02 * heading.speed.y;
				}
			}
			if(ship is EnemyShip && !heading.accelerate)
			{
				heading.speed.x = 0.9 * heading.speed.x;
				heading.speed.y = 0.9 * heading.speed.y;
			}
			else
			{
				heading.speed.x -= 0.009 * heading.speed.x;
				heading.speed.y -= 0.009 * heading.speed.y;
			}
			if(ship is PlayerShip)
			{
				_loc6_ = g.bodyManager.bodies;
				_loc15_ = int(_loc6_.length);
				_loc22_ = 0;
				while(_loc22_ < _loc15_)
				{
					_loc17_ = _loc6_[_loc22_];
					if(_loc17_.type == "sun")
					{
						_loc2_ = _loc17_.pos.x - heading.pos.x;
						_loc7_ = _loc17_.pos.y - heading.pos.y;
						_loc5_ = _loc2_ * _loc2_ + _loc7_ * _loc7_;
						if(_loc5_ <= _loc17_.gravityDistance)
						{
							if(_loc5_ != 0)
							{
								if(_loc5_ < _loc17_.gravityMin)
								{
									_loc5_ = _loc17_.gravityMin;
								}
								_loc16_ = Math.atan2(_loc7_,_loc2_);
								_loc16_ = Util.clampRadians(_loc16_);
								_loc28_ = _loc17_.gravityForce / _loc5_ * _loc10_ * 0.001;
								heading.speed.x += Math.cos(_loc16_) * _loc28_;
								heading.speed.y += Math.sin(_loc16_) * _loc28_;
							}
						}
					}
					_loc22_++;
				}
			}
			heading.pos.x += heading.speed.x * _loc10_ * 0.001;
			heading.pos.y += heading.speed.y * _loc10_ * 0.001;
			heading.time += _loc10_;
		}
	}
}

