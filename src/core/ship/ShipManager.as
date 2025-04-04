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
    public function ShipManager(g:Game) {
        var _loc4_:int = 0;
        var _loc2_:PlayerShip = null;
        var _loc3_:EnemyShip = null;
        ships = new Vector.<Ship>();
        players = new Vector.<PlayerShip>();
        inactivePlayers = new Vector.<PlayerShip>();
        enemies = new Vector.<EnemyShip>();
        inactiveEnemies = new Vector.<EnemyShip>();
        enemiesById = new Dictionary();
        super();
        this.g = g;
        shipSync = new ShipSync(g);
        _loc4_ = 0;
        while (_loc4_ < 4) {
            _loc2_ = new PlayerShip(g);
            inactivePlayers.push(_loc2_);
            _loc4_++;
        }
        _loc4_ = 0;
        while (_loc4_ < 20) {
            _loc3_ = new EnemyShip(g);
            inactiveEnemies.push(_loc3_);
            _loc4_++;
        }
    }
    public var shipSync:ShipSync;
    public var ships:Vector.<Ship>;
    public var players:Vector.<PlayerShip>;
    public var enemies:Vector.<EnemyShip>;
    public var enemiesById:Dictionary;
    private var g:Game;
    private var inactivePlayers:Vector.<PlayerShip>;
    private var inactiveEnemies:Vector.<EnemyShip>;

    public function addMessageHandlers():void {
        shipSync.addMessageHandlers();
        g.addMessageHandler("enemyUpdate", onEnemyUpdate);
    }

    public function addEarlyMessageHandlers():void {
        g.addMessageHandler("spawnEnemy", onSpawnEnemy);
    }

    public function update():void {
        var _loc1_:int = 0;
        var _loc2_:Ship = null;
        _loc1_ = ships.length - 1;
        while (_loc1_ > -1) {
            _loc2_ = ships[_loc1_];
            if (_loc2_.alive) {
                _loc2_.update();
            } else {
                removeShip(_loc2_, _loc1_);
            }
            _loc1_--;
        }
    }

    public function getPlayerShip():PlayerShip {
        var _loc1_:PlayerShip = null;
        if (inactivePlayers.length > 0) {
            _loc1_ = inactivePlayers.pop();
        } else {
            _loc1_ = new PlayerShip(g);
        }
        _loc1_.reset();
        return _loc1_;
    }

    public function activatePlayerShip(s:PlayerShip):void {
        g.unitManager.add(s, g.canvasPlayerShips);
        ships.push(s);
        players.push(s);
        s.alive = true;
    }

    public function getEnemyShip():EnemyShip {
        var _loc1_:EnemyShip = null;
        if (inactiveEnemies.length > 0) {
            _loc1_ = inactiveEnemies.pop();
        } else {
            _loc1_ = new EnemyShip(g);
        }
        _loc1_.reset();
        return _loc1_;
    }

    public function activateEnemyShip(s:EnemyShip):void {
        g.unitManager.add(s, g.canvasEnemyShips);
        ships.push(s);
        enemies.push(s);
        s.alive = true;
    }

    public function removeShip(s:Ship, index:int):void {
        ships.splice(index, 1);
        var _loc3_:int = 0;
        if (s is PlayerShip) {
            _loc3_ = int(players.indexOf(PlayerShip(s)));
            players.splice(_loc3_, 1);
            inactivePlayers.push(s);
        } else if (s is EnemyShip) {
            _loc3_ = int(enemies.indexOf(EnemyShip(s)));
            enemies.splice(_loc3_, 1);
            inactiveEnemies.push(s);
            if (s.id.toString() in enemiesById) {
                delete enemiesById[s.id];
            }
        }
        g.unitManager.remove(s);
    }

    public function spawnEnemy(m:Message, startIndex:int = 0, endIndex:int = 0):void {
        var _loc20_:int = 0;
        var _loc28_:int = 0;
        var _loc22_:* = 0;
        var _loc18_:String = null;
        var _loc17_:int = 0;
        var _loc30_:int = 0;
        var _loc21_:String = null;
        var _loc15_:Number = NaN;
        var _loc5_:Number = NaN;
        var _loc10_:Number = NaN;
        var _loc12_:Number = NaN;
        var _loc23_:Number = NaN;
        var _loc16_:Number = NaN;
        var _loc4_:Boolean = false;
        var _loc8_:Boolean = false;
        var _loc25_:Spawner = null;
        var _loc14_:Heading = null;
        var _loc7_:EnemyShip = null;
        var _loc11_:Number = NaN;
        var _loc24_:int = 0;
        var _loc19_:int = 0;
        var _loc26_:Number = NaN;
        var _loc6_:int = 0;
        var _loc9_:int = 0;
        var _loc13_:Unit = null;
        var _loc29_:int = 21;
        if (endIndex != 0) {
            _loc20_ = endIndex - startIndex;
            _loc28_ = _loc20_ / _loc29_;
        } else {
            _loc28_ = m.length / _loc29_;
            endIndex = m.length;
        }
        if (_loc28_ == 0) {
            return;
        }
        _loc22_ = startIndex;
        while (_loc22_ < endIndex) {
            _loc18_ = m.getString(_loc22_++);
            _loc17_ = m.getInt(_loc22_++);
            _loc30_ = m.getInt(_loc22_++);
            _loc21_ = m.getString(_loc22_++);
            _loc15_ = m.getNumber(_loc22_++);
            _loc5_ = m.getNumber(_loc22_++);
            _loc10_ = m.getNumber(_loc22_++);
            _loc12_ = m.getNumber(_loc22_++);
            _loc23_ = m.getNumber(_loc22_++);
            _loc16_ = m.getNumber(_loc22_++);
            _loc4_ = m.getBoolean(_loc22_++);
            _loc8_ = m.getBoolean(_loc22_++);
            _loc25_ = g.spawnManager.getSpawnerByKey(_loc21_);
            _loc14_ = new Heading();
            _loc22_ = _loc14_.parseMessage(m, _loc22_);
            if (_loc25_ != null) {
                _loc25_.initialHardenedShield = false;
            }
            _loc7_ = ShipFactory.createEnemy(g, _loc18_, _loc30_);
            createSetEnemy(_loc7_, _loc17_, _loc14_, _loc28_, _loc15_, _loc25_, _loc5_, _loc10_, _loc12_, _loc23_, _loc16_, _loc4_);
            if (_loc30_ == 6) {
                _loc7_.hp = m.getInt(_loc22_++);
                _loc7_.hpMax = _loc7_.hp;
                _loc7_.shieldHp = m.getInt(_loc22_++);
                _loc7_.shieldHpMax = _loc7_.shieldHp;
                _loc7_.shieldRegen = m.getInt(_loc22_++);
                _loc7_.engine.speed = m.getNumber(_loc22_++);
                _loc7_.engine.acceleration = m.getNumber(_loc22_++);
                _loc11_ = m.getNumber(_loc22_++);
                _loc24_ = m.getInt(_loc22_++);
                _loc19_ = m.getInt(_loc22_++);
                _loc26_ = m.getNumber(_loc22_++);
                _loc6_ = m.getInt(_loc22_++);
                for each(var _loc27_ in _loc7_.weapons) {
                    _loc27_.speed = _loc11_;
                    _loc27_.ttl = _loc24_;
                    _loc27_.numberOfHits = _loc19_;
                    _loc27_.reloadTime = _loc26_;
                    _loc27_.multiNrOfP = _loc6_;
                }
                _loc7_.name = m.getString(_loc22_++);
                _loc9_ = m.getInt(_loc22_++);
                _loc13_ = g.unitManager.getTarget(_loc9_);
                _loc7_.owner = _loc13_ as PlayerShip;
            }
            if (_loc8_ == true) {
                _loc7_.cloakStart();
            }
            _loc22_;
        }
    }

    public function getShipFromId(id:int):Ship {
        for each(var _loc2_ in ships) {
            if (_loc2_.id == id) {
                return _loc2_;
            }
        }
        return null;
    }

    public function enemyFire(m:Message, i:int = 0):void {
        var _loc4_:int = 0;
        var _loc3_:Weapon = null;
        var _loc7_:int = m.getInt(i);
        var _loc8_:int = m.getInt(i + 1);
        var _loc5_:Boolean = m.getBoolean(i + 2);
        var _loc6_:Ship = getShipFromId(_loc7_);
        var _loc9_:Unit = null;
        if (m.length > 3) {
            _loc4_ = m.getInt(i + 3);
            _loc9_ = g.unitManager.getTarget(_loc4_);
        }
        if (_loc6_ != null) {
            _loc3_ = _loc6_.weapons[_loc8_];
            _loc3_.fire = _loc5_;
            _loc3_.target = _loc9_;
        }
    }

    public function damaged(m:Message, i:int):void {
        var _loc5_:int = 0;
        var _loc4_:int = m.getInt(i + 1);
        var _loc3_:EnemyShip = enemiesById[_loc4_];
        if (_loc3_ != null) {
            _loc5_ = m.getInt(i + 2);
            _loc3_.takeDamage(_loc5_);
            _loc3_.shieldHp = m.getInt(i + 3);
            if (_loc3_.shieldHp == 0) {
                if (_loc3_.shieldRegenCounter > -1000) {
                    _loc3_.shieldRegenCounter = -1000;
                }
            }
            _loc3_.hp = m.getInt(i + 4);
            if (m.getBoolean(i + 5)) {
                _loc3_.doDOTEffect(m.getInt(i + 6), m.getString(i + 7), m.getInt(i + 8));
            }
        }
    }

    public function killed(m:Message, i:int):void {
        var _loc5_:int = m.getInt(i);
        var _loc3_:Boolean = m.getBoolean(i + 1);
        var _loc4_:EnemyShip = enemiesById[_loc5_];
        if (_loc4_ != null) {
            _loc4_.destroy(_loc3_);
        }
    }

    public function initSyncEnemies(m:Message):void {
        var _loc2_:* = 1;
        var _loc3_:int = _loc2_ + m.getInt(0);
        g.turretManager.syncTurretTarget(m, _loc2_, _loc3_);
        _loc2_ = _loc3_ + 1;
        _loc3_ = _loc2_ + m.getInt(_loc3_);
        g.projectileManager.addInitProjectiles(m, _loc2_, _loc3_);
        _loc2_ = _loc3_;
        syncEnemyTarget(m, _loc2_);
    }

    public function initEnemies(m:Message):void {
        Console.write("running spawnEnemy");
        spawnEnemy(m, 0, 0);
    }

    public function dispose():void {
        var _loc1_:* = null;
        for each(_loc1_ in enemies) {
            _loc1_.removeFromCanvas();
            _loc1_.reset();
        }
        g.removeMessageHandler("spawnEnemy", onSpawnEnemy);
        enemies = null;
        inactiveEnemies = null;
        for each(_loc1_ in players) {
            _loc1_.removeFromCanvas();
            _loc1_.reset();
        }
        players = null;
        inactivePlayers = null;
    }

    private function onSpawnEnemy(m:Message):void {
        spawnEnemy(m);
    }

    private function createSetEnemy(enemy:EnemyShip, id:int, course:Heading, enemyCount:int, startTime:Number, s:Spawner, orbitAngle:Number, orbitRadius:Number, ellipseAlpha:Number, ellipseFactor:Number, angleVelocity:Number, spawnInOrbit:Boolean = false):void {
        enemy.id = id;
        randomizeSpeed(enemy);
        enemy.initCourse(course);
        enemy.engine.pos.x = enemy.pos.x;
        enemy.engine.pos.y = enemy.pos.y;
        if (enemiesById[enemy.id] != null) {
            Console.write("ERROR: enemy alrdy in use with id: " + enemy.id);
        }
        enemiesById[enemy.id] = enemy;
        if (enemy.orbitSpawner && s != null) {
            enemy.spawner = s;
            enemy.orbitAngle = orbitAngle;
            enemy.orbitRadius = orbitRadius;
            enemy.ellipseFactor = ellipseFactor;
            enemy.ellipseAlpha = ellipseAlpha;
            enemy.angleVelocity = angleVelocity;
            enemy.orbitStartTime = startTime;
            if (spawnInOrbit) {
                enemy.stateMachine.changeState(new AIOrbit(g, enemy));
            } else {
                enemy.stateMachine.changeState(new AIReturnOrbit(g, enemy, ellipseAlpha, startTime, course, 0));
            }
        } else if (enemy.teleport) {
            enemy.stateMachine.changeState(new AITeleportEntry(g, enemy, course));
        } else {
            enemy.stateMachine.changeState(new AIIdle(g, enemy, course));
        }
    }

    private function randomizeSpeed(enemy:EnemyShip):void {
        var _loc2_:Random = new Random(1 / enemy.id);
        _loc2_.stepTo(1);
        enemy.engine.speed *= 0.8 + 0.001 * _loc2_.random(201);
        enemy.engine.rotationSpeed *= 0.6 + 0.002 * _loc2_.random(201);
    }

    private function syncEnemyTarget(m:Message, startIndex:int):void {
        var _loc3_:* = 0;
        var _loc4_:EnemyShip = null;
        var _loc6_:String = null;
        var _loc7_:Unit = null;
        var _loc5_:int = 0;
        _loc3_ = startIndex;
        while (_loc3_ < m.length - 1) {
            _loc4_ = g.shipManager.enemiesById[m.getInt(_loc3_)];
            _loc6_ = m.getString(_loc3_ + 1);
            _loc7_ = g.unitManager.getTarget(m.getInt(_loc3_ + 2));
            if (_loc4_ != null) {
                if (!_loc4_.stateMachine.inState(_loc6_)) {
                    switch (_loc6_) {
                        case "AIObserve":
                            _loc4_.stateMachine.changeState(new AIObserve(g, _loc4_, _loc7_, _loc4_.course, 0));
                            break;
                        case "AIChase":
                            _loc4_.stateMachine.changeState(new AIChase(g, _loc4_, _loc7_, _loc4_.course, 0));
                            break;
                        case "AIResurect":
                            _loc4_.stateMachine.changeState(new AIResurect(g, _loc4_));
                            break;
                        case "AIFollow":
                            _loc4_.stateMachine.changeState(new AIFollow(g, _loc4_, _loc7_, _loc4_.course, 0));
                            break;
                        case "AIMelee":
                            _loc4_.stateMachine.changeState(new AIMelee(g, _loc4_, _loc7_, _loc4_.course, 0));
                            break;
                        case "AIOrbit":
                            _loc4_.stateMachine.changeState(new AIOrbit(g, _loc4_));
                            break;
                        case "AIIdle":
                            _loc4_.stateMachine.changeState(new AIIdle(g, _loc4_, _loc4_.course));
                            break;
                        case "AIKamikaze":
                            _loc4_.stateMachine.changeState(new AIKamikaze(g, _loc4_, _loc7_, _loc4_.course, 0));
                            break;
                        case "AITeleport":
                            _loc4_.stateMachine.changeState(new AITeleport(g, _loc4_, _loc7_));
                            break;
                        case "AITeleportExit":
                            _loc4_.stateMachine.changeState(new AITeleportExit(g, _loc4_));
                            break;
                        case "AIExit":
                            _loc4_.stateMachine.changeState(new AIExit(g, _loc4_));
                    }
                }
                _loc5_ = 0;
                while (_loc5_ < _loc4_.weapons.length) {
                    _loc3_++;
                    _loc4_.weapons[_loc5_].target = _loc7_;
                    _loc4_.weapons[_loc5_].fire = m.getBoolean(_loc3_ + 3);
                    _loc5_++;
                }
            }
            _loc3_ += 4;
        }
    }

    private function onEnemyUpdate(m:Message):void {
        var _loc5_:int = 0;
        var _loc4_:Boolean = false;
        var _loc2_:int = 0;
        var _loc3_:EnemyShip = g.shipManager.enemiesById[m.getInt(_loc2_++)];
        if (_loc3_ == null) {
            return;
        }
        _loc3_.hp = m.getInt(_loc2_++);
        _loc3_.shieldHp = m.getInt(_loc2_++);
        if (_loc3_.hp < _loc3_.hpMax || _loc3_.shieldHp < _loc3_.shieldHpMax) {
            _loc3_.isInjured = true;
        }
        var _loc6_:Ship = g.shipManager.getShipFromId(m.getInt(_loc2_++));
        _loc5_ = 0;
        while (_loc5_ < _loc3_.weapons.length) {
            _loc4_ = m.getBoolean(_loc2_++);
            _loc3_.weapons[_loc5_].fire = _loc4_;
            _loc3_.weapons[_loc5_].target = _loc4_ ? _loc6_ : null;
            _loc5_++;
        }
    }
}
}

