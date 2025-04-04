package generics {
import com.adobe.serialization.json.JSONDecoder;

import flash.utils.ByteArray;

import mx.resources.Locale;

public class Localize {
    public static var language:String = "en";
    public static var activateLanguageSelection:Boolean = false;
    private static var langObj:Object;
    private static var r:RegExp = new RegExp(/(\W+)/g);

    public static function setLocale(locale:String = "en_US"):void {
        var _loc2_:Locale = new Locale(locale || "en_US");
    }

    public static function t(key:String):String {
        if (!activateLanguageSelection) {
            return key;
        }
        var _loc3_:String = key.replace(r, "").toLowerCase();
        if (langObj[language] == null) {
            return key;
        }
        var _loc2_:String = langObj[language][_loc3_];
        if (_loc2_ == null) {
            return key;
        }
        if (_loc2_ == "") {
            return key;
        }
        return langObj[language][_loc3_].replace(/\\n/g, "\n");
    }

    public static function cacheLanguageData():void {
        var _loc2_:ByteArray = new EmbeddedAssets.LanguageFile() as ByteArray;
        var _loc1_:JSONDecoder = new JSONDecoder(_loc2_.readUTFBytes(_loc2_.length), true);
        langObj = _loc1_.getValue();
    }

    public static function newData(val:String):void {
        langObj = JSON.parse(val);
    }

    public function Localize() {
        super();
    }
}
}

