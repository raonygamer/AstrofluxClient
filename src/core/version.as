package core {
public class version {
    public function version(major:uint = 0, minor:uint = 0, build:uint = 0, revision:uint = 0) {
        super();
        this._value = major << 28 | minor << 24 | build << 16 | revision;
    }
    private var _value:Number = 0;

    public function get build():uint {
        return (this._value & 0xFF0000) >>> 16;
    }

    public function set build(value:uint):void {
        this._value = this._value & 4278255615 | value << 16;
    }

    public function get major():uint {
        return this._value >>> 28;
    }

    public function set major(value:uint):void {
        this._value = this._value & 0x0FFFFFFF | value << 28;
    }

    public function get minor():uint {
        return (this._value & 0x0F000000) >>> 24;
    }

    public function set minor(value:uint):void {
        this._value = this._value & 4043309055 | value << 24;
    }

    public function get revision():uint {
        return this._value & 0xFFFF;
    }

    public function set revision(value:uint):void {
        this._value = this._value & 4294901760 | value;
    }

    public function toString(fields:int = 0, separator:String = "."):String {
        var _loc4_:int = 0;
        var _loc5_:int = 0;
        var _loc3_:Array = [this.major, this.minor, this.build, this.revision];
        if (fields > 0 && fields < 5) {
            _loc3_ = _loc3_.slice(0, fields);
        } else {
            _loc5_ = int(_loc3_.length);
            _loc4_ = _loc5_ - 1;
            while (_loc4_ > 0) {
                if (_loc3_[_loc4_] != 0) {
                    break;
                }
                _loc3_.pop();
                _loc4_--;
            }
        }
        return _loc3_.join(separator);
    }

    public function valueOf():Number {
        return this._value;
    }
}
}

