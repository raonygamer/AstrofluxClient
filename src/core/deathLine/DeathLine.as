package core.deathLine {
import core.hud.components.Line;
import core.scene.Game;

import flash.geom.Point;

public class DeathLine extends Line {
    public function DeathLine(g:Game, color:uint = 16777215, alpha:Number = 1) {
        super("line2");
        init("line2", 6, color, alpha, true);
        this.g = g;
        this.visible = false;
    }
    public var nextDistanceCalculation:Number = -1;
    public var id:String = "";
    private var g:Game;

    public function update():void {
        if (nextDistanceCalculation <= 0) {
            updateIsNear();
        } else {
            nextDistanceCalculation -= 33;
        }
    }

    public function updateIsNear():void {
        if (g.me.ship == null) {
            return;
        }
        var _loc2_:Point = g.camera.getCameraCenter();
        var _loc1_:Number = x - _loc2_.x;
        var _loc4_:Number = y - _loc2_.y;
        var _loc6_:Number = toX - _loc2_.x;
        var _loc5_:Number = toY - _loc2_.y;
        var _loc7_:Number = g.stage.stageWidth;
        var distanceToCamera:Number = Math.sqrt(Math.min(_loc1_ * _loc1_ + _loc4_ * _loc4_, _loc6_ * _loc6_ + _loc5_ * _loc5_));
        var _loc3_:Number = distanceToCamera - _loc7_;
        nextDistanceCalculation = _loc3_ / (10 * 60) * 1000;
        visible = distanceToCamera < _loc7_;
    }

    public function lineIntersection(x3:Number, y3:Number, x4:Number, y4:Number, targetRadius:Number):Boolean {
        var _loc17_:Number = toY - y;
        var _loc15_:Number = x - toX;
        var _loc19_:Number = y4 - y3;
        var _loc18_:Number = x3 - x4;
        var _loc13_:Number = _loc17_ * _loc18_ - _loc19_ * _loc15_;
        if (_loc13_ == 0) {
            return false;
        }
        var _loc14_:Number = _loc17_ * x + _loc15_ * y;
        var _loc16_:Number = _loc19_ * x3 + _loc18_ * y3;
        var _loc22_:Number = (_loc18_ * _loc14_ - _loc15_ * _loc16_) / _loc13_;
        var _loc7_:Number = (_loc17_ * _loc16_ - _loc19_ * _loc14_) / _loc13_;
        var _loc21_:Number = Math.min(x, toX);
        var _loc11_:Number = Math.max(x, toX);
        var _loc20_:Number = Math.min(y, toY);
        var _loc9_:Number = Math.max(y, toY);
        if (_loc22_ < _loc21_ - targetRadius || _loc22_ > _loc11_ + targetRadius || _loc7_ < _loc20_ - targetRadius || _loc7_ > _loc9_ + targetRadius) {
            return false;
        }
        var _loc12_:Number = Math.min(x3, x4);
        var _loc8_:Number = Math.max(x3, x4);
        var _loc10_:Number = Math.min(y3, y4);
        var _loc6_:Number = Math.max(y3, y4);
        if (_loc22_ < _loc12_ - targetRadius || _loc22_ > _loc8_ + targetRadius || _loc7_ < _loc10_ - targetRadius || _loc7_ > _loc6_ + targetRadius) {
            return false;
        }
        return true;
    }

    public function lineIntersection2(px:Number, py:Number, x4:Number, y4:Number, targetRadius:Number):Boolean {
        var _loc15_:Number = Math.min(x, toX);
        var _loc7_:Number = Math.max(x, toX);
        var _loc13_:Number = Math.min(y, toY);
        var _loc6_:Number = Math.max(y, toY);
        if (px < _loc15_ - targetRadius || px > _loc7_ + targetRadius || py < _loc13_ - targetRadius || py > _loc6_ + targetRadius) {
            return false;
        }
        var _loc10_:Number = toX - x;
        var _loc11_:Number = toY - y;
        var _loc14_:Number = Math.sqrt(_loc10_ * _loc10_ + _loc11_ * _loc11_);
        _loc10_ /= _loc14_;
        _loc11_ /= _loc14_;
        var _loc8_:Number = x - px;
        var _loc12_:Number = y - py;
        var _loc16_:Number = _loc8_ * _loc10_ + _loc12_ * _loc11_;
        var _loc9_:Number = Math.sqrt(Math.pow(_loc8_ - _loc16_ * _loc10_, 2) + Math.pow(_loc12_ - _loc16_ * _loc11_, 2));
        return _loc9_ < targetRadius;
    }
}
}

