package core.weapon
{
	import core.projectile.Projectile;
	import core.projectile.ProjectileFactory;
	import core.scene.Game;
	import core.ship.PlayerShip;
	import flash.geom.Point;
	
	public class Blaster extends Weapon
	{
		private var nextShot:Number;
		
		public function Blaster(g:Game)
		{
			super(g);
		}
		
		override protected function shoot() : void
		{
			var _loc2_:PlayerShip = null;
			var _loc3_:Number = NaN;
			var _loc1_:Number = g.time;
			while(fireNextTime <= _loc1_)
			{
				if(unit is PlayerShip)
				{
					_loc2_ = unit as PlayerShip;
					if(!_loc2_.weaponHeat.canFire(heatCost))
					{
						fireNextTime += reloadTime;
						return;
					}
				}
				if(_loc1_ - lastFire > reloadTime)
				{
					burstCurrent = 0;
				}
				burstCurrent++;
				if(burstCurrent < burst)
				{
					_loc3_ = burstDelay;
				}
				else
				{
					_loc3_ = reloadTime;
					burstCurrent = 0;
				}
				if(burstCurrent > 0)
				{
					fireNextTime = _loc1_ + 1;
				}
				else if(fireNextTime == 0 || lastFire == 0)
				{
					fireNextTime = _loc1_ + _loc3_ - 33;
				}
				else
				{
					fireNextTime += _loc3_;
				}
				lastFire = _loc1_;
				playFireSound();
				if(sideShooter)
				{
					fireProjectiles(-0.5 * 3.141592653589793);
					fireProjectiles(0.5 * 3.141592653589793);
				}
				else
				{
					fireProjectiles();
				}
			}
		}
		
		private function fireProjectiles(offsetFireAngle:Number = 0) : void
		{
			var _loc9_:int = 0;
			var _loc2_:Projectile = null;
			var _loc11_:Number = NaN;
			var _loc5_:Number = NaN;
			var _loc3_:Number = NaN;
			var _loc8_:Number = NaN;
			var _loc7_:Number = NaN;
			var _loc4_:Number = NaN;
			var _loc10_:Number = NaN;
			var _loc6_:Weapon = this;
			_loc9_ = 0;
			while(_loc9_ < multiNrOfP)
			{
				_loc2_ = ProjectileFactory.create(projectileFunction,g,unit,_loc6_);
				if(_loc2_ == null)
				{
					return;
				}
				_loc11_ = multiNrOfP;
				_loc5_ = multiOffset * (_loc9_ - 0.5 * (_loc11_ - 1)) / _loc11_ + (positionYVariance - Math.random() * positionYVariance * 2) + unit.weaponPos.y;
				_loc3_ = unit.weaponPos.x + positionOffsetX + (positionXVariance - Math.random() * positionXVariance * 2);
				_loc8_ = new Point(_loc3_,_loc5_).length;
				_loc7_ = Math.atan2(_loc5_,_loc3_);
				_loc4_ = multiAngleOffset * (_loc9_ - 0.5 * (_loc11_ - 1)) / _loc11_;
				_loc10_ = unit.rotation + _loc4_ + _loc7_ + offsetFireAngle;
				_loc2_.course.pos.x = unit.x + Math.cos(_loc10_) * _loc8_;
				_loc2_.course.pos.y = unit.y + Math.sin(_loc10_) * _loc8_;
				_loc2_.course.rotation = unit.rotation + _loc4_ + offsetFireAngle + (angleVariance - Math.random() * angleVariance * 2);
				if(_loc2_.useShipSystem)
				{
					_loc2_.course.speed.x += Math.cos(_loc2_.course.rotation) * _loc2_.speedMax;
					_loc2_.course.speed.y += Math.sin(_loc2_.course.rotation) * _loc2_.speedMax;
				}
				else if(acceleration == 0)
				{
					_loc2_.course.speed.x = Math.cos(_loc2_.course.rotation) * _loc2_.speedMax;
					_loc2_.course.speed.y = Math.sin(_loc2_.course.rotation) * _loc2_.speedMax;
				}
				if(_loc2_.stateMachine.inState("Instant"))
				{
					_loc2_.range = range * (0.9 + 0.2 * Math.random());
				}
				g.projectileManager.activateProjectile(_loc2_);
				_loc9_++;
			}
		}
	}
}

