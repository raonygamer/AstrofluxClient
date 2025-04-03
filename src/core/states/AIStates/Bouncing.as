package core.states.AIStates
{
	import core.projectile.Projectile;
	import core.scene.Game;
	import core.states.IState;
	import core.states.StateMachine;
	import core.unit.Unit;
	import flash.geom.Point;
	import generics.Util;
	
	public class Bouncing implements IState
	{
		protected var m:Game;
		
		protected var p:Projectile;
		
		private var sm:StateMachine;
		
		private var isEnemy:Boolean;
		
		private var globalInterval:Number = 1000;
		
		private var localTargetList:Vector.<Unit>;
		
		private var nextGlobalUpdate:Number;
		
		private var nextLocalUpdate:Number;
		
		private var localRangeSQ:Number;
		
		private var firstUpdate:Boolean;
		
		public function Bouncing(m:Game, p:Projectile)
		{
			super();
			this.m = m;
			this.p = p;
			p.target = null;
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
			if(p.ttl < globalInterval)
			{
				globalInterval = p.ttl;
			}
			localTargetList = new Vector.<Unit>();
			firstUpdate = true;
			nextGlobalUpdate = 0;
			nextLocalUpdate = 0;
			localRangeSQ = globalInterval * 0.001 * (p.speedMax + 400);
			localRangeSQ *= localRangeSQ;
			if(p.unit.lastBulletTargetList != null)
			{
				if(p.unit.lastBulletGlobal > m.time)
				{
					nextGlobalUpdate = p.unit.lastBulletGlobal;
					localTargetList = p.unit.lastBulletTargetList;
					firstUpdate = false;
				}
				else
				{
					p.unit.lastBulletTargetList = null;
					firstUpdate = true;
				}
				if(p.unit.lastBulletLocal > m.time + 50)
				{
					nextLocalUpdate = p.unit.lastBulletLocal - 50;
					firstUpdate = false;
				}
			}
		}
		
		public function execute() : void
		{
			var _loc21_:Unit = null;
			var _loc18_:Number = NaN;
			var _loc13_:Number = NaN;
			var _loc26_:Number = NaN;
			var _loc25_:Number = NaN;
			var _loc19_:int = 0;
			var _loc16_:int = 0;
			var _loc15_:Number = NaN;
			var _loc20_:* = undefined;
			var _loc9_:Boolean = false;
			if(p.target != null)
			{
				nextLocalUpdate = m.time;
				nextGlobalUpdate = m.time;
				aim(p.target);
				p.target = null;
				p.error = null;
			}
			var _loc2_:Number = 33;
			var _loc1_:int = (p.convergenceTime - p.convergenceCounter) / p.convergenceTime;
			if(_loc1_ <= 0)
			{
				p.error = null;
			}
			if(p.error != null)
			{
				p.course.pos.x += p.error.x * _loc1_;
				p.course.pos.y += p.error.y * _loc1_;
			}
			p.oldPos.x = p.course.pos.x;
			p.oldPos.y = p.course.pos.y;
			p.updateHeading(p.course);
			if(p.error != null)
			{
				p.convergenceCounter++;
				_loc1_ = (p.convergenceTime - p.convergenceCounter) / p.convergenceTime;
				p.course.pos.x -= p.error.x * _loc1_;
				p.course.pos.y -= p.error.y * _loc1_;
			}
			if(nextLocalUpdate > m.time)
			{
				return;
			}
			var _loc24_:* = 100000000;
			var _loc3_:Point = p.course.pos;
			if(_loc3_.y == p.oldPos.y && _loc3_.x == p.oldPos.x)
			{
				return;
			}
			var _loc5_:Number = -Math.atan2(_loc3_.y - p.oldPos.y,_loc3_.x - p.oldPos.x);
			var _loc22_:Number = Math.cos(_loc5_);
			var _loc10_:Number = Math.sin(_loc5_);
			var _loc4_:Number = p.oldPos.x * _loc22_ - p.oldPos.y * _loc10_;
			var _loc7_:Number = p.oldPos.x * _loc10_ + p.oldPos.y * _loc22_;
			var _loc8_:Number = _loc3_.x * _loc22_ - _loc3_.y * _loc10_;
			var _loc6_:Number = _loc3_.x * _loc10_ + _loc3_.y * _loc22_;
			var _loc11_:Number = p.collisionRadius;
			var _loc12_:Number = Math.min(_loc4_,_loc8_) - _loc11_;
			var _loc14_:Number = Math.max(_loc4_,_loc8_) + _loc11_;
			var _loc23_:Number = Math.min(_loc7_,_loc6_) - _loc11_;
			var _loc17_:Number = Math.max(_loc7_,_loc6_) + _loc11_;
			if(isEnemy)
			{
				_loc19_ = int(m.shipManager.players.length);
				_loc16_ = 0;
				while(_loc16_ < _loc19_)
				{
					_loc21_ = m.shipManager.players[_loc16_];
					if(!(!_loc21_.alive || _loc21_.invulnerable))
					{
						_loc18_ = _loc21_.pos.x;
						_loc13_ = _loc21_.pos.y;
						_loc26_ = _loc3_.x - _loc18_;
						_loc25_ = _loc3_.y - _loc13_;
						_loc15_ = _loc26_ * _loc26_ + _loc25_ * _loc25_;
						if(_loc24_ > _loc15_)
						{
							_loc24_ = _loc15_;
						}
						if(_loc15_ <= 2500)
						{
							_loc4_ = _loc18_ * _loc22_ - _loc13_ * _loc10_;
							_loc7_ = _loc18_ * _loc10_ + _loc13_ * _loc22_;
							_loc11_ = _loc21_.collisionRadius;
							if(_loc4_ <= _loc14_ + _loc11_ && _loc4_ > _loc12_ - _loc11_ && _loc7_ <= _loc17_ + _loc11_ && _loc7_ > _loc23_ - _loc11_)
							{
								if(p.numberOfHits <= 1)
								{
									_loc3_.y = (_loc23_ * _loc22_ / _loc10_ - _loc4_ + (_loc11_ - p.collisionRadius)) / (1 * _loc10_ + _loc22_ * _loc22_ / _loc10_);
									_loc3_.x = (_loc23_ - _loc3_.y * _loc22_) / _loc10_;
									p.destroy();
									return;
								}
								p.explode();
								if(p.numberOfHits >= 10)
								{
									p.numberOfHits--;
								}
							}
						}
					}
					_loc16_++;
				}
				nextLocalUpdate = m.time + Math.sqrt(_loc24_) * 1000 / (p.speedMax + 5 * 60) - 35;
				if(firstUpdate)
				{
					firstUpdate = false;
					p.unit.lastBulletLocal = nextLocalUpdate;
				}
			}
			else
			{
				if(nextGlobalUpdate < m.time)
				{
					_loc9_ = true;
					_loc20_ = m.unitManager.units;
					localTargetList.splice(0,localTargetList.length);
					nextGlobalUpdate = m.time + 1000;
				}
				else
				{
					_loc9_ = false;
					_loc20_ = localTargetList;
				}
				_loc19_ = int(_loc20_.length);
				_loc16_ = 0;
				while(_loc16_ < _loc19_)
				{
					_loc21_ = _loc20_[_loc16_];
					if(!(!_loc21_.canBeDamage(p.unit,p) || !(p.aiTargetSelf && p.unit == _loc21_)))
					{
						_loc18_ = _loc21_.pos.x;
						_loc13_ = _loc21_.pos.y;
						_loc26_ = _loc3_.x - _loc18_;
						_loc25_ = _loc3_.y - _loc13_;
						_loc15_ = _loc26_ * _loc26_ + _loc25_ * _loc25_;
						if(_loc9_ && _loc15_ < localRangeSQ)
						{
							localTargetList.push(_loc21_);
						}
						if(_loc24_ > _loc15_)
						{
							_loc24_ = _loc15_;
						}
						if(_loc15_ <= 2500)
						{
							_loc4_ = _loc18_ * _loc22_ - _loc13_ * _loc10_;
							_loc7_ = _loc18_ * _loc10_ + _loc13_ * _loc22_;
							_loc11_ = _loc21_.collisionRadius;
							if(_loc4_ <= _loc14_ + _loc11_ && _loc4_ > _loc12_ - _loc11_ && _loc7_ <= _loc17_ + _loc11_ && _loc7_ > _loc23_ - _loc11_)
							{
								if(p.numberOfHits <= 1)
								{
									_loc3_.y = (_loc23_ * _loc22_ / _loc10_ - _loc4_ + (_loc11_ - p.collisionRadius)) / (1 * _loc10_ + _loc22_ * _loc22_ / _loc10_);
									_loc3_.x = (_loc23_ - _loc3_.y * _loc22_) / _loc10_;
									p.destroy();
									return;
								}
								p.explode();
								if(p.numberOfHits >= 10)
								{
									p.numberOfHits--;
								}
							}
						}
					}
					_loc16_++;
				}
				nextLocalUpdate = m.time + Math.sqrt(_loc24_) * 1000 / (p.speedMax + 400) - 35;
				if(nextGlobalUpdate < nextLocalUpdate)
				{
					nextGlobalUpdate = nextLocalUpdate;
				}
				if(firstUpdate)
				{
					firstUpdate = false;
					p.unit.lastBulletGlobal = nextGlobalUpdate;
					p.unit.lastBulletLocal = nextLocalUpdate;
					p.unit.lastBulletTargetList = localTargetList;
				}
			}
		}
		
		public function aim(target:Unit) : void
		{
			var _loc9_:Number = 0;
			var _loc7_:Number = 0;
			var _loc8_:Number = target.pos.x;
			var _loc6_:Number = target.pos.y;
			var _loc11_:Number = p.course.pos.x;
			var _loc2_:Number = p.course.pos.y;
			_loc9_ = _loc8_ - _loc11_;
			_loc7_ = _loc6_ - _loc2_;
			var _loc3_:Number = Math.sqrt(_loc9_ * _loc9_ + _loc7_ * _loc7_);
			_loc9_ /= _loc3_;
			_loc7_ /= _loc3_;
			var _loc10_:Number = _loc3_ / (p.course.speed.length - Util.dotProduct(target.speed.x,target.speed.y,_loc9_,_loc7_));
			var _loc5_:Number = _loc8_ + target.speed.x * _loc10_;
			var _loc4_:Number = _loc6_ + target.speed.y * _loc10_;
			p.course.rotation = Math.atan2(_loc4_ - _loc2_,_loc5_ - _loc11_);
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
			return "Bouncing";
		}
	}
}

