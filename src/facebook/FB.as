package facebook {
import flash.events.*;
import flash.external.*;
import flash.net.*;
import flash.system.*;

public class FB {
    private static var access_token:String = null;
    private static var app_id:String = null;
    private static var debug:Boolean = false;
    private static var uiFlashId:String = null;
    private static var uiCallbackId:Number = 0;
    private static var allowedMethods:Object = {
        "GET": 1,
        "POST": 1,
        "DELETE": 1,
        "PUT": 1
    };
    private static var readOnlyCalls:Object = {
        "fql_query": 1,
        "fql_multiquery": 1,
        "friends_get": 1,
        "notifications_get": 1,
        "stream_get": 1,
        "users_getinfo": 1
    };
    private static var data:FBData = new FBData();

    public static function get Data():FBData {
        return data;
    }

    public static function get uiAvailable():Boolean {
        return initUI() == null;
    }

    public static function init(params:*):void {
        debug = !!params.debug;
        app_id = params.app_id;
        if ((params.access_token + "").length < 3) {
            error("You must supply the init method with an not-null access_token string.");
        } else {
            access_token = params.access_token;
            log("Initializing with access_token: " + access_token);
        }
    }

    public static function api(...rest):void {
        requireAccessToken("api");
        if (typeof rest[0] == "string") {
            graphCall.apply(null, rest);
        } else {
            restCall.apply(null, rest);
        }
    }

    public static function ui(params:*, cb:Function):void {
        var callbackId:String;
        var err:String = initUI();
        if (err != null) {
            error(err);
        }
        if (!params.method) {
            error("\"method\" is a required parameter for FB.ui().");
        }
        callbackId = "as_ui_callback_" + uiCallbackId++;
        ExternalInterface.addCallback(callbackId, function (param1:*):void {
            log("Got response from Javascript FB.ui: " + toString(param1));
            cb(param1);
        });
        ExternalInterface.call("__doFBUICall", uiFlashId, params, callbackId);
    }

    public static function toString(obj:*):String {
        var _loc4_:String = null;
        var _loc6_:String = null;
        var _loc3_:Boolean = false;
        var _loc2_:Boolean = false;
        if (obj == null) {
            return "[null]";
        }
        switch (typeof obj) {
            case "object":
                _loc4_ = "{";
                _loc6_ = "[";
                _loc3_ = true;
                _loc2_ = false;
                for (var _loc5_ in obj) {
                    _loc4_ += (_loc4_ == "{" ? "" : ", ") + _loc5_ + "=" + toString(obj[_loc5_]);
                    _loc6_ += (_loc6_ == "[" ? "" : ", ") + toString(obj[_loc5_]);
                    if (typeof _loc5_ != "number") {
                        _loc3_ = false;
                    }
                    _loc2_ = true;
                }
                return _loc3_ && _loc2_ ? _loc6_ + "]" : _loc4_ + "}";
            case "string":
                return "\"" + obj.replace("\n", "\\n").replace("\r", "\\r") + "\"";
            default:
                return obj + "";
        }
    }

    internal static function stringTrim(s:String):String {
        var _trimRE:RegExp = /^\s*|\s*$/g;
        return s.replace(_trimRE, "");
    }

    internal static function stringFormat(format:String, ...rest):String {
        var args:Array = rest;
        var _formatRE:RegExp = /(\{[^\}^\{]+\})/g;
        return format.replace(_formatRE, function (param1:String, param2:String, param3:int, param4:String):String {
            var _loc5_:int = parseInt(param2.substr(1), 10);
            var _loc6_:* = args[_loc5_];
            if (_loc6_ === null || typeof _loc6_ == "undefined") {
                return "";
            }
            return _loc6_.toString();
        });
    }

    internal static function stringQuote(value:String):String {
        var subst:Object = {
            "\b": "\\b",
            "\t": "\\t",
            "\n": "\\n",
            "\f": "\\f",
            "\r": "\\r",
            "\"": "\\\"",
            "\\": "\\\\"
        };
        var _quoteRE:RegExp = /["\\\x00-\x1f\x7f-\x9f]/g;
        return !!_quoteRE.test(value) ? "\"" + value.replace(_quoteRE, function (param1:String):String {
            var _loc2_:String = subst[param1];
            if (_loc2_) {
                return _loc2_;
            }
            _loc2_ = param1.charCodeAt().toString();
            return "\\u00" + Math.floor(Number(_loc2_) / 16).toString(16) + (Number(_loc2_) % 16).toString(16);
        }) + "\"" : "\"" + value + "\"";
    }

    internal static function arrayIndexOf(arr:Array, item:*):int {
        var _loc4_:int = 0;
        var _loc3_:uint = arr.length;
        if (_loc3_) {
            _loc4_ = 0;
            while (_loc4_ < _loc3_) {
                if (arr[_loc4_] === item) {
                    return _loc4_;
                }
                _loc4_++;
            }
        }
        return -1;
    }

    internal static function arrayMerge(target:Array, source:Array):Array {
        var _loc3_:int = 0;
        _loc3_ = 0;
        while (_loc3_ < source.length) {
            if (arrayIndexOf(target, source[_loc3_]) < 0) {
                target.push(source[_loc3_]);
            }
            _loc3_++;
        }
        return target;
    }

    internal static function arrayMap(arr:Array, transform:Function):Array {
        var _loc4_:int = 0;
        var _loc3_:Array = [];
        _loc4_ = 0;
        while (_loc4_ < arr.length) {
            _loc3_.push(transform(arr[_loc4_]));
            _loc4_++;
        }
        return _loc3_;
    }

    internal static function arrayFilter(arr:Array, fn:Function):Array {
        var _loc4_:int = 0;
        var _loc3_:Array = [];
        _loc4_ = 0;
        while (_loc4_ < arr.length) {
            if (fn(arr[_loc4_])) {
                _loc3_.push(arr[_loc4_]);
            }
            _loc4_++;
        }
        return _loc3_;
    }

    internal static function objCopy(target:Object, source:Object, overwrite:Boolean, transform:Function):Object {
        for (var _loc5_ in source) {
            if (overwrite || typeof target[_loc5_] == "undefined") {
                target[_loc5_] = typeof transform == "function" ? transform(source[_loc5_]) : source[_loc5_];
            }
        }
        return target;
    }

    internal static function forEach(item:*, fn:Function):void {
        var _loc4_:* = 0;
        if (!item) {
            return;
        }
        if (item is Array) {
            _loc4_ = 0;
            while (_loc4_ != item.length) {
                fn(item[_loc4_], _loc4_, item);
                _loc4_++;
            }
        } else if (item is Object) {
            for (var _loc3_ in item) {
                fn(item[_loc3_], _loc3_, item);
            }
        }
    }

    private static function initUI():String {
        var allowsExternalInterface:Boolean;
        var hasJavascript:Boolean;
        var source:String;
        if (uiFlashId == null) {
            Security.allowDomain("*");
            allowsExternalInterface = false;
            try {
                allowsExternalInterface = ExternalInterface.call("eval", "true");
            } catch (e:*) {
            }
            if (!allowsExternalInterface) {
                return "The flash element must not have allowNetworking = \'none\' in the containing page in order to call the FB.ui() method.";
            }
            hasJavascript = ExternalInterface.call("eval", "typeof(FB)!=\'undefined\' && typeof(FB.ui)!=\'undefined\'");
            if (!hasJavascript) {
                return "The FB.ui() method can only be used when the containing page includes the Facebook Javascript SDK. Read more here: http://developers.facebook.com/docs/reference/javascript/FB.init";
            }
            uiFlashId = "flash_" + new Date().getTime() + Math.round(Math.random() * 9999999);
            ExternalInterface.addCallback("getFlashId", function ():String {
                return uiFlashId;
            });
            source = "";
            source += "__doFBUICall = function(uiFlashId,params,callbackId){";
            source += " var find = function(tag){var list=document.getElementsByTagName(tag);for(var i=0;i!=list.length;i++){if(list[i].getFlashId&&list[i].getFlashId()==\"" + uiFlashId + "\"){return list[i]}}};";
            source += " var flashObj = find(\"embed\") || find(\"object\");";
            source += " if(flashObj != null){";
            source += "  FB.ui(params, function(response){";
            source += "   flashObj[callbackId](response);";
            source += "  })";
            source += " }else{alert(\"could not find flash element on the page w/ uiFlashId: " + uiFlashId + "\")}";
            source += "};";
            ExternalInterface.call("eval", source);
        }
        return null;
    }

    private static function graphCall(...rest):void {
        var _loc6_:String = null;
        var _loc7_:String = null;
        var _loc4_:* = null;
        var _loc5_:* = null;
        var _loc8_:Function = null;
        var _loc3_:String = rest.shift();
        var _loc2_:* = rest.shift();
        while (_loc2_) {
            _loc6_ = typeof _loc2_;
            if (_loc6_ === "string" && _loc4_ == null) {
                _loc7_ = _loc2_.toUpperCase();
                if (allowedMethods[_loc7_]) {
                    _loc4_ = _loc7_;
                } else {
                    error("Invalid method passed to FB.api(" + _loc3_ + "): " + _loc2_);
                }
            } else if (_loc6_ === "function" && _loc8_ == null) {
                _loc8_ = _loc2_;
            } else if (_loc6_ === "object" && _loc5_ == null) {
                _loc5_ = _loc2_;
            } else {
                error("Invalid argument passed to FB.api(" + _loc3_ + "): " + _loc2_);
            }
            _loc2_ = rest.shift();
        }
        _loc4_ ||= "GET";
        _loc5_ ||= {};
        log("Graph call: path=" + _loc3_ + ", method=" + _loc4_ + ", params=" + toString(_loc5_));
        oauthRequest("https://graph.facebook.com" + _loc3_, _loc4_, _loc5_, _loc8_);
    }

    private static function restCall(params:*, cb:Function):void {
        var _loc3_:String = (params.method + "").toLowerCase().replace(".", "_");
        params.format = "json-strings";
        params.api_key = app_id;
        log("REST call: method=" + _loc3_ + ", params=" + toString(params));
        oauthRequest("https://" + (!!readOnlyCalls[_loc3_] ? "api-read" : "api") + ".facebook.com/restserver.php", "get", params, cb);
    }

    private static function oauthRequest(url:String, method:String, params:*, cb:Function):void {
        var x:*;
        var loader:URLLoader;
        var request:URLRequest = new URLRequest(url);
        request.method = method;
        request.data = new URLVariables();
        request.data.access_token = access_token;
        for (x in params) {
            request.data[x] = params[x];
        }
        request.data.callback = "c";
        loader = new URLLoader();
        loader.addEventListener("complete", function (param1:Event):void {
            var _loc3_:String = loader.data;
            if (_loc3_.length > 2 && _loc3_.substring(0, 12) == "/**/ /**/ c(") {
                _loc3_ = loader.data.substring(loader.data.indexOf("(") + 1, loader.data.lastIndexOf(")"));
            } else if (_loc3_.length > 2 && _loc3_.substring(0, 7) == "/**/ c(") {
                _loc3_ = loader.data.substring(loader.data.indexOf("(") + 1, loader.data.lastIndexOf(")"));
            }
            var _loc2_:* = JSON2.deserialize(_loc3_);
            if (url.substring(0, 11) == "https://api") {
                log("REST call result, method=" + params.method + " => " + toString(_loc2_));
            } else {
                log("Graph call result, path=" + url + " => " + toString(_loc2_));
            }
            cb(_loc2_);
        });
        loader.addEventListener("ioError", function (param1:IOErrorEvent):void {
            error("Error in response from Facebook api servers, most likely cause is expired or invalid access_token. Error message: " + param1.text);
        });
        loader.load(request);
    }

    private static function requireAccessToken(callerName:String):void {
        if (access_token == null) {
            error("You must call FB.init({access_token:\"...\") before attempting to call FB." + callerName + "()");
        }
    }

    private static function error(msg:String):void {
        if (debug) {
        }
        throw new Error(msg);
    }

    private static function log(msg:String):void {
        if (debug) {
        }
    }

    public function FB() {
        super();
    }
}
}

