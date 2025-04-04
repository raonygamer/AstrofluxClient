package core.spawner
{
	import core.scene.Game;
	import starling.textures.Texture;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class OrganicSpawner extends Spawner
	{
		private static const NR_OF_INACTIVE_FRAMES:int = 7;
		private var dmgTile:int = -1;
		private var dmgTileDuration:int = 1000;
		private var dmgTileNextReduction:Number = 0;
		private var inactiveTexturesArray:Vector.<Vector.<Texture>>;
		
		public function OrganicSpawner(g:Game)
		{
			super(g);
			inactiveTexturesArray = new Vector.<Vector.<Texture>>();
		}
		
		override public function update() : void
		{
			var _loc1_:int = 0;
			super.update();
			if(alive && _textures.length > 0 && inactiveTexturesArray.length > 0)
			{
				if(dmgTile <= 7 - 1 && dmgTile > -1)
				{
					_loc1_ = 7 - 1 - dmgTile;
					if(_loc1_ > inactiveTexturesArray.length - 1)
					{
						_loc1_ = inactiveTexturesArray.length - 1;
					}
					changeStateTextures(inactiveTexturesArray[_loc1_]);
				}
				if(dmgTileNextReduction < g.time)
				{
					if(dmgTile > -1)
					{
						dmgTile--;
					}
					if(dmgTile == -1)
					{
						changeStateTextures(_textures,true);
					}
					dmgTileNextReduction = g.time + dmgTileDuration;
				}
			}
		}
		
		override public function switchTexturesByObj(obj:Object, textureAtlas:String = "texture_main_NEW.png") : void
		{
			var _loc4_:* = undefined;
			var _loc5_:* = undefined;
			super.switchTexturesByObj(obj,textureAtlas);
			var _loc6_:ITextureManager = TextureLocator.getService();
			if(imgObj != null)
			{
				_loc4_ = _loc6_.getTexturesMainByTextureName(imgObj.textureName.replace("active","inactive"));
				for each(var _loc3_ in _loc4_)
				{
					_loc5_ = new Vector.<Texture>();
					_loc5_.push(_loc3_);
					inactiveTexturesArray.push(_loc5_);
				}
			}
		}
		
		override public function takeDamage(dmg:int) : void
		{
			if(dmgTile < 6)
			{
				dmgTile++;
			}
			super.takeDamage(dmg);
		}
	}
}

