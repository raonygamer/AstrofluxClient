package core.hud.components.pvp {
	import com.greensock.TweenMax;
	import core.scene.Game;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import starling.display.Image;
	import textures.ITextureManager;
	import textures.TextureLocator;
	import textures.TextureManager;
	
	public class DominationZone {
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
		
		public function DominationZone(g:Game, obj:Object, id:int) {
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
			if(id == 3) {
				name = "Alpha Station";
			} else if(id == 1) {
				name = "Beta Station";
			} else if(id == 2) {
				name = "Gamma Station";
			} else if(id == 3) {
				name = "Delta Station";
			} else {
				name = "Epsilon Station";
			}
		}
		
		public function updateZone() : void {
			if(g.me == null) {
				return;
			}
			var _local2:int = g.me.team;
			var _local1:Number = Math.abs(capCounter / 10);
			if(_local2 == 0 && capCounter < 0 || _local2 == 1 && capCounter > 0) {
				TweenMax.to(enemyZone,1,{"scaleX":0});
				TweenMax.to(enemyZone,1,{"scaleY":0});
				TweenMax.to(friendlyZone,1,{"scaleX":_local1});
				TweenMax.to(friendlyZone,1,{"scaleY":_local1});
			} else if(_local2 == 0 && capCounter > 0 || _local2 == 1 && capCounter < 0) {
				TweenMax.to(friendlyZone,1,{"scaleX":0});
				TweenMax.to(friendlyZone,1,{"scaleY":0});
				TweenMax.to(enemyZone,1,{"scaleX":_local1});
				TweenMax.to(enemyZone,1,{"scaleY":_local1});
			} else {
				TweenMax.to(enemyZone,1,{"scaleX":0});
				TweenMax.to(enemyZone,1,{"scaleY":0});
				TweenMax.to(friendlyZone,1,{"scaleX":0});
				TweenMax.to(friendlyZone,1,{"scaleY":0});
			}
			if(_local2 == 0) {
				if(oldCapCounter == -10 && capCounter == -9) {
					g.textManager.createPvpText("The enemy team is assaulting " + name + "!",0,40,0xff5555);
					status = 2;
				}
				if(oldCapCounter == 10 && capCounter == 9) {
					g.textManager.createPvpText("Your team is assulting " + name + "!",0,40,0x5555ff);
					status = 1;
				}
				if(oldCapCounter == 9 && capCounter == 10) {
					g.textManager.createPvpText("The enemy team have captured " + name + "!",0,40,0xff5555);
					status = 0;
				}
				if(oldCapCounter == -9 && capCounter == -10) {
					g.textManager.createPvpText("Your team have captured " + name + "!",0,40,0x5555ff);
					status = 0;
				}
			}
			if(_local2 == 1) {
				if(oldCapCounter == -10 && capCounter == -9) {
					g.textManager.createPvpText("Your team is assaulting " + name + "!",0,40,0x5555ff);
					status = 1;
				}
				if(oldCapCounter == 10 && capCounter == 9) {
					g.textManager.createPvpText("The enemy team is assaulting " + name + "!",0,40,0xff5555);
					status = 2;
				}
				if(oldCapCounter == -9 && capCounter == -10) {
					g.textManager.createPvpText("The enemy team have captured " + name + "!",0,40,0xff5555);
					status = 0;
				}
				if(oldCapCounter == 9 && capCounter == 10) {
					g.textManager.createPvpText("Your team have captured " + name + "!",0,40,0x5555ff);
					status = 0;
				}
			}
			oldCapCounter = capCounter;
		}
		
		public function getMiniZone() : Image {
			var _local8:Image = null;
			var _local1:* = 0;
			_local1 = 0xffffff;
			var _local5:Sprite = new Sprite();
			_local5.graphics.lineStyle(1,_local1,0.2);
			var _local7:String = "radial";
			var _local3:Array = [0,_local1];
			var _local4:Array = [0,0.6];
			var _local6:Array = [0,255];
			var _local2:Matrix = new Matrix();
			_local2.createGradientBox(40,40,0,-20,-20);
			_local5.graphics.beginGradientFill(_local7,_local3,_local4,_local6,_local2);
			_local5.graphics.drawCircle(0,0,20);
			_local5.graphics.endFill();
			_local8 = TextureManager.imageFromSprite(_local5,name);
			_local8.x = x;
			_local8.y = y;
			_local8.pivotX = _local8.width / 2;
			_local8.pivotY = _local8.height / 2;
			_local8.scaleX = 1;
			_local8.scaleY = 1;
			_local8.alpha = 1;
			_local8.blendMode = "add";
			return _local8;
		}
		
		private function createZoneImg(obj:Object, colour:uint, name:String) : Image {
			var _local10:Image = null;
			var _local7:Sprite = new Sprite();
			_local7.graphics.lineStyle(1,colour,0.2);
			var _local9:String = "radial";
			var _local5:Array = [0,colour];
			var _local6:Array = [0,0.6];
			var _local8:Array = [0,255];
			var _local4:Matrix = new Matrix();
			_local4.createGradientBox(2 * zoneRadius,2 * zoneRadius,0,-zoneRadius,-zoneRadius);
			_local7.graphics.beginGradientFill(_local9,_local5,_local6,_local8,_local4);
			_local7.graphics.drawCircle(0,0,zoneRadius);
			_local7.graphics.endFill();
			_local10 = TextureManager.imageFromSprite(_local7,name);
			_local10.x = x;
			_local10.y = y;
			_local10.pivotX = _local10.width / 2;
			_local10.pivotY = _local10.height / 2;
			_local10.scaleX = 1;
			_local10.scaleY = 1;
			_local10.alpha = 0.25;
			_local10.blendMode = "add";
			return _local10;
		}
	}
}

