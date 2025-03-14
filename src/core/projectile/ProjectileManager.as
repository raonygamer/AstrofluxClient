package core.projectile {
	import core.player.Player;
	import core.scene.Game;
	import core.ship.EnemyShip;
	import core.ship.PlayerShip;
	import core.ship.Ship;
	import core.states.AIStates.ProjectileStuck;
	import core.turret.Turret;
	import core.unit.Unit;
	import core.weapon.ProjectileGun;
	import core.weapon.Weapon;
	import debug.Console;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import generics.Util;
	import movement.Heading;
	import playerio.Message;
	import starling.display.MeshBatch;
	
	public class ProjectileManager {
		public var inactiveProjectiles:Vector.<Projectile>;
		public var projectiles:Vector.<Projectile>;
		public var projectilesById:Dictionary;
		private var TARGET_TYPE_SHIP:String = "ship";
		private var TARGET_TYPE_SPAWNER:String = "spawner";
		private var g:Game;
		private var meshBatch:MeshBatch;
		
		public function ProjectileManager(g:Game) {
			var _local3:int = 0;
			var _local2:Projectile = null;
			inactiveProjectiles = new Vector.<Projectile>();
			projectiles = new Vector.<Projectile>();
			projectilesById = new Dictionary();
			meshBatch = new MeshBatch();
			super();
			this.g = g;
			_local3 = 0;
			while(_local3 < 100) {
				_local2 = new Projectile(g);
				inactiveProjectiles.push(_local2);
				_local3++;
			}
		}
		
		public function addMessageHandlers() : void {
			g.addMessageHandler("projectileAddEnemy",addEnemyProjectile);
			g.addMessageHandler("projectileAddPlayer",addPlayerProjectile);
			g.addMessageHandler("projectileCourse",updateCourse);
			g.addMessageHandler("killProjectile",killProjectile);
			g.addMessageHandler("killStuckProjectiles",killStuckProjectiles);
			g.canvasProjectiles.addChild(meshBatch);
		}
		
		public function update() : void {
			var _local3:int = 0;
			var _local1:Projectile = null;
			meshBatch.clear();
			var _local2:int = int(projectiles.length);
			_local3 = _local2 - 1;
			while(_local3 > -1) {
				_local1 = projectiles[_local3];
				if(_local1.alive) {
					_local1.update();
					if(_local1.hasImage && _local1.isVisible) {
						meshBatch.addMesh(_local1.movieClip);
					}
				} else {
					remove(_local1,_local3);
				}
				_local3--;
			}
		}
		
		public function getProjectile() : Projectile {
			var _local1:Projectile = null;
			if(inactiveProjectiles.length > 0) {
				_local1 = inactiveProjectiles.pop();
			} else {
				_local1 = new Projectile(g);
			}
			_local1.reset();
			return _local1;
		}
		
		public function handleBouncing(m:Message, i:int) : void {
			var _local3:int = m.getInt(i);
			var _local5:int = m.getInt(i + 1);
			var _local4:Projectile = projectilesById[_local3];
			if(_local4 == null) {
				return;
			}
			_local4.target = g.unitManager.getTarget(_local5);
		}
		
		public function activateProjectile(p:Projectile) : void {
			p.x = p.course.pos.x;
			p.y = p.course.pos.y;
			if(p.randomAngle) {
				p.rotation = Math.random() * 3.141592653589793 * 2;
			} else {
				p.rotation = p.course.rotation;
			}
			projectiles.push(p);
			p.addToCanvas();
			p.tryAddRibbonTrail();
			if(projectilesById[p.id] != null) {
				Console.write("error: p.id: " + p.id);
			}
			if(p.id != 0) {
				projectilesById[p.id] = p;
			}
		}
		
		public function addEnemyProjectile(m:Message) : void {
			var _local7:int = 0;
			var _local8:int = 0;
			var _local2:int = 0;
			var _local5:int = 0;
			var _local9:Heading = null;
			var _local13:int = 0;
			var _local4:int = 0;
			var _local14:int = 0;
			var _local12:Number = NaN;
			var _local3:EnemyShip = null;
			var _local10:Weapon = null;
			var _local6:Turret = null;
			var _local11:Dictionary = g.shipManager.enemiesById;
			_local7 = 0;
			while(_local7 < m.length - 6) {
				_local8 = m.getInt(_local7);
				_local2 = m.getInt(_local7 + 1);
				_local5 = m.getInt(_local7 + 2);
				_local9 = new Heading();
				_local9.parseMessage(m,_local7 + 3);
				_local13 = m.getInt(_local7 + 3 + 10);
				_local4 = m.getInt(_local7 + 4 + 10);
				_local14 = m.getInt(_local7 + 5 + 10);
				_local12 = m.getNumber(_local7 + 6 + 10);
				_local3 = _local11[_local2];
				if(_local3 != null && _local3.weapons.length > _local5 && _local3.weapons[_local5] != null) {
					_local10 = _local3.weapons[_local5];
					createSetProjectile(ProjectileFactory.create(_local10.projectileFunction,g,_local3,_local10,_local9),_local8,_local3,_local9,_local13,_local4,_local14,_local12);
				} else {
					_local6 = g.turretManager.getTurretById(_local2);
					if(_local6 != null && _local6.weapon != null) {
						_local10 = _local6.weapon;
						createSetProjectile(ProjectileFactory.create(_local10.projectileFunction,g,_local6,_local10),_local8,_local6,_local9,_local13,_local4,_local14,_local12);
					}
				}
				_local7 += 7 + 10;
			}
		}
		
		public function addInitProjectiles(m:Message, startIndex:int, endIndex:int) : void {
			var _local11:* = 0;
			var _local7:int = 0;
			var _local6:int = 0;
			var _local10:int = 0;
			var _local8:Ship = null;
			var _local5:Heading = null;
			var _local9:int = 0;
			var _local4:Weapon = null;
			_local11 = startIndex;
			while(_local11 < endIndex - 4) {
				_local7 = m.getInt(_local11);
				_local6 = m.getInt(_local11 + 1);
				_local10 = m.getInt(_local11 + 2);
				_local8 = g.unitManager.getTarget(_local6) as Ship;
				_local5 = new Heading();
				_local5.pos.x = m.getNumber(_local11 + 3);
				_local5.pos.y = m.getNumber(_local11 + 4);
				_local9 = m.getNumber(_local11 + 5);
				if(_local8 != null && _local10 > 0 && _local10 < _local8.weapons.length) {
					_local4 = _local8.weapons[_local10];
					createSetProjectile(ProjectileFactory.create(_local4.projectileFunction,g,_local8,_local4),_local7,_local8,_local5,_local9);
				}
				_local11 += 6;
			}
		}
		
		public function addPlayerProjectile(m:Message) : void {
			var _local6:int = 0;
			var _local8:int = 0;
			var _local10:String = null;
			var _local4:int = 0;
			var _local5:int = 0;
			var _local14:Heading = null;
			var _local13:int = 0;
			var _local3:int = 0;
			var _local15:int = 0;
			var _local11:Number = NaN;
			var _local2:Player = null;
			var _local9:PlayerShip = null;
			var _local7:ProjectileGun = null;
			var _local12:Unit = null;
			_local6 = 0;
			while(_local6 < m.length - 8 - 10) {
				if(m.length < 6 + 10) {
					return;
				}
				_local8 = m.getInt(_local6);
				_local10 = m.getString(_local6 + 1);
				_local4 = m.getInt(_local6 + 2);
				_local5 = m.getInt(_local6 + 3);
				_local14 = new Heading();
				_local14.parseMessage(m,_local6 + 5);
				_local13 = m.getInt(_local6 + 5 + 10);
				_local3 = m.getInt(_local6 + 6 + 10);
				_local15 = m.getInt(_local6 + 7 + 10);
				_local11 = m.getNumber(_local6 + 8 + 10);
				_local2 = g.playerManager.playersById[_local10];
				if(_local2 == null) {
					return;
				}
				_local9 = _local2.ship;
				if(_local9 == null || _local9.weapons == null) {
					return;
				}
				if(!(_local4 > -1 && _local4 < _local2.ship.weapons.length)) {
					return;
				}
				_local2.selectedWeaponIndex = _local4;
				if(_local9.weapon != null && _local9.weapon is ProjectileGun) {
					_local7 = _local9.weapon as ProjectileGun;
					_local12 = null;
					if(_local5 != -1) {
						_local12 = g.unitManager.getTarget(_local5);
					}
					_local7.shootSyncedProjectile(_local8,_local12,_local14,_local13,m.getNumber(_local6 + 4),_local3,_local15,_local11);
				}
				_local6 += 9 + 10;
			}
		}
		
		private function createSetProjectile(p:Projectile, id:int, enemy:Unit, course:Heading, multiPid:int, xRandOffset:int = 0, yRandOffset:int = 0, maxSpeed:Number = 0) : void {
			var _local10:Point = null;
			var _local13:Number = NaN;
			var _local11:Number = NaN;
			var _local9:Number = NaN;
			var _local15:Number = NaN;
			var _local12:Number = NaN;
			if(p == null) {
				return;
			}
			var _local14:Weapon = p.weapon;
			p.id = id;
			if(maxSpeed != 0) {
				p.speedMax = maxSpeed;
			}
			if(p.speedMax != 0) {
				_local10 = new Point();
				if(multiPid > -1) {
					_local13 = _local14.multiNrOfP;
					_local11 = enemy.weaponPos.y + _local14.multiOffset * (multiPid - 0.5 * (_local13 - 1)) / _local13;
				} else {
					_local11 = enemy.weaponPos.y;
				}
				_local9 = enemy.weaponPos.x + _local14.positionOffsetX;
				_local15 = new Point(_local9,_local11).length;
				_local12 = Math.atan2(_local11,_local9);
				_local10.x = enemy.pos.x + Math.cos(enemy.rotation + _local12) * _local15 + xRandOffset;
				_local10.y = enemy.pos.y + Math.sin(enemy.rotation + _local12) * _local15 + yRandOffset;
				p.unit = enemy;
				p.course = course;
				p.rotation = course.rotation;
				p.fastforward();
				p.x = course.pos.x;
				p.y = course.pos.y;
				p.collisionRadius = 0.5 * p.collisionRadius;
				p.error = new Point(-p.course.pos.x + _local10.x,-p.course.pos.y + _local10.y);
				p.convergenceCounter = 0;
				p.course = course;
				p.convergenceTime = 151.51515151515153;
				if(p.error.length > 1000) {
					p.error.x = 0;
					p.error.y = 0;
				}
				if(maxSpeed != 0) {
					if(p.stateMachine.inState("Instant")) {
						p.range = maxSpeed;
						p.speedMax = 10000;
					} else {
						p.speedMax = maxSpeed;
					}
				}
			} else {
				p.course = course;
				p.x = course.pos.x;
				p.y = course.pos.y;
			}
			activateProjectile(p);
			_local14.playFireSound();
		}
		
		private function updateCourse(m:Message) : void {
			var _local9:int = 0;
			var _local2:int = 0;
			var _local7:int = 0;
			var _local5:Projectile = null;
			var _local6:int = 0;
			var _local3:Number = NaN;
			var _local8:Heading = null;
			var _local4:Dictionary = g.shipManager.enemiesById;
			_local9 = 0;
			while(_local9 < m.length) {
				_local2 = m.getInt(_local9);
				_local7 = m.getInt(_local9 + 1);
				_local5 = projectilesById[_local2];
				if(_local5 == null) {
					return;
				}
				_local6 = m.getInt(_local9 + 2);
				if(_local7 == 0) {
					_local5.direction = _local6;
					if(_local5.direction > 0) {
						_local5.boomerangReturning = true;
						_local5.rotationSpeedMax = m.getNumber(_local9 + 3);
					}
					if(_local6 == 3) {
						_local5.course.rotation = Util.clampRadians(_local5.course.rotation + 3.141592653589793);
					}
				} else if(_local7 == 1) {
					_local5.target = g.unitManager.getTarget(_local6);
					_local5.targetProjectile = null;
					_local3 = m.getNumber(_local9 + 3);
					if(_local3 > 0) {
						_local5.aiStuck = true;
						_local5.aiStuckDuration = _local3;
					}
				} else if(_local7 == 2) {
					_local5.aiStuck = false;
					_local5.target = null;
					_local5.targetProjectile = projectilesById[_local6];
				} else if(_local7 == 3) {
					_local5.aiStuck = false;
					_local5.target = null;
					_local5.targetProjectile = null;
					_local8 = new Heading();
					_local8.parseMessage(m,_local9 + 4);
					_local5.error = new Point(_local5.course.pos.x - _local8.pos.x,_local5.course.pos.y - _local8.pos.y);
					_local5.errorRot = Util.clampRadians(_local5.course.rotation - _local8.rotation);
					if(_local5.errorRot > 3.141592653589793) {
						_local5.errorRot -= 2 * 3.141592653589793;
					}
					_local5.convergenceCounter = 0;
					_local5.course = _local8;
					_local5.convergenceTime = 500 / 33;
				} else {
					_local8 = new Heading();
					_local8.parseMessage(m,_local9 + 4);
					while(_local8.time < _local5.course.time) {
						_local5.updateHeading(_local8);
					}
					_local5.course = _local8;
				}
				_local9 += 4 + 10;
			}
		}
		
		private function killProjectile(m:Message) : void {
			var _local4:int = 0;
			var _local2:int = 0;
			var _local3:Projectile = null;
			_local4 = 0;
			while(_local4 < m.length) {
				_local2 = m.getInt(_local4);
				_local3 = projectilesById[_local2];
				if(_local3 != null) {
					_local3.destroy();
				}
				_local4++;
			}
		}
		
		private function killStuckProjectiles(m:Message) : void {
			var _local2:int = m.getInt(0);
			var _local3:Unit = g.unitManager.getTarget(_local2);
			if(_local3 == null) {
				return;
			}
			for each(var _local4:* in projectiles) {
				if(_local4.stateMachine.inState(ProjectileStuck) && _local4.target == _local3) {
					_local4.destroy(true);
				}
			}
		}
		
		public function remove(p:Projectile, index:int) : void {
			projectiles.splice(index,1);
			inactiveProjectiles.push(p);
			if(p.id != 0) {
				delete projectilesById[p.id];
			}
			p.removeFromCanvas();
			p.reset();
		}
		
		public function forceUpdate() : void {
			var _local1:Projectile = null;
			var _local2:int = 0;
			_local2 = 0;
			while(_local2 < projectiles.length) {
				_local1 = projectiles[_local2];
				_local1.nextDistanceCalculation = -1;
				_local2++;
			}
		}
		
		public function dispose() : void {
			for each(var _local1:* in projectiles) {
				_local1.removeFromCanvas();
				_local1.reset();
			}
			projectiles = null;
			projectilesById = null;
			inactiveProjectiles = null;
		}
	}
}

