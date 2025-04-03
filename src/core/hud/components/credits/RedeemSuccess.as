package core.hud.components.credits
{
	import core.hud.components.Style;
	import core.hud.components.dialogs.PopupMessage;
	import core.scene.Game;
	import generics.Localize;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.text.TextFormat;
	
	public class RedeemSuccess extends PopupMessage
	{
		private var container:Sprite;
		
		private var g:Game;
		
		public function RedeemSuccess(g:Game, skin:String)
		{
			var _loc8_:int = 0;
			var _loc9_:int = 0;
			var _loc3_:Image = null;
			container = new Sprite();
			super();
			this.g = g;
			var _loc10_:TextField = new TextField(100,20,"Congratulations you have received\n7 days of",new TextFormat("DAIDRR",14,Style.COLOR_YELLOW));
			_loc10_.autoSize = "bothDirections";
			container.addChild(_loc10_);
			var _loc4_:Array = ["ti_tractor_beam","ti_xp_boost","ti_xp_protection","ti_cargo_protection"];
			var _loc5_:Array = ["Tractor beam","XP boost","XP protection","Cargo protection"];
			_loc8_ = 0;
			_loc9_ = 0;
			while(_loc8_ < 4)
			{
				_loc9_ = _loc8_ * 30 + 50;
				_loc3_ = new Image(g.textureManager.getTextureGUIByTextureName(_loc4_[_loc8_]));
				_loc3_.scaleX = _loc3_.scaleY = 0.5;
				_loc3_.y = _loc9_;
				container.addChild(_loc3_);
				_loc10_ = new TextField(100,_loc3_.height,Localize.t(_loc5_[_loc8_]));
				_loc10_.format.color = 0xffffff;
				_loc10_.autoSize = "horizontal";
				_loc10_.x = 30;
				_loc10_.y = _loc3_.y;
				container.addChild(_loc10_);
				_loc8_++;
			}
			_loc10_ = new TextField(100,20,Localize.t("And and new ship has \nbeen added to your fleet."),new TextFormat("DAIDRR",14,Style.COLOR_YELLOW));
			_loc10_.y = _loc9_ + 50;
			_loc10_.autoSize = "bothDirections";
			container.addChild(_loc10_);
			var _loc6_:Object = g.dataManager.loadKey("Skins",skin);
			var _loc11_:Object = g.dataManager.loadKey("Ships",_loc6_.ship);
			var _loc7_:Object = g.dataManager.loadKey("Images",_loc11_.bitmap);
			_loc3_ = new Image(g.textureManager.getTextureMainByTextureName(_loc7_.textureName + "1"));
			_loc3_.y = _loc10_.y + _loc10_.height + 10;
			container.addChild(_loc3_);
			_loc10_ = new TextField(100,_loc3_.height,_loc6_.name);
			_loc10_.x = _loc3_.width + 5;
			_loc10_.y = _loc3_.y;
			_loc10_.format.color = 0xffffff;
			_loc10_.autoSize = "horizontal";
			container.addChild(_loc10_);
			container.x = 10;
			box.addChild(container);
			this.textField.height = container.height;
		}
		
		override protected function redraw(e:Event = null) : void
		{
			if(stage == null)
			{
				return;
			}
			var _loc2_:int = container.width + 25;
			closeButton.y = Math.round(container.height + 25);
			closeButton.x = Math.round(_loc2_ / 2 - closeButton.width / 2);
			var _loc3_:int = closeButton.y + closeButton.height - 3;
			box.width = _loc2_;
			box.height = _loc3_;
			box.x = Math.round(stage.stageWidth / 2 - box.width / 2);
			box.y = Math.round(stage.stageHeight / 2 - box.height / 2);
			bgr.width = stage.stageWidth;
			bgr.height = stage.stageHeight;
		}
	}
}

