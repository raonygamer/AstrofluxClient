package core.hud.components.credits {
	import core.hud.components.Style;
	import core.hud.components.dialogs.PopupMessage;
	import core.scene.Game;
	import generics.Localize;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.text.TextFormat;
	
	public class RedeemSuccess extends PopupMessage {
		private var container:Sprite;
		private var g:Game;
		
		public function RedeemSuccess(g:Game, skin:String) {
			var _local11:int = 0;
			var _local10:int = 0;
			var _local8:Image = null;
			container = new Sprite();
			super();
			this.g = g;
			var _local5:TextField = new TextField(100,20,"Congratulations you have received\n7 days of",new TextFormat("DAIDRR",14,Style.COLOR_YELLOW));
			_local5.autoSize = "bothDirections";
			container.addChild(_local5);
			var _local9:Array = ["ti_tractor_beam","ti_xp_boost","ti_xp_protection","ti_cargo_protection"];
			var _local3:Array = ["Tractor beam","XP boost","XP protection","Cargo protection"];
			_local11 = 0;
			_local10 = 0;
			while(_local11 < 4) {
				_local10 = _local11 * 30 + 50;
				_local8 = new Image(g.textureManager.getTextureGUIByTextureName(_local9[_local11]));
				_local8.scaleX = _local8.scaleY = 0.5;
				_local8.y = _local10;
				container.addChild(_local8);
				_local5 = new TextField(100,_local8.height,Localize.t(_local3[_local11]));
				_local5.format.color = 0xffffff;
				_local5.autoSize = "horizontal";
				_local5.x = 30;
				_local5.y = _local8.y;
				container.addChild(_local5);
				_local11++;
			}
			_local5 = new TextField(100,20,Localize.t("And and new ship has \nbeen added to your fleet."),new TextFormat("DAIDRR",14,Style.COLOR_YELLOW));
			_local5.y = _local10 + 50;
			_local5.autoSize = "bothDirections";
			container.addChild(_local5);
			var _local6:Object = g.dataManager.loadKey("Skins",skin);
			var _local7:Object = g.dataManager.loadKey("Ships",_local6.ship);
			var _local4:Object = g.dataManager.loadKey("Images",_local7.bitmap);
			_local8 = new Image(g.textureManager.getTextureMainByTextureName(_local4.textureName + "1"));
			_local8.y = _local5.y + _local5.height + 10;
			container.addChild(_local8);
			_local5 = new TextField(100,_local8.height,_local6.name);
			_local5.x = _local8.width + 5;
			_local5.y = _local8.y;
			_local5.format.color = 0xffffff;
			_local5.autoSize = "horizontal";
			container.addChild(_local5);
			container.x = 10;
			box.addChild(container);
			this.textField.height = container.height;
		}
		
		override protected function redraw(e:Event = null) : void {
			if(stage == null) {
				return;
			}
			var _local2:int = container.width + 25;
			closeButton.y = Math.round(container.height + 25);
			closeButton.x = Math.round(_local2 / 2 - closeButton.width / 2);
			var _local3:int = closeButton.y + closeButton.height - 3;
			box.width = _local2;
			box.height = _local3;
			box.x = Math.round(stage.stageWidth / 2 - box.width / 2);
			box.y = Math.round(stage.stageHeight / 2 - box.height / 2);
			bgr.width = stage.stageWidth;
			bgr.height = stage.stageHeight;
		}
	}
}

