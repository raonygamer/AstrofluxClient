package core.strings {
public function userAgent(apptoken:String = "", noself:Boolean = false, minimal:Boolean = false, compatible:Boolean = false):String {
    var _loc13_:Class = null;
    var _loc14_:String = null;
    var _loc15_:String = null;
    var _loc5_:* = Security.sandboxType == "application";
    if ((_loc5_) && compatible) {
        _loc13_ = ApplicationDomain.currentDomain.getDefinition("flash.net.URLRequestDefaults") as Class;
        if ((Boolean(_loc13_)) && "userAgent" in _loc13_) {
            return _loc13_["userAgent"];
        }
    }
    var _loc6_:String = compatible ? "Mozilla/5.0" : "Tamarin/" + System.vmVersion;
    var _loc7_:String = _loc5_ ? "AdobeAIR" : "AdobeFlashPlayer";
    var _loc8_:String = Capabilities.version.split(" ")[1].split(",").join(".");
    var _loc9_:Array = [];
    var _loc10_:String = Capabilities.manufacturer.split("Adobe ")[1];
    var _loc11_:String = Capabilities.playerType;
    _loc9_.push(_loc10_, _loc11_);
    if (!minimal) {
        _loc14_ = Capabilities.os;
        _loc15_ = _loc5_ ? Capabilities["languages"] : Capabilities.language;
        _loc9_.push(_loc14_, _loc15_);
    }
    if (Capabilities.isDebugger) {
        _loc9_.push("DEBUG");
    }
    var _loc12_:String = "";
    _loc12_ = _loc12_ + _loc6_;
    _loc12_ = _loc12_ + (" (" + _loc9_.join("; ") + ")");
    if (!noself || apptoken == "") {
        _loc12_ += " " + _loc7_ + "/" + _loc8_;
    }
    if (apptoken != "") {
        _loc12_ += " " + apptoken;
    }
    return _loc12_;
}
}







