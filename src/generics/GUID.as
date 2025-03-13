package generics {
	import flash.system.Capabilities;
	
	public class GUID {
		private static var counter:Number = 0;
		
		public function GUID() {
			super();
		}
		
		public static function create() : String {
			var _local1:Date = new Date();
			var _local3:Number = Number(_local1.getTime());
			var _local2:Number = Math.random() * 1.7976931348623157e+308;
			var _local6:String = Capabilities.serverString;
			var _local4:String = calculate(_local3 + _local6 + _local2 + counter++).toUpperCase();
			return _local4.substring(0,8) + "-" + _local4.substring(8,12) + "-" + _local4.substring(12,16) + "-" + _local4.substring(16,20) + "-" + _local4.substring(20,32);
		}
		
		private static function calculate(src:String) : String {
			return hex_sha1(src);
		}
		
		private static function hex_sha1(src:String) : String {
			return binb2hex(core_sha1(str2binb(src),src.length * 8));
		}
		
		private static function core_sha1(x:Array, len:Number) : Array {
			var _local9:Number = NaN;
			var _local16:* = NaN;
			var _local14:* = NaN;
			var _local8:Number = NaN;
			var _local13:Number = NaN;
			x[len >> 5] |= 128 << 24 - len % 32;
			x[(len + 64 >> 9 << 4) + 15] = len;
			var _local10:Array = new Array(80);
			var _local7:* = 1732584193;
			var _local5:* = -271733879;
			var _local6:Number = -1732584194;
			var _local3:* = 271733878;
			var _local4:* = -1009589776;
			_local9 = 0;
			while(_local9 < x.length) {
				_local16 = _local7;
				var _local15:* = _local5;
				_local14 = _local6;
				var _local12:* = _local3;
				var _local11:* = _local4;
				_local8 = 0;
				while(_local8 < 80) {
					if(_local8 < 16) {
						_local10[_local8] = x[_local9 + _local8];
					} else {
						_local10[_local8] = rol(_local10[_local8 - 3] ^ _local10[_local8 - 8] ^ _local10[_local8 - 14] ^ _local10[_local8 - 16],1);
					}
					_local13 = safe_add(safe_add(rol(_local7,5),sha1_ft(_local8,_local5,_local6,_local3)),safe_add(safe_add(_local4,_local10[_local8]),sha1_kt(_local8)));
					_local4 = _local3;
					_local3 = _local6;
					_local6 = rol(_local5,30);
					_local5 = _local7;
					_local7 = _local13;
					_local8++;
				}
				_local7 = safe_add(_local7,_local16);
				_local5 = safe_add(_local5,_local15);
				_local6 = safe_add(_local6,_local14);
				_local3 = safe_add(_local3,_local12);
				_local4 = safe_add(_local4,_local11);
				_local9 += 16;
			}
			return new Array(_local7,_local5,_local6,_local3,_local4);
		}
		
		private static function sha1_ft(t:Number, b:Number, c:Number, d:Number) : Number {
			if(t < 20) {
				return b & c | ~b & d;
			}
			if(t < 40) {
				return b ^ c ^ d;
			}
			if(t < 60) {
				return b & c | b & d | c & d;
			}
			return b ^ c ^ d;
		}
		
		private static function sha1_kt(t:Number) : Number {
			return t < 20 ? 1518500249 : (t < 40 ? 1859775393 : (t < 60 ? -1894007588 : -899497514));
		}
		
		private static function safe_add(x:Number, y:Number) : Number {
			var _local3:Number = (x & 0xFFFF) + (y & 0xFFFF);
			var _local4:Number = (x >> 16) + (y >> 16) + (_local3 >> 16);
			return _local4 << 16 | _local3 & 0xFFFF;
		}
		
		private static function rol(num:Number, cnt:Number) : Number {
			return num << cnt | num >>> 32 - cnt;
		}
		
		private static function str2binb(str:String) : Array {
			var _local4:Number = NaN;
			var _local3:Array = [];
			var _local2:Number = 255;
			_local4 = 0;
			while(_local4 < str.length * 8) {
				var _local5:* = _local4 >> 5;
				var _local6:* = _local3[_local5] | (str.charCodeAt(_local4 / 8) & _local2) << 24 - _local4 % 32;
				_local3[_local5] = _local6;
				_local4 += 8;
			}
			return _local3;
		}
		
		private static function binb2hex(binarray:Array) : String {
			var _local4:Number = NaN;
			var _local2:String = new String("");
			var _local3:String = new String("0123456789abcdef");
			_local4 = 0;
			while(_local4 < binarray.length * 4) {
				_local2 += _local3.charAt(binarray[_local4 >> 2] >> (3 - _local4 % 4) * 8 + 4 & 0x0F) + _local3.charAt(binarray[_local4 >> 2] >> (3 - _local4 % 4) * 8 & 0x0F);
				_local4++;
			}
			return _local2;
		}
	}
}

