package core.hud.components {
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;
	import textures.TextureLocator;
	
	public class SaleSticker extends Sprite {
		public function SaleSticker(caption:String = "", captionBelow:String = "", captionAbove:String = "", color:uint = 14942208, overrideTexture:Texture = null, overrideTextureFB:Texture = null) {
			var _local11:Image = null;
			super();
			var _local10:Image = new Image(overrideTexture == null ? TextureLocator.getService().getTextureGUIByTextureName("sale_sticker") : overrideTexture);
			_local10.pivotX = _local10.texture.width / 2;
			_local10.pivotY = _local10.texture.height / 2;
			_local10.color = color;
			addChild(_local10);
			if(Login.currentState == "facebook") {
				_local11 = new Image(overrideTexture == null ? TextureLocator.getService().getTextureGUIByTextureName("fb_sale_lg") : overrideTextureFB);
				_local11.y = _local10.y + _local10.height / 2 - 45;
				_local11.pivotX = _local11.width / 2;
				_local11.x = _local10.x + 1;
				addChild(_local11);
			}
			var _local7:Text = new Text();
			_local7.size = 36;
			_local7.width = 110;
			_local7.htmlText = caption;
			_local7.centerPivot();
			addChild(_local7);
			var _local9:Text = new Text();
			_local9.size = 18;
			_local9.width = 110;
			_local9.htmlText = captionAbove;
			_local9.y = -_local7.height / 2 - 5;
			_local9.centerPivot();
			addChild(_local9);
			var _local8:Text = new Text();
			_local8.size = 18;
			_local8.width = 110;
			_local8.htmlText = captionBelow;
			_local8.y = _local7.height / 2 + 5;
			_local8.centerPivot();
			addChild(_local8);
		}
	}
}

