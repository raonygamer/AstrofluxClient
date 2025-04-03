package
{
	import core.scene.Game;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.UncaughtErrorEvent;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import starling.core.Starling;
	import starling.events.Event;
	import starling.events.ResizeEvent;
	
	public class RymdenRunt extends Sprite
	{
		public static var s:Starling;
		
		public static var origin:String = "not set";
		
		public static var isInFocus:Boolean = true;
		
		public static var instance:RymdenRunt;
		
		public static var info:Object;
		
		public static var isDesktop:Boolean;
		
		public static var isBuggedFlashVersion:Boolean = false;
		
		public static var parameters:Object = {};
		
		public static var partnerSegmentArray:Array = [];
		
		private static var startTime:Date = new Date();
		
		public function RymdenRunt(info:Object = null)
		{
			super();
			RymdenRunt.instance = this;
			if(info)
			{
				RymdenRunt.isDesktop = true;
				RymdenRunt.info = info;
			}
			else if(this.root && this.root.loaderInfo)
			{
				parameters = LoaderInfo(this.root.loaderInfo).parameters;
				if(parameters.origin)
				{
					origin = parameters.origin;
					partnerSegmentArray = ["origin:" + origin];
				}
				else
				{
					origin = "browser";
				}
				if(parameters.fb_action_types)
				{
					partnerSegmentArray.push("fb_action:" + parameters.fb_action_types);
				}
			}
			if(Capabilities.version.indexOf("23,0,0,162") > -1 && Capabilities.os.indexOf("Mac") != -1)
			{
				isBuggedFlashVersion = true;
			}
			if(stage)
			{
				init(null);
			}
			else
			{
				addEventListener("addedToStage",init);
			}
		}
		
		public static function initTimeStamp() : void
		{
			startTime = new Date();
		}
		
		private function init(o:Object) : void
		{
			removeEventListener("addedToStage",init);
			stage.align = "TL";
			stage.scaleMode = "noScale";
			stage.quality = "low";
			stage.frameRate = 60;
			s = new Starling(Login,stage,null,null,"auto","auto");
			s.start();
			s.skipUnchangedFrames = true;
			s.addEventListener("rootCreated",onRootCreated);
			stage.addEventListener("rightClick",function():void
			{
				s.stage.dispatchEventWith("rightClick");
			});
			stage.addEventListener("rightMouseDown",function():void
			{
				s.stage.dispatchEventWith("rightClickDown");
			});
			stage.addEventListener("rightMouseUp",function():void
			{
				s.stage.dispatchEventWith("rightClickUp");
			});
			stage.addEventListener("deactivate",notFocused);
			stage.addEventListener("activate",focused);
			loaderInfo.uncaughtErrorEvents.addEventListener("uncaughtError",onUncaughtError);
		}
		
		private function onUncaughtError(e:UncaughtErrorEvent) : void
		{
			if(!Game.instance || !Game.instance.client)
			{
				throw e;
			}
			var _loc2_:Object = {};
			_loc2_.os = Capabilities.os;
			_loc2_.version = Capabilities.version;
			_loc2_.profile = s.profile;
			_loc2_.origin = RymdenRunt.origin;
			if(Game.instance.me)
			{
				_loc2_.player = Game.instance.me.id;
			}
			Game.instance.client.errorLog.writeError(e.error.toString(),"UncaughtErrorEvent",e.error.getStackTrace(),_loc2_);
			throw e;
		}
		
		private function onRootCreated(e:starling.events.Event, preload:Login) : void
		{
			s.removeEventListener("rootCreated",onRootCreated);
			s.stage.addEventListener("resize",resize);
			resize();
			preload.start();
		}
		
		private function resize(e:ResizeEvent = null) : void
		{
			if(!s.context || s.context.driverInfo == "Disposed")
			{
				return;
			}
			if(stage.stageWidth === 0 || stage.stageHeight === 0)
			{
				return;
			}
			var _loc2_:int = int(stage.stageWidth % 2 == 0 ? stage.stageWidth : stage.stageWidth - 1);
			var _loc3_:int = int(stage.stageHeight % 2 == 0 ? stage.stageHeight : stage.stageHeight - 1);
			s.stage.stageWidth = _loc2_;
			s.stage.stageHeight = _loc3_;
			var _loc4_:Rectangle = s.viewPort;
			_loc4_.width = _loc2_;
			_loc4_.height = _loc3_;
			s.viewPort = _loc4_;
		}
		
		private function notFocused(e:flash.events.Event) : void
		{
			isInFocus = false;
		}
		
		private function focused(e:flash.events.Event) : void
		{
			isInFocus = true;
		}
	}
}

