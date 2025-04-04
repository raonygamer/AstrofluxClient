package {
import com.hurlant.crypto.hash.MD5;
import com.hurlant.util.Hex;

import flash.utils.ByteArray;

public class MD5Util {
    internal static var _instance:MD5 = new MD5();

    public static function hashString(str:String):String {
        if (_instance == null) {
            _instance = new MD5();
        }

        var bytes:ByteArray = new ByteArray();
        bytes.writeUTFBytes(str);
        bytes.position = 0;
        var hash:String = Hex.fromArray(_instance.hash(bytes));
        return hash;
    }
}
}