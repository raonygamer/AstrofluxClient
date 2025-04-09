package facebook {
internal class JSON2 {
    public static function deserialize(source:String):* {
        source = new String(source);
        var at:Number = 0;
        var ch:String = " ";
        var _isDigit:Function = function (param1:String):* {
            return "0" <= param1 && param1 <= "9";
        };
        var _isHexDigit:Function = function (param1:String):* {
            return _isDigit(param1) || "A" <= param1 && param1 <= "F" || "a" <= param1 && param1 <= "f";
        };
        var _error:Function = function (param1:String):void {
            throw new Error(param1, at - 1);
        };
        var _next:Function = function ():* {
            ch = source.charAt(at);
            at += 1;
            return ch;
        };
        var _white:Function = function ():void {
            while (ch) {
                if (ch <= " ") {
                    _next();
                } else {
                    if (ch != "/") {
                        break;
                    }
                    switch (_next()) {
                        case "/":
                            while (_next() && ch != "\n" && ch != "\r") {
                            }
                            break;
                        case "*":
                            _next();
                            while (true) {
                                if (ch) {
                                    if (ch == "*") {
                                        if (_next() == "/") {
                                            break;
                                        }
                                    } else {
                                        _next();
                                    }
                                } else {
                                    _error("Unterminated Comment");
                                }
                            }
                            _next();
                            break;
                        default:
                            _error("Syntax Error");
                    }
                }
            }
        };
        var _string:Function = function ():* {
            var _loc2_:* = undefined;
            var _loc3_:* = undefined;
            var _loc5_:* = "";
            var _loc1_:* = "";
            var _loc4_:Boolean = false;
            if (ch == "\"") {
                while (Boolean(_next())) {
                    if (ch == "\"") {
                        _next();
                        return _loc1_;
                    }
                    if (ch == "\\") {
                        switch (_next()) {
                            case "b":
                                _loc1_ += "\b";
                                break;
                            case "f":
                                _loc1_ += "\f";
                                break;
                            case "n":
                                _loc1_ += "\n";
                                break;
                            case "r":
                                _loc1_ += "\r";
                                break;
                            case "t":
                                _loc1_ += "\t";
                                break;
                            case "u":
                                _loc3_ = 0;
                                _loc5_ = 0;
                                while (_loc5_ < 4) {
                                    _loc2_ = parseInt(_next(), 16);
                                    if (!isFinite(_loc2_)) {
                                        _loc4_ = true;
                                        break;
                                    }
                                    _loc3_ = _loc3_ * 16 + _loc2_;
                                    _loc5_ += 1;
                                }
                                if (_loc4_) {
                                    _loc4_ = false;
                                    break;
                                }
                                _loc1_ += String.fromCharCode(_loc3_);
                                break;
                            default:
                                _loc1_ += ch;
                        }
                    } else {
                        _loc1_ += ch;
                    }
                }
            }
            _error("Bad String");
            return null;
        };
        var _array:Function = function ():* {
            var _loc1_:Array = [];
            if (ch == "[") {
                _next();
                _white();
                if (ch == "]") {
                    _next();
                    return _loc1_;
                }
                while (ch) {
                    _loc1_.push(_value());
                    _white();
                    if (ch == "]") {
                        _next();
                        return _loc1_;
                    }
                    if (ch != ",") {
                        break;
                    }
                    _next();
                    _white();
                }
            }
            _error("Bad Array");
            return null;
        };
        var _object:Function = function ():* {
            var _loc1_:* = {};
            var _loc2_:* = {};
            if (ch == "{") {
                _next();
                _white();
                if (ch == "}") {
                    _next();
                    return _loc2_;
                }
                while (ch) {
                    _loc1_ = _string();
                    _white();
                    if (ch != ":") {
                        break;
                    }
                    _next();
                    _loc2_[_loc1_] = _value();
                    _white();
                    if (ch == "}") {
                        _next();
                        return _loc2_;
                    }
                    if (ch != ",") {
                        break;
                    }
                    _next();
                    _white();
                }
            }
            _error("Bad Object");
        };
        var _number:Function = function ():* {
            var _loc1_:* = undefined;
            var _loc4_:* = "";
            var _loc3_:String = "";
            var _loc2_:String = "";
            if (ch == "-") {
                _loc2_ = _loc4_ = "-";
                _next();
            }
            if (ch == "0") {
                _next();
                if (ch == "x" || ch == "X") {
                    _next();
                    while (Boolean(_isHexDigit(ch))) {
                        _loc3_ += ch;
                        _next();
                    }
                    if (_loc3_ != "") {
                        return Number(_loc2_ + "0x" + _loc3_);
                    }
                    _error("mal formed Hexadecimal");
                } else {
                    _loc4_ += "0";
                }
            }
            while (Boolean(_isDigit(ch))) {
                _loc4_ += ch;
                _next();
            }
            if (ch == ".") {
                _loc4_ += ".";
                while (_next() && ch >= "0" && ch <= "9") {
                    _loc4_ += ch;
                }
            }
            _loc1_ = 1 * _loc4_;
            if (!isFinite(_loc1_)) {
                _error("Bad Number");
                return NaN;
            }
            return _loc1_;
        };
        var _word:Function = function ():* {
            switch (ch) {
                case "t":
                    if (_next() == "r" && _next() == "u" && _next() == "e") {
                        _next();
                        return true;
                    }
                    break;
                case "f":
                    if (_next() == "a" && _next() == "l" && _next() == "s" && _next() == "e") {
                        _next();
                        return false;
                    }
                    break;
                case "n":
                    if (_next() == "u" && _next() == "l" && _next() == "l") {
                        _next();
                        return null;
                    }
                    break;
            }
            _error("Syntax Error");
            return null;
        };
        var _value:Function = function ():* {
            _white();
            switch (ch) {
                case "{":
                    return _object();
                case "[":
                    return _array();
                case "\"":
                    return _string();
                case "-":
                    return _number();
                default:
                    return ch >= "0" && ch <= "9" ? _number() : _word();
            }
        };
        return _value();
    }

    public static function serialize(o:*):String {
        var _loc2_:String = null;
        var _loc7_:Number = NaN;
        var _loc8_:Number = NaN;
        var _loc5_:* = undefined;
        var _loc4_:Number = NaN;
        var _loc3_:String = "";
        switch (typeof o) {
            case "object":
                if (o) {
                    if (o is Array) {
                        _loc8_ = Number(o.length);
                        _loc7_ = 0;
                        while (_loc7_ < _loc8_) {
                            _loc5_ = serialize(o[_loc7_]);
                            if (_loc3_) {
                                _loc3_ += ",";
                            }
                            _loc3_ += _loc5_;
                            _loc7_++;
                        }
                        return "[" + _loc3_ + "]";
                    }
                    if (typeof o.toString != "undefined") {
                        for (var _loc6_ in o) {
                            _loc5_ = o[_loc6_];
                            if (typeof _loc5_ != "undefined" && typeof _loc5_ != "function") {
                                _loc5_ = serialize(_loc5_);
                                if (_loc3_) {
                                    _loc3_ += ",";
                                }
                                _loc3_ += serialize(_loc6_) + ":" + _loc5_;
                            }
                        }
                        return "{" + _loc3_ + "}";
                    }
                }
                return "null";
            case "number":
                return isFinite(o) ? o : "null";
            case "string":
                _loc8_ = Number(o.length);
                _loc3_ = "\"";
                _loc7_ = 0;
                while (_loc7_ < _loc8_) {
                    _loc2_ = o.charAt(_loc7_);
                    if (_loc2_ >= " ") {
                        if (_loc2_ == "\\" || _loc2_ == "\"") {
                            _loc3_ += "\\";
                        }
                        _loc3_ += _loc2_;
                    } else {
                        switch (_loc2_) {
                            case "\b":
                                _loc3_ += "\\b";
                                break;
                            case "\f":
                                _loc3_ += "\\f";
                                break;
                            case "\n":
                                _loc3_ += "\\n";
                                break;
                            case "\r":
                                _loc3_ += "\\r";
                                break;
                            case "\t":
                                _loc3_ += "\\t";
                                break;
                            default:
                                _loc4_ = Number(_loc2_.charCodeAt());
                                _loc3_ += "\\u00" + Math.floor(_loc4_ / 16).toString(16) + (_loc4_ % 16).toString(16);
                        }
                    }
                    _loc7_ += 1;
                }
                return _loc3_ + "\"";
            case "boolean":
                return o;
            default:
                return "null";
        }
    }

    public function JSON2() {
        super();
    }
}
}

