package core.hud.components {
	import core.scene.Game;
	import debug.Console;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.system.Capabilities;
	import starling.core.Starling;
	
	public class FullScreenButton extends Sprite {
		private var hoverImage:Sprite = new Sprite();
		
		public function FullScreenButton() {
			super();
			tabChildren = false;
			tabEnabled = false;
			graphics.beginFill(1842461);
			graphics.lineStyle(1,4409416);
			graphics.drawRoundRect(0,0,22,25,4,4);
			graphics.beginFill(0xc6c6c6);
			graphics.lineStyle(0,0);
			graphics.drawRoundRect(3,8,16,12,2,2);
			graphics.beginFill(0);
			graphics.drawRoundRect(6,12,10,4,2,2);
			graphics.endFill();
			hoverImage.graphics.beginFill(1842461);
			hoverImage.graphics.lineStyle(1,4409416);
			hoverImage.graphics.drawRoundRect(0,0,22,25,4,4);
			hoverImage.graphics.beginFill(0xc6c6c6);
			hoverImage.graphics.lineStyle(0,0);
			hoverImage.graphics.drawRoundRect(3,8,16,12,2,2);
			hoverImage.graphics.beginFill(0);
			hoverImage.graphics.drawRoundRect(6,12,10,4,2,2);
			hoverImage.graphics.endFill();
			hoverImage.blendMode = "add";
			hoverImage.visible = false;
			addChild(hoverImage);
			addEventListener("click",onFullscreen);
			addEventListener("mouseOver",function(param1:MouseEvent):void {
				hoverImage.visible = true;
			});
			addEventListener("mouseOut",function(param1:MouseEvent):void {
				hoverImage.visible = false;
			});
			this.buttonMode = true;
			this.useHandCursor = true;
		}
		
		public function onFullscreen(e:MouseEvent) : void {
			var _local4:* = Starling.current.nativeStage.displayState == "fullScreenInteractive";
			_local4 = !_local4;
			var _local3:String = Capabilities.version;
			var _local7:Array = _local3.split(" ");
			var _local2:Array = _local7[1].split(",");
			var _local6:String = _local7[0];
			var _local5:Number = Number(_local2[0]);
			_local5 = _local5 + _local2[1] / 10;
			if(_local4 && _local5 >= 1.3) {
				Starling.current.nativeStage.displayState = "fullScreenInteractive";
			} else if(_local4) {
				Console.write("You need flash version 11.3");
			} else {
				Starling.current.nativeStage.displayState = "normal";
			}
			Game.instance.hud.resize();
			Game.instance.hud.removeFullScreenHint();
		}
	}
}

