package facebook {
public class FBQuery extends FBWaitable {
    private static var counter:int = 0;

    public function FBQuery() {
        super();
        name = "v_" + counter++;
    }
    public var name:String = "";
    public var hasDependency:Boolean = false;
    public var fields:Array = [];
    public var table:String = null;
    public var where:Object = null;

    public function toFql():String {
        var _loc1_:String = "select " + this.fields.join(",") + " from " + this.table + " where ";
        switch (this.where.type) {
            case "unknown":
                _loc1_ += this.where.value;
                break;
            case "index":
                _loc1_ += this.where.key + "=" + this._encode(this.where.value);
                break;
            case "in":
                if (this.where.value.length == 1) {
                    _loc1_ += this.where.key + "=" + this._encode(this.where.value[0]);
                } else {
                    _loc1_ += this.where.key + " in (" + FB.arrayMap(this.where.value, this._encode).join(",") + ")";
                }
        }
        return _loc1_;
    }

    public function toString():String {
        return "#" + this.name;
    }

    internal function parse(template:String, args:Array):FBQuery {
        var _loc5_:* = 0;
        var _loc3_:String = FB.stringFormat(template, args);
        var _loc4_:Object = /^select (.*?) from (\w+)\s+where (.*)$/i.exec(_loc3_);
        this.fields = _toFields(_loc4_[1]);
        this.table = _loc4_[2];
        this.where = _parseWhere(_loc4_[3]);
        _loc5_ = 0;
        while (_loc5_ < args.length) {
            if (args[_loc5_] is FBQuery) {
                args[_loc5_].hasDependency = true;
            }
            _loc5_++;
        }
        return this;
    }

    private function _encode(value:Object):String {
        return typeof value == "string" ? FB.stringQuote(value + "") : value + "";
    }

    private function _toFields(s:String):Array {
        return FB.arrayMap(s.split(","), FB.stringTrim);
    }

    private function _parseWhere(s:String):Object {
        var _loc3_:Object = /^\s*(\w+)\s*=\s*(.*)\s*$/i.exec(s);
        var _loc2_:Object = null;
        var _loc5_:* = null;
        var _loc4_:String = "unknown";
        if (_loc3_) {
            _loc5_ = _loc3_[2];
            if (/^(["'])(?:\\?.)*?\1$/.test(_loc5_)) {
                _loc5_ = JSON2.deserialize(_loc5_);
                _loc4_ = "index";
            } else if (/^\d+\.?\d*$/.test(_loc5_)) {
                _loc4_ = "index";
            }
        }
        if (_loc4_ == "index") {
            _loc2_ = {
                "type": "index",
                "key": _loc3_[1],
                "value": _loc5_
            };
        } else {
            _loc2_ = {
                "type": "unknown",
                "value": s
            };
        }
        return _loc2_;
    }
}
}

