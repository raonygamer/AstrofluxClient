package core.states.AIStates {
import core.projectile.Projectile;
import core.scene.Game;
import core.states.IState;
import core.states.StateMachine;
import core.unit.Unit;

import flash.geom.Point;

public class ProjectileBullet implements IState {
    public function ProjectileBullet(m:Game, p:Projectile) {
        super();
        this.m = m;
        this.p = p;
        if (p.isHeal || p.unit.factions.length > 0) {
            this.isEnemy = false;
        } else {
            this.isEnemy = p.unit.type == "enemyShip" || p.unit.type == "turret";
        }
    }
    protected var m:Game;
    protected var p:Projectile;
    protected var sm:StateMachine;
    protected var isEnemy:Boolean;
    private var globalInterval:Number = 1000;
    private var localTargetList:Vector.<Unit>;
    private var nextGlobalUpdate:Number;
    private var nextLocalUpdate:Number;
    private var localRangeSQ:Number;
    private var firstUpdate:Boolean;

    public function set stateMachine(sm:StateMachine):void {
        this.sm = sm;
    }

    public function get type():String {
        return "ProjectileBullet";
    }

    public function enter():void {
        if (p.ttl < globalInterval) {
            globalInterval = p.ttl;
        }
        localTargetList = new Vector.<Unit>();
        firstUpdate = true;
        nextGlobalUpdate = 0;
        nextLocalUpdate = 0;
        localRangeSQ = globalInterval * 0.001 * (p.speedMax + 500);
        localRangeSQ *= localRangeSQ;
        if (p.unit.lastBulletTargetList != null) {
            if (p.unit.lastBulletGlobal > m.time) {
                nextGlobalUpdate = p.unit.lastBulletGlobal;
                localTargetList = p.unit.lastBulletTargetList;
                firstUpdate = false;
            } else {
                p.unit.lastBulletTargetList = null;
                firstUpdate = true;
            }
            if (p.unit.lastBulletLocal > m.time + 50) {
                nextLocalUpdate = p.unit.lastBulletLocal - 50;
                firstUpdate = false;
            }
        }
    }

    public function execute():void {
        var _loc22_:Unit = null;
        var _loc19_:Number = NaN;
        var _loc13_:Number = NaN;
        var _loc27_:Number = NaN;
        var _loc26_:Number = NaN;
        var _loc20_:int = 0;
        var _loc15_:* = undefined;
        var _loc17_:int = 0;
        var _loc16_:Number = NaN;
        var _loc21_:* = undefined;
        var _loc9_:Boolean = false;
        var _loc2_:Number = 33;
        var _loc1_:int = (p.convergenceTime - p.convergenceCounter) / p.convergenceTime;
        if (_loc1_ <= 0) {
            p.error = null;
        }
        if (p.error != null) {
            p.course.pos.x += p.error.x * _loc1_;
            p.course.pos.y += p.error.y * _loc1_;
        }
        p.oldPos.x = p.course.pos.x;
        p.oldPos.y = p.course.pos.y;
        p.updateHeading(p.course);
        if (p.error != null) {
            p.convergenceCounter++;
            _loc1_ = (p.convergenceTime - p.convergenceCounter) / p.convergenceTime;
            p.course.pos.x -= p.error.x * _loc1_;
            p.course.pos.y -= p.error.y * _loc1_;
        }
        if (nextLocalUpdate > m.time) {
            return;
        }
        var _loc25_:* = 100000000;
        var _loc3_:Point = p.course.pos;
        if (_loc3_.y == p.oldPos.y && _loc3_.x == p.oldPos.x) {
            return;
        }
        var _loc5_:Number = -Math.atan2(_loc3_.y - p.oldPos.y, _loc3_.x - p.oldPos.x);
        var _loc23_:Number = Math.cos(_loc5_);
        var _loc10_:Number = Math.sin(_loc5_);
        if (Math.abs(_loc10_) < 0.0001) {
            _loc10_ = 0.0001;
        }
        var _loc4_:Number = p.oldPos.x * _loc23_ - p.oldPos.y * _loc10_;
        var _loc7_:Number = p.oldPos.x * _loc10_ + p.oldPos.y * _loc23_;
        var _loc8_:Number = _loc3_.x * _loc23_ - _loc3_.y * _loc10_;
        var _loc6_:Number = _loc3_.x * _loc10_ + _loc3_.y * _loc23_;
        var _loc11_:Number = p.collisionRadius;
        var _loc12_:Number = Math.min(_loc4_, _loc8_) - _loc11_;
        var _loc14_:Number = Math.max(_loc4_, _loc8_) + _loc11_;
        var _loc24_:Number = Math.min(_loc7_, _loc6_) - _loc11_;
        var _loc18_:Number = Math.max(_loc7_, _loc6_) + _loc11_;
        if (isEnemy) {
            _loc20_ = int(m.shipManager.players.length);
            _loc15_ = m.shipManager.players;
            _loc17_ = 0;
            while (_loc17_ < _loc20_) {
                _loc22_ = _loc15_[_loc17_];
                if (!(!_loc22_.alive || _loc22_ == p.unit || _loc22_.invulnerable)) {
                    _loc19_ = _loc22_.pos.x;
                    _loc13_ = _loc22_.pos.y;
                    _loc27_ = _loc3_.x - _loc19_;
                    _loc26_ = _loc3_.y - _loc13_;
                    _loc16_ = _loc27_ * _loc27_ + _loc26_ * _loc26_;
                    if (_loc25_ > _loc16_) {
                        _loc25_ = _loc16_;
                    }
                    if (_loc16_ <= 2500) {
                        _loc4_ = _loc19_ * _loc23_ - _loc13_ * _loc10_;
                        _loc7_ = _loc19_ * _loc10_ + _loc13_ * _loc23_;
                        _loc11_ = _loc22_.collisionRadius;
                        if (_loc4_ <= _loc14_ + _loc11_ && _loc4_ > _loc12_ - _loc11_ && _loc7_ <= _loc18_ + _loc11_ && _loc7_ > _loc24_ - _loc11_) {
                            if (p.debuffType == 2) {
                                _loc3_.y = (_loc24_ * _loc23_ / _loc10_ - _loc4_ + (_loc11_ - p.collisionRadius)) / (1 * _loc10_ + _loc23_ * _loc23_ / _loc10_);
                                _loc3_.x = (_loc24_ - _loc3_.y * _loc23_) / _loc10_;
                                p.ttl = p.weapon.debuffDuration * 1000;
                                sm.changeState(new ProjectileStuck(m, p, _loc22_));
                                return;
                            }
                            if (p.numberOfHits <= 1) {
                                _loc3_.y = (_loc24_ * _loc23_ / _loc10_ - _loc4_ + (_loc11_ - p.collisionRadius)) / (1 * _loc10_ + _loc23_ * _loc23_ / _loc10_);
                                _loc3_.x = (_loc24_ - _loc3_.y * _loc23_) / _loc10_;
                                p.destroy();
                                return;
                            }
                            p.explode();
                            if (p.numberOfHits >= 10) {
                                p.numberOfHits--;
                            }
                        }
                    }
                }
                _loc17_++;
            }
            nextLocalUpdate = m.time + Math.sqrt(_loc25_) * 1000 / (p.speedMax + 5 * 60) - 35;
            if (firstUpdate) {
                firstUpdate = false;
                p.unit.lastBulletLocal = nextLocalUpdate;
            }
        } else {
            if (nextGlobalUpdate < m.time) {
                if (p.unit.lastBulletGlobal > m.time - 35 && p.unit.lastBulletTargetList != null) {
                    localTargetList = p.unit.lastBulletTargetList;
                    _loc21_ = localTargetList;
                    _loc9_ = false;
                    nextGlobalUpdate = m.time + 1000;
                } else {
                    _loc9_ = true;
                    _loc21_ = m.unitManager.units;
                    localTargetList.splice(0, localTargetList.length);
                    nextGlobalUpdate = m.time + 1000;
                }
            } else {
                _loc9_ = false;
                _loc21_ = localTargetList;
            }
            _loc20_ = int(_loc21_.length);
            _loc17_ = 0;
            while (_loc17_ < _loc20_) {
                _loc22_ = _loc21_[_loc17_];
                if (_loc22_.canBeDamage(p.unit, p)) {
                    _loc19_ = _loc22_.pos.x;
                    _loc13_ = _loc22_.pos.y;
                    _loc27_ = _loc3_.x - _loc19_;
                    _loc26_ = _loc3_.y - _loc13_;
                    _loc16_ = _loc27_ * _loc27_ + _loc26_ * _loc26_;
                    if (_loc9_ && _loc16_ < localRangeSQ) {
                        localTargetList.push(_loc22_);
                    }
                    if (_loc25_ > _loc16_) {
                        _loc25_ = _loc16_;
                    }
                    if (_loc16_ <= 2500) {
                        _loc4_ = _loc19_ * _loc23_ - _loc13_ * _loc10_;
                        _loc7_ = _loc19_ * _loc10_ + _loc13_ * _loc23_;
                        _loc11_ = _loc22_.collisionRadius;
                        if (_loc4_ <= _loc14_ + _loc11_ && _loc4_ > _loc12_ - _loc11_ && _loc7_ <= _loc18_ + _loc11_ && _loc7_ > _loc24_ - _loc11_) {
                            if (p.debuffType == 2) {
                                _loc3_.y = (_loc24_ * _loc23_ / _loc10_ - _loc4_ + (_loc11_ - p.collisionRadius)) / (1 * _loc10_ + _loc23_ * _loc23_ / _loc10_);
                                _loc3_.x = (_loc24_ - _loc3_.y * _loc23_) / _loc10_;
                                p.ttl = p.weapon.debuffDuration * 1000;
                                sm.changeState(new ProjectileStuck(m, p, _loc22_));
                                return;
                            }
                            if (p.numberOfHits <= 1) {
                                _loc3_.y = (_loc24_ * _loc23_ / _loc10_ - _loc4_ + (_loc11_ - p.collisionRadius)) / (1 * _loc10_ + _loc23_ * _loc23_ / _loc10_);
                                _loc3_.x = (_loc24_ - _loc3_.y * _loc23_) / _loc10_;
                                p.destroy();
                                return;
                            }
                            p.explode();
                            if (p.numberOfHits >= 10) {
                                p.numberOfHits--;
                            }
                        }
                    }
                }
                _loc17_++;
            }
            nextLocalUpdate = m.time + Math.sqrt(_loc25_) * 1000 / (p.speedMax + 400) - 35;
            if (nextGlobalUpdate < nextLocalUpdate) {
                nextGlobalUpdate = nextLocalUpdate;
            }
            if (_loc9_) {
                _loc9_ = false;
                firstUpdate = false;
                p.unit.lastBulletGlobal = nextGlobalUpdate;
                p.unit.lastBulletLocal = nextLocalUpdate;
                p.unit.lastBulletTargetList = localTargetList;
            }
        }
    }

    public function exit():void {
    }
}
}

