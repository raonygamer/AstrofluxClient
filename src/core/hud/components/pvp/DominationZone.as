package core.hud.components.pvp
{
	import com.greensock.TweenMax;
	import core.scene.Game;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import starling.display.Image;
	import textures.ITextureManager;
	import textures.TextureLocator;
	import textures.TextureManager;
	
	public class DominationZone
	{
		private var textureManager:ITextureManager;
		
		public var zoneRadius:Number = 250;
		
		public var id:int;
		
		public var name:String = "";
		
		public var ownerTeam:int;
		
		public var capCounter:int;
		
		public var nrTeam:Vector.<int> = new Vector.<int>();
		
		private var g:Game;
		
		private var friendlyZone:Image;
		
		private var neutralZone:Image;
		
		private var enemyZone:Image;
		
		private var img:Image;
		
		public var friendlyColor:uint = 255;
		
		public var neutralColor:uint = 16777215;
		
		public var enemyColor:uint = 16711680;
		
		public var x:int;
		
		public var y:int;
		
		private var oldCapCounter:int = 0;
		
		public var status:int = 0;
		
		public const STATUS_IDLE:int = 0;
		
		public const STATUS_MY_TEAM_ASSAULTING:int = 1;
		
		public const STATUS_OPPONENT_TEAM_ASSAULTING:int = 2;
		
		public function DominationZone(g:Game, obj:Object, id:int)
		{
			super();
			textureManager = TextureLocator.getService();
			this.g = g;
			this.id = id;
			nrTeam.push(0);
			nrTeam.push(0);
			this.x = obj.x;
			this.y = obj.y;
			friendlyZone = createZoneImg(obj,friendlyColor,"friendly");
			neutralZone = createZoneImg(obj,neutralColor,"neutral");
			enemyZone = createZoneImg(obj,enemyColor,"enemy");
			img = new Image(textureManager.getTextureByTextureName("piratebay","texture_body.png"));
			img.x = neutralZone.x - img.width / 2;
			img.y = neutralZone.y - img.height / 2 + 8;
			img.alpha = 1;
			this.g.addChildToCanvasAt(img,6);
			neutralZone.alpha = 0.25;
			this.g.addChildToCanvasAt(neutralZone,7);
			friendlyZone.alpha = 1;
			friendlyZone.scaleX = 0;
			friendlyZone.scaleY = 0;
			this.g.addChildToCanvasAt(friendlyZone,8);
			enemyZone.alpha = 1;
			enemyZone.scaleX = 0;
			enemyZone.scaleY = 0;
			this.g.addChildToCanvasAt(enemyZone,9);
			if(id == 3)
			{
				name = "Alpha Station";
			}
			else if(id == 1)
			{
				name = "Beta Station";
			}
			else if(id == 2)
			{
				name = "Gamma Station";
			}
			else if(id == 3)
			{
				name = "Delta Station";
			}
			else
			{
				name = "Epsilon Station";
			}
		}
		
		public function updateZone() : void
		{
			if(g.me == null)
			{
				return;
			}
			var _loc1_:int = g.me.team;
			var _loc2_:Number = Math.abs(capCounter / 10);
			if(_loc1_ == 0 && capCounter < 0 || _loc1_ == 1 && capCounter > 0)
			{
				TweenMax.to(enemyZone,1,{"scaleX":0});
				TweenMax.to(enemyZone,1,{"scaleY":0});
				TweenMax.to(friendlyZone,1,{"scaleX":_loc2_});
				TweenMax.to(friendlyZone,1,{"scaleY":_loc2_});
			}
			else if(_loc1_ == 0 && capCounter > 0 || _loc1_ == 1 && capCounter < 0)
			{
				TweenMax.to(friendlyZone,1,{"scaleX":0});
				TweenMax.to(friendlyZone,1,{"scaleY":0});
				TweenMax.to(enemyZone,1,{"scaleX":_loc2_});
				TweenMax.to(enemyZone,1,{"scaleY":_loc2_});
			}
			else
			{
				TweenMax.to(enemyZone,1,{"scaleX":0});
				TweenMax.to(enemyZone,1,{"scaleY":0});
				TweenMax.to(friendlyZone,1,{"scaleX":0});
				TweenMax.to(friendlyZone,1,{"scaleY":0});
			}
			if(_loc1_ == 0)
			{
				if(oldCapCounter == -10 && capCounter == -9)
				{
					g.textManager.createPvpText("The enemy team is assaulting " + name + "!",0,40,0xff5555);
					status = 2;
				}
				if(oldCapCounter == 10 && capCounter == 9)
				{
					g.textManager.createPvpText("Your team is assulting " + name + "!",0,40,0x5555ff);
					status = 1;
				}
				if(oldCapCounter == 9 && capCounter == 10)
				{
					g.textManager.createPvpText("The enemy team have captured " + name + "!",0,40,0xff5555);
					status = 0;
				}
				if(oldCapCounter == -9 && capCounter == -10)
				{
					g.textManager.createPvpText("Your team have captured " + name + "!",0,40,0x5555ff);
					status = 0;
				}
			}
			if(_loc1_ == 1)
			{
				if(oldCapCounter == -10 && capCounter == -9)
				{
					g.textManager.createPvpText("Your team is assaulting " + name + "!",0,40,0x5555ff);
					status = 1;
				}
				if(oldCapCounter == 10 && capCounter == 9)
				{
					g.textManager.createPvpText("The enemy team is assaulting " + name + "!",0,40,0xff5555);
					status = 2;
				}
				if(oldCapCounter == -9 && capCounter == -10)
				{
					g.textManager.createPvpText("The enemy team have captured " + name + "!",0,40,0xff5555);
					status = 0;
				}
				if(oldCapCounter == 9 && capCounter == 10)
				{
					g.textManager.createPvpText("Your team have captured " + name + "!",0,40,0x5555ff);
					status = 0;
				}
			}
			oldCapCounter = capCounter;
		}
		
		public function getMiniZone() : Image
		{
			var _loc4_:Image = null;
			var _loc2_:* = 0;
			_loc2_ = 0xffffff;
			var _loc3_:Sprite = new Sprite();
			_loc3_.graphics.lineStyle(1,_loc2_,0.2);
			var _loc5_:String = "radial";
			var _loc8_:Array = [0,_loc2_];
			var _loc6_:Array = [0,0.6];
			var _loc7_:Array = [0,255];
			var _loc1_:Matrix = new Matrix();
			_loc1_.createGradientBox(40,40,0,-20,-20);
			_loc3_.graphics.beginGradientFill(_loc5_,_loc8_,_loc6_,_loc7_,_loc1_);
			_loc3_.graphics.drawCircle(0,0,20);
			_loc3_.graphics.endFill();
			_loc4_ = TextureManager.imageFromSprite(_loc3_,name);
			_loc4_.x = x;
			_loc4_.y = y;
			_loc4_.pivotX = _loc4_.width / 2;
			_loc4_.pivotY = _loc4_.height / 2;
			_loc4_.scaleX = 1;
			_loc4_.scaleY = 1;
			_loc4_.alpha = 1;
			_loc4_.blendMode = "add";
			return _loc4_;
		}
		
		private function createZoneImg(obj:Object, colour:uint, name:String) : Image
		{
			var _loc6_:Image = null;
			var _loc5_:Sprite = new Sprite();
			_loc5_.graphics.lineStyle(1,colour,0.2);
			var _loc7_:String = "radial";
			var _loc10_:Array = [0,colour];
			var _loc8_:Array = [0,0.6];
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

