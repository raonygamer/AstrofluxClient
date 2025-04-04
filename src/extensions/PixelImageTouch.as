package extensions
{
	import flash.geom.Point;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.textures.SubTexture;
	import starling.textures.Texture;
	
	public class PixelImageTouch extends Image
	{
		private var _hitArea:PixelHitArea;
		private var threshold:uint;
		
		public function PixelImageTouch(texture:Texture, hitArea:PixelHitArea = null, threshold:uint = 255)
		{
			super(texture);
			this.hitArea = hitArea;
			this.threshold = threshold;
		}
		
		override public function hitTest(localPoint:Point) : DisplayObject
		{
			var _loc3_:Number = NaN;
			var _loc4_:Number = NaN;
			var _loc2_:SubTexture = null;
			if(getBounds(this).containsPoint(localPoint) && hitArea && !hitArea.disposed)
			{
				_loc3_ = 0;
				_loc4_ = 0;
				if(texture is SubTexture)
				{
					_loc2_ = SubTexture(texture);
					_loc3_ = _loc2_.region.x / _loc2_.parent.width;
					_loc3_ = _loc2_.region.y / _loc2_.parent.height;
				}
				return hitArea.getAlphaPixel(localPoint.x + hitArea.width * _loc3_,localPoint.y + hitArea.height * _loc4_) >= threshold ? this : null;
			}
			return super.hitTest(localPoint);
		}
		
		override public function dispose() : void
		{
			if(hitArea && hitArea.disposed)
			{
				hitArea = null;
			}
			super.dispose();
		}
		
		public function get hitArea() : PixelHitArea
		{
			return _hitArea;
		}
		
		public function set hitArea(value:PixelHitArea) : void
		{
			_hitArea = value;
		}
	}
}

