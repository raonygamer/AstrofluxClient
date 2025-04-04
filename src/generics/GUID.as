package generics {
import flash.system.Capabilities;

public class GUID {
    private static var counter:Number = 0;

    public static function create():String {
        var _loc1_:Date = new Date();
        var _loc4_:Number = Number(_loc1_.getTime());
        var _loc3_:Number = Math.random() * 1.7976931348623157e+308;
        var _loc6_:String = Capabilities.serverString;
        var _loc5_:String = calculate(_loc4_ + _loc6_ + _loc3_ + counter++).toUpperCase();
        return _loc5_.substring(0, 8) + "-" + _loc5_.substring(8, 12) + "-" + _loc5_.substring(12, 16) + "-" + _loc5_.substring(16, 20) + "-" + _loc5_.substring(20, 32);
    }

    private static function calculate(src:String):String {
        return hex_sha1(src);
    }

    private static function hex_sha1(src:String):String {
        return binb2hex(core_sha1(str2binb(src), src.length * 8));
    }

    private static function core_sha1(x:Array, len:Number):Array {
        var _loc9_:Number = NaN;
        var _loc13_:* = NaN;
        var _loc8_:* = NaN;
        var _loc12_:Number = NaN;
        var _loc15_:Number = NaN;
        x[len >> 5] |= 128 << 24 - len % 32;
        x[(len + 64 >> 9 << 4) + 15] = len;
        var _loc16_:Array = new Array(80);
        var _loc3_:* = 1732584193;
        var _loc4_:* = -271733879;
        var _loc5_:Number = -1732584194;
        var _loc6_:* = 271733878;
        var _loc7_:* = -1009589776;
        _loc9_ = 0;
        while (_loc9_ < x.length) {
            _loc13_ = _loc3_;
            var _loc14_:* = _loc4_;
            _loc8_ = _loc5_;
            var _loc10_:* = _loc6_;
            var _loc11_:* = _loc7_;
            _loc12_ = 0;
            while (_loc12_ < 80) {
                if (_loc12_ < 16) {
                    _loc16_[_loc12_] = x[_loc9_ + _loc12_];
                } else {
                    _loc16_[_loc12_] = rol(_loc16_[_loc12_ - 3] ^ _loc16_[_loc12_ - 8] ^ _loc16_[_loc12_ - 14] ^ _loc16_[_loc12_ - 16], 1);
                }
                _loc15_ = safe_add(safe_add(rol(_loc3_, 5), sha1_ft(_loc12_, _loc4_, _loc5_, _loc6_)), safe_add(safe_add(_loc7_, _loc16_[_loc12_]), sha1_kt(_loc12_)));
                _loc7_ = _loc6_;
                _loc6_ = _loc5_;
                _loc5_ = rol(_loc4_, 30);
                _loc4_ = _loc3_;
                _loc3_ = _loc15_;
                _loc12_++;
            }
            _loc3_ = safe_add(_loc3_, _loc13_);
            _loc4_ = safe_add(_loc4_, _loc14_);
            _loc5_ = safe_add(_loc5_, _loc8_);
            _loc6_ = safe_add(_loc6_, _loc10_);
            _loc7_ = safe_add(_loc7_, _loc11_);
            _loc9_ += 16;
        }
        return new Array(_loc3_, _loc4_, _loc5_, _loc6_, _loc7_);
    }

    private static function sha1_ft(t:Number, b:Number, c:Number, d:Number):Number {
        if (t < 20) {
            return b & c | ~b & d;
        }
        if (t < 40) {
            return b ^ c ^ d;
        }
        if (t < 60) {
            return b & c | b & d | c & d;
        }
        return b ^ c ^ d;
    }

    private static function sha1_kt(t:Number):Number {
        return t < 20 ? 1518500249 : (t < 40 ? 1859775393 : (t < 60 ? -1894007588 : -899497514));
    }

    private static function safe_add(x:Number, y:Number):Number {
        var _loc4_:Number = (x & 0xFFFF) + (y & 0xFFFF);
        var _loc3_:Number = (x >> 16) + (y >> 16) + (_loc4_ >> 16);
        return _loc3_ << 16 | _loc4_ & 0xFFFF;
    }

    private static function rol(num:Number, cnt:Number):Number {
        return num << cnt | num >>> 32 - cnt;
    }

    private static function str2binb(str:String):Array {
        var _loc3_:Number = NaN;
        var _loc2_:Array = [];
        var _loc4_:Number = 255;
        _loc3_ = 0;
        while (_loc3_ < str.length * 8) {
            var _loc5_:* = _loc3_ >> 5;
            var _loc6_:* = _loc2_[_loc5_] | (str.charCodeAt(_loc3_ / 8) & _loc4_) << 24 - _loc3_ % 32;
            _loc2_[_loc5_] = _loc6_;
            _loc3_ += 8;
        }
        return _loc2_;
    }

    private static function binb2hex(binarray:Array):String {
        var _loc4_:Number = NaN;
        var _loc2_:String = new String("");
        var _loc3_:String = new String("0123456789abcdef");
        _loc4_ = 0;
        while (_loc4_ < binarray.length * 4) {
            _loc2_ += _loc3_.charAt(binarray[_loc4_ >> 2] >> (3 - _loc4_ % 4) * 8 + 4 & 0x0F) + _loc3_.charAt(binarray[_loc4_ >> 2] >> (3 - _loc4_ % 4) * 8 & 0x0F);
            _loc4_++;
        }
        return _loc2_;
    }

    public function GUID() {
        super();
    }
}
}

