package extensions {
	import core.scene.Game;
	import flash.geom.Point;
	import starling.animation.IAnimatable;
	import starling.display.DisplayObject;
	import starling.display.Mesh;
	import starling.rendering.IndexData;
	import starling.rendering.VertexData;
	import starling.textures.Texture;
	
	public class RibbonTrail extends Mesh implements IAnimatable {
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
		
		public function RibbonTrail(g:Game, trailSegments:int = 8) {
			this.g = g;
			raiseCapacity(trailSegments);
			super(mVertexData,mIndexData);
			updatevertexData();
			style.textureRepeat = false;
			blendMode = "add";
		}
		
		override public function set color(value:uint) : void {
			vertexData.colorize("color",value);
		}
		
		public function get followingEnable() : Boolean {
			return mFollowingEnable;
		}
		
		public function set followingEnable(value:Boolean) : void {
			mFollowingEnable = value;
		}
		
		public function get isPlaying() : Boolean {
			return mIsPlaying;
		}
		
		public function set isPlaying(value:Boolean) : void {
			mIsPlaying = value;
		}
		
		public function get movingRatio() : Number {
			return mMovingRatio;
		}
		
		public function set movingRatio(value:Number) : void {
			if(mMovingRatio != value) {
				mMovingRatio = value < 0 ? 0 : (value > 1 ? 1 : value);
			}
		}
		
		public function get alphaRatio() : Number {
			return mAlphaRatio;
		}
		
		public function set alphaRatio(value:Number) : void {
			if(mAlphaRatio != value) {
				mAlphaRatio = value < 0 ? 0 : (value > 1 ? 1 : value);
			}
		}
		
		public function get repeat() : Boolean {
			return mRepeat;
		}
		
		public function set repeat(value:Boolean) : void {
			if(mRepeat != value) {
				mRepeat = value;
			}
		}
		
		public function getRibbonSegment(index:int) : RibbonSegment {
			return mRibbonSegments[index];
		}
		
		public function followTrailSegmentsLine(followingRibbonSegmentLine:Vector.<RibbonSegment>) : void {
			mFollowingRibbonSegmentLine = followingRibbonSegmentLine;
		}
		
		public function resetAllTo(x0:Number, y0:Number, x1:Number, y1:Number, alpha:Number = 1) : void {
			var _local7:RibbonSegment = null;
			alphaArray = [];
			if(mNumRibbonSegments > mRibbonSegments.length) {
				return;
			}
			var _local6:int = 0;
			while(_local6 < mNumRibbonSegments) {
				_local7 = mRibbonSegments[_local6];
				_local7.setTo(x0,y0,x1,y1,alpha);
				_local6++;
			}
		}
		
		protected function updatevertexData() : void {
			var _local4:Number = 1 / (mNumRibbonSegments - 1);
			var _local3:Number = 0;
			var _local1:int = 0;
			var _local2:int = 0;
			while(_local2 < mNumRibbonSegments) {
				_local1 = _local2 * 2;
				_local3 = _local2 * _local4;
				if(mRepeat) {
					sMapTexCoords[0] = _local2;
					sMapTexCoords[1] = 0;
					sMapTexCoords[2] = _local2;
					sMapTexCoords[3] = 1;
				} else {
					sMapTexCoords[0] = _local3;
					sMapTexCoords[1] = 0;
					sMapTexCoords[2] = _local3;
					sMapTexCoords[3] = 1;
				}
				setTexCoords(_local1,sMapTexCoords[0],sMapTexCoords[1]);
				setTexCoords(_local1 + 1,sMapTexCoords[2],sMapTexCoords[3]);
				_local2++;
			}
		}
		
		protected function createTrailSegment() : RibbonSegment {
			return new RibbonSegment();
		}
		
		override public function hitTest(localPoint:Point) : DisplayObject {
			return null;
		}
		
		public function advanceTime(passedTime:Number) : void {
			var _local7:RibbonSegment = null;
			var _local4:RibbonSegment = null;
			var _local8:* = null;
			var _local6:Number = NaN;
			if(!mIsPlaying) {
				return;
			}
			var _local5:int = int(!!mFollowingRibbonSegmentLine ? mFollowingRibbonSegmentLine.length : 0);
			if(_local5 == 0) {
				return;
			}
			var _local2:int = 0;
			var _local3:int = 0;
			if(mRibbonSegments.length < mNumRibbonSegments) {
				return;
			}
			while(_local3 < mNumRibbonSegments) {
				_local7 = mRibbonSegments[_local3];
				_local4 = _local3 < _local5 ? mFollowingRibbonSegmentLine[_local3] : null;
				if(_local4) {
					_local7.copyFrom(_local4);
				} else if(mFollowingEnable && _local8) {
					_local7.tweenTo(_local8);
				}
				_local8 = _local7;
				_local2 = _local3 * 2;
				_local6 = _local7.alpha;
				setVertexPosition(_local2,_local7.x0,_local7.y0);
				setVertexPosition(_local2 + 1,_local7.x1,_local7.y1);
				if(alphaArray.length <= _local3) {
					alphaArray.push(_local6);
					setVertexAlpha(_local2,_local6);
					setVertexAlpha(_local2 + 1,_local6);
					alphaArray[_local3] = _local6;
				}
				if(alphaArray[_local3] != _local6) {
					setVertexAlpha(_local2,_local6);
					setVertexAlpha(_local2 + 1,_local6);
					alphaArray[_local3] = _local6;
				}
				_local3++;
			}
		}
		
		public function raiseCapacity(byAmount:int) : void {
			var _local4:RibbonSegment = null;
			var _local2:* = 0;
			var _local5:int = 0;
			var _local3:int = mNumRibbonSegments;
			mNumRibbonSegments = Math.min(8129,_local3 + byAmount);
			mRibbonSegments.fixed = false;
			_local2 = _local3;
			while(_local2 < mNumRibbonSegments) {
				_local4 = createTrailSegment();
				_local4.ribbonTrail = this;
				mRibbonSegments[_local2] = _local4;
				if(_local2 > 0) {
					_local5 = _local2 * 2 - 2;
					mIndexData.addQuad(_local5,_local5 + 1,_local5 + 2,_local5 + 3);
				}
				_local2++;
			}
			mRibbonSegments.fixed = true;
		}
		
		override public function dispose() : void {
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

