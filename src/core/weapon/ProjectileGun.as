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

    override protected function shoot():void {
        var _loc1_:PlayerShip = null;
        if (unit is PlayerShip) {
            if (hasChargeUp && (projectiles.length < maxProjectiles || maxProjectiles == 0)) {
                if (unit != null && unit is PlayerShip) {
                    _loc1_ = unit as PlayerShip;
                    if (fireNextTime < g.time) {
                        if (chargeUpTime == 0) {
                            if (fireEffect != "") {
                                _loc1_.startChargeUpEffect(fireEffect);
                            } else {
                                _loc1_.startChargeUpEffect();
                            }
                        }
                        chargeUpTime += 33;
                        if (_loc1_.player.isMe) {
                            if (chargeUpTime < chargeUpTimeMax) {
                                g.hud.powerBar.updateLoadBar(chargeUpTime / chargeUpTimeMax);
                            } else {
                                g.hud.powerBar.updateLoadBar(1);
                            }
                        }
                        if (triggerMeleeAnimation) {
                            (unit as PlayerShip).triggerMeleeTextures(reloadTime / 1000);
                        }
                    } else if (_loc1_.player.isMe) {
                        g.hud.powerBar.updateLoadBar(0);
                        chargeUpTime = 0;
                    }

                }
            }
        }
    }

    public function shootSyncedProjectile(id:int, target:Unit, heading:Heading, multiPid:int = -1, power:Number = 0, xRandOffset:Number = 0, yRandOffset:Number = 0, maxSpeed:Number = 0):void {
        var _loc14_:PlayerShip = null;
        var _loc18_:Number = NaN;
        var _loc17_:Number = NaN;
        var _loc19_:Number = NaN;
        if (unit == null) {
            return;
        }
        if (fireCallback != null && this.hasChargeUp && (projectiles.length + 1 < maxProjectiles || maxProjectiles == 0)) {
            lastFire = g.time;
            fireNextTime = g.time + reloadTime;
            fireCallback();
        }
        if (unit is PlayerShip) {
            _loc14_ = unit as PlayerShip;
            _loc14_.weaponHeat.setHeat(power);
            if (hasChargeUp && !_loc14_.player.isMe) {
                fire = false;
            } else if (triggerMeleeAnimation) {
                (unit as PlayerShip).triggerMeleeTextures(reloadTime / 1000);
            }
        }
        var _loc13_:Weapon = this;
        var _loc12_:Projectile = ProjectileFactory.create(projectileFunction, g, unit, this);
        if (_loc12_ == null) {
            return;
        }
        if (target != null) {
            _loc12_.target = target;
        }
        if (name == "Snow Cannon" || name == "Poison Arrow" || name == "Nexar Projector" || name == "Shadow Projector") {
            _loc12_.speedMax = maxSpeed;
            if (name == "Snow Cannon") {
                _loc12_.scaleX = 0.2 + 0.5 * _loc12_.speedMax / (25 * 60);
                _loc12_.scaleY = 0.2 + 0.5 * _loc12_.speedMax / (25 * 60);
            }
        }
        if (maxSpeed != 0) {
            if (_loc12_.stateMachine.inState("Instant")) {
                _loc12_.range = maxSpeed;
                _loc12_.speedMax = 10000;
            } else {
                _loc12_.speedMax = maxSpeed;
            }
        }
        if (target != null) {
            _loc13_.target = target;
            _loc18_ = aim();
        } else {
            _loc18_ = 0;
        }
        var _loc11_:Number = multiNrOfP;
        if (multiNrOfP > 1 && multiPid > -1) {
            _loc17_ = unit.weaponPos.y + multiOffset * (multiPid - 0.5 * (_loc11_ - 1)) / _loc11_;
        } else if (multiPid > -1) {
            _loc17_ = unit.weaponPos.y + 0.25 * multiOffset * (2 * (multiPid % 2) - 1);
        } else {
            _loc17_ = unit.weaponPos.y;
        }
        var _loc15_:Number = unit.weaponPos.x + positionOffsetX;
        var _loc9_:Number = new Point(_loc15_, _loc17_).length;
        var _loc10_:Number = Math.atan2(_loc17_, _loc15_);
        var _loc16_:Number = multiAngleOffset * (multiPid - 0.5 * (_loc11_ - 1)) / _loc11_;
        _loc12_.course.pos.x = unit.pos.x + Math.cos(unit.rotation + _loc16_ + _loc10_ + _loc18_) * _loc9_;
        _loc12_.course.pos.y = unit.pos.y + Math.sin(unit.rotation + _loc16_ + _loc10_ + _loc18_) * _loc9_;
        _loc12_.course.pos.x += xRandOffset;
        _loc12_.course.pos.y += yRandOffset;
        _loc12_.course.rotation = unit.rotation + _loc16_ + _loc18_ + (angleVariance - Math.random() * angleVariance * 2);
        if (fireBackwards) {
            _loc12_.course.rotation -= 3.141592653589793;
        }
        if (acceleration == 0) {
            _loc12_.course.speed.x = Math.cos(_loc12_.course.rotation) * _loc12_.speedMax;
            _loc12_.course.speed.y = Math.sin(_loc12_.course.rotation) * _loc12_.speedMax;
        } else if (multiSpreadStart) {
            _loc12_.course.speed.x = _loc12_.unit.speed.x * 0.5;
            _loc12_.course.speed.y = _loc12_.unit.speed.y * 0.5;
            _loc19_ = 10 * (multiPid - 0.5 * (_loc11_ - 1)) / _loc11_;
            if (_loc19_ > 0) {
                _loc19_ += 10;
            } else {
                _loc19_ -= 10;
            }
            _loc12_.course.speed.x -= Math.sin(_loc12_.course.rotation) * _loc19_;
            _loc12_.course.speed.y += Math.cos(_loc12_.course.rotation) * _loc19_;
        } else {
            _loc12_.course.speed.x = unit.speed.x * 0.5;
            _loc12_.course.speed.y = unit.speed.y * 0.5;
        }
        _loc12_.target = target;
        _loc12_.error = new Point(_loc12_.course.pos.x - heading.pos.x, _loc12_.course.pos.y - heading.pos.y);
        _loc12_.convergenceCounter = 0;
        _loc12_.course = heading;
        _loc12_.convergenceTime = 1000 / 33;
        _loc12_.collisionRadius = 0;
        _loc12_.id = id;
        g.projectileManager.activateProjectile(_loc12_);
        playFireSound();
    }
}
}

