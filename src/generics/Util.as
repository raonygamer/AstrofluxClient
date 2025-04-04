package generics {
import flash.geom.Point;
import flash.geom.Rectangle;

public class Util {
    public static var Math2PI:Number = 6.283185307179586;

    public static function degreesToRadians(degrees:Number):Number {
        return degrees * 3.141592653589793 / (3 * 60);
    }

    public static function getRotationEaseAmount(diff:Number, k:Number):Number {
        if (diff > 3.141592653589793) {
            diff -= Math2PI;
        } else if (diff < -3.141592653589793) {
            diff = Math2PI + diff;
        }
        return diff * k;
    }

    public static function angleDifference(x:Number, y:Number):Number {
        var _loc3_:Number = x - y;
        if (_loc3_ > 3.141592653589793) {
            return _loc3_ - Math2PI;
        }
        if (_loc3_ < -3.141592653589793) {
            return _loc3_ + Math2PI;
        }
        return _loc3_;
    }

    public static function radiansToDegrees(radians:Number):Number {
        return radians * (3 * 60) / 3.141592653589793;
    }

    public static function isAngleBetween(angle:Number, angle1:Number, angle2:Number):Boolean {
        var _loc4_:Boolean = false;
        angle = clampDegrees(angle);
        angle1 = clampDegrees(angle1);
        angle2 = clampDegrees(angle2);
        _loc4_ = angle >= angle1 && angle <= angle2;
        if (angle1 > 3 * 60 && angle2 < 3 * 60) {
            if (angle <= 6 * 60 && angle >= angle1) {
                _loc4_ = true;
            }
            if (angle >= 0 && angle <= angle2) {
                _loc4_ = true;
            }
        }
        return _loc4_;
    }

    public static function clampDegrees(degrees:Number):Number {
        return degrees % (6 * 60);
    }

    public static function clampRadians(radians:Number):Number {
        radians /= Math2PI;
        return (radians - Math.floor(radians)) * Math2PI;
    }

    public static function formatDecimal(n:Number, count:int = 1):Number {
        return Math.floor(n * 10 * count) / 10 * count;
    }

    public static function sign(n:Number):Number {
        if (n >= 0) {
            return 1;
        }
        return -1;
    }

    public static function formatAmount(amount:Number):String {
        var _loc2_:String = "";
        if (amount > 1000000) {
            amount /= 1000000;
            _loc2_ = "m";
        } else if (amount > 1000) {
            amount /= 1000;
            _loc2_ = "k";
        }
        return _loc2_ == "" ? amount.toString() : amount.toFixed(1) + _loc2_;
    }

    public static function dotProduct(x:Number, y:Number, x2:Number, y2:Number):Number {
        return x * x2 + y * y2;
    }

    public static function intersectLineAndRect(x1:Number, y1:Number, x2:Number, y2:Number, rect:Rectangle):Point {
        var _loc6_:Point = Util.intersectLines(x1, y1, x2, y2, rect.right, rect.y, rect.right, rect.bottom);
        if (_loc6_ == null) {
            _loc6_ = Util.intersectLines(x1, y1, x2, y2, rect.x, rect.y, rect.x, rect.bottom);
        }
        if (_loc6_ == null) {
            _loc6_ = Util.intersectLines(x1, y1, x2, y2, rect.x, rect.y, rect.right, rect.y);
        }
        if (_loc6_ == null) {
            _loc6_ = Util.intersectLines(x1, y1, x2, y2, rect.x, rect.bottom, rect.right, rect.bottom);
        }
        return _loc6_;
    }

    public static function intersectLines(x1:Number, y1:Number, x2:Number, y2:Number, x3:Number, y3:Number, x4:Number, y4:Number):Point {
        var _loc18_:* = NaN;
        var _loc12_:* = NaN;
        var _loc19_:* = NaN;
        var _loc13_:* = NaN;
        var _loc16_:* = NaN;
        var _loc9_:* = NaN;
        var _loc17_:* = NaN;
        var _loc11_:* = NaN;
        var _loc10_:Number = ((x4 - x3) * (y1 - y3) - (y4 - y3) * (x1 - x3)) / ((y4 - y3) * (x2 - x1) - (x4 - x3) * (y2 - y1));
        var _loc15_:Number = x1 + _loc10_ * (x2 - x1);
        var _loc14_:Number = y1 + _loc10_ * (y2 - y1);
        if (_loc15_.toString() == (NaN).toString() || _loc14_.toString() == (NaN).toString()) {
            return null;
        }
        if (x1 > x2) {
            _loc18_ = x2;
            _loc12_ = x1;
        } else {
            _loc18_ = x1;
            _loc12_ = x2;
        }
        if (y1 > y2) {
            _loc19_ = y2;
            _loc13_ = y1;
        } else {
            _loc19_ = y1;
            _loc13_ = y2;
        }
        if (x3 > x4) {
            _loc16_ = x4;
            _loc9_ = x3;
        } else {
            _loc16_ = x3;
            _loc9_ = x4;
        }
        if (y3 > y4) {
            _loc17_ = y4;
            _loc11_ = y3;
        } else {
            _loc17_ = y3;
            _loc11_ = y4;
        }
        if (_loc15_ >= _loc18_ && _loc15_ <= _loc12_ && _loc14_ >= _loc19_ && _loc14_ <= _loc13_ && _loc15_ >= _loc16_ && _loc15_ <= _loc9_ && _loc14_ >= _loc17_ && _loc14_ <= _loc11_) {
            return new Point(_loc15_, _loc14_);
        }
        return null;
    }

    public static function getFormattedTime(totalTime:Number):String {
        var _loc2_:int = Math.floor(totalTime / 1000);
        var _loc4_:int = Math.floor(_loc2_ / (60));
        var _loc3_:int = Math.floor(_loc4_ / (60));
        _loc2_ -= _loc4_ * (60);
        _loc4_ -= _loc3_ * (60);
        var _loc5_:String = "";
        if (_loc3_ > 0) {
            _loc5_ = _loc3_ + "h ";
        }
        if (_loc4_ > 0 || _loc3_ > 0) {
            _loc5_ = _loc5_ + _loc4_ + "m ";
        }
        if (_loc2_ > 0 || _loc4_ > 0 || _loc3_ > 0) {
            _loc5_ = _loc5_ + _loc2_ + "s ";
        }
        return _loc5_;
    }

    public static function trimUsername(s:String):String {
        return s.replace(/^([\s|\t|\n]+)?(.*)([\s|\t|\n]+)?$/gm, "$2");
    }

    public static function lerpAngle(a:Number, b:Number, t:Number):Number {
        var _loc4_:Number = b - a;
        while (_loc4_ < -3.141592653589793) {
            _loc4_ += 2 * 3.141592653589793;
        }
        while (_loc4_ > 3.141592653589793) {
            _loc4_ -= 2 * 3.141592653589793;
        }
        return a + _loc4_ * t;
    }

    public function Util() {
        super();
    }
}
}

