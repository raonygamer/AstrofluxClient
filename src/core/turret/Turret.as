package core.turret {
import core.boss.Boss;
import core.scene.Game;
import core.ship.Ship;
import core.unit.Unit;
import core.weapon.Weapon;

import flash.geom.Point;

import generics.Util;

public class Turret extends Unit {
    public function Turret(g:Game) {
        weaponPos = new Point();
        super(g);
    }
    public var weapon:Weapon;
    public var aimSkill:Number;
    public var aimArc:Number;
    public var target:Ship;
    public var visionRange:int;
    public var offset:Point;
    public var startAngle:Number;
    public var angleTargetPos:Point;
    public var rotationSpeed:Number;

    override public function get id():int {
        return super.id;
    }

    override public function set id(value:int):void {
        super.id = value;
    }

    override public function get type():String {
        return "turret";
    }

    override public function update():void {
        if (!alive || !active) {
            if (weapon != null) {
                weapon.fire = false;
            }
            return;
        }
        if (parentObj is Boss) {
            for each(var _loc2_ in triggers) {
                _loc2_.tryActivateTrigger(this, Boss(parentObj));
            }
        }
        var _loc1_:Number = parentObj.rotation;
        _pos.x = offset.x * Math.cos(_loc1_) - offset.y * Math.sin(_loc1_) + parentObj.x;
        _pos.y = offset.x * Math.sin(_loc1_) + offset.y * Math.cos(_loc1_) + parentObj.y;
        stateMachine.update();
        if (lastDmgText != null) {
            lastDmgText.x = _pos.x;
            lastDmgText.y = _pos.y - 20 + lastDmgTextOffset;
            lastDmgTextOffset += lastDmgText.speed.y * 33 / 1000;
            if (lastDmgTime < g.time - 1000) {
                lastDmgTextOffset = 0;
                lastDmgText = null;
            }
        }
        if (lastHealText != null) {
            lastHealText.x = _pos.x;
            lastHealText.y = _pos.y - 5 + lastHealTextOffset;
            lastHealTextOffset += lastHealText.speed.y * 33 / 1000;
            if (lastHealTime < g.time - 1000) {
                lastHealTextOffset = 0;
                lastHealText = null;
            }
        }
        super.update();
    }

    override public function destroy(explode:Boolean = true):void {
        hpBar.visible = false;
        shieldBar.visible = false;
        visible = false;
        super.destroy(explode);
    }

    public function updateRotation():void {
        var _loc3_:Number = NaN;
        var _loc4_:Number = NaN;
        var _loc6_:Number = NaN;
        var _loc7_:Number = NaN;
        var _loc1_:int = 33;
        var _loc5_:Number = rotationSpeed * _loc1_ / 1000;
        var _loc2_:Number = parentObj.rotation;
        if (aimArc == 0) {
            _rotation = Util.clampRadians(startAngle + _loc2_);
        }
        if (aimArc == 2 * 3.141592653589793) {
            if (angleTargetPos != null) {
                _loc3_ = Util.clampRadians(Math.atan2(angleTargetPos.y - _pos.y, angleTargetPos.x - _pos.x));
            } else {
                _loc3_ = Util.clampRadians(startAngle + _loc2_);
            }
            _loc4_ = Util.angleDifference(_rotation, _loc3_ + 3.141592653589793);
            if (_loc4_ > 0 && _loc4_ < 3.141592653589793 - _loc5_) {
                _rotation += _loc5_;
                _rotation = Util.clampRadians(_rotation);
            } else if (_loc4_ <= 0 && _loc4_ > -3.141592653589793 + _loc5_) {
                _rotation -= _loc5_;
                _rotation = Util.clampRadians(_rotation);
            } else {
                _rotation = Util.clampRadians(_loc3_);
            }
        } else {
            _loc6_ = Util.clampRadians(startAngle + _loc2_ - aimArc / 2);
            if (angleTargetPos != null) {
                _loc3_ = Util.clampRadians(Math.atan2(angleTargetPos.y - _pos.y, angleTargetPos.x - _pos.x) - _loc6_);
            } else {
                _loc3_ = Util.clampRadians(startAngle + _loc2_ - _loc6_);
            }
            _loc7_ = Util.clampRadians(_rotation - _loc6_);
            if (_loc3_ < 0 || _loc3_ > aimArc) {
                _loc3_ = Util.clampRadians(startAngle + _loc2_ - _loc6_);
            }
            if (_loc7_ < _loc3_ - _loc5_) {
                _rotation += _loc5_;
                _rotation = Util.clampRadians(_rotation);
            } else if (_loc7_ > _loc3_ + _loc5_) {
                _rotation -= _loc5_;
                _rotation = Util.clampRadians(_rotation);
            } else {
                _rotation = Util.clampRadians(_loc3_ + _loc6_);
            }
        }
    }

    public function updateWeapons():void {
        if (weapon != null) {
            weapon.update();
        }
    }

    public function rebuild():void {
        hp = hpMax;
        shieldHp = shieldHpMax;
        hpBar.visible = true;
        shieldBar.visible = true;
        visible = true;
        alive = true;
    }
}
}

