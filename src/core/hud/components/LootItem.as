package core.hud.components
{
	import data.DataLocator;
	import data.IDataManager;
	import playerio.DatabaseObject;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class LootItem extends Sprite
	{
		private var dataManager:IDataManager;
		
		private var textureManager:ITextureManager;
		
		private var obj:DatabaseObject;
		
		private var image:Image;
		
		private var bgr:Quad;
		
		public function LootItem(table:String, item:String, amount:int, size:int = 12)
		{
			var _loc6_:TextBitmap = null;
			bgr = new Quad(230,32,1450513);
			super();
			dataManager = DataLocator.getService();
			textureManager = TextureLocator.getService();
			var _loc7_:Object = dataManager.loadKey(table,item);
			var _loc8_:String = "";
			if(table == "Weapons")
			{
				_loc8_ = _loc7_.techIcon;
			}
			else
			{
				_loc8_ = _loc7_.bitmap;
			}
			addChild(bgr);
			image = new Image(textureManager.getTextureGUIByKey(_loc8_));
			image.x = 16;
			image.y = 16;
			image.pivotX = Math.round(image.width / 2);
			image.pivotY = Math.round(image.height / 2);
			addChild(image);
			var _loc5_:TextBitmap = new TextBitmap(35,8);
			_loc5_.text = _loc7_.name;
			_loc5_.format.color = 0x666666;
			_loc5_.size = 12;
			addChild(_loc5_);
			if(table == "Weapons")
			{
				_loc5_.size = size + 4;
			}
			if(table != "Weapons")
			{
				_loc6_ = new TextBitmap(0,5);
				_loc6_.text = amount.toString();
				_loc6_.format.color = 0xffffff;
				_loc6_.size = 16;
				_loc6_.alignRight();
				_loc6_.x = 220;
				addChild(_loc6_);
			}
		}
	}
}

