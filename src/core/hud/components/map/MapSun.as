package core.hud.components.map
{
	import core.scene.Game;
	import core.solarSystem.Body;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;
	
	public class MapSun extends MapBodyBase
	{
		public function MapSun(g:Game, container:Sprite, body:Body)
		{
			super(g,container,body);
			layer.touchable = false;
			addImage();
			addOrbits();
			init();
		}
		
		private function addImage() : void
		{
			layer.touchable = false;
			var _loc2_:Texture = textureManager.getTextureGUIByTextureName("map_sun.png");
			radius = _loc2_.width / 2;
			var _loc1_:Image = new Image(_loc2_);
			if(body.name == "Black Hole")
			{
				_loc1_.color = 0x6600ff;
			}
			layer.addChild(_loc1_);
		}
	}
}

