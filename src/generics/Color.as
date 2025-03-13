package generics {
	import flash.geom.ColorTransform;
	
	public class Color {
		private static const lR:Number = 0.213;
		private static const lG:Number = 0.715;
		private static const lB:Number = 0.072;
		
		public function Color() {
			super();
		}
		
		public static function tintColor(colTransform:ColorTransform, tintColor:uint, tintMultiplier:Number) : ColorTransform {
			colTransform.redMultiplier = colTransform.greenMultiplier = colTransform.blueMultiplier = 1 - tintMultiplier;
			colTransform.redOffset = Math.round(((tintColor & 0xFF0000) >> 16) * tintMultiplier);
			colTransform.greenOffset = Math.round(((tintColor & 0xFF00) >> 8) * tintMultiplier);
			colTransform.blueOffset = Math.round((tintColor & 0xFF) * tintMultiplier);
			return colTransform;
		}
		
		public static function getDesaturationMatrix(saturation:Number, desaturation:Number, alpha:Number) : Array {
			var _local4:Array = [];
			_local4 = _local4.concat([saturation,desaturation,desaturation,0,0]);
			_local4 = _local4.concat([desaturation,saturation,desaturation,0,0]);
			_local4 = _local4.concat([desaturation,desaturation,saturation,0,0]);
			return _local4.concat([0,0,0,alpha,0]);
		}
		
		public static function getColorMatrix(brightness:Number, r:Number, g:Number, b:Number, alpha:Number) : Vector.<Number> {
			var _local6:Number = brightness * r;
			var _local7:Number = brightness * g;
			var _local8:Number = brightness * b;
			return new <Number>[_local6,_local7,_local8,0,0,_local6,_local7,_local8,0,0,_local6,_local7,_local8,0,0,0,0,0,alpha,0];
		}
		
		public static function fixColorCode(c:Object, hasAlpha:Boolean = false) : uint {
			var _local4:Number = Number(c);
			var _local3:Number = hasAlpha ? 4294967295 : 16777215;
			return uint(Math.min(Math.max(_local4,0),_local3));
		}
		
		public static function HEXtoRGB(hex:uint) : Array {
			var _local2:* = hex >> 16 & 0xFF;
			var _local4:* = hex >> 8 & 0xFF;
			var _local3:* = hex & 0xFF;
			return [_local2,_local4,_local3];
		}
		
		public static function adjustColor(Brightness:Number = 0, Contrast:Number = 0, Saturation:Number = 0, Hue:Number = 0) : Vector.<Number> {
			var _local5:Vector.<Number> = new <Number>[1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0];
			multiplyMatrix(_local5,adjustHue(Hue));
			multiplyMatrix(_local5,adjustSaturation(Saturation));
			multiplyMatrix(_local5,adjustBrightness(Brightness));
			multiplyMatrix(_local5,adjustContrast(Contrast));
			return _local5;
		}
		
		public static function adjustHue(value:Number) : Vector.<Number> {
			value = value < -1 ? -1 : value;
			value = value > 1 ? 1 : value;
			var _local2:Number = 3 * 60 * value * (3.141592653589793 / (3 * 60));
			var _local4:Number = Math.cos(_local2);
			var _local3:Number = Math.sin(_local2);
			return new <Number>[0.213 + _local4 * (1 - 0.213) + _local3 * -0.213,0.715 + _local4 * -0.715 + _local3 * -0.715,0.072 + _local4 * -0.072 + _local3 * (1 - 0.072),0,0,0.213 + _local4 * -0.213 + _local3 * 0.143,0.715 + _local4 * (1 - 0.715) + _local3 * 0.14,0.072 + _local4 * -0.072 + _local3 * -0.283,0,0,0.213 + _local4 * -0.213 + _local3 * -0.787,0.715 + _local4 * -0.715 + _local3 * 0.715,0.072 + _local4 * (1 - 0.072) + _local3 * 0.072,0,0,0,0,0,1,0];
		}
		
		public static function RGBToHex(r:uint, g:uint, b:uint) : uint {
			return uint(r << 16 | g << 8 | b);
		}
		
		public static function HexToRGB(hex:uint) : Array {
			var _local5:Array = [];
			var _local4:uint = uint(hex >> 16 & 0xFF);
			var _local2:uint = uint(hex >> 8 & 0xFF);
			var _local3:uint = uint(hex & 0xFF);
			_local5.push(_local4,_local2,_local3);
			return _local5;
		}
		
		public static function RGBtoHSV(r:Number, g:Number, b:Number) : Array {
			var _local5:uint = Math.max(r,g,b);
			var _local4:uint = Math.min(r,g,b);
			var _local8:Number = 0;
			var _local6:Number = 0;
			var _local9:Number = 0;
			var _local7:Array = [];
			if(_local5 == _local4) {
				_local8 = 0;
			} else if(_local5 == r) {
				_local8 = (60 * (g - b) / (_local5 - _local4) + 6 * 60) % (6 * 60);
			} else if(_local5 == g) {
				_local8 = 60 * (b - r) / (_local5 - _local4) + 2 * 60;
			} else if(_local5 == b) {
				_local8 = 60 * (r - g) / (_local5 - _local4) + 4 * 60;
			}
			_local9 = _local5;
			if(_local5 == 0) {
				_local6 = 0;
			} else {
				_local6 = (_local5 - _local4) / _local5;
			}
			return [Math.round(_local8),Math.round(_local6 * 100),Math.round(_local9 / 255 * 100)];
		}
		
		public static function HSVtoRGB(h:Number, s:Number, v:Number) : Array {
			var _local12:* = 0;
			var _local5:* = 0;
			var _local6:* = 0;
			var _local7:Array = [];
			var _local10:Number = s / 100;
			var _local9:Number = v / 100;
			var _local8:int = Math.floor(h / (60)) % 6;
			var _local4:Number = h / (60) - Math.floor(h / (60));
			var _local14:Number = _local9 * (1 - _local10);
			var _local13:Number = _local9 * (1 - _local4 * _local10);
			var _local11:Number = _local9 * (1 - (1 - _local4) * _local10);
			switch(_local8) {
				case 0:
					_local12 = _local9;
					_local5 = _local11;
					_local6 = _local14;
					break;
				case 1:
					_local12 = _local13;
					_local5 = _local9;
					_local6 = _local14;
					break;
				case 2:
					_local12 = _local14;
					_local5 = _local9;
					_local6 = _local11;
					break;
				case 3:
					_local12 = _local14;
					_local5 = _local13;
					_local6 = _local9;
					break;
				case 4:
					_local12 = _local11;
					_local5 = _local14;
					_local6 = _local9;
					break;
				case 5:
					_local12 = _local9;
					_local5 = _local14;
					_local6 = _local13;
			}
			return [Math.round(_local12 * 255),Math.round(_local5 * 255),Math.round(_local6 * 255)];
		}
		
		public static function HEXHue(c:uint, a:Number) : uint {
			var _local7:Number = extractRedFromHEX(c);
			var _local4:Number = extractGreenFromHEX(c);
			var _local6:Number = extractBlueFromHEX(c);
			var _local8:Array = RGBtoHSV(_local7,_local4,_local6);
			var _local10:Number = Number(_local8[0]);
			var _local5:Number = Number(_local8[1]);
			var _local3:Number = Number(_local8[2]);
			_local10 += Util.radiansToDegrees(a * 2);
			if(_local10 < 0) {
				_local10 = 359 - _local10;
			} else if(_local10 > 359) {
				_local10 -= 359;
			}
			var _local9:Array = HSVtoRGB(_local10,_local5,_local3);
			return RGBToHex(_local9[0],_local9[1],_local9[2]);
		}
		
		public static function adjustSaturation(value:Number) : Vector.<Number> {
			value = value < -1 ? -1 : value;
			value = value > 1 ? 1 : value;
			var _local3:Number = value + 1;
			var _local6:Number = 1 - _local3;
			var _local5:Number = _local6 * 0.213;
			var _local2:Number = _local6 * 0.715;
			var _local4:Number = _local6 * 0.072;
			return new <Number>[_local5 + _local3,_local2,_local4,0,0,_local5,_local2 + _local3,_local4,0,0,_local5,_local2,_local4 + _local3,0,0,0,0,0,1,0];
		}
		
		public static function adjustContrast(value:Number) : Vector.<Number> {
			value = value < -1 ? -1 : value;
			value = value > 1 ? 1 : value;
			var _local2:Number = value + 1;
			var _local3:Number = 128 * (1 - _local2);
			return new <Number>[_local2,0,0,0,_local3,0,_local2,0,0,_local3,0,0,_local2,0,_local3,0,0,0,_local2,0];
		}
		
		public static function adjustBrightness(value:Number) : Vector.<Number> {
			value = value < -1 ? -1 : value;
			value = value > 1 ? 1 : value;
			var _local2:Number = 255 * value;
			return new <Number>[1,0,0,0,_local2,0,1,0,0,_local2,0,0,1,0,_local2,0,0,0,1,0];
		}
		
		protected static function multiplyMatrix(TargetMatrix:Vector.<Number>, MultiplyMatrix:Vector.<Number>) : void {
			var _local7:* = 0;
			var _local5:* = 0;
			var _local6:Number = NaN;
			var _local3:Number = NaN;
			var _local4:Array = [];
			_local7 = 0;
			while(_local7 < 4) {
				_local5 = 0;
				while(_local5 < 5) {
					_local4[_local5] = TargetMatrix[_local5 + _local7 * 5];
					_local5++;
				}
				_local5 = 0;
				while(_local5 < 5) {
					_local3 = 0;
					_local6 = 0;
					while(_local6 < 4) {
						_local3 += MultiplyMatrix[_local5 + _local6 * 5] * _local4[_local6];
						_local6++;
					}
					TargetMatrix[_local5 + _local7 * 5] = _local3;
					_local5++;
				}
				_local7++;
			}
		}
		
		public static function RGBtoHEX(r:uint, g:uint, b:uint) : uint {
			return r << 16 | g << 8 | b;
		}
		
		public static function extractRedFromHEX(c:uint) : uint {
			return c >> 16 & 0xFF;
		}
		
		public static function extractGreenFromHEX(c:uint) : uint {
			return c >> 8 & 0xFF;
		}
		
		public static function extractBlueFromHEX(c:uint) : uint {
			return c & 0xFF;
		}
		
		public static function interpolateColor(fromColor:uint, toColor:uint, progress:Number) : uint {
			var _local16:Number = 1 - progress;
			var _local13:uint = uint(fromColor >> 24 & 0xFF);
			var _local14:uint = uint(fromColor >> 16 & 0xFF);
			var _local8:uint = uint(fromColor >> 8 & 0xFF);
			var _local5:uint = uint(fromColor & 0xFF);
			var _local11:uint = uint(toColor >> 24 & 0xFF);
			var _local17:uint = uint(toColor >> 16 & 0xFF);
			var _local4:uint = uint(toColor >> 8 & 0xFF);
			var _local9:uint = uint(toColor & 0xFF);
			var _local7:uint = _local13 * _local16 + _local11 * progress;
			var _local15:uint = _local14 * _local16 + _local17 * progress;
			var _local10:uint = _local8 * _local16 + _local4 * progress;
			var _local6:uint = _local5 * _local16 + _local9 * progress;
			return uint(_local7 << 24 | _local15 << 16 | _local10 << 8 | _local6);
		}
	}
}

