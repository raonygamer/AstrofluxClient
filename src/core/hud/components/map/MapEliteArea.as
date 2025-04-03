package core.hud.components.map
{
	import core.hud.components.TextBitmap;
	import core.scene.Game;
	import core.solarSystem.Body;
	import flash.display.Sprite;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;
	import textures.TextureManager;
	
	public class MapEliteArea extends MapBodyBase
	{
		public function MapEliteArea(g:Game, container:starling.display.Sprite, body:Body)
		{
			super(g,container,body);
			addImage();
			addOrbits();
			addText();
			layer.touchable = false;
			init();
		}
		
		private function addImage() : void
		{
			var _loc2_:Texture = textureManager.getTextureGUIByTextureName("warning.png");
			var _loc1_:Image = new Image(_loc2_);
			_loc1_.x = -_loc1_.width / 2 - 26;
			_loc1_.y = 15 + body.labelOffset;
			layer.addChild(_loc1_);
		}
		
		override protected function addOrbits() : void
		{
			var _loc2_:flash.display.Sprite = new flash.display.Sprite();
			_loc2_.graphics.beginFill(15636992,0.1);
			_loc2_.graphics.lineStyle(2,15636992,0.3);
			_loc2_.graphics.drawCircle(2,2,body.warningRadius * Map.SCALE);
			_loc2_.graphics.endFill();
			var _loc1_:Image = TextureManager.imageFromSprite(_loc2_,body.key);
			layer.addChild(_loc1_);
		}
		
		private function addText() : void
		{
			var _loc1_:TextBitmap = new TextBitmap();
			_loc1_.text = body.name == "Warning" ? "Elite Zone" : body.name;
			_loc1_.x = -_loc1_.width / 2 + 20;
			_loc1_.y = 15 + body.labelOffset;
			_loc1_.format.color = 15636992;
			_loc1_.touchable = false;
			layer.addChild(_loc1_);
		}
	}
}

