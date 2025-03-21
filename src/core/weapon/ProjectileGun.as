package core.weapon {
	import core.projectile.Projectile;
	import core.projectile.ProjectileFactory;
	import core.scene.Game;
	import core.ship.PlayerShip;
	import core.unit.Unit;
	import flash.geom.Point;
	import movement.Heading;
	
	public class ProjectileGun extends Weapon {
		public function ProjectileGun(g:Game) {
			super(g);
		}
		
		override protected function shoot() : void {
			var _local1:PlayerShip = null;
			if(unit is PlayerShip) {
				if(hasChargeUp && (projectiles.length < maxProjectiles || maxProjectiles == 0)) {
					if(unit != null && unit is PlayerShip) {
						_local1 = unit as PlayerShip;
						if(fireNextTime < g.time) {
							if(chargeUpTime == 0) {
								if(fireEffect != "") {
									_local1.startChargeUpEffect(fireEffect);
								} else {
									_local1.startChargeUpEffect();
								}
							}
							chargeUpTime += 33;
							if(_local1.player.isMe) {
								if(chargeUpTime < chargeUpTimeMax) {
									g.hud.powerBar.updateLoadBar(chargeUpTime / chargeUpTimeMax);
								} else {
									g.hud.powerBar.updateLoadBar(1);
								}
							}
							if(triggerMeleeAnimation) {
								(unit as PlayerShip).triggerMeleeTextures(reloadTime / 1000);
							}
						} else if(_local1.player.isMe) {
							g.hud.powerBar.updateLoadBar(0);
							chargeUpTime = 0;
						}
						return;
					}
				}
			}
		}
		
		public function shootSyncedProjectile(id:int, target:Unit, heading:Heading, multiPid:int = -1, power:Number = 0, xRandOffset:Number = 0, yRandOffset:Number = 0, maxSpeed:Number = 0) : void {
			var _local14:PlayerShip = null;
			var _local19:Number = NaN;
			var _local10:Number = NaN;
			var _local18:Number = NaN;
			if(unit == null) {
				return;
			}
			if(fireCallback != null && this.hasChargeUp == true && (projectiles.length + 1 < maxProjectiles || maxProjectiles == 0)) {
				lastFire = g.time;
				fireNextTime = g.time + reloadTime;
				fireCallback();
			}
			if(unit is PlayerShip) {
				_local14 = unit as PlayerShip;
				_local14.weaponHeat.setHeat(power);
				if(hasChargeUp && !_local14.player.isMe) {
					fire = false;
				} else if(triggerMeleeAnimation) {
					(unit as PlayerShip).triggerMeleeTextures(reloadTime / 1000);
				}
			}
			var _local13:Weapon = this;
			var _local15:Projectile = ProjectileFactory.create(projectileFunction,g,unit,this);
			if(_local15 == null) {
				return;
			}
			if(target != null) {
				_local15.target = target;
			}
			if(name == "Snow Cannon" || name == "Poison Arrow" || name == "Nexar Projector" || name == "Shadow Projector") {
				_local15.speedMax = maxSpeed;
				if(name == "Snow Cannon") {
					_local15.scaleX = 0.2 + 0.5 * _local15.speedMax / (25 * 60);
					_local15.scaleY = 0.2 + 0.5 * _local15.speedMax / (25 * 60);
				}
			}
			if(maxSpeed != 0) {
				if(_local15.stateMachine.inState("Instant")) {
					_local15.range = maxSpeed;
					_local15.speedMax = 10000;
				} else {
					_local15.speedMax = maxSpeed;
				}
			}
			if(target != null) {
				_local13.target = target;
				_local19 = aim();
			} else {
				_local19 = 0;
			}
			var _local12:Number = multiNrOfP;
			if(multiNrOfP > 1 && multiPid > -1) {
				_local10 = unit.weaponPos.y + multiOffset * (multiPid - 0.5 * (_local12 - 1)) / _local12;
			} else if(multiPid > -1) {
				_local10 = unit.weaponPos.y + 0.25 * multiOffset * (2 * (multiPid % 2) - 1);
			} else {
				_local10 = unit.weaponPos.y;
			}
			var _local9:Number = unit.weaponPos.x + positionOffsetX;
			var _local17:Number = new Point(_local9,_local10).length;
			var _local11:Number = Math.atan2(_local10,_local9);
			var _local16:Number = multiAngleOffset * (multiPid - 0.5 * (_local12 - 1)) / _local12;
			_local15.course.pos.x = unit.pos.x + Math.cos(unit.rotation + _local16 + _local11 + _local19) * _local17;
			_local15.course.pos.y = unit.pos.y + Math.sin(unit.rotation + _local16 + _local11 + _local19) * _local17;
			_local15.course.pos.x += xRandOffset;
			_local15.course.pos.y += yRandOffset;
			_local15.course.rotation = unit.rotation + _local16 + _local19 + (angleVariance - Math.random() * angleVariance * 2);
			if(fireBackwards) {
				_local15.course.rotation -= 3.141592653589793;
			}
			if(acceleration == 0) {
				_local15.course.speed.x = Math.cos(_local15.course.rotation) * _local15.speedMax;
				_local15.course.speed.y = Math.sin(_local15.course.rotation) * _local15.speedMax;
			} else if(multiSpreadStart) {
				_local15.course.speed.x = _local15.unit.speed.x * 0.5;
				_local15.course.speed.y = _local15.unit.speed.y * 0.5;
				_local18 = 10 * (multiPid - 0.5 * (_local12 - 1)) / _local12;
				if(_local18 > 0) {
					_local18 += 10;
				} else {
					_local18 -= 10;
				}
				_local15.course.speed.x -= Math.sin(_local15.course.rotation) * _local18;
				_local15.course.speed.y += Math.cos(_local15.course.rotation) * _local18;
			} else {
				_local15.course.speed.x = unit.speed.x * 0.5;
				_local15.course.speed.y = unit.speed.y * 0.5;
			}
			_local15.target = target;
			_local15.error = new Point(_local15.course.pos.x - heading.pos.x,_local15.course.pos.y - heading.pos.y);
			_local15.convergenceCounter = 0;
			_local15.course = heading;
			_local15.convergenceTime = 1000 / 33;
			_local15.collisionRadius = 0;
			_local15.id = id;
			g.projectileManager.activateProjectile(_local15);
			playFireSound();
		}
	}
}

