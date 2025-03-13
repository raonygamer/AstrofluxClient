package core.hud.components.map {
	import core.scene.Game;
	import core.solarSystem.Body;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;
	
	public class MapSun extends MapBodyBase {
		public function MapSun(g:Game, container:Sprite, body:Body) {
			super(g,container,body);
			layer.touchable = false;
			addImage();
			addOrbits();
			init();
		}
		
		private function addImage() : void {
			layer.touchable = false;
			var _local1:Texture = textureManager.getTextureGUIByTextureName("map_sun.png");
			radius = _local1.width / 2;
			var _local2:Image = new Image(_local1);
			if(body.name == "Black Hole") {
				_local2.color = 0x6600ff;
			}
			layer.addChild(_local2);
		}
	}
}

