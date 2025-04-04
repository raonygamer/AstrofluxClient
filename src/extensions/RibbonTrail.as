package extensions
{
	import core.scene.Game;
	import flash.geom.Point;
	import starling.animation.IAnimatable;
	import starling.display.DisplayObject;
	import starling.display.Mesh;
	import starling.rendering.IndexData;
	import starling.rendering.VertexData;
	import starling.textures.Texture;
	
	public class RibbonTrail extends Mesh implements IAnimatable
	{
		private static var sRenderAlpha:Vector.<Number> = new <Number>[1,1,1,1];
		private static var sMapTexCoords:Vector.<Number> = new <Number>[0,0,0,0];
		protected var mVertexData:VertexData = new VertexData();
		protected var mIndexData:IndexData = new IndexData();
		protected var mTexture:Texture;
		protected var mRibbonSegments:Vector.<RibbonSegment> = new Vector.<RibbonSegment>(0);
		protected var mNumRibbonSegments:int;
		protected var mFollowingEnable:Boolean = true;
		protected var mMovingRatio:Number = 0.5;
		protected var mAlphaRatio:Number = 0.95;
		protected var mRepeat:Boolean = false;
		protected var mIsPlaying:Boolean = false;
		protected var mFollowingRibbonSegmentLine:Vector.<RibbonSegment>;
		protected var g:Game;
		protected var alphaArray:Array = [];
		
		public function RibbonTrail(g:Game, trailSegments:int = 8)
		{
			this.g = g;
			raiseCapacity(trailSegments);
			super(mVertexData,mIndexData);
			updatevertexData();
			style.textureRepeat = false;
			blendMode = "add";
		}
		
		override public function set color(value:uint) : void
		{
			vertexData.colorize("color",value);
		}
		
		public function get followingEnable() : Boolean
		{
			return mFollowingEnable;
		}
		
		public function set followingEnable(value:Boolean) : void
		{
			mFollowingEnable = value;
		}
		
		public function get isPlaying() : Boolean
		{
			return mIsPlaying;
		}
		
		public function set isPlaying(value:Boolean) : void
		{
			mIsPlaying = value;
		}
		
		public function get movingRatio() : Number
		{
			return mMovingRatio;
		}
		
		public function set movingRatio(value:Number) : void
		{
			if(mMovingRatio != value)
			{
				mMovingRatio = value < 0 ? 0 : (value > 1 ? 1 : value);
			}
		}
		
		public function get alphaRatio() : Number
		{
			return mAlphaRatio;
		}
		
		public function set alphaRatio(value:Number) : void
		{
			if(mAlphaRatio != value)
			{
				mAlphaRatio = value < 0 ? 0 : (value > 1 ? 1 : value);
			}
		}
		
		public function get repeat() : Boolean
		{
			return mRepeat;
		}
		
		public function set repeat(value:Boolean) : void
		{
			if(mRepeat != value)
			{
				mRepeat = value;
			}
		}
		
		public function getRibbonSegment(index:int) : RibbonSegment
		{
			return mRibbonSegments[index];
		}
		
		public function followTrailSegmentsLine(followingRibbonSegmentLine:Vector.<RibbonSegment>) : void
		{
			mFollowingRibbonSegmentLine = followingRibbonSegmentLine;
		}
		
		public function resetAllTo(x0:Number, y0:Number, x1:Number, y1:Number, alpha:Number = 1) : void
		{
			var _loc6_:RibbonSegment = null;
			alphaArray = [];
			if(mNumRibbonSegments > mRibbonSegments.length)
			{
				return;
			}
			var _loc7_:int = 0;
			while(_loc7_ < mNumRibbonSegments)
			{
				_loc6_ = mRibbonSegments[_loc7_];
				_loc6_.setTo(x0,y0,x1,y1,alpha);
				_loc7_++;
			}
		}
		
		protected function updatevertexData() : void
		{
			var _loc1_:Number = 1 / (mNumRibbonSegments - 1);
			var _loc4_:Number = 0;
			var _loc2_:int = 0;
			var _loc3_:int = 0;
			while(_loc3_ < mNumRibbonSegments)
			{
				_loc2_ = _loc3_ * 2;
				_loc4_ = _loc3_ * _loc1_;
				if(mRepeat)
				{
					sMapTexCoords[0] = _loc3_;
					sMapTexCoords[1] = 0;
					sMapTexCoords[2] = _loc3_;
					sMapTexCoords[3] = 1;
				}
				else
				{
					sMapTexCoords[0] = _loc4_;
					sMapTexCoords[1] = 0;
					sMapTexCoords[2] = _loc4_;
					sMapTexCoords[3] = 1;
				}
				setTexCoords(_loc2_,sMapTexCoords[0],sMapTexCoords[1]);
				setTexCoords(_loc2_ + 1,sMapTexCoords[2],sMapTexCoords[3]);
				_loc3_++;
			}
		}
		
		protected function createTrailSegment() : RibbonSegment
		{
			return new RibbonSegment();
		}
		
		override public function hitTest(localPoint:Point) : DisplayObject
		{
			return null;
		}
		
		public function advanceTime(passedTime:Number) : void
		{
			var _loc3_:RibbonSegment = null;
			var _loc8_:RibbonSegment = null;
			var _loc5_:* = null;
			var _loc6_:Number = NaN;
			if(!mIsPlaying)
			{
				return;
			}
			var _loc7_:int = int(!!mFollowingRibbonSegmentLine ? mFollowingRibbonSegmentLine.length : 0);
			if(_loc7_ == 0)
			{
				return;
			}
			var _loc2_:int = 0;
			var _loc4_:int = 0;
			if(mRibbonSegments.length < mNumRibbonSegments)
			{
				return;
			}
			while(_loc4_ < mNumRibbonSegments)
			{
				_loc3_ = mRibbonSegments[_loc4_];
				_loc8_ = _loc4_ < _loc7_ ? mFollowingRibbonSegmentLine[_loc4_] : null;
				if(_loc8_)
				{
					_loc3_.copyFrom(_loc8_);
				}
				else if(mFollowingEnable && _loc5_)
				{
					_loc3_.tweenTo(_loc5_);
				}
				_loc5_ = _loc3_;
				_loc2_ = _loc4_ * 2;
				_loc6_ = _loc3_.alpha;
				setVertexPosition(_loc2_,_loc3_.x0,_loc3_.y0);
				setVertexPosition(_loc2_ + 1,_loc3_.x1,_loc3_.y1);
				if(alphaArray.length <= _loc4_)
				{
					alphaArray.push(_loc6_);
					setVertexAlpha(_loc2_,_loc6_);
					setVertexAlpha(_loc2_ + 1,_loc6_);
					alphaArray[_loc4_] = _loc6_;
				}
				if(alphaArray[_loc4_] != _loc6_)
				{
					setVertexAlpha(_loc2_,_loc6_);
					setVertexAlpha(_loc2_ + 1,_loc6_);
					alphaArray[_loc4_] = _loc6_;
				}
				_loc4_++;
			}
		}
		
		public function raiseCapacity(byAmount:int) : void
		{
			var _loc3_:RibbonSegment = null;
			var _loc4_:* = 0;
			var _loc5_:int = 0;
			var _loc2_:int = mNumRibbonSegments;
			mNumRibbonSegments = Math.min(8129,_loc2_ + byAmount);
			mRibbonSegments.fixed = false;
			_loc4_ = _loc2_;
			while(_loc4_ < mNumRibbonSegments)
			{
				_loc3_ = createTrailSegment();
				_loc3_.ribbonTrail = this;
				mRibbonSegments[_loc4_] = _loc3_;
				if(_loc4_ > 0)
				{
					_loc5_ = _loc4_ * 2 - 2;
					mIndexData.addQuad(_loc5_,_loc5_ + 1,_loc5_ + 2,_loc5_ + 3);
				}
				_loc4_++;
			}
			mRibbonSegments.fixed = true;
		}
		
		override public function dispose() : void
		{
			super.dispose();
			mVertexData.clear();
			mVertexData = null;
			mIndexData.clear();
			mIndexData = null;
			mFollowingRibbonSegmentLine = null;
			mFollowingEnable = false;
			mTexture = null;
			mRibbonSegments = null;
			mIsPlaying = false;
			mNumRibbonSegments = 0;
		}
	}
}

