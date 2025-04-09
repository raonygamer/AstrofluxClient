package facebook {
public class FBWaitable {
    public function FBWaitable() {
        super();
    }
    private var subscribers:Object = {};

    private var _value:Object = null;

    public function get value():Object {
        return _value;
    }

    public function set value(value:Object):void {
        if (JSON2.serialize(value) != JSON2.serialize(_value)) {
            _value = value;
            fire("value", value);
        }
    }

    public function error(ex:Error):void {
        fire("error", ex);
    }

    public function wait(callback:Function, ...rest):void {
        var t:*;
        var args:Array = rest;
        var errorHandler:Function = args.length == 1 && args[0] is Function ? args[0] : null;
        if (errorHandler != null) {
            this.subscribe("error", errorHandler);
        }
        t = this;
        this.monitor("value", function ():Boolean {
            if (t.value != null) {
                callback(t.value);
                return true;
            }
            return false;
        });
    }

    public function subscribe(name:String, cb:Function):void {
        if (!subscribers[name]) {
            subscribers[name] = [cb];
        } else {
            subscribers[name].push(cb);
        }
    }

    public function unsubscribe(name:String, cb:Function):void {
        var _loc4_:int = 0;
        var _loc3_:Array = subscribers[name];
        if (_loc3_) {
            _loc4_ = 0;
            while (_loc4_ != _loc3_.length) {
                if (_loc3_[_loc4_] == cb) {
                    _loc3_[_loc4_] = null;
                }
                _loc4_++;
            }
        }
    }

    public function monitor(name:String, callback:Function):void {
        var ctx:FBWaitable;
        var fn:Function;
        if (!callback()) {
            ctx = this;
            fn = function (...rest):void {
                if (callback.apply(callback, rest)) {
                    ctx.unsubscribe(name, fn);
                }
            };
            subscribe(name, fn);
        }
    }

    public function clear(name:String):void {
        delete subscribers[name];
    }

    public function fire(name:String, ...rest):void {
        var _loc4_:int = 0;
        var _loc3_:Array = subscribers[name];
        if (_loc3_) {
            _loc4_ = 0;
            while (_loc4_ != _loc3_.length) {
                if (_loc3_[_loc4_] != null) {
                    _loc3_[_loc4_].apply(this, rest);
                }
                _loc4_++;
            }
        }
    }
}
}

