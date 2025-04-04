package core.projectile {
import core.particle.EmitterFactory;
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
    public function ProjectileManager(g:Game) {
        var _loc3_:int = 0;
        var _loc2_:Projectile = null;
        inactiveProjectiles = new Vector.<Projectile>();
        projectiles = new Vector.<Projectile>();
        projectilesById = new Dictionary();
        meshBatch = new MeshBatch();
        super();
        this.g = g;
        _loc3_ = 0;
        while (_loc3_ < 100) {
            _loc2_ = new Projectile(g);
            inactiveProjectiles.push(_loc2_);
            _loc3_++;
        }
    }
    public var inactiveProjectiles:Vector.<Projectile>;
    public var projectiles:Vector.<Projectile>;
    public var projectilesById:Dictionary;
    private var TARGET_TYPE_SHIP:String = "ship";
    private var TARGET_TYPE_SPAWNER:String = "spawner";
    private var g:Game;
    private var meshBatch:MeshBatch;

    public function addMessageHandlers():void {
        g.addMessageHandler("projectileAddEnemy", addEnemyProjectile);
        g.addMessageHandler("projectileAddPlayer", addPlayerProjectile);
        g.addMessageHandler("projectileCourse", updateCourse);
        g.addMessageHandler("killProjectile", killProjectile);
        g.addMessageHandler("killStuckProjectiles", killStuckProjectiles);
        g.canvasProjectiles.addChild(meshBatch);
    }

    public function update():void {
        var _loc2_:int = 0;
        var _loc1_:Projectile = null;
        meshBatch.clear();
        var _loc3_:int = int(projectiles.length);
        _loc2_ = _loc3_ - 1;
        while (_loc2_ > -1) {
            _loc1_ = projectiles[_loc2_];
            if (_loc1_.alive) {
                _loc1_.update();
                if (_loc1_.hasImage && _loc1_.isVisible) {
                    meshBatch.addMesh(_loc1_.movieClip);
                }
            } else {
                remove(_loc1_, _loc2_);
            }
            _loc2_--;
        }
    }

    public function getProjectile():Projectile {
        var _loc1_:Projectile = null;
        if (inactiveProjectiles.length > 0) {
            _loc1_ = inactiveProjectiles.pop();
        } else {
            _loc1_ = new Projectile(g);
        }
        _loc1_.reset();
        return _loc1_;
    }

    public function handleBouncing(m:Message, i:int):void {
        var _loc5_:int = m.getInt(i);
        var _loc4_:int = m.getInt(i + 1);
        var _loc3_:Projectile = projectilesById[_loc5_];
        if (_loc3_ == null) {
            return;
        }
        _loc3_.target = g.unitManager.getTarget(_loc4_);
    }

    public function activateProjectile(p:Projectile):void {
        p.x = p.course.pos.x;
        p.y = p.course.pos.y;
        if (p.randomAngle) {
            p.rotation = Math.random() * 3.141592653589793 * 2;
        } else {
            p.rotation = p.course.rotation;
        }
        projectiles.push(p);
        p.addToCanvas();
        p.tryAddRibbonTrail();
        if (projectilesById[p.id] != null) {
            Console.write("error: p.id: " + p.id);
        }
        if (p.id != 0) {
            projectilesById[p.id] = p;
        }
    }

    public function addEnemyProjectile(m:Message):void {
        var _loc5_:int = 0;
        var _loc12_:int = 0;
        var _loc14_:int = 0;
        var _loc9_:int = 0;
        var _loc11_:Heading = null;
        var _loc6_:int = 0;
        var _loc2_:int = 0;
        var _loc3_:int = 0;
        var _loc8_:Number = NaN;
        var _loc7_:EnemyShip = null;
        var _loc10_:Weapon = null;
        var _loc4_:Turret = null;
        var _loc13_:Dictionary = g.shipManager.enemiesById;
        _loc5_ = 0;
        while (_loc5_ < m.length - 6) {
            _loc12_ = m.getInt(_loc5_);
            _loc14_ = m.getInt(_loc5_ + 1);
            _loc9_ = m.getInt(_loc5_ + 2);
            _loc11_ = new Heading();
            _loc11_.parseMessage(m, _loc5_ + 3);
            _loc6_ = m.getInt(_loc5_ + 3 + 10);
            _loc2_ = m.getInt(_loc5_ + 4 + 10);
            _loc3_ = m.getInt(_loc5_ + 5 + 10);
            _loc8_ = m.getNumber(_loc5_ + 6 + 10);
            _loc7_ = _loc13_[_loc14_];
            if (_loc7_ != null && _loc7_.weapons.length > _loc9_ && _loc7_.weapons[_loc9_] != null) {
                _loc10_ = _loc7_.weapons[_loc9_];
                createSetProjectile(ProjectileFactory.create(_loc10_.projectileFunction, g, _loc7_, _loc10_, _loc11_), _loc12_, _loc7_, _loc11_, _loc6_, _loc2_, _loc3_, _loc8_);
            } else {
                _loc4_ = g.turretManager.getTurretById(_loc14_);
                if (_loc4_ != null && _loc4_.weapon != null) {
                    _loc10_ = _loc4_.weapon;
                    createSetProjectile(ProjectileFactory.create(_loc10_.projectileFunction, g, _loc4_, _loc10_), _loc12_, _loc4_, _loc11_, _loc6_, _loc2_, _loc3_, _loc8_);
                }
            }
            _loc5_ += 7 + 10;
        }
    }

    public function addInitProjectiles(m:Message, startIndex:int, endIndex:int):void {
        var _loc5_:* = 0;
        var _loc9_:int = 0;
        var _loc11_:int = 0;
        var _loc10_:int = 0;
        var _loc6_:Ship = null;
        var _loc7_:Heading = null;
        var _loc8_:int = 0;
        var _loc4_:Weapon = null;
        _loc5_ = startIndex;
        while (_loc5_ < endIndex - 4) {
            _loc9_ = m.getInt(_loc5_);
            _loc11_ = m.getInt(_loc5_ + 1);
            _loc10_ = m.getInt(_loc5_ + 2);
            _loc6_ = g.unitManager.getTarget(_loc11_) as Ship;
            _loc7_ = new Heading();
            _loc7_.pos.x = m.getNumber(_loc5_ + 3);
            _loc7_.pos.y = m.getNumber(_loc5_ + 4);
            _loc8_ = m.getNumber(_loc5_ + 5);
            if (_loc6_ != null && _loc10_ > 0 && _loc10_ < _loc6_.weapons.length) {
                _loc4_ = _loc6_.weapons[_loc10_];
                createSetProjectile(ProjectileFactory.create(_loc4_.projectileFunction, g, _loc6_, _loc4_), _loc9_, _loc6_, _loc7_, _loc8_);
            }
            _loc5_ += 6;
        }
    }

    public function addPlayerProjectile(m:Message):void {
        var _loc6_:int = 0;
        var _loc13_:int = 0;
        var _loc14_:String = null;
        var _loc9_:int = 0;
        var _loc2_:int = 0;
        var _loc4_:Heading = null;
        var _loc7_:int = 0;
        var _loc3_:int = 0;
        var _loc5_:int = 0;
        var _loc8_:Number = NaN;
        var _loc15_:Player = null;
        var _loc11_:PlayerShip = null;
        var _loc12_:ProjectileGun = null;
        var _loc10_:Unit = null;
        _loc6_ = 0;
        while (_loc6_ < m.length - 8 - 10) {
            if (m.length < 6 + 10) {
                return;
            }
            _loc13_ = m.getInt(_loc6_);
            _loc14_ = m.getString(_loc6_ + 1);
            _loc9_ = m.getInt(_loc6_ + 2);
            _loc2_ = m.getInt(_loc6_ + 3);
            _loc4_ = new Heading();
            _loc4_.parseMessage(m, _loc6_ + 5);
            if (_loc13_ == -1) {
                EmitterFactory.create("A086BD35-4F9B-5BD4-518F-4C543B2AB0CF", g, _loc4_.pos.x, _loc4_.pos.y, null, true);
                return;
            }
            _loc7_ = m.getInt(_loc6_ + 5 + 10);
            _loc3_ = m.getInt(_loc6_ + 6 + 10);
            _loc5_ = m.getInt(_loc6_ + 7 + 10);
            _loc8_ = m.getNumber(_loc6_ + 8 + 10);
            _loc15_ = g.playerManager.playersById[_loc14_];
            if (_loc15_ == null) {
                return;
            }
            _loc11_ = _loc15_.ship;
            if (_loc11_ == null || _loc11_.weapons == null) {
                return;
            }
            if (!(_loc9_ > -1 && _loc9_ < _loc15_.ship.weapons.length)) {
                return;
            }
            _loc15_.selectedWeaponIndex = _loc9_;
            if (_loc11_.weapon != null && _loc11_.weapon is ProjectileGun) {
                _loc12_ = _loc11_.weapon as ProjectileGun;
                _loc10_ = null;
                if (_loc2_ != -1) {
                    _loc10_ = g.unitManager.getTarget(_loc2_);
                }
                _loc12_.shootSyncedProjectile(_loc13_, _loc10_, _loc4_, _loc7_, m.getNumber(_loc6_ + 4), _loc3_, _loc5_, _loc8_);
            }
            _loc6_ += 9 + 10;
        }
    }

    public function remove(p:Projectile, index:int):void {
        projectiles.splice(index, 1);
        inactiveProjectiles.push(p);
        if (p.id != 0) {
            delete projectilesById[p.id];
        }
        p.removeFromCanvas();
        p.reset();
    }

    public function forceUpdate():void {
        var _loc1_:Projectile = null;
        var _loc2_:int = 0;
        _loc2_ = 0;
        while (_loc2_ < projectiles.length) {
            _loc1_ = projectiles[_loc2_];
            _loc1_.nextDistanceCalculation = -1;
            _loc2_++;
        }
    }

    public function dispose():void {
        for each(var _loc1_ in projectiles) {
            _loc1_.removeFromCanvas();
            _loc1_.reset();
        }
        projectiles = null;
        projectilesById = null;
        inactiveProjectiles = null;
    }

    private function createSetProjectile(p:Projectile, id:int, enemy:Unit, course:Heading, multiPid:int, xRandOffset:int = 0, yRandOffset:int = 0, maxSpeed:Number = 0):void {
        var _loc11_:Point = null;
        var _loc12_:Number = NaN;
        var _loc14_:Number = NaN;
        var _loc13_:Number = NaN;
        var _loc9_:Number = NaN;
        var _loc10_:Number = NaN;
        if (p == null) {
            return;
        }
        var _loc15_:Weapon = p.weapon;
        p.id = id;
        if (maxSpeed != 0) {
            p.speedMax = maxSpeed;
        }
        if (p.speedMax != 0) {
            _loc11_ = new Point();
            if (multiPid > -1) {
                _loc12_ = _loc15_.multiNrOfP;
                _loc14_ = enemy.weaponPos.y + _loc15_.multiOffset * (multiPid - 0.5 * (_loc12_ - 1)) / _loc12_;
            } else {
                _loc14_ = enemy.weaponPos.y;
            }
            _loc13_ = enemy.weaponPos.x + _loc15_.positionOffsetX;
            _loc9_ = new Point(_loc13_, _loc14_).length;
            _loc10_ = Math.atan2(_loc14_, _loc13_);
            _loc11_.x = enemy.pos.x + Math.cos(enemy.rotation + _loc10_) * _loc9_ + xRandOffset;
            _loc11_.y = enemy.pos.y + Math.sin(enemy.rotation + _loc10_) * _loc9_ + yRandOffset;
            p.unit = enemy;
            p.course = course;
            p.rotation = course.rotation;
            p.fastforward();
            p.x = course.pos.x;
            p.y = course.pos.y;
            p.collisionRadius = 0.5 * p.collisionRadius;
            p.error = new Point(-p.course.pos.x + _loc11_.x, -p.course.pos.y + _loc11_.y);
            p.convergenceCounter = 0;
            p.course = course;
            p.convergenceTime = 151.51515151515153;
            if (p.error.length > 1000) {
                p.error.x = 0;
                p.error.y = 0;
            }
            if (maxSpeed != 0) {
                if (p.stateMachine.inState("Instant")) {
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
        _loc15_.playFireSound();
    }

    private function updateCourse(m:Message):void {
        var _loc5_:int = 0;
        var _loc6_:int = 0;
        var _loc7_:int = 0;
        var _loc2_:Projectile = null;
        var _loc3_:int = 0;
        var _loc9_:Number = NaN;
        var _loc4_:Heading = null;
        var _loc8_:Dictionary = g.shipManager.enemiesById;
        _loc5_ = 0;
        while (_loc5_ < m.length) {
            _loc6_ = m.getInt(_loc5_);
            _loc7_ = m.getInt(_loc5_ + 1);
            _loc2_ = projectilesById[_loc6_];
            if (_loc2_ == null) {
                return;
            }
            _loc3_ = m.getInt(_loc5_ + 2);
            if (_loc7_ == 0) {
                _loc2_.direction = _loc3_;
                if (_loc2_.direction > 0) {
                    _loc2_.boomerangReturning = true;
                    _loc2_.rotationSpeedMax = m.getNumber(_loc5_ + 3);
                }
                if (_loc3_ == 3) {
                    _loc2_.course.rotation = Util.clampRadians(_loc2_.course.rotation + 3.141592653589793);
                }
            } else if (_loc7_ == 1) {
                _loc2_.target = g.unitManager.getTarget(_loc3_);
                _loc2_.targetProjectile = null;
                _loc9_ = m.getNumber(_loc5_ + 3);
                if (_loc9_ > 0) {
                    _loc2_.aiStuck = true;
                    _loc2_.aiStuckDuration = _loc9_;
                }
            } else if (_loc7_ == 2) {
                _loc2_.aiStuck = false;
                _loc2_.target = null;
                _loc2_.targetProjectile = projectilesById[_loc3_];
            } else if (_loc7_ == 3) {
                _loc2_.aiStuck = false;
                _loc2_.target = null;
                _loc2_.targetProjectile = null;
                _loc4_ = new Heading();
                _loc4_.parseMessage(m, _loc5_ + 4);
                _loc2_.error = new Point(_loc2_.course.pos.x - _loc4_.pos.x, _loc2_.course.pos.y - _loc4_.pos.y);
                _loc2_.errorRot = Util.clampRadians(_loc2_.course.rotation - _loc4_.rotation);
                if (_loc2_.errorRot > 3.141592653589793) {
                    _loc2_.errorRot -= 2 * 3.141592653589793;
                }
                _loc2_.convergenceCounter = 0;
                _loc2_.course = _loc4_;
                _loc2_.convergenceTime = 500 / 33;
            } else {
                _loc4_ = new Heading();
                _loc4_.parseMessage(m, _loc5_ + 4);
                while (_loc4_.time < _loc2_.course.time) {
                    _loc2_.updateHeading(_loc4_);
                }
                _loc2_.course = _loc4_;
            }
            _loc5_ += 4 + 10;
        }
    }

    private function killProjectile(m:Message):void {
        var _loc3_:int = 0;
        var _loc4_:int = 0;
        var _loc2_:Projectile = null;
        _loc3_ = 0;
        while (_loc3_ < m.length) {
            _loc4_ = m.getInt(_loc3_);
            _loc2_ = projectilesById[_loc4_];
            if (_loc2_ != null) {
                _loc2_.destroy();
            }
            _loc3_++;
        }
    }

    private function killStuckProjectiles(m:Message):void {
        var _loc4_:int = m.getInt(0);
        var _loc3_:Unit = g.unitManager.getTarget(_loc4_);
        if (_loc3_ == null) {
            return;
        }
        for each(var _loc2_ in projectiles) {
            if (_loc2_.stateMachine.inState(ProjectileStuck) && _loc2_.target == _loc3_) {
                _loc2_.destroy(true);
            }
        }
    }
}
}

