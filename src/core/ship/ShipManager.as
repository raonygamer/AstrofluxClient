package core.ship {
	import core.scene.Game;
	import core.spawner.Spawner;
	import core.states.AIStates.AIChase;
	import core.states.AIStates.AIExit;
	import core.states.AIStates.AIFollow;
	import core.states.AIStates.AIIdle;
	import core.states.AIStates.AIKamikaze;
	import core.states.AIStates.AIMelee;
	import core.states.AIStates.AIObserve;
	import core.states.AIStates.AIOrbit;
	import core.states.AIStates.AIResurect;
	import core.states.AIStates.AIReturnOrbit;
	import core.states.AIStates.AITeleport;
	import core.states.AIStates.AITeleportEntry;
	import core.states.AIStates.AITeleportExit;
	import core.unit.Unit;
	import core.weapon.Weapon;
	import debug.Console;
	import flash.utils.Dictionary;
	import generics.Random;
	import movement.Heading;
	import playerio.Message;
	
	public class ShipManager {
		private var g:Game;
		public var shipSync:ShipSync;
		public var ships:Vector.<Ship>;
		public var players:Vector.<PlayerShip>;
		private var inactivePlayers:Vector.<PlayerShip>;
		public var enemies:Vector.<EnemyShip>;
		private var inactiveEnemies:Vector.<EnemyShip>;
		public var enemiesById:Dictionary;
		
		public function ShipManager(g:Game) {
			var _local4:int = 0;
			var _local3:PlayerShip = null;
			var _local2:EnemyShip = null;
			ships = new Vector.<Ship>();
			players = new Vector.<PlayerShip>();
			inactivePlayers = new Vector.<PlayerShip>();
			enemies = new Vector.<EnemyShip>();
			inactiveEnemies = new Vector.<EnemyShip>();
			enemiesById = new Dictionary();
			super();
			this.g = g;
			shipSync = new ShipSync(g);
			_local4 = 0;
			while(_local4 < 4) {
				_local3 = new PlayerShip(g);
				inactivePlayers.push(_local3);
				_local4++;
			}
			_local4 = 0;
			while(_local4 < 20) {
				_local2 = new EnemyShip(g);
				inactiveEnemies.push(_local2);
				_local4++;
			}
		}
		
		public function addMessageHandlers() : void {
			shipSync.addMessageHandlers();
			g.addMessageHandler("enemyUpdate",onEnemyUpdate);
		}
		
		public function addEarlyMessageHandlers() : void {
			g.addMessageHandler("spawnEnemy",onSpawnEnemy);
		}
		
		public function update() : void {
			var _local2:int = 0;
			var _local1:Ship = null;
			_local2 = ships.length - 1;
			while(_local2 > -1) {
				_local1 = ships[_local2];
				if(_local1.alive) {
					_local1.update();
				} else {
					removeShip(_local1,_local2);
				}
				_local2--;
			}
		}
		
		public function getPlayerShip() : PlayerShip {
			var _local1:PlayerShip = null;
			if(inactivePlayers.length > 0) {
				_local1 = inactivePlayers.pop();
			} else {
				_local1 = new PlayerShip(g);
			}
			_local1.reset();
			return _local1;
		}
		
		public function activatePlayerShip(s:PlayerShip) : void {
			g.unitManager.add(s,g.canvasPlayerShips);
			ships.push(s);
			players.push(s);
			s.alive = true;
		}
		
		public function getEnemyShip() : EnemyShip {
			var _local1:EnemyShip = null;
			if(inactiveEnemies.length > 0) {
				_local1 = inactiveEnemies.pop();
			} else {
				_local1 = new EnemyShip(g);
			}
			_local1.reset();
			return _local1;
		}
		
		public function activateEnemyShip(s:EnemyShip) : void {
			g.unitManager.add(s,g.canvasEnemyShips);
			ships.push(s);
			enemies.push(s);
			s.alive = true;
		}
		
		public function removeShip(s:Ship, index:int) : void {
			ships.splice(index,1);
			var _local3:int = 0;
			if(s is PlayerShip) {
				_local3 = int(players.indexOf(PlayerShip(s)));
				players.splice(_local3,1);
				inactivePlayers.push(s);
			} else if(s is EnemyShip) {
				_local3 = int(enemies.indexOf(EnemyShip(s)));
				enemies.splice(_local3,1);
				inactiveEnemies.push(s);
				if(s.id.toString() in enemiesById) {
					delete enemiesById[s.id];
				}
			}
			g.unitManager.remove(s);
		}
		
		private function onSpawnEnemy(m:Message) : void {
			spawnEnemy(m);
		}
		
		public function spawnEnemy(m:Message, startIndex:int = 0, endIndex:int = 0) : void {
			var _local4:int = 0;
			var _local25:int = 0;
			var _local26:* = 0;
			var _local17:String = null;
			var _local9:int = 0;
			var _local16:int = 0;
			var _local12:String = null;
			var _local8:Number = NaN;
			var _local19:Number = NaN;
			var _local14:Number = NaN;
			var _local7:Number = NaN;
			var _local23:Number = NaN;
			var _local11:Number = NaN;
			var _local21:Boolean = false;
			var _local28:Boolean = false;
			var _local29:Spawner = null;
			var _local10:Heading = null;
			var _local18:EnemyShip = null;
			var _local20:Number = NaN;
			var _local24:int = 0;
			var _local22:int = 0;
			var _local6:Number = NaN;
			var _local30:int = 0;
			var _local5:int = 0;
			var _local13:Unit = null;
			var _local15:int = 21;
			if(endIndex != 0) {
				_local4 = endIndex - startIndex;
				_local25 = _local4 / _local15;
			} else {
				_local25 = m.length / _local15;
				endIndex = m.length;
			}
			if(_local25 == 0) {
				return;
			}
			_local26 = startIndex;
			while(_local26 < endIndex) {
				_local17 = m.getString(_local26++);
				_local9 = m.getInt(_local26++);
				_local16 = m.getInt(_local26++);
				_local12 = m.getString(_local26++);
				_local8 = m.getNumber(_local26++);
				_local19 = m.getNumber(_local26++);
				_local14 = m.getNumber(_local26++);
				_local7 = m.getNumber(_local26++);
				_local23 = m.getNumber(_local26++);
				_local11 = m.getNumber(_local26++);
				_local21 = m.getBoolean(_local26++);
				_local28 = m.getBoolean(_local26++);
				_local29 = g.spawnManager.getSpawnerByKey(_local12);
				_local10 = new Heading();
				_local26 = _local10.parseMessage(m,_local26);
				if(_local29 != null) {
					_local29.initialHardenedShield = false;
				}
				_local18 = ShipFactory.createEnemy(g,_local17,_local16);
				createSetEnemy(_local18,_local9,_local10,_local25,_local8,_local29,_local19,_local14,_local7,_local23,_local11,_local21);
				if(_local16 == 6) {
					_local18.hp = m.getInt(_local26++);
					_local18.hpMax = _local18.hp;
					_local18.shieldHp = m.getInt(_local26++);
					_local18.shieldHpMax = _local18.shieldHp;
					_local18.shieldRegen = m.getInt(_local26++);
					_local18.engine.speed = m.getNumber(_local26++);
					_local18.engine.acceleration = m.getNumber(_local26++);
					_local20 = m.getNumber(_local26++);
					_local24 = m.getInt(_local26++);
					_local22 = m.getInt(_local26++);
					_local6 = m.getNumber(_local26++);
					_local30 = m.getInt(_local26++);
					for each(var _local27 in _local18.weapons) {
						_local27.speed = _local20;
						_local27.ttl = _local24;
						_local27.numberOfHits = _local22;
						_local27.reloadTime = _local6;
						_local27.multiNrOfP = _local30;
					}
					_local18.name = m.getString(_local26++);
					_local5 = m.getInt(_local26++);
					_local13 = g.unitManager.getTarget(_local5);
					_local18.owner = _local13 as PlayerShip;
				}
				if(_local28 == true) {
					_local18.cloakStart();
				}
				_local26;
			}
		}
		
		private function createSetEnemy(enemy:EnemyShip, id:int, course:Heading, enemyCount:int, startTime:Number, s:Spawner, orbitAngle:Number, orbitRadius:Number, ellipseAlpha:Number, ellipseFactor:Number, angleVelocity:Number, spawnInOrbit:Boolean = false) : void {
			enemy.id = id;
			randomizeSpeed(enemy);
			enemy.initCourse(course);
			enemy.engine.pos.x = enemy.pos.x;
			enemy.engine.pos.y = enemy.pos.y;
			if(enemiesById[enemy.id] != null) {
				Console.write("ERROR: enemy alrdy in use with id: " + enemy.id);
			}
			enemiesById[enemy.id] = enemy;
			if(enemy.orbitSpawner && s != null) {
				enemy.spawner = s;
				enemy.orbitAngle = orbitAngle;
				enemy.orbitRadius = orbitRadius;
				enemy.ellipseFactor = ellipseFactor;
				enemy.ellipseAlpha = ellipseAlpha;
				enemy.angleVelocity = angleVelocity;
				enemy.orbitStartTime = startTime;
				if(spawnInOrbit) {
					enemy.stateMachine.changeState(new AIOrbit(g,enemy));
				} else {
					enemy.stateMachine.changeState(new AIReturnOrbit(g,enemy,ellipseAlpha,startTime,course,0));
				}
			} else if(enemy.teleport) {
				enemy.stateMachine.changeState(new AITeleportEntry(g,enemy,course));
			} else {
				enemy.stateMachine.changeState(new AIIdle(g,enemy,course));
			}
		}
		
		private function randomizeSpeed(enemy:EnemyShip) : void {
			var _local2:Random = new Random(1 / enemy.id);
			_local2.stepTo(1);
			enemy.engine.speed *= 0.8 + 0.001 * _local2.random(201);
			enemy.engine.rotationSpeed *= 0.6 + 0.002 * _local2.random(201);
		}
		
		public function getShipFromId(id:int) : Ship {
			for each(var _local2 in ships) {
				if(_local2.id == id) {
					return _local2;
				}
			}
			return null;
		}
		
		public function enemyFire(m:Message, i:int = 0) : void {
			var _local8:int = 0;
			var _local5:Weapon = null;
			var _local3:int = m.getInt(i);
			var _local7:int = m.getInt(i + 1);
			var _local9:Boolean = m.getBoolean(i + 2);
			var _local4:Ship = getShipFromId(_local3);
			var _local6:Unit = null;
			if(m.length > 3) {
				_local8 = m.getInt(i + 3);
				_local6 = g.unitManager.getTarget(_local8);
			}
			if(_local4 != null) {
				_local5 = _local4.weapons[_local7];
				_local5.fire = _local9;
				_local5.target = _local6;
			}
		}
		
		public function damaged(m:Message, i:int) : void {
			var _local5:int = 0;
			var _local4:int = m.getInt(i + 1);
			var _local3:EnemyShip = enemiesById[_local4];
			if(_local3 != null) {
				_local5 = m.getInt(i + 2);
				_local3.takeDamage(_local5);
				_local3.shieldHp = m.getInt(i + 3);
				if(_local3.shieldHp == 0) {
					if(_local3.shieldRegenCounter > -1000) {
						_local3.shieldRegenCounter = -1000;
					}
				}
				_local3.hp = m.getInt(i + 4);
				if(m.getBoolean(i + 5)) {
					_local3.doDOTEffect(m.getInt(i + 6),m.getString(i + 7),m.getInt(i + 8));
				}
			}
		}
		
		public function killed(m:Message, i:int) : void {
			var _local5:int = m.getInt(i);
			var _local4:Boolean = m.getBoolean(i + 1);
			var _local3:EnemyShip = enemiesById[_local5];
			if(_local3 != null) {
				_local3.destroy(_local4);
			}
		}
		
		private function syncEnemyTarget(m:Message, startIndex:int) : void {
			var _local7:* = 0;
			var _local3:EnemyShip = null;
			var _local5:String = null;
			var _local4:Unit = null;
			var _local6:int = 0;
			_local7 = startIndex;
			while(_local7 < m.length - 1) {
				_local3 = g.shipManager.enemiesById[m.getInt(_local7)];
				_local5 = m.getString(_local7 + 1);
				_local4 = g.unitManager.getTarget(m.getInt(_local7 + 2));
				if(_local3 != null) {
					if(!_local3.stateMachine.inState(_local5)) {
						switch(_local5) {
							case "AIObserve":
								_local3.stateMachine.changeState(new AIObserve(g,_local3,_local4,_local3.course,0));
								break;
							case "AIChase":
								_local3.stateMachine.changeState(new AIChase(g,_local3,_local4,_local3.course,0));
								break;
							case "AIResurect":
								_local3.stateMachine.changeState(new AIResurect(g,_local3));
								break;
							case "AIFollow":
								_local3.stateMachine.changeState(new AIFollow(g,_local3,_local4,_local3.course,0));
								break;
							case "AIMelee":
								_local3.stateMachine.changeState(new AIMelee(g,_local3,_local4,_local3.course,0));
								break;
							case "AIOrbit":
								_local3.stateMachine.changeState(new AIOrbit(g,_local3));
								break;
							case "AIIdle":
								_local3.stateMachine.changeState(new AIIdle(g,_local3,_local3.course));
								break;
							case "AIKamikaze":
								_local3.stateMachine.changeState(new AIKamikaze(g,_local3,_local4,_local3.course,0));
								break;
							case "AITeleport":
								_local3.stateMachine.changeState(new AITeleport(g,_local3,_local4));
								break;
							case "AITeleportExit":
								_local3.stateMachine.changeState(new AITeleportExit(g,_local3));
								break;
							case "AIExit":
								_local3.stateMachine.changeState(new AIExit(g,_local3));
						}
					}
					_local6 = 0;
					while(_local6 < _local3.weapons.length) {
						_local7++;
						_local3.weapons[_local6].target = _local4;
						_local3.weapons[_local6].fire = m.getBoolean(_local7 + 3);
						_local6++;
					}
				}
				_local7 += 4;
			}
		}
		
		public function initSyncEnemies(m:Message) : void {
			var _local2:* = 1;
			var _local3:int = _local2 + m.getInt(0);
			g.turretManager.syncTurretTarget(m,_local2,_local3);
			_local2 = _local3 + 1;
			_local3 = _local2 + m.getInt(_local3);
			g.projectileManager.addInitProjectiles(m,_local2,_local3);
			_local2 = _local3;
			syncEnemyTarget(m,_local2);
		}
		
		public function initEnemies(m:Message) : void {
			Console.write("running spawnEnemy");
			spawnEnemy(m,0,0);
		}
		
		private function onEnemyUpdate(m:Message) : void {
			var _local4:int = 0;
			var _local5:Boolean = false;
			var _local6:int = 0;
			var _local2:EnemyShip = g.shipManager.enemiesById[m.getInt(_local6++)];
			if(_local2 == null) {
				return;
			}
			_local2.hp = m.getInt(_local6++);
			_local2.shieldHp = m.getInt(_local6++);
			if(_local2.hp < _local2.hpMax || _local2.shieldHp < _local2.shieldHpMax) {
				_local2.isInjured = true;
			}
			var _local3:Ship = g.shipManager.getShipFromId(m.getInt(_local6++));
			_local4 = 0;
			while(_local4 < _local2.weapons.length) {
				_local5 = m.getBoolean(_local6++);
				_local2.weapons[_local4].fire = _local5;
				_local2.weapons[_local4].target = _local5 ? _local3 : null;
				_local4++;
			}
		}
		
		public function dispose() : void {
			var _local1:* = null;
			for each(_local1 in enemies) {
				_local1.removeFromCanvas();
				_local1.reset();
			}
			g.removeMessageHandler("spawnEnemy",onSpawnEnemy);
			enemies = null;
			inactiveEnemies = null;
			for each(_local1 in players) {
				_local1.removeFromCanvas();
				_local1.reset();
			}
			players = null;
			inactivePlayers = null;
		}
	}
}

