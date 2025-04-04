package io
{
	import core.scene.Game;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.utils.Dictionary;
	import starling.core.Starling;
	import starling.display.Stage;
	import starling.events.Event;
	import starling.events.TouchEvent;
	
	public class InputManager implements IInput
	{
		private var _isMousePressed:Boolean;
		private var _isRightMousePressed:Boolean = false;
		private var downKeys:Dictionary;
		private var pressedKeys:Dictionary;
		private var releasedKeys:Dictionary;
		private var mouseHasMoved:Boolean;
		private var prevMouseX:Number;
		private var prevMouseY:Number;
		private var stage:Stage;
		private var listedListenerKeys:Array = [];
		
		public function InputManager(stage:Stage)
		{
			super();
			this.stage = stage;
			pressedKeys = new Dictionary();
			releasedKeys = new Dictionary();
			downKeys = new Dictionary();
			Starling.current.nativeStage.addEventListener("keyDown",keyDown,false,10000);
			Starling.current.nativeStage.addEventListener("keyUp",keyUp,false,10000);
			stage.addEventListener("touch",onTouch);
			Starling.current.nativeStage.addEventListener("mouseFocusChange",focusChange);
			Starling.current.nativeStage.addEventListener("keyFocusChange",focusChange);
			stage.addEventListener("rightClickDown",rightMouseDown);
			stage.addEventListener("rightClickUp",rightMouseUp);
		}
		
		public function reset() : void
		{
			for(var _loc1_ in releasedKeys)
			{
				releasedKeys[_loc1_] = false;
			}
			for(_loc1_ in pressedKeys)
			{
				pressedKeys[_loc1_] = false;
			}
		}
		
		private function focusChange(e:FocusEvent) : void
		{
			e.preventDefault();
		}
		
		private function rightMouseDown(e:Event) : void
		{
			Game.playerPerformedAction();
			_isRightMousePressed = true;
		}
		
		private function rightMouseUp(e:Event) : void
		{
			_isRightMousePressed = false;
		}
		
		private function mouseDown(e:TouchEvent) : void
		{
			Game.playerPerformedAction();
			if(e.target is Stage)
			{
				_isMousePressed = true;
			}
		}
		
		private function mouseUp(e:TouchEvent) : void
		{
			_isMousePressed = false;
		}
		
		private function onTouch(e:TouchEvent) : void
		{
			Game.playerPerformedAction();
			if(e.getTouch(stage,"began"))
			{
				mouseDown(e);
			}
			else if(e.getTouch(stage,"ended"))
			{
				mouseUp(e);
			}
			mouseHasMoved = !!e.getTouch(stage,"moved") ? true : false;
		}
		
		private function keyDown(e:KeyboardEvent) : void
		{
			var _loc3_:Array = null;
			Game.playerPerformedAction();
			if(!isKeyDown(e.keyCode))
			{
				downKeys[e.keyCode] = true;
				pressedKeys[e.keyCode] = true;
				for each(var _loc2_ in listedListenerKeys)
				{
					_loc3_ = _loc2_[0];
					for each(var _loc4_ in _loc3_)
					{
						if(_loc4_ == e.keyCode)
						{
							_loc2_[1]();
							listedListenerKeys.splice(listedListenerKeys.indexOf(_loc2_),1);
							return;
						}
					}
				}
			}
			e.stopPropagation();
		}
		
		private function keyUp(e:KeyboardEvent) : void
		{
			downKeys[e.keyCode] = false;
			releasedKeys[e.keyCode] = true;
			e.stopPropagation();
		}
		
		public function get isMousePressed() : Boolean
		{
			return _isMousePressed;
		}
		
		public function get isMouseRightPressed() : Boolean
		{
			return _isRightMousePressed;
		}
		
		public function isAnyKeyPressed() : Boolean
		{
			for(var _loc1_ in pressedKeys)
			{
				if(pressedKeys[_loc1_])
				{
					return true;
				}
			}
			return false;
		}
		
		public function hasMouseMoved() : Boolean
		{
			return mouseHasMoved;
		}
		
		public function isKeyPressed(keyCode:uint) : Boolean
		{
			return pressedKeys[keyCode];
		}
		
		public function isKeyReleased(keyCode:uint) : Boolean
		{
			return releasedKeys[keyCode];
		}
		
		public function isKeyDown(keyCode:uint) : Boolean
		{
			return downKeys[keyCode];
		}
		
		public function isKeyUp(keyCode:uint) : Boolean
		{
			return !isKeyDown(keyCode);
		}
		
		public function listenToKeys(keys:Array, callback:Function) : void
		{
			if(callback == null)
			{
				return;
			}
			if(keys == null || keys.length == 0)
			{
				return;
			}
			listedListenerKeys.push([keys,callback]);
		}
		
		public function stopListenToKeys(callback:Function) : void
		{
			var _loc2_:int = 0;
			var _loc3_:Array = null;
			if(callback == null)
			{
				return;
			}
			var _loc4_:int = int(listedListenerKeys.length);
			_loc2_ = _loc4_ - 1;
			while(_loc2_ > -1)
			{
				_loc3_ = listedListenerKeys[_loc2_];
				if(_loc3_[1] == callback)
				{
					listedListenerKeys.splice(listedListenerKeys.indexOf(_loc3_),1);
				}
				_loc2_--;
			}
		}
		
		public function dispose() : void
		{
			listedListenerKeys = [];
		}
	}
}

