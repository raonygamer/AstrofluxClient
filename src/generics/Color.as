package generics
{
	import flash.geom.ColorTransform;
	
	public class Color
	{
		private static const lR:Number = 0.213;
		
		private static const lG:Number = 0.715;
		
		private static const lB:Number = 0.072;
		
		public function Color()
		{
			super();
		}
		
		public static function tintColor(colTransform:ColorTransform, tintColor:uint, tintMultiplier:Number) : ColorTransform
		{
			colTransform.redMultiplier = colTransform.greenMultiplier = colTransform.blueMultiplier = 1 - tintMultiplier;
			colTransform.redOffset = Math.round(((tintColor & 0xFF0000) >> 16) * tintMultiplier);
			colTransform.greenOffset = Math.round(((tintColor & 0xFF00) >> 8) * tintMultiplier);
			colTransform.blueOffset = Math.round((tintColor & 0xFF) * tintMultiplier);
			return colTransform;
		}
		
		public static function getDesaturationMatrix(saturation:Number, desaturation:Number, alpha:Number) : Array
		{
			var _loc4_:Array = [];
			_loc4_ = _loc4_.concat([saturation,desaturation,desaturation,0,0]);
			_loc4_ = _loc4_.concat([desaturation,saturation,desaturation,0,0]);
			_loc4_ = _loc4_.concat([desaturation,desaturation,saturation,0,0]);
			return _loc4_.concat([0,0,0,alpha,0]);
		}
		
		public static function getColorMatrix(brightness:Number, r:Number, g:Number, b:Number, alpha:Number) : Vector.<Number>
		{
			var _loc6_:Number = brightness * r;
			var _loc8_:Number = brightness * g;
			var _loc7_:Number = brightness * b;
			return new <Number>[_loc6_,_loc8_,_loc7_,0,0,_loc6_,_loc8_,_loc7_,0,0,_loc6_,_loc8_,_loc7_,0,0,0,0,0,alpha,0];
		}
		
		public static function fixColorCode(c:Object, hasAlpha:Boolean = false) : uint
		{
			var _loc3_:Number = Number(c);
			var _loc4_:Number = hasAlpha ? 4294967295 : 16777215;
			return uint(Math.min(Math.max(_loc3_,0),_loc4_));
		}
		
		public static function HEXtoRGB(hex:uint) : Array
		{
			var _loc2_:* = hex >> 16 & 0xFF;
			var _loc3_:* = hex >> 8 & 0xFF;
			var _loc4_:* = hex & 0xFF;
			return [_loc2_,_loc3_,_loc4_];
		}
		
		public static function adjustColor(Brightness:Number = 0, Contrast:Number = 0, Saturation:Number = 0, Hue:Number = 0) : Vector.<Number>
		{
			var _loc5_:Vector.<Number> = new <Number>[1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0];
			multiplyMatrix(_loc5_,adjustHue(Hue));
			multiplyMatrix(_loc5_,adjustSaturation(Saturation));
			multiplyMatrix(_loc5_,adjustBrightness(Brightness));
			multiplyMatrix(_loc5_,adjustContrast(Contrast));
			return _loc5_;
		}
		
		public static function adjustHue(value:Number) : Vector.<Number>
		{
			value = value < -1 ? -1 : value;
			value = value > 1 ? 1 : value;
			var _loc4_:Number = 3 * 60 * value * (3.141592653589793 / (3 * 60));
			var _loc2_:Number = Math.cos(_loc4_);
			var _loc3_:Number = Math.sin(_loc4_);
			return new <Number>[0.213 + _loc2_ * (1 - 0.213) + _loc3_ * -0.213,0.715 + _loc2_ * -0.715 + _loc3_ * -0.715,0.072 + _loc2_ * -0.072 + _loc3_ * (1 - 0.072),0,0,0.213 + _loc2_ * -0.213 + _loc3_ * 0.143,0.715 + _loc2_ * (1 - 0.715) + _loc3_ * 0.14,0.072 + _loc2_ * -0.072 + _loc3_ * -0.283,0,0,0.213 + _loc2_ * -0.213 + _loc3_ * -0.787,0.715 + _loc2_ * -0.715 + _loc3_ * 0.715,0.072 + _loc2_ * (1 - 0.072) + _loc3_ * 0.072,0,0,0,0,0,1,0];
		}
		
		public static function RGBToHex(r:uint, g:uint, b:uint) : uint
		{
			return uint(r << 16 | g << 8 | b);
		}
		
		public static function HexToRGB(hex:uint) : Array
		{
			var _loc5_:Array = [];
			var _loc2_:uint = uint(hex >> 16 & 0xFF);
			var _loc4_:uint = uint(hex >> 8 & 0xFF);
			var _loc3_:uint = uint(hex & 0xFF);
			_loc5_.push(_loc2_,_loc4_,_loc3_);
			return _loc5_;
		}
		
		public static function RGBtoHSV(r:Number, g:Number, b:Number) : Array
		{
			var _loc6_:uint = Math.max(r,g,b);
			var _loc5_:uint = Math.min(r,g,b);
			var _loc7_:Number = 0;
			var _loc4_:Number = 0;
			var _loc9_:Number = 0;
			var _loc8_:Array = [];
			if(_loc6_ == _loc5_)
			{
				_loc7_ = 0;
			}
			else if(_loc6_ == r)
			{
				_loc7_ = (60 * (g - b) / (_loc6_ - _loc5_) + 6 * 60) % (6 * 60);
			}
			else if(_loc6_ == g)
			{
				_loc7_ = 60 * (b - r) / (_loc6_ - _loc5_) + 2 * 60;
			}
			else if(_loc6_ == b)
			{
				_loc7_ = 60 * (r - g) / (_loc6_ - _loc5_) + 4 * 60;
			}
			_loc9_ = _loc6_;
			if(_loc6_ == 0)
			{
				_loc4_ = 0;
			}
			else
			{
				_loc4_ = (_loc6_ - _loc5_) / _loc6_;
			}
			return [Math.round(_loc7_),Math.round(_loc4_ * 100),Math.round(_loc9_ / 255 * 100)];
		}
		
		public static function HSVtoRGB(h:Number, s:Number, v:Number) : Array
		{
			var _loc13_:* = 0;
			var _loc7_:* = 0;
			var _loc5_:* = 0;
			var _loc8_:Array = [];
			var _loc9_:Number = s / 100;
			var _loc10_:Number = v / 100;
			var _loc4_:int = Math.floor(h / (60)) % 6;
			var _loc6_:Number = h / (60) - Math.floor(h / (60));
			var _loc11_:Number = _loc10_ * (1 - _loc9_);
			var _loc12_:Number = _loc10_ * (1 - _loc6_ * _loc9_);
			var _loc14_:Number = _loc10_ * (1 - (1 - _loc6_) * _loc9_);
			switch(_loc4_)
			{
				case 0:
					_loc13_ = _loc10_;
					_loc7_ = _loc14_;
					_loc5_ = _loc11_;
					break;
				case 1:
					_loc13_ = _loc12_;
					_loc7_ = _loc10_;
					_loc5_ = _loc11_;
					break;
				case 2:
					_loc13_ = _loc11_;
					_loc7_ = _loc10_;
					_loc5_ = _loc14_;
					break;
				case 3:
					_loc13_ = _loc11_;
					_loc7_ = _loc12_;
					_loc5_ = _loc10_;
					break;
				case 4:
					_loc13_ = _loc14_;
					_loc7_ = _loc11_;
					_loc5_ = _loc10_;
					break;
				case 5:
					_loc13_ = _loc10_;
					_loc7_ = _loc11_;
					_loc5_ = _loc12_;
			}
			return [Math.round(_loc13_ * 255),Math.round(_loc7_ * 255),Math.round(_loc5_ * 255)];
		}
		
		public static function HEXHue(c:uint, a:Number) : uint
		{
			var _loc3_:Number = extractRedFromHEX(c);
			var _loc7_:Number = extractGreenFromHEX(c);
			var _loc4_:Number = extractBlueFromHEX(c);
			var _loc9_:Array = RGBtoHSV(_loc3_,_loc7_,_loc4_);
			var _loc8_:Number = Number(_loc9_[0]);
			var _loc5_:Number = Number(_loc9_[1]);
			var _loc6_:Number = Number(_loc9_[2]);
			_loc8_ += Util.radiansToDegrees(a * 2);
			if(_loc8_ < 0)
			{
				_loc8_ = 359 - _loc8_;
			}
			else if(_loc8_ > 359)
			{
				_loc8_ -= 359;
			}
			var _loc10_:Array = HSVtoRGB(_loc8_,_loc5_,_loc6_);
			return RGBToHex(_loc10_[0],_loc10_[1],_loc10_[2]);
		}
		
		public static function adjustSaturation(value:Number) : Vector.<Number>
		{
			value = value < -1 ? -1 : value;
			value = value > 1 ? 1 : value;
			var _loc4_:Number = value + 1;
			var _loc6_:Number = 1 - _loc4_;
			var _loc2_:Number = _loc6_ * 0.213;
			var _loc5_:Number = _loc6_ * 0.715;
			var _loc3_:Number = _loc6_ * 0.072;
			return new <Number>[_loc2_ + _loc4_,_loc5_,_loc3_,0,0,_loc2_,_loc5_ + _loc4_,_loc3_,0,0,_loc2_,_loc5_,_loc3_ + _loc4_,0,0,0,0,0,1,0];
		}
		
		public static function adjustContrast(value:Number) : Vector.<Number>
		{
			value = value < -1 ? -1 : value;
			value = value > 1 ? 1 : value;
			var _loc2_:Number = value + 1;
			var _loc3_:Number = 128 * (1 - _loc2_);
			return new <Number>[_loc2_,0,0,0,_loc3_,0,_loc2_,0,0,_loc3_,0,0,_loc2_,0,_loc3_,0,0,0,_loc2_,0];
		}
		
		public static function adjustBrightness(value:Number) : Vector.<Number>
		{
			value = value < -1 ? -1 : value;
			value = value > 1 ? 1 : value;
			var _loc2_:Number = 255 * value;
			return new <Number>[1,0,0,0,_loc2_,0,1,0,0,_loc2_,0,0,1,0,_loc2_,0,0,0,1,0];
		}
		
		protected static function multiplyMatrix(TargetMatrix:Vector.<Number>, MultiplyMatrix:Vector.<Number>) : void
		{
			var _loc5_:* = 0;
			var _loc6_:* = 0;
			var _loc7_:Number = NaN;
			var _loc3_:Number = NaN;
			var _loc4_:Array = [];
			_loc5_ = 0;
			while(_loc5_ < 4)
			{
				_loc6_ = 0;
				while(_loc6_ < 5)
				{
					_loc4_[_loc6_] = TargetMatrix[_loc6_ + _loc5_ * 5];
					_loc6_++;
				}
				_loc6_ = 0;
				while(_loc6_ < 5)
				{
					_loc3_ = 0;
					_loc7_ = 0;
					while(_loc7_ < 4)
					{
						_loc3_ += MultiplyMatrix[_loc6_ + _loc7_ * 5] * _loc4_[_loc7_];
						_loc7_++;
					}
					TargetMatrix[_loc6_ + _loc5_ * 5] = _loc3_;
					_loc6_++;
				}
				_loc5_++;
			}
		}
		
		public static function RGBtoHEX(r:uint, g:uint, b:uint) : uint
		{
			return r << 16 | g << 8 | b;
		}
		
		public static function extractRedFromHEX(c:uint) : uint
		{
			return c >> 16 & 0xFF;
		}
		
		public static function extractGreenFromHEX(c:uint) : uint
		{
			return c >> 8 & 0xFF;
		}
		
		public static function extractBlueFromHEX(c:uint) : uint
		{
			return c & 0xFF;
		}
		
		public static function interpolateColor(fromColor:uint, toColor:uint, progress:Number) : uint
		{
			var _loc13_:Number = 1 - progress;
			var _loc5_:uint = uint(fromColor >> 24 & 0xFF);
			var _loc16_:uint = uint(fromColor >> 16 & 0xFF);
			var _loc11_:uint = uint(fromColor >> 8 & 0xFF);
			var _loc8_:uint = uint(fromColor & 0xFF);
			var _loc7_:uint = uint(toColor >> 24 & 0xFF);
			var _loc14_:uint = uint(toColor >> 16 & 0xFF);
			var _loc9_:uint = uint(toColor >> 8 & 0xFF);
			var _loc6_:uint = uint(toColor & 0xFF);
			var _loc12_:uint = _loc5_ * _loc13_ + _loc7_ * progress;
			var _loc17_:uint = _loc16_ * _loc13_ + _loc14_ * progress;
			var _loc4_:uint = _loc11_ * _loc13_ + _loc9_ * progress;
			var _loc10_:uint = _loc8_ * _loc13_ + _loc6_ * progress;
			return uint(_loc12_ << 24 | _loc17_ << 16 | _loc4_ << 8 | _loc10_);
		}
	}
}

