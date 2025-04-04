package core.hud.components.pvp
{
	import core.player.Player;
	import core.scene.Game;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import starling.display.Image;
	import textures.ITextureManager;
	import textures.TextureLocator;
	import textures.TextureManager;
	
	public class TeamSafeZone
	{
		private var textureManager:ITextureManager;
		public var zoneRadius:Number = 350;
		public var team:int = -1;
		private var g:Game;
		private var friendlyZone:Image;
		private var enemyZone:Image;
		private var img:Image;
		public var friendlyColor:uint = 255;
		public var enemyColor:uint = 16711680;
		public var x:int;
		public var y:int;
		
		public function TeamSafeZone(g:Game, obj:Object, team:int)
		{
			super();
			textureManager = TextureLocator.getService();
			this.g = g;
			this.team = team;
			this.x = obj.x;
			this.y = obj.y;
			friendlyZone = createZoneImg(obj,friendlyColor,"tsf_friendly");
			enemyZone = createZoneImg(obj,enemyColor,"tsf_enemy");
			img = new Image(textureManager.getTextureByTextureName("warpGate","texture_body.png"));
			img.x = friendlyZone.x - img.width / 2;
			img.y = friendlyZone.y - img.height / 2 + 8;
			img.alpha = 1;
			enemyZone.alpha = 1;
			this.g.addChildToCanvasAt(enemyZone,7);
			friendlyZone.alpha = 0;
			this.g.addChildToCanvasAt(friendlyZone,8);
			this.g.addChildToCanvasAt(img,9);
		}
		
		public function updateZone() : void
		{
			var _loc2_:Number = NaN;
			var _loc3_:Number = NaN;
			var _loc4_:Number = NaN;
			if(g.me.team == team)
			{
				friendlyZone.alpha = 1;
				enemyZone.alpha = 0;
			}
			else
			{
				friendlyZone.alpha = 0;
				enemyZone.alpha = 1;
			}
			for each(var _loc1_ in g.playerManager.players)
			{
				if(_loc1_.ship != null && _loc1_.team > -1 && _loc1_.team == team)
				{
					_loc2_ = _loc1_.ship.pos.x - x;
					_loc3_ = _loc1_.ship.pos.y - y;
					_loc4_ = _loc2_ * _loc2_ + _loc3_ * _loc3_;
					if(_loc4_ < zoneRadius * zoneRadius)
					{
						_loc1_.inSafeZone = true;
					}
				}
			}
		}
		
		private function createZoneImg(obj:Object, colour:uint, name:String) : Image
		{
			var _loc6_:Image = null;
			var _loc5_:Sprite = new Sprite();
			_loc5_.graphics.lineStyle(1,colour,0.2);
			var _loc7_:String = "radial";
			var _loc10_:Array = [0,colour];
			var _loc8_:Array = [0,0.4];
			var _loc9_:Array = [0,255];
			var _loc4_:Matrix = new Matrix();
			_loc4_.createGradientBox(2 * zoneRadius,2 * zoneRadius,0,-zoneRadius,-zoneRadius);
			_loc5_.graphics.beginGradientFill(_loc7_,_loc10_,_loc8_,_loc9_,_loc4_);
			_loc5_.graphics.drawCircle(0,0,zoneRadius);
			_loc5_.graphics.endFill();
			_loc6_ = TextureManager.imageFromSprite(_loc5_,name);
			_loc6_.x = x;
			_loc6_.y = y;
			_loc6_.pivotX = _loc6_.width / 2;
			_loc6_.pivotY = _loc6_.height / 2;
			_loc6_.scaleX = 1;
			_loc6_.scaleY = 1;
			_loc6_.alpha = 0.25;
			_loc6_.blendMode = "add";
			return _loc6_;
		}
	}
}

