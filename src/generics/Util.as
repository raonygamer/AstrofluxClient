package generics {
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Util {
		public static var Math2PI:Number = 6.283185307179586;
		
		public function Util() {
			super();
		}
		
		public static function degreesToRadians(degrees:Number) : Number {
			return degrees * 3.141592653589793 / (3 * 60);
		}
		
		public static function getRotationEaseAmount(diff:Number, k:Number) : Number {
			if(diff > 3.141592653589793) {
				diff -= Math2PI;
			} else if(diff < -3.141592653589793) {
				diff = Math2PI + diff;
			}
			return diff * k;
		}
		
		public static function angleDifference(x:Number, y:Number) : Number {
			var _local3:Number = x - y;
			if(_local3 > 3.141592653589793) {
				return _local3 - Math2PI;
			}
			if(_local3 < -3.141592653589793) {
				return _local3 + Math2PI;
			}
			return _local3;
		}
		
		public static function radiansToDegrees(radians:Number) : Number {
			return radians * (3 * 60) / 3.141592653589793;
		}
		
		public static function isAngleBetween(angle:Number, angle1:Number, angle2:Number) : Boolean {
			var _local4:Boolean = false;
			angle = clampDegrees(angle);
			angle1 = clampDegrees(angle1);
			angle2 = clampDegrees(angle2);
			_local4 = angle >= angle1 && angle <= angle2;
			if(angle1 > 3 * 60 && angle2 < 3 * 60) {
				if(angle <= 6 * 60 && angle >= angle1) {
					_local4 = true;
				}
				if(angle >= 0 && angle <= angle2) {
					_local4 = true;
				}
			}
			return _local4;
		}
		
		public static function clampDegrees(degrees:Number) : Number {
			return degrees % (6 * 60);
		}
		
		public static function clampRadians(radians:Number) : Number {
			radians /= Math2PI;
			return (radians - Math.floor(radians)) * Math2PI;
		}
		
		public static function formatDecimal(n:Number, count:int = 1) : Number {
			return Math.floor(n * 10 * count) / 10 * count;
		}
		
		public static function sign(n:Number) : Number {
			if(n >= 0) {
				return 1;
			}
			return -1;
		}
		
		public static function formatAmount(amount:Number) : String {
			var _local2:String = "";
			if(amount > 5000) {
				amount /= 1000;
				_local2 = "k";
			}
			return _local2 == "" ? amount.toString() : amount.toFixed(1) + _local2;
		}
		
		public static function dotProduct(x:Number, y:Number, x2:Number, y2:Number) : Number {
			return x * x2 + y * y2;
		}
		
		public static function intersectLineAndRect(x1:Number, y1:Number, x2:Number, y2:Number, rect:Rectangle) : Point {
			var _local6:Point = Util.intersectLines(x1,y1,x2,y2,rect.right,rect.y,rect.right,rect.bottom);
			if(_local6 == null) {
				_local6 = Util.intersectLines(x1,y1,x2,y2,rect.x,rect.y,rect.x,rect.bottom);
			}
			if(_local6 == null) {
				_local6 = Util.intersectLines(x1,y1,x2,y2,rect.x,rect.y,rect.right,rect.y);
			}
			if(_local6 == null) {
				_local6 = Util.intersectLines(x1,y1,x2,y2,rect.x,rect.bottom,rect.right,rect.bottom);
			}
			return _local6;
		}
		
		public static function intersectLines(x1:Number, y1:Number, x2:Number, y2:Number, x3:Number, y3:Number, x4:Number, y4:Number) : Point {
			var _local12:* = NaN;
			var _local11:* = NaN;
			var _local15:* = NaN;
			var _local14:* = NaN;
			var _local18:* = NaN;
			var _local17:* = NaN;
			var _local16:* = NaN;
			var _local13:* = NaN;
			var _local10:Number = ((x4 - x3) * (y1 - y3) - (y4 - y3) * (x1 - x3)) / ((y4 - y3) * (x2 - x1) - (x4 - x3) * (y2 - y1));
			var _local9:Number = x1 + _local10 * (x2 - x1);
			var _local19:Number = y1 + _local10 * (y2 - y1);
			if(_local9.toString() == (NaN).toString() || _local19.toString() == (NaN).toString()) {
				return null;
			}
			if(x1 > x2) {
				_local12 = x2;
				_local11 = x1;
			} else {
				_local12 = x1;
				_local11 = x2;
			}
			if(y1 > y2) {
				_local15 = y2;
				_local14 = y1;
			} else {
				_local15 = y1;
				_local14 = y2;
			}
			if(x3 > x4) {
				_local18 = x4;
				_local17 = x3;
			} else {
				_local18 = x3;
				_local17 = x4;
			}
			if(y3 > y4) {
				_local16 = y4;
				_local13 = y3;
			} else {
				_local16 = y3;
				_local13 = y4;
			}
			if(_local9 >= _local12 && _local9 <= _local11 && _local19 >= _local15 && _local19 <= _local14 && _local9 >= _local18 && _local9 <= _local17 && _local19 >= _local16 && _local19 <= _local13) {
				return new Point(_local9,_local19);
			}
			return null;
		}
		
		public static function getFormattedTime(totalTime:Number) : String {
			var _local5:int = Math.floor(totalTime / 1000);
			var _local2:int = Math.floor(_local5 / (60));
			var _local4:int = Math.floor(_local2 / (60));
			_local5 -= _local2 * (60);
			_local2 -= _local4 * (60);
			var _local3:String = "";
			if(_local4 > 0) {
				_local3 = _local4 + "h ";
			}
			if(_local2 > 0 || _local4 > 0) {
				_local3 = _local3 + _local2 + "m ";
			}
			if(_local5 > 0 || _local2 > 0 || _local4 > 0) {
				_local3 = _local3 + _local5 + "s ";
			}
			return _local3;
		}
		
		public static function trimUsername(s:String) : String {
			return s.replace(/^([\s|\t|\n]+)?(.*)([\s|\t|\n]+)?$/gm,"$2");
		}
	}
}

