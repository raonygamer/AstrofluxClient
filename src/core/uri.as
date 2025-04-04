package core {
public class uri {
    public function uri(raw:String) {
        super();
        this._source = raw;
        this._parse(raw);
    }
    private var _username:String = "";
    private var _password:String = "";
    private var _r:RegExp = /\\/g;

    private var _source:String = "";

    public function get source():String {
        return this._source;
    }

    private var _scheme:String = "";

    public function get scheme():String {
        return this._scheme;
    }

    public function set scheme(value:String):void {
        this._scheme = value;
    }

    private var _host:String = "";

    public function get host():String {
        return this._host;
    }

    public function set host(value:String):void {
        this._host = value;
    }

    private var _port:int = -1;

    public function get port():int {
        return this._port;
    }

    public function set port(value:int):void {
        this._port = value;
    }

    private var _path:String = "";

    public function get path():String {
        return this._path;
    }

    public function set path(value:String):void {
        this._path = value;
    }

    private var _query:String = "";

    public function get query():String {
        return this._query;
    }

    public function set query(value:String):void {
        this._query = value;
    }

    private var _fragment:String = "";

    public function get fragment():String {
        return this._fragment;
    }

    public function set fragment(value:String):void {
        this._fragment = value;
    }

    public function get authority():String {
        var _loc1_:String = "";
        if (this.userinfo) {
            _loc1_ += this.userinfo + "@";
        }
        _loc1_ += this.host;
        if (this.host != "" && this.port > -1) {
            _loc1_ += ":" + this.port;
        }
        return _loc1_;
    }

    public function get userinfo():String {
        if (!this._username) {
            return "";
        }
        var _loc1_:String = "";
        _loc1_ += this._username;
        return _loc1_ + (":" + this._password);
    }

    public function toString():String {
        var _loc1_:String = "";
        if (this.scheme) {
            _loc1_ += this.scheme + ":";
        }
        if (this.authority) {
            _loc1_ += "//" + this.authority;
        }
        if (this.authority == "" && this.scheme == "file") {
            _loc1_ += "//";
        }
        _loc1_ += this.path;
        if (this.query) {
            _loc1_ += "?" + this.query;
        }
        if (this.fragment) {
            _loc1_ += "#" + this.fragment;
        }
        return _loc1_;
    }

    public function valueOf():String {
        return this.toString();
    }

    private function _parseUnixAbsoluteFilePath(str:String):void {
        this.scheme = "file";
        this._port = -1;
        this._fragment = "";
        this._query = "";
        this._host = "";
        this._path = "";
        if (str.substr(0, 2) == "//") {
            while (str.charAt(0) == "/") {
                str = str.substr(1);
            }
            this._path = "/" + str;
        }
        if (!this._path) {
            this._path = str;
        }
    }

    private function _parseWindowsAbsoluteFilePath(str:String):void {
        if (str.length > 2 && str.charAt(2) != "\\" && str.charAt(2) != "/") {
            return;
        }
        this.scheme = "file";
        this._port = -1;
        this._fragment = "";
        this._query = "";
        this._host = "";
        this._path = "/" + str.replace(this._r, "/");
    }

    private function _parseWindowsUNC(str:String):void {
        this.scheme = "file";
        this._port = -1;
        this._fragment = "";
        this._query = "";
        while (str.charAt(0) == "\\") {
            str = str.substr(1);
        }
        var _loc2_:int = int(str.indexOf("\\"));
        if (_loc2_ > 0) {
            this._path = str.substring(_loc2_);
            this._host = str.substring(0, _loc2_);
        } else {
            this._host = str;
            this._path = "";
        }
        this._path = this._path.replace(this._r, "/");
    }

    private function _parse(str:String):void {
        var _loc5_:String = null;
        var _loc6_:String = null;
        var _loc7_:String = null;
        var _loc8_:String = null;
        var _loc9_:int = 0;
        var _loc10_:String = null;
        var _loc11_:Boolean = false;
        var _loc2_:int = int(str.indexOf(":"));
        if (_loc2_ < 0) {
            if (str.charAt(0) == "/") {
                this._parseUnixAbsoluteFilePath(str);
            } else if (str.substr(0, 2) == "\\\\") {
                this._parseWindowsUNC(str);
            }
            return;
        }
        if (_loc2_ == 1) {
            this._parseWindowsAbsoluteFilePath(str);
            return;
        }
        var _loc3_:RegExp = new RegExp("^(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)([?]([^#]*))?(#(.*))?", null);
        var _loc4_:Object = _loc3_.exec(str);
        if (Boolean(_loc4_[1]) && Boolean(_loc4_[2])) {
            this.scheme = _loc4_[2];
        }
        if (_loc4_[3]) {
            _loc5_ = _loc4_[4];
            _loc6_ = "";
            if (_loc5_.indexOf("@") > -1) {
                _loc7_ = _loc5_.split("@")[0];
                _loc6_ = _loc5_.split("@")[1];
                if (_loc7_.indexOf(":") != -1) {
                    this._username = _loc7_.split(":")[0];
                    this._password = _loc7_.split(":")[1];
                } else {
                    this._username = _loc7_;
                }
            } else {
                _loc6_ = _loc5_;
            }
            if (_loc6_.indexOf(":") > -1) {
                _loc8_ = _loc6_.split(":")[1];
                _loc11_ = true;
                _loc9_ = 0;
                while (_loc9_ < _loc8_.length) {
                    _loc10_ = _loc8_.charAt(_loc9_);
                    if (!("0" <= _loc10_ && _loc10_ <= "9")) {
                        _loc11_ = false;
                    }
                    _loc9_++;
                }
                if (_loc11_) {
                    _loc6_ = _loc6_.split(":")[0];
                    if (Boolean(_loc8_) && _loc8_.length > 0) {
                        this.port = parseInt(_loc8_);
                    }
                }
            }
            this.host = _loc6_;
        }
        if (_loc4_[5]) {
            this.path = _loc4_[5];
        }
        if (_loc4_[6]) {
            this._query = _loc4_[7];
        }
        if (_loc4_[8]) {
            this._fragment = _loc4_[9];
        }
    }
}
}

