package extensions
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.sampler.getSize;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import starling.utils.Color;
	
	public class PixelHitArea
	{
		private static var hitAreas:Dictionary;
		private static var id:int = 0;
		public var width:Number;
		public var height:Number;
		public var name:String;
		public var scaleBitmapData:Number;
		private var sampleWidth:uint;
		private var sampleHeight:uint;
		private var alphaData:Vector.<uint>;
		private var tempData:Vector.<uint>;
		private var createTime:int;
		private var _disposed:Boolean;
		
		public function PixelHitArea(bitmap:Bitmap, bitmapSampling:Number = 1, name:String = "")
		{
			var _loc4_:* = 0;
			super();
			var _loc6_:int = getTimer();
			if(name == "")
			{
				name = "_hit#" + id;
				id++;
			}
			PixelHitArea.registerHitArea(this,name);
			this.width = bitmap.width;
			this.height = bitmap.height;
			this.scaleBitmapData = bitmapSampling;
			if(bitmapSampling > 1 || bitmapSampling < 0.1)
			{
				throw new Error("Incorrect bitmap sampling, correct range is 0.1 - 1");
			}
			var _loc7_:BitmapData = new BitmapData(Math.ceil(bitmap.width * bitmapSampling),Math.ceil(bitmap.height * bitmapSampling),true,0);
			_loc7_ = bitmap.bitmapData.clone();
			bitmapSampling < 1 ? _loc7_.draw(bitmap.bitmapData,new Matrix(bitmapSampling,0,0,bitmapSampling,0,0)) : (_loc7_);
			this.sampleWidth = _loc7_.width;
			this.sampleHeight = _loc7_.height;
			tempData = _loc7_.getVector(_loc7_.rect);
			alphaData = new Vector.<uint>(Math.ceil(sampleWidth * sampleHeight / 4),true);
			var _loc5_:uint = 0;
			_loc4_ = 0;
			while(_loc4_ < alphaData.length)
			{
				alphaData[_loc4_] = getAlpha(_loc5_) << 24 | getAlpha(_loc5_ + 1) << 16 | getAlpha(_loc5_ + 2) << 8 | getAlpha(_loc5_ + 3);
				_loc5_ += 4;
				_loc4_++;
			}
			tempData = null;
			_loc7_.dispose();
			_loc7_ = null;
			createTime = getTimer() - _loc6_;
		}
		
		private static function registerHitArea(hitArea:PixelHitArea, name:String) : void
		{
			if(hitAreas == null)
			{
				hitAreas = new Dictionary();
			}
			if(hitAreas[name] != null)
			{
				throw new Error("PixelTouch: hitArea name duplicate");
			}
			hitAreas[name] = hitArea;
		}
		
		public static function disposeHitArea(hitArea:PixelHitArea) : void
		{
			for(var _loc2_ in hitAreas)
			{
				if(hitAreas[_loc2_] == hitArea)
				{
					hitArea.dispose();
					hitAreas[_loc2_] = null;
				}
			}
		}
		
		public static function dispose() : void
		{
			var _loc2_:PixelHitArea = null;
			for(var _loc1_ in hitAreas)
			{
				_loc2_ = hitAreas[_loc1_];
				if(_loc2_)
				{
					_loc2_.dispose();
					hitAreas[_loc1_] = null;
				}
			}
			hitAreas = null;
			id = 0;
		}
		
		public static function getHitArea(name:String) : PixelHitArea
		{
			if(hitAreas[name])
			{
				return hitAreas[name];
			}
			throw new Error("HitArea " + name + " not found");
		}
		
		public static function getDebugInfo() : String
		{
			var _loc6_:PixelHitArea = null;
			var _loc3_:Number = NaN;
			var _loc2_:String = "HitArea memory size:\r";
			var _loc4_:Number = 0;
			var _loc5_:Number = 0;
			for(var _loc1_ in hitAreas)
			{
				_loc6_ = hitAreas[_loc1_];
				if(_loc6_)
				{
					_loc3_ = _loc6_.getMemorySize() / 1024 / 1024;
					_loc4_ += _loc3_;
					_loc5_ += _loc6_.getCreatTime();
					_loc2_ += _loc1_ + ":\t" + _loc3_.toFixed(2) + " mb \t";
					_loc2_ += "create time:\t" + _loc6_.createTime + " ms\r";
				}
			}
			_loc2_ += "-----------------------\r";
			return _loc2_ + ("total:\t\t" + _loc4_.toFixed(2) + " mb \t\t\t" + _loc5_ + " ms");
		}
		
		private function getAlpha(index:uint) : uint
		{
			return index < tempData.length ? Color.getAlpha(tempData[index]) : 0;
		}
		
		public function getAlphaPixel(x:uint, y:uint) : uint
		{
			var _loc5_:Number = (Math.floor(y * scaleBitmapData) * sampleWidth + Math.floor(x * scaleBitmapData)) / 4;
			var _loc3_:Number = _loc5_ % Math.floor(_loc5_);
			var _loc4_:uint = alphaData[Math.floor(_loc5_)];
			if(_loc3_ == 0)
			{
				return Color.getAlpha(_loc4_);
			}
			if(_loc3_ == 0.25)
			{
				return Color.getRed(_loc4_);
			}
			if(_loc3_ == 0.5)
			{
				return Color.getGreen(_loc4_);
			}
			if(_loc3_ == 0.75)
			{
				return Color.getBlue(_loc4_);
			}
			return 0;
		}
		
		public function dispose() : void
		{
			alphaData = null;
			disposed = true;
		}
		
		public function getMemorySize() : Number
		{
			return !!alphaData ? getSize(alphaData) : 0;
		}
		
		public function getCreatTime() : Number
		{
			return createTime;
		}
		
		public function get disposed() : Boolean
		{
			return _disposed;
		}
		
		public function set disposed(value:Boolean) : void
		{
			_disposed = value;
		}
	}
}

