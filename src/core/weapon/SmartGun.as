package core.weapon {
	import core.projectile.Projectile;
	import core.projectile.ProjectileFactory;
	import core.scene.Game;
	import core.ship.PlayerShip;
	import flash.geom.Point;
	
	public class SmartGun extends Weapon {
		public function SmartGun(g:Game) {
			super(g);
		}
		
		override public function init(obj:Object, techLevel:int, eliteTechLevel:int = -1, eliteTech:String = "") : void {
			super.init(obj,techLevel,eliteTechLevel,eliteTech);
		}
		
		override public function destroy() : void {
			super.destroy();
		}
		
		override protected function shoot() : void {
			var _local2:PlayerShip = null;
			var _local3:Number = NaN;
			var _local4:Number = NaN;
			var _local1:Number = Number(g.time.valueOf());
			while(fireNextTime < g.time) {
				if(unit is PlayerShip) {
					_local2 = unit as PlayerShip;
					if(!_local2.weaponHeat.canFire(heatCost)) {
						fireNextTime += reloadTime;
						return;
					}
				}
				if(_local1 - lastFire > reloadTime) {
					burstCurrent = 0;
				}
				burstCurrent++;
				if(burstCurrent < burst) {
					_local3 = burstDelay;
				} else {
					_local3 = reloadTime;
					burstCurrent = 0;
				}
				playFireSound();
				if(target == null || !target.alive || !inRange(target)) {
					fireProjectiles();
				} else {
					_local4 = aim();
					fireProjectiles(_local4);
				}
				if(burstCurrent > 0) {
					fireNextTime = g.time + 1;
				} else if(fireNextTime == 0 || lastFire == 0) {
					fireNextTime = _local1 + _local3 - 33;
				} else {
					fireNextTime += _local3;
				}
				lastFire = g.time;
			}
		}
		
		private function fireProjectiles(offsetFireAngle:Number = 0) : void {
			var _local10:int = 0;
			var _local5:Projectile = null;
			var _local8:Number = NaN;
			var _local4:Number = NaN;
			var _local3:Number = NaN;
			var _local7:Number = NaN;
			var _local9:Number = NaN;
			var _local6:Number = NaN;
			var _local2:Weapon = this;
			_local10 = 0;
			while(_local10 < multiNrOfP) {
				_local5 = ProjectileFactory.create(projectileFunction,g,unit,_local2);
				if(_local5 == null) {
					return;
				}
				if(_local10 == 1 && multiNrOfP == 2) {
					_local5.scaleY = -1;
				}
				_local8 = multiNrOfP;
				_local4 = multiOffset * (_local10 - 0.5 * (_local8 - 1)) / _local8 + (positionYVariance - Math.random() * positionYVariance * 2) + unit.weaponPos.y;
				_local3 = unit.weaponPos.x + positionOffsetX + (positionXVariance - Math.random() * positionXVariance * 2);
				_local7 = new Point(_local3,_local4).length;
				_local9 = Math.atan2(_local4,_local3);
				_local6 = multiAngleOffset * (_local10 - 0.5 * (_local8 - 1)) / _local8;
				_local5.course.pos.x = unit.pos.x + Math.cos(unit.rotation + _local6 + _local9 + offsetFireAngle) * _local7;
				_local5.course.pos.y = unit.pos.y + Math.sin(unit.rotation + _local6 + _local9 + offsetFireAngle) * _local7;
				_local5.course.rotation = unit.rotation + _local6 + offsetFireAngle + (angleVariance - Math.random() * angleVariance * 2);
				if(fireBackwards) {
					_local5.course.rotation -= 3.141592653589793;
				}
				if(_local5.useShipSystem) {
					_local5.course.speed.x += Math.cos(_local5.course.rotation) * _local5.speedMax;
					_local5.course.speed.y += Math.sin(_local5.course.rotation) * _local5.speedMax;
				} else if(acceleration == 0) {
					_local5.course.speed.x = Math.cos(_local5.course.rotation) * _local5.speedMax;
					_local5.course.speed.y = Math.sin(_local5.course.rotation) * _local5.speedMax;
				}
				if(_local5.stateMachine.inState("Instant")) {
					_local5.range = range * (0.9 + 0.2 * Math.random());
				}
				g.projectileManager.activateProjectile(_local5);
				_local10++;
			}
		}
	}
}

