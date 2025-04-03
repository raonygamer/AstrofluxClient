package core.hud.components.map
{
	import core.scene.Game;
	import core.solarSystem.Body;
	import starling.display.Image;
	import starling.display.Sprite;
	
	public class MapStation extends MapBodyBase
	{
		public function MapStation(g:Game, container:Sprite, body:Body)
		{
			super(g,container,body);
			layer.useHandCursor = true;
			container.addChild(text);
			addImage();
			addText();
			init();
		}
		
		private function addImage() : void
		{
			var _loc2_:String = body.type.toLowerCase().replace(" ","");
			var _loc1_:Image = new Image(textureManager.getTextureGUIByTextureName("map_" + _loc2_));
			_loc1_.color = body.typeColor;
			imgSelected = new Image(textureManager.getTextureGUIByTextureName("map_" + _loc2_ + "_selected"));
			imgSelected.color = body.selectedTypeColor;
			imgHover = new Image(textureManager.getTextureGUIByTextureName("map_" + _loc2_ + "_hover"));
			imgHover.color = body.selectedTypeColor;
			radius = _loc1_.width / 2;
			layer.addChild(_loc1_);
		}
		
		private function addText() : void
		{
			text.size = 11;
			text.format.color = body.color;
			text.text = body.name;
		}
	}
}

