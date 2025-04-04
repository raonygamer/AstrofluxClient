package camerafocus
{
	import camerafocus.events.CameraFocusEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import starling.display.DisplayObject;
	import starling.display.Stage;
	
	public final class StarlingCameraFocus
	{
		private var _stage:Stage;
		private var _stageContainer:DisplayObject;
		private var _focusPosition:Point;
		private var _focusTracker:Point;
		private var _focusOrientation:Point;
		public var _focusCurrentLoc:Point;
		public var speed:Point;
		private var _focusLastLoc:Point;
		private var _focusDistX:Number;
		private var _focusDistY:Number;
		public var focusTarget:Object;
		private var _layersInfo:Dictionary;
		private var _boundaryLayer:DisplayObject;
		private var _switch:Boolean;
		private var _targetLastX:Number;
		private var _targetLastY:Number;
		private var _targetCurrentX:Number;
		private var _targetCurrentY:Number;
		private var _zoomFactor:Number;
		private var _intensity:Number;
		private var _shakeTimer:int;
		private var _shakeDecay:Number;
		public var trackStep:uint;
		public var swapStep:uint;
		public var zoomStep:uint;
		private var _tempStep:uint;
		private var _step:uint;
		public var ignoreLeftBound:Boolean;
		public var ignoreRightBound:Boolean;
		public var ignoreTopBound:Boolean;
		public var ignoreBottomBound:Boolean;
		public var isFocused:Boolean;
		public var isSwaping:Boolean;
		public var isZooming:Boolean;
		public var isShaking:Boolean;
		public var enableCallBack:Boolean;
		private var _boundaryEvent:CameraFocusEvent;
		private var _swapStartedEvent:CameraFocusEvent;
		private var _swapFinishedEvent:CameraFocusEvent;
		private var _zoomStartedEvent:CameraFocusEvent;
		private var _zoomFinishedEvent:CameraFocusEvent;
		private var _shakeStartedEvent:CameraFocusEvent;
		private var _shakeFinishedEvent:CameraFocusEvent;
		private var _upperLeftX:Number;
		private var _upperLeftY:Number;
		private var _lowerRightX:Number;
		private var _lowerRightY:Number;
		
		public function StarlingCameraFocus(aStage:Stage, aStageContainer:DisplayObject, aFocusTarget:Object, aLayersInfo:Array, aAutoStart:Boolean = false)
		{
			super();
			_stage = aStage;
			_stageContainer = aStageContainer;
			_layersInfo = new Dictionary();
			enableCallBack = true;
			focusTarget = aFocusTarget;
			_focusPosition = new Point();
			_focusTracker = new Point();
			_focusTracker.x = focusTarget.x;
			_focusTracker.y = focusTarget.y;
			_focusOrientation = new Point();
			_focusOrientation.x = focusTarget.x;
			_focusOrientation.y = focusTarget.y;
			_focusCurrentLoc = _focusTracker.clone();
			_focusLastLoc = _focusTracker.clone();
			speed = new Point();
			for each(var _loc6_ in aLayersInfo)
			{
				_loc6_.ox = _loc6_.instance.x;
				_loc6_.oy = _loc6_.instance.y;
				_layersInfo[_loc6_.name] = _loc6_;
			}
			_targetLastX = _targetCurrentX = focusTarget.x;
			_targetLastY = _targetCurrentY = focusTarget.y;
			trackStep = 5;
			swapStep = 10;
			zoomStep = 10;
			_step = trackStep;
			_tempStep = trackStep;
			_zoomFactor = _stageContainer.scaleX;
			setFocusPosition(_stage.stageWidth * 0.5,_stage.stageHeight * 0.5);
			setBoundary();
			_boundaryEvent = new CameraFocusEvent("hitBoundary");
			_swapStartedEvent = new CameraFocusEvent("swapStarted");
			_swapFinishedEvent = new CameraFocusEvent("swapFinished");
			_zoomStartedEvent = new CameraFocusEvent("zoomStarted");
			_zoomFinishedEvent = new CameraFocusEvent("zoomFinished");
			_shakeStartedEvent = new CameraFocusEvent("shakeStarted");
			_shakeFinishedEvent = new CameraFocusEvent("shakeFinished");
			if(aAutoStart)
			{
				start();
			}
			else
			{
				pause();
			}
		}
		
		public function get zoomFactor() : Number
		{
			return _zoomFactor;
		}
		
		private function get globalTrackerLoc() : Point
		{
			var _loc1_:Point = null;
			if(focusTarget is Point)
			{
				_loc1_ = _stageContainer.localToGlobal(_focusTracker);
			}
			else if(focusTarget is DisplayObject && focusTarget.parent != null)
			{
				_loc1_ = focusTarget.parent.localToGlobal(_focusTracker);
			}
			else if(focusTarget is DisplayObject)
			{
				_loc1_ = _stageContainer.localToGlobal(_focusTracker);
			}
			return _loc1_;
		}
		
		public function getCameraCenter() : Point
		{
			return _focusCurrentLoc;
		}
		
		public function getLayerByName(aName:String) : DisplayObject
		{
			return _layersInfo[aName].instance;
		}
		
		public function start() : void
		{
			_switch = true;
		}
		
		public function pause() : void
		{
			_switch = false;
		}
		
		public function destroy() : void
		{
			_stage = null;
			_stageContainer = null;
			_boundaryLayer = null;
			_layersInfo = null;
			focusTarget = null;
			_boundaryEvent = null;
			_swapStartedEvent = null;
			_swapFinishedEvent = null;
			_zoomStartedEvent = null;
			_zoomFinishedEvent = null;
			_shakeStartedEvent = null;
			_shakeFinishedEvent = null;
		}
		
		public function setFocusPosition(aX:Number, aY:Number) : void
		{
			_focusPosition.x = aX;
			_focusPosition.y = aY;
		}
		
		public function setBoundary(aLayer:DisplayObject = null) : void
		{
			_boundaryLayer = aLayer;
		}
		
		public function jumpToFocus(aFocusTarget:Object = null) : void
		{
			if(aFocusTarget == null)
			{
				aFocusTarget = focusTarget;
			}
			focusTarget = aFocusTarget;
			_focusCurrentLoc.x = _focusLastLoc.x = _focusTracker.x = aFocusTarget.x;
			_focusCurrentLoc.y = _focusLastLoc.y = _focusTracker.y = aFocusTarget.y;
		}
		
		public function swapFocus(aFocusTarget:Object, aSwapStep:uint = 10, aZoom:Boolean = false, aZoomFactor:Number = 1, aZoomStep:int = 10) : void
		{
			focusTarget = aFocusTarget;
			swapStep = Math.max(1,aSwapStep);
			_tempStep = trackStep;
			_step = swapStep;
			isSwaping = true;
			if(enableCallBack)
			{
				_stage.dispatchEvent(_swapStartedEvent);
			}
			if(aZoom)
			{
				zoomFocus(aZoomFactor,aZoomStep);
			}
		}
		
		public function zoomFocus(aZoomFactor:Number, aZoomStep:uint = 10) : void
		{
			_zoomFactor = Math.max(0,aZoomFactor);
			zoomStep = Math.max(1,aZoomStep);
			isZooming = true;
			if(enableCallBack)
			{
				_stage.dispatchEvent(_zoomStartedEvent);
			}
		}
		
		public function shake(aIntensity:Number, aShakeTimer:int) : void
		{
			_intensity = aIntensity;
			_shakeTimer = aShakeTimer;
			_shakeDecay = aIntensity / aShakeTimer;
			isShaking = true;
			if(enableCallBack)
			{
				_stage.dispatchEvent(_shakeStartedEvent);
			}
		}
		
		public function update() : void
		{
			if(!_switch)
			{
				return;
			}
			if(focusTarget == null)
			{
				speed.x = 0;
				speed.y = 0;
				return;
			}
			_tempStep = trackStep;
			_step = _tempStep;
			if((focusTarget.x - _focusTracker.x) * (focusTarget.y - _focusTracker.y) <= 1000)
			{
				if(isSwaping)
				{
					isSwaping = false;
					if(enableCallBack)
					{
						_stage.dispatchEvent(_swapFinishedEvent);
					}
				}
				isFocused = true;
			}
			else
			{
				isFocused = false;
			}
			speed.x = (focusTarget.x - _focusTracker.x) / _step;
			speed.y = (focusTarget.y - _focusTracker.y) / _step;
			_focusTracker.x += speed.x;
			_focusTracker.y += speed.y;
			_focusLastLoc.x = _focusCurrentLoc.x;
			_focusLastLoc.y = _focusCurrentLoc.y;
			_focusCurrentLoc.x = _focusTracker.x;
			_focusCurrentLoc.y = _focusTracker.y;
			_targetLastX = _targetCurrentX;
			_targetLastY = _targetCurrentY;
			_targetCurrentX = focusTarget.x;
			_targetCurrentY = focusTarget.y;
			if(isZooming)
			{
				_stageContainer.scaleX += (_zoomFactor - _stageContainer.scaleX) / zoomStep;
				_stageContainer.scaleY += (_zoomFactor - _stageContainer.scaleY) / zoomStep;
				if(Math.abs(_stageContainer.scaleX - _zoomFactor) < 0.00001)
				{
					isZooming = false;
					_stageContainer.scaleX = _stageContainer.scaleY = _zoomFactor;
					if(enableCallBack)
					{
						_stage.dispatchEvent(_zoomFinishedEvent);
					}
				}
			}
			positionStageContainer();
			var _loc1_:Object = testBounds();
			positionParallax(_loc1_);
			updateViewRectangle();
			if(isShaking)
			{
				if(_shakeTimer > 0)
				{
					_shakeTimer -= 33;
					if(_shakeTimer <= 0)
					{
						_shakeTimer = 0;
						isShaking = false;
						if(enableCallBack)
						{
							_stage.dispatchEvent(_shakeFinishedEvent);
						}
					}
					else
					{
						_intensity -= _shakeDecay;
						_stageContainer.x = Math.random() * _intensity * _stage.stageWidth * 2 - _intensity * _stage.stageWidth + _stageContainer.x;
						_stageContainer.y = Math.random() * _intensity * _stage.stageHeight * 2 - _intensity * _stage.stageHeight + _stageContainer.y;
					}
				}
			}
		}
		
		private function testBounds() : Object
		{
			var _loc5_:Object = {
				"top":false,
				"bottom":false,
				"left":false,
				"right":false
			};
			if(_boundaryLayer == null)
			{
				return _loc5_;
			}
			var _loc1_:Point = _boundaryLayer.parent.localToGlobal(new Point(_boundaryLayer.x,_boundaryLayer.y));
			var _loc2_:Point = _boundaryLayer.parent.localToGlobal(new Point(_boundaryLayer.x + _boundaryLayer.width,_boundaryLayer.y + _boundaryLayer.height));
			var _loc6_:Number = _loc1_.x;
			var _loc7_:Number = _loc1_.y;
			var _loc3_:Number = _loc2_.x;
			var _loc4_:Number = _loc2_.y;
			if(_loc6_ > 0)
			{
				if(!ignoreLeftBound)
				{
					_stageContainer.x += 0 - _loc6_;
				}
				if(enableCallBack)
				{
					_boundaryEvent.boundary = "left";
					_stage.dispatchEvent(_boundaryEvent);
				}
				_loc5_.left = true;
			}
			if(_loc3_ < _stage.stageWidth)
			{
				if(!ignoreRightBound)
				{
					_stageContainer.x += _stage.stageWidth - _loc3_;
				}
				if(enableCallBack)
				{
					_boundaryEvent.boundary = "right";
					_stage.dispatchEvent(_boundaryEvent);
				}
				_loc5_.right = true;
			}
			if(_loc7_ > 0)
			{
				if(!ignoreTopBound)
				{
					_stageContainer.y += 0 - _loc7_;
				}
				if(enableCallBack)
				{
					_boundaryEvent.boundary = "top";
					_stage.dispatchEvent(_boundaryEvent);
				}
				_loc5_.top = true;
			}
			if(_loc4_ < _stage.stageHeight)
			{
				if(!ignoreBottomBound)
				{
					_stageContainer.y += _stage.stageHeight - _loc4_;
				}
				if(enableCallBack)
				{
					_boundaryEvent.boundary = "bottom";
					_stage.dispatchEvent(_boundaryEvent);
				}
				_loc5_.bottom = true;
			}
			return _loc5_;
		}
		
		private function positionStageContainer() : void
		{
			if(globalTrackerLoc == null)
			{
				return;
			}
			_stageContainer.x += _focusPosition.x - globalTrackerLoc.x;
			_stageContainer.y += _focusPosition.y - globalTrackerLoc.y;
		}
		
		private function positionParallax(aTestResult:Object) : void
		{
			var _loc8_:DisplayObject = null;
			var _loc5_:Number = NaN;
			var _loc4_:Number = NaN;
			var _loc9_:Number = NaN;
			var _loc2_:Number = NaN;
			var _loc3_:Number = NaN;
			var _loc6_:* = aTestResult;
			for each(var _loc7_ in _layersInfo)
			{
				_loc8_ = _loc7_.instance;
				_loc5_ = Number(_loc7_.ox);
				_loc4_ = Number(_loc7_.oy);
				_loc9_ = Number(_loc7_.ratio);
				_loc2_ = (_focusCurrentLoc.x - _focusOrientation.x) * _loc9_;
				_loc3_ = (_focusCurrentLoc.y - _focusOrientation.y) * _loc9_;
				if(!_loc6_.left && _loc2_ <= 0 || !_loc6_.right && _loc2_ >= 0)
				{
					_loc8_.x = _loc5_ + _loc2_;
				}
				if(!_loc6_.top && _loc3_ <= 0 || !_loc6_.bottom && _loc3_ >= 0)
				{
					_loc8_.y = _loc4_ + _loc3_;
				}
			}
		}
		
		private function updateViewRectangle() : void
		{
			_upperLeftX = _focusTracker.x - _stage.stageWidth * 0.5 / _zoomFactor;
			_upperLeftY = _focusTracker.y - _stage.stageHeight * 0.5 / _zoomFactor;
			_lowerRightX = _focusTracker.x + _stage.stageWidth * 0.5 / _zoomFactor;
			_lowerRightY = _focusTracker.y + _stage.stageHeight * 0.5 / _zoomFactor;
		}
		
		public function isCircleOnScreen(x:Number, y:Number, radius:Number) : Boolean
		{
			var _loc6_:Number = x + radius;
			var _loc4_:Number = x - radius;
			var _loc5_:Number = y + radius;
			var _loc7_:Number = y - radius;
			return isOnScreen(_loc6_,_loc5_) || isOnScreen(_loc4_,_loc5_) || isOnScreen(_loc6_,_loc7_) || isOnScreen(_loc4_,_loc7_);
		}
		
		public function isOnScreen(x:Number, y:Number) : Boolean
		{
			return !(x < _upperLeftX || y < _upperLeftY || x > _lowerRightX || y > _lowerRightY);
		}
	}
}

